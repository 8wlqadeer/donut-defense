extends Node3D
class_name SpeedyEnemy
#sets up the variables
var damage: int = 5
var despawning:bool = false
var curve_3d:Curve3D
var enemy_progress:float = 0
var enemy_speed:float = 3
var enemy_health:int = 100
var enemy_worth:int = 50
var toxic_attack:int = 0
@onready var basic_enemy = $"."

#when the scene is loaded, follows path
func _ready():
	$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
	$Path3D/PathFollow3D/SpeedyEnemy.show()
	curve_3d=Curve3D.new()
	var seed:Seed
	var toxic:ToxicProjectile
	for i in PathGenInstance.get_path_route():
		curve_3d.add_point(Vector3(i.x,0,i.y))
	$Path3D.curve = curve_3d
	$Path3D/PathFollow3D.progress_ratio = 0
#when spawning, plays animation
func _on_spawning_state_entered():
	
	$AnimationPlayer.play("SPAWNING")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_travelling")

#when travelling, moves along path
func _on_travelling_state_processing(delta):
	enemy_progress += delta*enemy_speed
	$Path3D/PathFollow3D.progress = enemy_progress
	
	if enemy_progress > PathGenInstance.get_path_route().size():
		$EnemyStateChart.send_event("to_despawning")

#when at the end, plays despawn animation, deleted itself and deals damage.
func _on_despawning_state_entered():
	$AnimationPlayer.play("DESPAWNING")
	await $AnimationPlayer.animation_finished
	GameManaging.health -= damage
	
	if GameManaging.health <= 0:
		#if you die, go to death screen
		get_tree().change_scene_to_file("res://scenes/menu/DeathScreen.tscn")
	queue_free()

func _death():
		$Path3D/PathFollow3D/SpeedyEnemy.hide()
		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
		$Path3D/PathFollow3D/healthbarender.hide()
		$Path3D/PathFollow3D/death.emitting = true
		await get_tree().create_timer(0.5).timeout
		print("dead")
		GameManaging.money += enemy_worth
		GameManaging.enemies_left.erase(1)
		GameManaging.score += 50
		queue_free()

func _process(delta):
	if enemy_health <= 0:
		_death()
	else:
		pass

func _fire_attack():
		var fire_attack = 0
		$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
		$Path3D/PathFollow3D/SpeedyEnemy.hide()
		while fire_attack <= 10:
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(0.25).timeout
			$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(0.25).timeout
			print(enemy_health)
			fire_attack += 1

		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
		$Path3D/PathFollow3D/SpeedyEnemy.show()


# area 3ds for different types
func _toxic_attack():
		toxic_attack = 0
		$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
		$Path3D/PathFollow3D/SpeedyEnemy.hide()
		while toxic_attack <= 3:
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(1.5).timeout
			$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(1.5).timeout
			print(enemy_health)
			toxic_attack += 1

		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
		$Path3D/PathFollow3D/SpeedyEnemy.show()
		

func _on_area_3d_reg_detect_area_entered(area):
	enemy_health -= GameManaging.seed_damage

func _on_area_3d_frost_detect_area_entered(area):
	enemy_speed -= 5.5
	enemy_health -= GameManaging.seed_damage
	print("frosted")
	await get_tree().create_timer(0.1).timeout
	print("defrosted")
	enemy_speed += 5.5
	GameManaging.score +=50
	
func _on_area_3d_toxic_detect_area_entered(area):
	_toxic_attack()
	GameManaging.score += 25
	await get_tree().create_timer(0.5).timeout


func _on_area_3d_fire_detect_area_entered(area):
	print("Attack")
	_fire_attack()
	await get_tree().create_timer(0.5).timeout
