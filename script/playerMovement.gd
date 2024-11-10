extends CharacterBody3D 

@export var SPEED = 5.0
@export var sprintSpeed = 7.0
@onready var area3d = $Sprite3D/playerHitArea
@onready var animation = $AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var playerHealth = 100
var isAttacking = false

##### DÉBUT PROCESS DELTA #####
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	############## MOVEMENT ###############
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Define reduced speed for attacking
	var attackSpeed = SPEED / 5.0
	var currentSpeed = SPEED  # Default to normal speed
	
	###### COURIR (Sprinting) #######
	if Input.is_action_pressed("Courir") and direction and not isAttacking:
		currentSpeed = sprintSpeed
	elif isAttacking:
		currentSpeed = attackSpeed  # Set reduced speed while attacking

	# Movement and animation logic
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed

		# Play movement animation if not attacking
		if not isAttacking:
			animation.play("BrainMoving", -1, 2.0 if currentSpeed == sprintSpeed else 1.0, true)

		# Rotate character based on input direction
		if input_dir.x < 0:  # Moving left
			$Sprite3D.flip_h = true
			area3d.scale.x = -abs(area3d.scale.x)
		elif input_dir.x > 0:  
			$Sprite3D.flip_h = false  
			area3d.scale.x = abs(area3d.scale.x)
	else:
		# If not moving, transition to idle unless attacking
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if not isAttacking:
			animation.play("BrainIdle", -1, 1.0, true)

	# Move the character
	move_and_slide()

	###### COMBAT (Attack handling) #######
	# Start the attack if the button is pressed and not currently attacking
	if Input.is_action_just_pressed("playerAttack") and not isAttacking:
		isAttacking = true
		if animation.has_animation("Attack"):
			animation.play("Attack")

	# End the attack state if the attack button is released
	if isAttacking and not Input.is_action_pressed("playerAttack"):
		isAttacking = false  # Reset attack state after releasing button

	############# CAMERA ################
	var camera_position = $CameraControl.position
	camera_position.x = lerp(camera_position.x, position.x, 0.08)
	camera_position.z = lerp(camera_position.z, position.z, 0.08)
	camera_position.y = lerp(camera_position.y, position.y, 0.08)
	$CameraControl.position = camera_position
##### FIN PROCESS DELTA ##### 

################ RECEVOIR DAMAGES ################
func hurt(hitPoints):
	if hitPoints < playerHealth:
		playerHealth -= hitPoints
	else:
		playerHealth = 0
	$CameraControl/CameraTarget/Camera3D/ProgressBar.value = playerHealth
	if playerHealth == 0:
		die()

func die():
	queue_free()

func _on_player_hit_area_body_entered(body):
	if body.is_in_group("Enemi"):
		get_tree().call_group("Enemi", "hurt", 10)
