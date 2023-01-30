class_name Player2
extends RigidBody2D

# Class written by Mattéo DERANSART
# Using Character Demo, written by Juan Linietsky.

const WALK_ACCEL = 1300.0
const WALK_DEACCEL = 1300.0
const WALK_MAX_VELOCITY = 200.0
const AIR_ACCEL = 300.0
const AIR_DEACCEL = 300.0
const JUMP_VELOCITY = 450
const STOP_JUMP_FORCE = 80
const MAX_SHOOT_POSE_TIME = 0.3
const MAX_FLOOR_AIRBORNE_TIME = 0.15

const LAUNCH_FORCE = 800
const PARABOLA_FORCE = 200

var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false
var shooting = false
var held_object : Node2D

var floor_h_velocity = 0.0
var airborne_time = 1e20
var shoot_time = 1e20

var cumul : float = 0.0

#controller
export var player_index = 0;

var move_left_action = ["move_left", "move_left2"]
var move_right_action = ["move_right", "move_right2"]
var jump_action = ["jump", "jump2"]
var down_action = ["down", "down2"]
var grab_action = ["grab", "grab2"]

func _ready():
#	print($AnimatedSprite.get_texture())
	pass

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()

	var new_anim = anim
	var new_siding_left = siding_left

	# Get player input.
	var move_left = Input.is_action_pressed(move_left_action[player_index])
	var move_right = Input.is_action_pressed(move_right_action[player_index])
	var jump = Input.is_action_pressed(jump_action[player_index])
	var down = Input.is_action_pressed(down_action[player_index])
	var grab = Input.is_action_just_pressed(grab_action[player_index])
	

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
		$AnimatedSprite.play(anim)

	# grab interractions
	var dir_ray = int(move_left) * Vector2.LEFT + int(move_right) * Vector2.RIGHT \
				+ int(jump) * Vector2.UP + int(down) * Vector2.DOWN
	$RayCast2D.set_cast_to(dir_ray.normalized() * 35)
	if grab:
		grab_detection(lv)
	if held_object:
		held_object.global_transform.origin = self.global_transform.origin + dir_ray.normalized() * 35

	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = s.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity

	# Finally, apply gravity and set back the linear velocity.
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)

func grab_detection(lv):
	if held_object != null:
		throw_object(lv)
	elif $RayCast2D.get_collider():
		if $RayCast2D.get_collider().get_parent().name == "obstacles":
			grab($RayCast2D.get_collider())

		
func grab (object):
	if held_object != null:
		return
		
	held_object = object
	held_object.unfreeze()
	
	held_object.get_parent().set_deferred("remove_child", held_object)
	set_deferred("add_child", held_object)
	held_object.set_deferred("mode", RigidBody2D.MODE_STATIC)
	held_object.collision_mask = 0
	held_object.collision_layer = 0
	
	
	
func throw_object(lv):	
	set_deferred("remove_child", held_object)
	get_node("../obstacles").set_deferred("add_child", held_object)
	held_object.global_transform.origin = self.global_transform.origin + $RayCast2D.get_cast_to()
	held_object.set_deferred("mode", RigidBody2D.MODE_RIGID)
	held_object.collision_mask = 1
	held_object.collision_layer = 1
	
	var throw_impulse = $RayCast2D.get_cast_to().normalized() * LAUNCH_FORCE + lv * 0.5
	if $RayCast2D.get_cast_to().y == 0 and $RayCast2D.get_cast_to().x != 0: # add a small parabolla
		throw_impulse.y += -PARABOLA_FORCE
	
	held_object.set_linear_velocity(throw_impulse)
	held_object.throw(self)
	
	held_object = null
