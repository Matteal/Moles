extends Node2D

var height_detection = 50

onready var collision_detection = get_node("NextLevel").get_child(0)
onready var ground = get_node("ground2").get_child(0)
onready var next_level_step = get_node("NextLevel").get_child(0).get_shape().get_extents().y

var camera_initial_position = Vector2.ZERO
var camera_next_position : Vector2
var interpolation : float

const PAUSE_TIME = 2.0
# Declare member variables here. Examples:
# var b = "text"
# var a = 2



# Called when the node enters the scene tree for the first time.
func _ready():
	collision_detection.get_parent().collision_mask = 0
	
	pass # Replace with function body.


func _process(delta):
	if get_tree().paused == true:
		$Camera.set_position(camera_initial_position.linear_interpolate(camera_next_position, interpolation))
		interpolation += delta
		if(interpolation > 1.0):
			interpolation = 1.0
			camera_initial_position = camera_next_position
	pass

func clear_level():
	collision_detection.get_parent().collision_mask = 1
	camera_next_position = camera_initial_position - Vector2(0, next_level_step)
	interpolation = 0.0
	unpause(PAUSE_TIME)

func _on_NextLevel_body_entered(body):
	if(body.get_parent() == get_node("../obstacles")):
		body.get_parent().remove_child(body)
		
	collision_detection.get_parent().set_deferred("collision_mask", 0) #delete collision detection after all resolutions
	get_tree().paused = true
	pass # Replace with function body.

func unpause(sleep):
	yield(get_tree().create_timer(sleep), "timeout")
	
	# setting up the ground / Camera position
	ground.set_position(ground.get_position() - Vector2(0, next_level_step))
	collision_detection.set_position(collision_detection.get_position() - Vector2(0, next_level_step))
	
	get_tree().paused = false
