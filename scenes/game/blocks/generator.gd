extends Node2D

var Crate = load("res://scenes/game/blocks/crate.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("generate"):
#		var crate = Crate.new()
		var crate = preload("res://scenes/game/blocks/crate.tscn").instance()
		get_node("../obstacles").add_child(crate)
		crate.global_transform.origin = self.global_transform.origin
