extends RigidBody2D

#var player = load("res://scenes/game/characters/player.tscn").instance()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var p : Node2D

var held = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#create a crate with a random texture here
	# with $Sprite.<...>
	pass # Replace with function body.

func grabbed(player):
	get_parent().remove_child(self)
	player.add_child(self)
	set_mode(RigidBody2D.MODE_KINEMATIC)
	print(self.get_parent().name)
	
	p = player

func _physics_process(delta):
	if !held: # basic behaviour
		return
	
	set_global_position(Vector2(500, 300))
