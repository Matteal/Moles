extends Node

var game_scene = load("res://scenes/game/game_world.tscn")

func _ready():
	randomize()
	
	var game_world = game_scene.instance()
	add_child(game_world)
	
	Input.connect("joy_connection_changed",self,"joy_con_changed")
	print("t")


func joy_con_changed(deviceid,isConnected):

	if isConnected:
		print("Joystick " + str(deviceid) + " connected")

	if Input.is_joy_known(0):
		print("Recognized and compatible joystick")
		print(Input.get_joy_name(0) + " device connected")
	
	else:
		print("Joystick " + str(deviceid) + " disconnected")


# TODO get automatic joystick connection
# see https://github.com/sustainablelab/eat-and-poop/blob/master/scripts/World.gd
#func add_player(player_index: int):
#	pass #choose between controler and keyboard
#
#func set_player_to_keyboard(player_index: int):
#	pass
#
#func set_player_to_controller(player_index: int, device_id: int):
#	pass
