extends CharacterBody3D

enum {
	IDLE,
	ALERT,
}

@onready var raycasts = [
	$MeshInstance3D2/RayCast3D,
	$MeshInstance3D2/RayCast3D2,
	$MeshInstance3D2/RayCast3D3
]

var state = IDLE
var target
var bullet = preload("res://bullet.tscn") 
var instance
@export var turnSpeed = 2.0 

@onready var eyes = $Eyes
@onready var shootTimer = $ShootTimer


func _ready():
	pass

func _process(delta):
	match state:
		IDLE:
			print("Quoicoubeh")
		ALERT:
			print("Apagnan")
			if target:
				var target_position = target.global_transform.origin
				var current_position = global_transform.origin
				var direction = (target_position - current_position).normalized()
				var target_rotation = -atan2(direction.x, direction.z)
				rotation.y = lerp_angle(rotation.y, target_rotation, turnSpeed * delta)
				eyes.look_at(target_position, Vector3.UP)

func _on_sight_range_body_entered(body):
	if body.is_in_group("Player"):
		state = ALERT
		target = body
		shootTimer.start()

func _on_sight_range_body_exited(body):
	if body == target:
		state = IDLE
		target = body
		shootTimer.stop()

func _on_shoot_timer_timeout():
	for raycast in raycasts:
		if raycast.is_colliding():
			var hit = raycast.get_collider()
			if hit.is_in_group("Player"):
				# Properly instantiate the bullet
				instance = bullet.instantiate()
				instance.global_position = $MeshInstance3D2.global_position
				instance.transform.basis = $MeshInstance3D2.global_transform.basis
				get_parent().add_child(instance)
				print("Gotcha !!")
				break  
