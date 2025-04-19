extends CharacterBody3D

enum { ROAMING, CHASING }

@onready var navAgent = $NavigationAgent3D
@onready var animation = $AnimationPlayer
@onready var damageNumbersOrigin = $"DamageNumbers origin"

@export var changeDirectionInterval : float = 2.0

var SPEED = 3.0
var damage = 10
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var enemyHealth = 100
var timer : float = 0.0
var direction : Vector3 = Vector3.ZERO
var state = ROAMING

func _ready():
	velocity.y = 0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  

	match state:
		ROAMING:
			timer += delta
			if timer >= changeDirectionInterval:
				change_direction()  
				timer = 0.0
			velocity.x = direction.x * SPEED  
			velocity.z = direction.z * SPEED  
			

		CHASING:
			var currentLocation = global_transform.origin
			var nextLocation = navAgent.get_next_path_position()
			var newVelocity = (nextLocation - currentLocation).normalized() * SPEED
			velocity.x = newVelocity.x  
			velocity.z = newVelocity.z  
			

	move_and_slide()  

func updateTargetLocation(target_location):
	navAgent.set_target_position(target_location)

func change_direction():
	direction = Vector3(
		randf_range(-1.0, 1.0),  
		0,                       
		randf_range(-1.0, 1.0)  
	).normalized()

###### RECEIVE DAMAGE ########
func hurt(hitPoints):
	if hitPoints < enemyHealth:
		enemyHealth -= hitPoints
		DamageNumbers.display_number(hitPoints, damageNumbersOrigin.global_position)
	else:
		enemyHealth = 0

	if enemyHealth == 0:
		queue_free()  

####### DEAL DAMAGE #######
func _on_enemy_hit_area_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "hurt", damage)

func _on_enemy_detection_body_entered(body):
	if body.is_in_group("Player"):
		state = CHASING  

func _on_enemy_detection_body_exited(body):
	if body.is_in_group("Player"):
		state = ROAMING  
