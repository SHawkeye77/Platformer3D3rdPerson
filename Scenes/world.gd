extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	# Resetting persistant variables
	Global.wonGame = false
	# Capturing the mouse in the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_death_plane_body_entered(body):
	if body.is_in_group("player"):
		player.death() 
