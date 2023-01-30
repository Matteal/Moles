extends RigidBody2D

#var player = load("res://scenes/game/characters/player.tscn").instance()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var p : Node2D

var held = false
var thread := Thread.new()

var initial_throw_velocity = Vector2.ZERO

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

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	if initial_throw_velocity:
		var opposing_force = initial_throw_velocity.linear_interpolate(Vector2.ZERO, interpolation) * step * 15
#		opposing_force.y *= 2
		if opposing_force.x * lv.x < 0: # prevent the object to be pushed back
			opposing_force.x = 0
		if opposing_force.y * lv.y < 0: # prevent the object to be pushed back
			opposing_force.y = 0
		apply_central_impulse(-opposing_force)
		if interpolation < 1:
			interpolation += step * 3
			print(interpolation)
		else:
			interpolation = 1
			initial_throw_velocity = Vector2.ZERO
		

func unfreeze():
	for body in get_colliding_bodies():
		if get_parent() == body.get_parent(): #! only work for objects on obstacle's node
			body.set_sleeping(false)
	
func grabbed(player):
	get_parent().remove_child(self)
	player.add_child(self)
	set_mode(RigidBody2D.MODE_KINEMATIC)
	print(self.get_parent().name)
	
	p = player

#func _physics_process(delta):
#	if !held: # basic behaviour
#		return



func is_massive(second):
	
	yield(get_tree().create_timer(second), "timeout")
	print("return 0")
	

func throw():
	connect("body_entered", self, "_on_rectangle_body_entered")
	initial_throw_velocity = get_linear_velocity()
	interpolation = 0
	
	set_deferred("set_mass", 20.0)
	set_deferred("set_linear_damp", 0)

func _on_rectangle_body_entered(body):
	disconnect("body_entered", self, "_on_rectangle_body_entered")
	initial_throw_velocity = Vector2.ZERO
	
	set_deferred("set_mass", 4.6)
	set_deferred("set_linear_damp", 0.1)
