extends Node3D
class_name Enemy
#sets up the variables
var damage: int = 1
var despawning:bool = false
var curve_3d:Curve3D
var enemy_progress:float = 0
var enemy_speed:float = 1
var enemy_health:int = 100
var enemy_worth:int = 10
var toxic_attack:int = 0
@onready var basic_enemy = $"."

#when the scene is loaded, follows path
func _ready(): #executes whenever scene loads
	$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
	$Path3D/PathFollow3D/donutEnemyPink.show()
	curve_3d=Curve3D.new() #creates curve to follow
	var seed:Seed #declares variable for watermelon projectile
	var toxic:ToxicProjectile #declares variable for apple projectile
	for i in PathGenInstance.get_path_route(): #coordinates from pasth generator, 2d coordinates
		curve_3d.add_point(Vector3(i.x,0,i.y)) #set y = 0
	$Path3D.curve = curve_3d #path3d curve gains coordinates to new one to look like our new path
	$Path3D/PathFollow3D.progress_ratio = 0 #sets to position 0 so spawns at start of path
#when spawning, plays animation
func _on_spawning_state_entered():
	
	$AnimationPlayer.play("spawn") #when spawns plays spawn animation
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_travelling") # sends to different state

#when travelling, moves along path
func _on_travelling_state_processing(delta): #to travelling function
	enemy_progress += delta*enemy_speed # delta is number to show frames per second
	#increase progress of enemy on track , frames per second in travelling state
	$Path3D/PathFollow3D.progress = enemy_progress #distance follow along path is the same as enemy progress
	
	if enemy_progress > PathGenInstance.get_path_route().size(): #when reach end of track start to despawn
		$EnemyStateChart.send_event("to_despawning")

#when at the end, plays despawn animation, deleted itself and deals damage.
func _on_despawning_state_entered():
	$AnimationPlayer.play("Despawn")
	await $AnimationPlayer.animation_finished
	GameManaging.health -= damage
	# when health is less than 0
	if GameManaging.health <= 0:
		#if you die, go to death screen
		get_tree().change_scene_to_file("res://scenes/menu/DeathScreen.tscn")
	#deletes itself
	queue_free()
# death function
func _death():
		$Path3D/PathFollow3D/donutEnemyPink.hide() # this hides everything before deleting it so that the death an
		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()# imation plays before the donut is deleted
		$Path3D/PathFollow3D/healthbarender.hide()
		$Path3D/PathFollow3D/death.emitting = true  
		await get_tree().create_timer(0.5).timeout
		print("dead")
		GameManaging.money += enemy_worth
		GameManaging.score += 5
		queue_free()
		


func _process(delta):
	if enemy_health <= 0:
		_death()
	else:
		pass

func _fire_attack():
		var fire_attack = 0
		$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
		$Path3D/PathFollow3D/donutEnemyPink.hide()
		while fire_attack <= 10:
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(0.25).timeout
			$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(0.25).timeout
			print(enemy_health)
			fire_attack += 1

		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
		$Path3D/PathFollow3D/donutEnemyPink.show()

# area 3ds for different types
func _toxic_attack():
		toxic_attack = 0
		$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
		$Path3D/PathFollow3D/donutEnemyPink.hide()
		while toxic_attack <= 3:
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(1.5).timeout
			$Path3D/PathFollow3D/donutEnemyBasicToxic.show()
			enemy_health -= GameManaging.toxic_damage
			await get_tree().create_timer(1.5).timeout
			print(enemy_health)
			toxic_attack += 1

		$Path3D/PathFollow3D/donutEnemyBasicToxic.hide()
		$Path3D/PathFollow3D/donutEnemyPink.show()
		

func _on_area_3d_reg_detect_area_entered(area):
	enemy_health -= GameManaging.seed_damage

func _on_area_3d_frost_detect_area_entered(area):
	enemy_speed -= 2
	enemy_health -= GameManaging.seed_damage
	print("frosted")
	await get_tree().create_timer(0.25).timeout
	print("defrosted")
	enemy_speed += 2
	
func _on_area_3d_toxic_detect_area_entered(area):
	_toxic_attack()
	await get_tree().create_timer(0.5).timeout


func _on_area_3d_fire_detect_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Attack")
	_fire_attack()
	await get_tree().create_timer(0.5).timeout
