extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite

const WALK_FORCE = 600
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 400

export (int, 0, 200) var inertia = 50

#default settings for default gravity
#const WALK_FORCE = 600
#const WALK_MAX_SPEED = 200
#const STOP_FORCE = 1300
#const JUMP_SPEED = 200

var velocity = Vector2()

#onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = 500

func _physics_process(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
	#velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP, false, 4, PI/4, false)
	#4th parameter usefull to stand still on slopes
	#velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = -JUMP_SPEED

	# Interact with rigidBodies
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		print(collision.collider.get_class())
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)
			
	set_sprite()
	
func set_sprite():
	if(velocity.x == 0):
		_animated_sprite.play("idle")
	if(Input.get_action_strength("move_right")):
		_animated_sprite.play("run_right")
	if(Input.get_action_strength("move_left")):
		_animated_sprite.play("run_left")
