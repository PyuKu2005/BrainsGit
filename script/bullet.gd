extends Node3D

@export var speed = 10

@onready var area = $enemyHitArea
@onready var mesh = $MeshInstance3D

var damage = 15

func _ready():
	pass

func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	
	
func _on_enemy_hit_area_body_entered(body):
	if body.is_in_group("Player"):
		print("Toucé!")
		body.hurt(damage)
		queue_free()
