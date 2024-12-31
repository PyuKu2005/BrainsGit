extends CharacterBody3D

@export var SPEED = 5.0
@export var sprintSpeed = 8.5
@export var dash_speed = 20.0  
@export var dash_duration = 0.2  

@onready var area3d = $Sprite3D/playerHitArea
@onready var animation = $AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var playerHealth = 100
var isAttacking = false
var last_facing_direction = 1
var isDashing = false  
var dashTimer = 0.0  
var attackSpeed = SPEED / 5.0  
var currentAttackAnimation = "Attack2"  
var attackComboTimer = 0.0  
var comboDelay = 0.5  


##### DÉBUT PROCESS DELTA #####
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var currentSpeed = SPEED

	# Handle dash input
	if Input.is_action_just_pressed("Dash") and not isDashing:
		isDashing = true
		dashTimer = dash_duration
		velocity.x = direction.x * dash_speed
		velocity.z = direction.z * dash_speed
		$Marker3D/Sprite3D/RunningParticles.visible = true
		animation.play("Dash")

	# Dash logic
	if isDashing:
		dashTimer -= delta
		if dashTimer <= 0:
			isDashing = false


	if not isDashing:
		if Input.is_action_pressed("Courir") and direction and not isAttacking:
			currentSpeed = sprintSpeed
		elif isAttacking:
			currentSpeed = attackSpeed

		if direction:
			velocity.x = direction.x * currentSpeed
			velocity.z = direction.z * currentSpeed
			$Marker3D/Sprite3D/WalkingDust.visible = true
			if not isAttacking:
				animation.play("BrainMoving", -1, 2.0 if currentSpeed == sprintSpeed else 1.0, true)
				$Marker3D/Sprite3D/RunningParticles.visible = false
				if currentSpeed == sprintSpeed:
					$Marker3D/Sprite3D/RunningParticles.visible = true
	if isAttacking:
	# Lock the marker's rotation based on the last facing direction
		if last_facing_direction < 0:
			$Marker3D.scale.x = -1
			$Marker3D/Sprite3D.flip_h = true
		elif last_facing_direction > 0:
			$Marker3D.scale.x = 1
			$Marker3D/Sprite3D.flip_h = false
	else:
		# Update facing direction based on horizontal input only
		if input_dir.x < 0:
			$Marker3D.scale.x = -1
			$Marker3D/Sprite3D.flip_h = true
			last_facing_direction = -1  # Update facing direction to left
		elif input_dir.x > 0:
			$Marker3D.scale.x = 1
			$Marker3D/Sprite3D.flip_h = false
			last_facing_direction = 1   # Update facing direction to right
		if direction:
			velocity.x = direction.x * currentSpeed
			velocity.z = direction.z * currentSpeed




		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			$Marker3D/Sprite3D/WalkingDust.visible = false
			$Marker3D/Sprite3D/RunningParticles.visible = false
			if not isAttacking:
				animation.play("BrainIdle", -1, 1.0, true)
	move_and_slide()


	if Input.is_action_pressed("playerAttack"):
		if not isAttacking:
			isAttacking = true
			animation.play(currentAttackAnimation, -1, 2.0, true)  
		else:
			if attackComboTimer <= 0:
				if currentAttackAnimation == "Attack2":
					currentAttackAnimation = "Attack"
				else:
					currentAttackAnimation = "Attack2"
				attackComboTimer = comboDelay  

			animation.play(currentAttackAnimation, -1, 2.0, true)
		attackComboTimer -= delta

	if not Input.is_action_pressed("playerAttack"):
		if isAttacking:
			isAttacking = false
			attackComboTimer = 0  
			currentAttackAnimation = "Attack2" 
		if direction.length() > 0:
			animation.play("BrainMoving", -1, 1.0, true)
		else:
			animation.play("BrainIdle", -1, 1.0, true)

	############# CAMERA ################
	var camera_position = $CameraControl.position
	camera_position.x = lerp(camera_position.x, position.x, 0.08)
	camera_position.z = lerp(camera_position.z, position.z, 0.08)
	camera_position.y = lerp(camera_position.y, position.y, 0.08)
	$CameraControl.position = camera_position
##### FIN PROCESS DELTA ##### 

################ RECEVOIR DAMAGE ################
func hurt(hitPoints):
	if hitPoints < playerHealth:
		playerHealth -= hitPoints
	else:
		playerHealth = 0
	$CameraControl/CameraTarget/Camera3D/ProgressBar.value = playerHealth
	if playerHealth == 0:
		die()

func die():
	print("YOU DIED")

func _on_player_hit_area_body_entered(body):
	if body.is_in_group("Enemi"):
		body.hurt(10)  

