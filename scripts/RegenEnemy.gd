extends Node3D
class_name RegenEnemy
#sets up the variables
var damage: int = 7
var despawning:bool = false
var curve_3d:Curve3D
var enemy_progress:float = 0
var enemy_speed:float = 0.5
var enemy_health:int = 700
var enemy_worth:int = 100
var toxic_attack:int = 0
@onready var basic_enemy = $"."

#when the scene is loaded, follows path
func _ready():
	$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
	$Path3D/PathFollow3D/regenenemy.show()
	curve_3d=Curve3D.new()
	var seed:Seed
	var toxic:ToxicProjectile
	for i in PathGenInstance.get_path_route():
		curve_3d.add_point(Vector3(i.x,0,i.y))
	$Path3D.curve = curve_3d
	$Path3D/PathFollow3D.progress_ratio = 0
#when spawning, plays animation
func _on_spawning_state_entered():
	
	$AnimationPlayer.play("spAWn")
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
	$AnimationPlayer.play("deSpawn")
	await $AnimationPlayer.animation_finished
	GameManaging.health -= damage
	
	if GameManaging.health <= 0:
		#if you die, go to death screen
		get_tree().change_scene_to_file("res://scenes/menu/DeathScreen.tscn")
	queue_free()

func _heal():
	if enemy_health < 300: #heals enemy when health low
		await get_tree().create_timer(1) #after 1 sec increases health by 2
		enemy_health += 0.5 
		await get_tree().create_timer(1)
		print("health back") #test code to know it has worked

func _death():
		$Path3D/PathFollow3D/regenenemy.hide() #disappears 
		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide() #disappears
		$Path3D/PathFollow3D/healthbarender.hide() #disapears
		$Path3D/PathFollow3D/death.emitting = true #play death effect
		await get_tree().create_timer(0.5).timeout #wait 0.5 s
		print("dead") #test to see if they are dead
		GameManaging.money += enemy_worth #when killed increases money
		GameManaging.enemies_left.erase(1) #removes one from array
		GameManaging.score += 50 #add score 50
		queue_free() #deletes itself

func _process(delta):
	# heals once a frame
	_heal()
	if enemy_health <= 0: # when health less than 0
		_death()#calls death function
	else:
		pass

func _fire_attack():
		var fire_attack = 0
		$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
		$Path3D/PathFollow3D/regenenemy.hide()
		while fire_attack <= 10:
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(0.25).timeout
			$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(0.25).timeout
			print(enemy_health)
			fire_attack += 1
		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
		$Path3D/PathFollow3D/regenenemy.show()
# area 3ds for different types
func _toxic_attack():
		toxic_attack = 0
		$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
		$Path3D/PathFollow3D/regenenemy.hide()
		while toxic_attack <= 3:
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(1.5).timeout
			$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(1.5).timeout
			print(enemy_health)
			toxic_attack += 1

		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
		$Path3D/PathFollow3D/regenenemy.show()
		

func _on_area_3d_reg_detect_area_entered(area):
	enemy_health -= GameManaging.seed_damage

func _on_area_3d_frost_detect_area_entered(area):
	enemy_speed -= 1.2
	enemy_health -= GameManaging.seed_damage
	print("frosted")
	await get_tree().create_timer(0.25).timeout
	print("defrosted")
	enemy_speed += 1.2
	
func _on_area_3d_toxic_detect_area_entered(area):
	_toxic_attack()
	await get_tree().create_timer(0.5).timeout

func _on_area_3d_fire_detect_area_entered(area):
	_fire_attack()
	await get_tree().create_timer(0.5).timeout
