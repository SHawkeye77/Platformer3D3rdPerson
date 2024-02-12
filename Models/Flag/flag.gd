extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player.victory()
