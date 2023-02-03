extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var collision_detection = $NextLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_detection.collision_mask = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func clear_level():
	collision_detection.collision_mask = 1

func _on_NextLevel_body_entered(body):
	if(body.get_parent() == get_node("../obstacles")):
		body.get_parent().remove_child(body)
		
	collision_detection.set_deferred("collision_mask", 0) #delete collision detection after all resolutions
	pass # Replace with function body.
