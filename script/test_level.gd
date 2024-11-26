extends Node3D
#Fixed!
@onready var player = $Player

func _physics_process(delta):
	get_tree().call_group("Enemi", "updateTargetLocation", player.global_transform.origin )
