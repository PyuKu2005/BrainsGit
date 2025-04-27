extends CharacterBody3D

enum {
	CHASING,
	SHOOTING
}

@onready var raycasts = [
	$MeshInstance3D2/RayCast3D,
	$MeshInstance3D2/RayCast3D2,
	$MeshInstance3D2/RayCast3D3
]
@onready var navAgent = $NavigationAgent3D
@onready var animation = $AnimationPlayer
@onready var eyes = $Eyes
@onready var shootTimer = $ShootTimer
@onready var damageNumbersOrigin = $Node3D

@export var changeDirectionInterval : float = 2.0
@export var turnSpeed = 2.0 

var SPEED = 3.0
var damage = 10
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var enemyHealth = 100
var timer : float = 0.0
var direction : Vector3 = Vector3.ZERO
var state = CHASING
var target
var bullet = preload("res://bullet.tscn") 
var instance


func _ready():
	pass

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  
	match state:
		CHASING:
			var currentLocation = global_transform.origin
			var nextLocation = navAgent.get_next_path_position()
			var newVelocity = (nextLocation - currentLocation).normalized() * SPEED
			velocity.x = newVelocity.x  
			velocity.z = newVelocity.z  
			
 
		SHOOTING:
			velocity = Vector3.ZERO
				
	move_and_slide() 
	
func _on_sight_range_body_entered(body):
	if body.is_in_group("Player"):
		state = SHOOTING
		target = body
		shootTimer.start()

func _on_sight_range_body_exited(body):
	if body == target:
		state = CHASING
		target = body
		shootTimer.stop()

func _on_shoot_timer_timeout():
	for raycast in raycasts:
		if raycast.is_colliding():
			var hit = raycast.get_collider()
			if hit.is_in_group("Player"):
				instance = bullet.instantiate()
				instance.global_position = $MeshInstance3D2.global_position
				instance.transform.basis = $MeshInstance3D2.global_transform.basis
				get_tree().current_scene.add_child(instance)
				print("Gotcha !!")
				break  
				

func _on_enemy_hit_area_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "hurt", damage)

func hurt(hitPoints):
	if hitPoints < enemyHealth:
		enemyHealth -= hitPoints
		DamageNumbers.display_number(hitPoints, damageNumbersOrigin.global_position)
	else:
		enemyHealth = 0

	if enemyHealth == 0:
		queue_free()  
