extends RigidBody2D

#var player = load("res://scenes/game/characters/player.tscn").instance()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var p : Node2D

var held = false

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
		
	pass # Replace with function body.

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

var thread := Thread.new()

func is_massive(second):
	
	yield(get_tree().create_timer(second), "timeout")
	print("return 0")
	

func throw():
	connect("body_entered", self, "_on_rectangle_body_entered")
	
	set_deferred("set_mass", 20.0)
	set_deferred("set_linear_damp", 0)

func _on_rectangle_body_entered(body):
	disconnect("body_entered", self, "_on_rectangle_body_entered")
	
	set_deferred("set_mass", 4.6)
	set_deferred("set_linear_damp", 0.1)
