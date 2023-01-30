extends RigidBody2D

#var player = load("res://scenes/game/characters/player.tscn").instance()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var p : Node2D

var held = false
var thread := Thread.new()

var initial_throw_velocity = Vector2.ZERO
var is_grabbed = false

var slow_interpolation_time = 0.5
var slow_force_multiplier = 15

# Called when the node enters the scene tree for the first time.
func _ready():
#	if node.get_class() == "Node":
	var type = self.filename.get_slice('/', 5).get_slice('.', 0)
	match type:
		"square":	
			$Sprite.set_frame(randi() % 9)
		"rectangle":
			$Sprite.set_frame(randi() % 3)
		"slope":
			$Sprite.set_frame(randi() % 3)
		
var interpolation : float
var slow_down = false
var counter = 0
func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	
	
	if slow_down:
		var opposing_force = initial_throw_velocity.linear_interpolate(Vector2.ZERO, interpolation) * step * slow_force_multiplier
#		opposing_force.y *= 4
		if opposing_force.x * lv.x < 0: # prevent the object to be pushed back
			opposing_force.x = 0
		if opposing_force.y * lv.y < 0: # prevent the object to be pushed back
			opposing_force.y = 0
		apply_central_impulse(-opposing_force)
		print(opposing_force)
		if interpolation < 1:
			interpolation += step / slow_interpolation_time
			print(interpolation)
			counter += 1 + step
		else:
			slow_down = false


func unfreeze():
	for body in get_colliding_bodies():
		if get_parent() == body.get_parent(): #! only work for objects on obstacle's node
			body.set_sleeping(false)
	
	
func grabbed(action):
	is_grabbed = action

#func _physics_process(delta):
#	if !held: # basic behaviour
#		return

var timer_before_slow_down = 0.2

func unset_massive(second):
	yield(get_tree().create_timer(second), "timeout")
	print("return 0")
	
	slow_down = false
	set_deferred("set_mass", 4.6)
	set_deferred("set_linear_damp", 0.1)
	
func prepare_slow_down():
	slow_down = false
	yield(get_tree().create_timer(timer_before_slow_down), "timeout")
	slow_down = true
	

var throwing_player

func throw(player):
	connect("body_entered", self, "_on_rectangle_body_entered")
	throwing_player = player
	initial_throw_velocity = get_linear_velocity()
#	initial_throw_velocity.y *= 2
	interpolation = 0
	prepare_slow_down()
	print(get_linear_velocity())
	set_deferred("set_mass", 20.0)
	set_deferred("set_linear_damp", 50)

func _on_rectangle_body_entered(body):
	if throwing_player != body:
		disconnect("body_entered", self, "_on_rectangle_body_entered")
		initial_throw_velocity = Vector2.ZERO
		slow_down = false
		
		unset_massive(0)

