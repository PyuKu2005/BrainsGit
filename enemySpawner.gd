extends Node3D

var enemyMele = preload("res://scenes/Enemis/enemyMelee.tscn")
var enemyRange = preload("res://scenes/Enemis/enemyRange.tscn")
var enemiesGenerated = [enemyMele, enemyRange]
var instance

@onready var timer = $enemySpawnTimer
@onready var spawnLocation = $spawnLocation

func _ready():
	timer.wait_time = 2.0
	timer.start()


func _on_enemy_spawn_timer_timeout():
	var randomNumber = randi_range(0,1)
	instance = enemiesGenerated[randomNumber].instantiate()
	var spawnPosition = spawnLocation.global_transform.origin
	get_tree().current_scene.add_child(instance)
	timer.start()
