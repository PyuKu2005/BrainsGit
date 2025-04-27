extends CharacterBody3D

enum { IDLE, MOVING, DASHING, ATTACKING }

@export var SPEED = 5.0
@export var sprintSpeed = 8.5
@export var dash_speed = 20.0
@export var dash_duration = 0.2

@onready var animation = $AnimationPlayer
@onready var area3d = $Marker3D/Sprite3D/playerHitArea
@onready var damageNumbersOrigin = $damageNumberOrigin
@export var attack_forward_speed = 2.0 # ← Avancer doucement pendant attaque

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var playerHealth = 100
var damage = 25
var state = IDLE
var direction = Vector3.ZERO
var last_facing_direction = 1
var dashTimer = 0.0
var dash_started = false
var attack_combo = ["Attack", "Attack2"]
var attack_index = 0
var combo_timer = 0.0
var combo_max_time = 0.5
var combo_queued = false
var attack_started = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	match state:
		IDLE:
			if direction.length() > 0:
				state = MOVING
			elif Input.is_action_just_pressed("Dash"):
				start_dash()
			elif Input.is_action_just_pressed("playerAttack"):
				state = ATTACKING
			else:
				animation.play("BrainIdle")

		MOVING:
			var currentSpeed = SPEED
			if Input.is_action_pressed("Courir"):
				currentSpeed = sprintSpeed
			elif Input.is_action_just_pressed("playerAttack"):
				state = ATTACKING
				return
			if direction.length() > 0:
				velocity.x = direction.x * currentSpeed
				velocity.z = direction.z * currentSpeed
				animation.play("BrainMoving", -1, 2.0 if currentSpeed == sprintSpeed else 1.0, true)
				$Marker3D/Sprite3D/WalkingDust.visible = true
				$Marker3D/Sprite3D/RunningParticles.visible = currentSpeed == sprintSpeed
			else:
				state = IDLE
				$Marker3D/Sprite3D/WalkingDust.visible = false
				$Marker3D/Sprite3D/RunningParticles.visible = false
				velocity.x = 0
				velocity.z = 0
			if Input.is_action_just_pressed("Dash"):
				start_dash()

		DASHING:
			if not dash_started:
				dash_started = true
				dashTimer = dash_duration
				# Appliquer direction au moment du dash
				direction = Vector3(last_facing_direction, 0, 0).normalized()
				velocity.x = direction.x * dash_speed
				velocity.z = direction.z * dash_speed
			dashTimer -= delta
			animation.play("Dash")
			$Marker3D/Sprite3D/RunningParticles.visible = true
			if dashTimer <= 0:
				state = IDLE
				dash_started = false
				velocity.x = 0
				velocity.z = 0
		ATTACKING:
			if not attack_started:
				_play_attack_animation()
				attack_started = true
				# Petite impulsion au début de l'attaque
				var attack_impulse = attack_forward_speed
				velocity.x += last_facing_direction * attack_impulse
				velocity.z = 0
			combo_timer -= delta
			# Freinage progressif
			velocity.x = lerp(velocity.x, 0.0, 0.2)
			if Input.is_action_just_pressed("playerAttack") and combo_timer > 0.0:
				combo_queued = true
			if not animation.is_playing():
				if combo_queued and attack_index < attack_combo.size() - 1:
					attack_index += 1
					_play_attack_animation()
					attack_started = false
					combo_queued = false
				else:
					# Fin du combo
					attack_index = 0
					attack_started = false
					combo_queued = false
					if direction.length() > 0:
						state = MOVING
					else:
						state = IDLE

	_update_facing(input_dir.x)
	move_and_slide()
	_update_camera()

############ OUTILS ############

func start_dash():
	state = DASHING
	dashTimer = dash_duration
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.length() == 0:
		direction = Vector3(last_facing_direction, 0, 0).normalized()
	else:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _play_attack_animation():
	var anim_name = attack_combo[attack_index]
	animation.play(anim_name, -1.0, 1.5)
	combo_timer = combo_max_time

func _update_camera():
	var camera_position = $CameraControl.position
	camera_position.x = lerp(camera_position.x, position.x, 0.08)
	camera_position.z = lerp(camera_position.z, position.z, 0.08)
	camera_position.y = lerp(camera_position.y, position.y, 0.08)
	$CameraControl.position = camera_position

func _update_facing(input_x):
	if state == ATTACKING:
		input_x = last_facing_direction
	if input_x < 0:
		last_facing_direction = -1
		$Marker3D.scale.x = -1
		$Marker3D/Sprite3D.flip_h = true
	elif input_x > 0:
		last_facing_direction = 1
		$Marker3D.scale.x = 1
		$Marker3D/Sprite3D.flip_h = false

########## RÉCEPTION DE DÉGÂTS ##########

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

########## INFLIGER DES DÉGÂTS ##########

func _on_player_hit_area_body_entered(body):
	if body.is_in_group("Enemi"):
		body.hurt(damage)
