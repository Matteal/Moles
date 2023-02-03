extends Node2D

var height_detection = 50

onready var collision_detection = get_node("NextLevel").get_child(0)
onready var ground = get_node("ground2").get_child(0)
onready var next_level_step = get_node("NextLevel").get_child(0).get_shape().get_extents().y


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	collision_detection.get_parent().collision_mask = 0
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time singet_tree().paused = falsee the previous frame.
#func _process(delta):
#	pass

func clear_level():
	collision_detection.get_parent().collision_mask = 1
	print(next_level_step)
	ground.set_position(ground.get_position() - Vector2(0, next_level_step))
	print(ground.get_position())
	collision_detection.set_position(collision_detection.get_position() - Vector2(0, next_level_step))
	unpause(2)

func _on_NextLevel_body_entered(body):
	if(body.get_parent() == get_node("../obstacles")):
		body.get_parent().remove_child(body)
		
	collision_detection.get_parent().set_deferred("collision_mask", 0) #delete collision detection after all resolutions
	get_tree().paused = true
	pass # Replace with function body.

func unpause(sleep):
	yield(get_tree().create_timer(sleep), "timeout")
	print(get_node("NextLevel").get_child(0).get_position())
	print(get_node("NextLevel").get_child(0).get_shape().get_extents())
	
	print(get_node("ground2").get_child(0).get_position())
	print(get_node("ground2").get_child(0).get_shape().get_extents())
	get_tree().paused = false
