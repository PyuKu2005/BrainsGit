extends Node3D

@export var speed = 40

@onready var area = $Area3D
@onready var mesh = $MeshInstance3D

func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
