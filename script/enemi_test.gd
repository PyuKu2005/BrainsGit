extends CharacterBody3D

@onready var navAgent = $NavigationAgent3D


var SPEED = 3.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var enemyHealth = 100

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var currentLocation = global_transform.origin
	var nextLocation = navAgent.get_next_path_position()
	var newVelocity = (nextLocation - currentLocation).normalized() * SPEED
	
	velocity = newVelocity
	move_and_slide()
	
func updateTargetLocation(target_location):
	navAgent.set_target_position(target_location)
	
######RECEIVE DAMAGE########
func hurt(hitPoints):
	if hitPoints < enemyHealth:
		enemyHealth -= hitPoints
	else:
		enemyHealth = 0
	$SubViewport/healthBar3d.value = enemyHealth
	if enemyHealth == 0:
		queue_free()
#######DEAL DAMAGE#######
func _on_enemy_hit_area_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "hurt", 10)
