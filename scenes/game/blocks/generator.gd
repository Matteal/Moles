extends Node2D

var Square = load("res://scenes/game/blocks/square.tscn")
var Rectangle = load("res://scenes/game/blocks/rectangle.tscn")
var Slope = load("res://scenes/game/blocks/slope.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("generate"):
		var crate
		match randi()%3:
			0:
				crate = Square.instance()
			1:
				crate = Rectangle.instance()
			2:
				crate = Slope.instance()
		get_node("../obstacles").add_child(crate)
		crate.global_transform.origin = self.global_transform.origin
