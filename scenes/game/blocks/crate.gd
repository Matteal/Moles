extends RigidBody2D

var held = false
var interpolation : float
var slow_down = false
var is_grabbed = false
var throwing_player

#time in seconds
const SLOW_INTERPOLATION_TIME = 0.4
const SLOW_FORCE_MULTIPLIER = 25
const TIMER_START_SLOW_DOWN = 0.2

const INITIAL_MASS = 4.6
const UPGRADED_MASS = 30.0

const UNSET_MASSIVE_COLLISION = 0.2
const UNSET_MASSIVE_DECELERATE = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	#attribute a random sprite
	var type = self.filename.get_slice('/', 5).get_slice('.', 0)
	match type:
		"square":	
			$Sprite.set_frame(randi() % 9)
		"rectangle":
			$Sprite.set_frame(randi() % 3)
		"slope":
			$Sprite.set_frame(randi() % 3)
		


func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	if slow_down:
		var opposing_force = lv.linear_interpolate(Vector2.ZERO, interpolation) * step * SLOW_FORCE_MULTIPLIER
		apply_central_impulse(-opposing_force)
		
		#for log only
		if interpolation == 0:
			print("start interpolation")
			
		if interpolation < 1:
			interpolation += step / SLOW_INTERPOLATION_TIME
		else:
			print("stop interpolation")
			slow_down = false
			unset_massive(UNSET_MASSIVE_DECELERATE)


func unfreeze():
	for body in get_colliding_bodies():
		if get_parent() == body.get_parent(): #! only work for objects on obstacle's node
			body.set_sleeping(false)
	
	
func grabbed(action):
	is_grabbed = action


func unset_massive(second):
	yield(get_tree().create_timer(second), "timeout")
	print("unset massive")
	
	slow_down = false
	set_deferred("set_mass", INITIAL_MASS)
	
func prepare_slow_down():
	slow_down = false
	interpolation = 0
	yield(get_tree().create_timer(TIMER_START_SLOW_DOWN), "timeout")
	slow_down = true


func throw(player):
	connect("body_entered", self, "_on_rectangle_body_entered")
	
	throwing_player = player
	prepare_slow_down()
	set_deferred("set_mass", UPGRADED_MASS)

func _on_rectangle_body_entered(body):
	if throwing_player != body: #is not the lauching player
		disconnect("body_entered", self, "_on_rectangle_body_entered")
		
		slow_down = false
		unset_massive(UNSET_MASSIVE_COLLISION)

