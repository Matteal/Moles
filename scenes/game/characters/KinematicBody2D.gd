extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite
#onready var _ray = $RayCast2D
#onready var _hold_position = $HoldPosition

var speed : int = 200
var jump_speed : int = 500
var gravity : int = 20
var velocity = Vector2()

var held_object : Node2D
var pos : Vector2

export (int, 0, 200) var inertia = 5

var push_factor : float = 1


func get_input(delta):
	velocity.x = 0
	$RayCast2D.set_cast_to(Vector2.ZERO)
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
		$RayCast2D.set_cast_to(Vector2(35, 0))
		pos = Vector2(abs(pos.x), pos.y)
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
		$RayCast2D.set_cast_to(Vector2(-35, 0))
		pos = Vector2(-abs(pos.x), pos.y)
	if Input.is_action_pressed("jump"):
		if(is_on_floor()):		
			velocity.y -= jump_speed
			
	if Input.is_action_just_pressed("grab"):
		if held_object != null:
			throw_object()
		elif $RayCast2D.get_collider():
			grab($RayCast2D.get_collider())
#		for object in $Hitbox.get_overlapping_bodies():
#			if object.get_parent().name == "obstacles":
#				grab(object)
				
	if held_object:
#		held_object.global_transform.origin = $HoldPosition.global_transform.origin
		held_object.global_transform.origin = self.global_transform.origin + pos 
	
	#gravity
	velocity.y += gravity
	velocity = move_and_slide_with_snap(velocity, Vector2(0, -10), Vector2.UP, true, 4, PI/4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)
			velocity += (collision.normal * inertia *4)
			
	pass

func grab (object):
	if held_object != null:
		return
		
	print(object.name)
	held_object = object
	pos = object.global_transform.origin - self.global_transform.origin
	held_object.get_parent().remove_child(held_object)
	add_child(held_object)
	held_object.mode = RigidBody2D.MODE_STATIC
	held_object.collision_mask = 0
	held_object.collision_layer = 0
	
func throw_object():
	print("throw")
	remove_child(held_object)
	get_node("../obstacles").add_child(held_object)
	held_object.global_transform.origin = self.global_transform.origin + pos
	held_object.mode = RigidBody2D.MODE_RIGID
	held_object.collision_mask = 1
	held_object.collision_layer = 1
	
	if(velocity.x == 0):
		pass
		
	held_object.set_linear_velocity(Vector2(velocity.x *2, -100))
	held_object = null


func set_sprite():
	if(velocity.x == 0):
		_animated_sprite.play("idle")
	if(Input.get_action_strength("move_right")):
		_animated_sprite.play("run_right")
	if(Input.get_action_strength("move_left")):
		_animated_sprite.play("run_left")

func _physics_process(delta):
	get_input(delta)
	set_sprite()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
