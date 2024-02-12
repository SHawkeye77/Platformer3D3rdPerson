extends Node2D

const playgroundScene = "res://Scenes/playground.tscn"
const worldScene = "res://Scenes/world.tscn"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_sample_level_button_pressed():
	var _level = get_tree().change_scene_to_file(worldScene)

func _on_playground_button_pressed():
	var _level = get_tree().change_scene_to_file(playgroundScene)
