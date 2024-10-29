extends CharacterBody3D

const SPEED = 5.0
@onready var area3d = $Sprite3D/playerHitArea
@onready var animation = $AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var isAttacking = false
var playerHealth = 100
@onready var timer = $Timer


##### DÉBUT PROCESS DELTA #####
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	############## MOVEMENT ###############
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction and isAttacking == false:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		animation.play("BrainMoving")

		# Rotate the character based on input
		if input_dir.x < 0:  # Moving left
			$Sprite3D.flip_h = true
			area3d.scale.x = -abs(area3d.scale.x)  
		elif input_dir.x > 0:  
			$Sprite3D.flip_h = false  
			area3d.scale.x = abs(area3d.scale.x)   
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if not animation.is_playing() or animation.current_animation != "Attack":
			animation.play("BrainIdle")
	move_and_slide()

						######COMBAT#######
	if Input.is_action_just_pressed("playerAttack"):
		isAttacking == true  
		print("Attack input detected")  
		if animation.has_animation("Attack"):
			print("Playing Attack animation") 
			animation.play("Attack")
			
		else:
			print("Attack animation not found")

	# Update the camera position smoothly
	var camera_position = $CameraControl.position
	camera_position.x = lerp(camera_position.x, position.x, 0.08)
	camera_position.z = lerp(camera_position.z, position.z, 0.08)
	camera_position.y = lerp(camera_position.y, position.y, 0.08)
	$CameraControl.position = camera_position
##### FIN PROCESS DELTA #####
	
	
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
