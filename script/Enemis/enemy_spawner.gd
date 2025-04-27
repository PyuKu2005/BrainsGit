extends Node3D

@onready var currentLevel = 1
@onready var enemyArray = {
	1: 1,
	2: 3,
	3: 5
}
@onready var enemy = preload("res://scenes/enemyMelee.tscn")
@onready var rand = RandomNumberGenerator.new()
@onready var deadEnemy = 0
var spawnedEnemies = 0  # Track the number of spawned enemies per level

func _ready():
	add_to_group("level")
	updateLevel(currentLevel)

func enemyDeath():
	print("Enemy dead")
	deadEnemy += 1
	if deadEnemy == enemyArray[currentLevel]:  # Check if all enemies for the level are defeated
		print("Wave complete. Waiting for the next wave...")
		$waitBetweenWave.start()
		deadEnemy = 0
		spawnedEnemies = 0  # Reset spawned enemies count for the next wave

func spawnEnemies():
	# Check if more enemies need to be spawned for the current level
	if spawnedEnemies < enemyArray[currentLevel]:
		var E = enemy.instantiate()
		print("Spawning enemy", spawnedEnemies + 1, "of", enemyArray[currentLevel])
		var spawnLength = $"..".get_child_count() - 1
		var randNum = rand.randi_range(0, spawnLength)
		var spawnPosition = $"..".get_child(randNum).position
		E.position = spawnPosition
		add_child(E)
		spawnedEnemies += 1  # Increment the spawn count
		
		# Wait 2 seconds before spawning the next enemy
		$waitBetweenWave.start(2.0)  # Use a timer to handle the delay
	else:
		print("All enemies for this wave have been spawned.")

func updateLevel(level):
	match level:
		1:
			print("Level one")
		2:
			print("Level two")
		3:
			print("Level three")
	spawnedEnemies = 0  # Reset spawn count for the new level
	spawnEnemies()  # Start the spawning process
	
func _on_wait_between_wave_timeout():
	print("Level", currentLevel, "finished.")
	currentLevel += 1
	if currentLevel in enemyArray.keys():
		updateLevel(currentLevel)
	else:
		print("All levels complete!")

func _on_spawn_timer_timeout():
	spawnEnemies()  # Spawn the next enemy after the timer times out
