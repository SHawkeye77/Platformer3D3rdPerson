extends Node2D

@onready var endStatusLabel = get_node("%EndStatusLabel")
const startScreen = "res://Scenes/start_screen.tscn"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Setting up the end screen text based on win or lose
	if Global.wonGame:
		endStatusLabel.text = "You won! Thanks for playing!"
	else:
		endStatusLabel.text = "You Died. Try again loser!"

func _on_main_menu_button_pressed():
	var _level = get_tree().change_scene_to_file(startScreen)
