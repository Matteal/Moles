extends Node
var game_world : Node2D

func _on_Game_starting(game_scene : PackedScene):
	
	game_world = game_scene.instance()
	add_child(game_world)
	
