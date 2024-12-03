extends CharacterBody3D

@export var SPEED = 5.0
@export var sprintSpeed = 8.5
@export var dash_duration = 0.5  # Duration of the dash in seconds
@export var dash_multiplier = 3.0  # Dash speed multiplier
@onready var area3d = $Sprite3D/playerHitArea
@onready var animation = $AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var playerHealth = 100
var isAttacking = false
var isDashing = false
var dashTimer = 0.0  # Timer to control the dash duration
var dashDirection = Vector3.ZERO  # The direction to dash in  
var attackSpeed = SPEED / 5.0  # Reduced speed during attacks
var currentAttackAnimation = "Attack2"  # Start with Attack2
var attackComboTimer = 0.0  # Timer to manage switching between Attack2 and Attack
var comboDelay = 0.5

var lastFlipDirection = 1  # Track the last flip direction (1 for right, -1 for left)

##### DÉBUT PROCESS DELTA #####
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var currentSpeed = SPEED

	if isDashing:
		dashTimer -= delta
		if dashTimer > 0:
			velocity.x = dashDirection.x * (currentSpeed * dash_multiplier)
			velocity.z = dashDirection.z * (currentSpeed * dash_multiplier)
		else:
			isDashing = false
			velocity = Vector3.ZERO  
		move_and_slide()  
		return  

	if Input.is_action_just_pressed("Dash") and direction != Vector3.ZERO:
		isDashing = true
		dashTimer = dash_duration
		dashDirection = direction  
		animation.play("Dash")  
		velocity.x = dashDirection.x * (currentSpeed * dash_multiplier)
		velocity.z = dashDirection.z * (currentSpeed * dash_multiplier)
		move_and_slide()  
		return  

	# Movement logic
	if direction.length() > 0:
		if isAttacking:
			currentSpeed *= 0.25  # Slow down during attacks
		elif Input.is_action_pressed("Courir") and not isAttacking:
			currentSpeed = sprintSpeed  

		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed

		# Flip the sprite only if not attacking
		if not isAttacking:
			if input_dir.x < 0:
				$Sprite3D.flip_h = true
				lastFlipDirection = -1
			elif input_dir.x > 0:
				$Sprite3D.flip_h = false
				lastFlipDirection = 1
		else:
			# Prevent sprite from flipping during the attack
			$Sprite3D.flip_h = lastFlipDirection  # Keep the flip direction from before the attack

		if not isAttacking:
			animation.play("BrainMoving", -1, 2.0 if currentSpeed == sprintSpeed else 1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if not isAttacking:
			animation.play("BrainIdle")

	# Attack logic
	if Input.is_action_pressed("playerAttack"):
		if not isAttacking:
			isAttacking = true
			animation.play(currentAttackAnimation, -1, 2)  
			attackComboTimer = animation.current_animation_length / 2  
			# Keep the flip direction when attack starts
			lastFlipDirection = $Sprite3D.flip_h
		else:
			attackComboTimer -= delta
			if attackComboTimer <= 0:
				currentAttackAnimation = "Attack" if currentAttackAnimation == "Attack2" else "Attack2"
				animation.play(currentAttackAnimation, -1, 2)  
				attackComboTimer = animation.current_animation_length / 2 
	else:
		if isAttacking:
			isAttacking = false
			attackComboTimer = 0
			currentAttackAnimation = "Attack2" 

	move_and_slide()  

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
		get_tree().call_group("Enemi", "hurt", 10)
