extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite

var speed : int = 200
var jump_speed : int = 500
var gravity : int = 20
var velocity = Vector2()

export (int, 0, 200) var inertia = 5

var push_factor : float = 1


func get_input(delta):
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	if Input.is_action_pressed("jump"):
		if(is_on_floor()):		
			velocity.y -= jump_speed
	
	#gravity
	velocity.y += gravity
	velocity = move_and_slide_with_snap(velocity, Vector2(0, -10), Vector2.UP, true, 4, PI/4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)
			velocity += (collision.normal * inertia *4)
			
			
	
	pass

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
