extends CharacterBody3D
@export var SPEED = 5.0
@export var sprintSpeed = 7.0
@onready var area3d = $Sprite3D/playerHitArea
@onready var animation = $AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var playerHealth = 100

var isAttacking = false
var attackSpeed = SPEED / 5.0  # Reduced speed during attacks
var currentAttackAnimation = "Attack2"  # Start with Attack2
var attackComboTimer = 0.0  # Timer to manage switching between Attack2 and Attack
var comboDelay = 0.5  # Delay between switching attacks in the loop

##### DÉBUT PROCESS DELTA #####
func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var currentSpeed = SPEED

	if Input.is_action_pressed("Courir") and direction and not isAttacking:
		isAttacking == false
		currentSpeed = sprintSpeed
	
	if isAttacking:
		currentSpeed = attackSpeed

	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
		if not isAttacking:
			animation.play("BrainMoving", -1, 2.0 if currentSpeed == sprintSpeed else 1.0, true)

		if input_dir.x < 0:  # Moving left
			$Sprite3D.flip_h = true
			area3d.scale.x = -abs(area3d.scale.x)
		elif input_dir.x > 0:  # Moving right
			$Sprite3D.flip_h = false
			area3d.scale.x = abs(area3d.scale.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if not isAttacking:
			animation.play("BrainIdle", -1, 1.0, true)

	move_and_slide()

	if Input.is_action_pressed("playerAttack"):
		if not isAttacking:
			isAttacking = true
			animation.play(currentAttackAnimation, -1, 1.0, true)  # Start with Attack2 animation
		else:
			if attackComboTimer <= 0:
				if currentAttackAnimation == "Attack2":
					currentAttackAnimation = "Attack"
				else:
					currentAttackAnimation = "Attack2"
				attackComboTimer = comboDelay 
			animation.play(currentAttackAnimation, -1, 1.0, true)
		
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
	queue_free()

func _on_player_hit_area_body_entered(body):
	if body.is_in_group("Enemi"):
		get_tree().call_group("Enemi", "hurt", 10)
