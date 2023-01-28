class_name Player2
extends RigidBody2D

# Character Demo, written by Juan Linietsky.
#
#  Implementation of a 2D Character controller.
#  This implementation uses the physics engine for
#  controlling a character, in a very similar way
#  than a 3D character controller would be implemented.
#
#  Using the physics engine for this has the main advantages:
#    - Easy to write.
#    - Interaction with other physics-based objects is free
#    - Only have to deal with the object linear velocity, not position
#    - All collision/area framework available
#
#  But also has the following disadvantages:
#    - Objects may bounce a little bit sometimes
#    - Going up ramps sends the chracter flying up, small hack is needed.
#    - A ray collider is needed to avoid sliding down on ramps and
#      undesiderd bumps, small steps and rare numerical precision errors.
#      (another alternative may be to turn on friction when the character is not moving).
#    - Friction cant be used, so floor velocity must be considered
#      for moving platforms.

const WALK_ACCEL = 1300.0
const WALK_DEACCEL = 1300.0
const WALK_MAX_VELOCITY = 200.0
const AIR_ACCEL = 300.0
const AIR_DEACCEL = 300.0
const JUMP_VELOCITY = 450
const STOP_JUMP_FORCE = 80
const MAX_SHOOT_POSE_TIME = 0.3
const MAX_FLOOR_AIRBORNE_TIME = 0.15

var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false
var shooting = false

var floor_h_velocity = 0.0

var airborne_time = 1e20
var shoot_time = 1e20

var held_object : Node2D

onready var _animated_sprite = $AnimatedSprite

var cumul : float = 0.0


func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()

	var new_anim = anim
	var new_siding_left = siding_left

	# Get player input.
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	

	# Deapply prev floor velocity.
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0

	# Find the floor (a contact with upwards facing collision normal).
	var found_floor = false
	var floor_index = -1

	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)

		if ci.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = x


	if found_floor:
		airborne_time = 0.0
		cumul = 0.0
	else:
		airborne_time += step # Time it spent in the air.
		cumul += step

	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump.
	if jumping:
		if lv.y > 0:
			# Set off the jumping flag if going down.
			jumping = false
		elif not jump:
			stopping_jump = true

		if stopping_jump:
			lv.y += STOP_JUMP_FORCE * cumul
			print(STOP_JUMP_FORCE * cumul)

	if on_floor:
		# Process logic when character is on floor.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

		# Check jump.
		if not jumping and jump:
			
			lv.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false

		# Check siding.
		if lv.x < 0 and move_left:
			new_siding_left = true
			new_anim = "run_left"
		elif lv.x > 0 and move_right:
			new_siding_left = false
			new_anim = "run_right"
		if abs(lv.x) < 0.1:
			new_anim = "idle"
	else:
		# Process logic when the character is in the air.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEACCEL * step

			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

		if lv.y < 0:
			new_anim = "jump"
		else:
			new_anim = "falling"

		siding_left = new_siding_left
	
	# Change animation.
	if new_anim != anim:
		anim = new_anim
		_animated_sprite.play(anim)

	# grab interractions
	grab_detection(lv)
	if held_object:
#		held_object.global_transform.origin = $HoldPosition.global_transform.origin
		held_object.global_transform.origin = self.global_transform.origin + Vector2(0, -45)

	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = s.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity

	# Finally, apply gravity and set back the linear velocity.
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)

func grab_detection(lv):
	if lv.x < 0:
		$RayCast2D.set_cast_to(Vector2(-35, 0))
	elif lv.x > 0:
		$RayCast2D.set_cast_to(Vector2(35, 0))
	if abs(lv.x) < 0.1:
		$RayCast2D.set_cast_to(Vector2.ZERO)
		
	if Input.is_action_just_pressed("grab"):
		if held_object != null:
			throw_object(lv)
		elif $RayCast2D.get_collider():
			if $RayCast2D.get_collider().get_parent().name == "obstacles":
				grab($RayCast2D.get_collider())
#		for object in $Hitbox.get_overlapping_bodies():
#			if object.get_parent().name == "obstacles":
#				grab(object)
				

		
func grab (object):
	if held_object != null:
		return
		
	print(object.name)
	held_object = object
	held_object.unfreeze()
	
	held_object.get_parent().remove_child(held_object)
	add_child(held_object)
	held_object.set_deferred("mode", RigidBody2D.MODE_STATIC)
	held_object.collision_mask = 0
	held_object.collision_layer = 0
	
	
	
func throw_object(lv):
	print("throw")
	remove_child(held_object)
	get_node("../obstacles").add_child(held_object)
	held_object.global_transform.origin = self.global_transform.origin + Vector2(0, -45)
	held_object.set_deferred("mode", RigidBody2D.MODE_RIGID)
	held_object.collision_mask = 1
	held_object.collision_layer = 1
	
		
	held_object.set_linear_velocity(Vector2(lv.x * 1.4, lv.y/2  - JUMP_VELOCITY/2))
	held_object = null
