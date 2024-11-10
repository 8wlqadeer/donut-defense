extends Node3D
# gets variables
@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_crossroads:PackedScene
@export var tile_enemy:PackedScene
@export var tile_empty:Array[PackedScene]
@export var basic_enemy:PackedScene
@export var speedy_enemy:PackedScene
@export var regen_enemy:PackedScene
@export var weak_boss:PackedScene
@export var frost_enemy:PackedScene
@export var boss_enemy:PackedScene
@export var wave:int = 1
@onready var next_wave = $Labels/NextWave
@onready var cam = $Camera3D
var num = 0
var ranGen = RandomNumberGenerator.new()
var RAYCAST_LENGTH:float = 100
var autostart: bool = false

## Assumes the path generator has finished, and adds the remaining tiles to fill in the grid.
func _ready(): # happens as soon as scene loads
	_complete_grid()#function for creating path
	next_wave.show() 
	$Labels/AppleUnlock.hide()
	$Labels/ApplePlaceButton.hide() #cannot place apple
	$Labels/AppleUnlock.show() #shows apple unlock button 'unlocked at round 2'
	# spawns the first wave
	await get_tree().create_timer(3).timeout #control
	

#raycast code.
func _physics_process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var space_state = get_world_3d().direct_space_state
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		var origin:Vector3 = cam.project_ray_origin(mouse_pos)
		var end:Vector3 = origin + cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var rayResult:Dictionary = space_state.intersect_ray(query)
		if rayResult.size() > 0:
			var co:CollisionObject3D = rayResult.get("collider")
# sets up the grid
func _complete_grid():
	for x in range(PathGenInstance.path_config.map_length):
		for y in range(PathGenInstance.path_config.map_height):
			if not PathGenInstance.get_path_route().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)
	
	
	for i in range(PathGenInstance.get_path_route().size()):
		var tile_score:int = PathGenInstance.get_tile_score(i)
		
		var tile:Node3D = tile_empty[0].instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO
		# rotates tiles accordingly
		if tile_score == 2:
			tile = tile_end.instantiate()
			tile_rotation = Vector3(0,-90,0)
		elif tile_score == 8:
			tile = tile_start.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 1 or tile_score == 4 or tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 6:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,180,0)
		elif tile_score == 12:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 9:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 3:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,270,0)
		elif tile_score == 15:
			tile = tile_crossroads.instantiate()
			tile_rotation = Vector3(0,0,0)
		#creates tiles
		add_child(tile)
		tile.global_position = Vector3(PathGenInstance.get_path_tile(i).x, 0, PathGenInstance.get_path_tile(i).y)
		tile.global_rotation_degrees = tile_rotation

func _process(delta):
	
	$Labels/Wave.text = "Wave " + str(wave)
	$Labels/Score.text = "Score: " +str(GameManaging.score)
# waves
func _on_next_wave_pressed():
	if wave == 1:
		GameManaging.money += 0
	else:
		GameManaging.money += 10 * (wave/2)
	next_wave.hide()
	if wave == 1:
		await get_tree().create_timer(0.0005).timeout
		for i in 1:
			await get_tree().create_timer(2).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1

	elif wave == 2:
		$Labels/ApplePlaceButton.show()
		$Labels/AppleUnlock.hide()
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 5:
			await get_tree().create_timer(1.5).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 3:
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 10:
			await get_tree().create_timer(1).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 4:
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			await get_tree().create_timer(0.5).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 5:
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 3:
			ranGen.randomize()
			num = ranGen.randi_range(1,2)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 6:
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 5:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 7:
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 10:
			ranGen.randomize()
			num = ranGen.randi_range(1,4)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num > 1:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 8:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 10:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 3:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 9:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			ranGen.randomize()
			num = ranGen.randi_range(1,5)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 4 or num == 2:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 10:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 20:
			ranGen.randomize()
			num = ranGen.randi_range(1,7)
			if num == 1:
				await get_tree().create_timer(0.2).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3 or num == 4:
				await get_tree().create_timer(0.4).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num < 4:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 11:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 25:
			ranGen.randomize()
			num = ranGen.randi_range(1,2)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 12:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			await get_tree().create_timer(0.2).timeout
			var speedEnemy = speedy_enemy.instantiate()
			add_child(speedEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 13:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			ranGen.randomize()
			num = ranGen.randi_range(1,2)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 14:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 30:
			await get_tree().create_timer(0.2).timeout
			var regenEnemy = regen_enemy.instantiate()
			add_child(regenEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 15:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 1:
			await get_tree().create_timer(0.2).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 16:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 40:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.35).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.35).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 17:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 50:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 18:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		for i in 30:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 19:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 1:
			await get_tree().create_timer(1.5).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 30:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 20:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 3:
			await get_tree().create_timer(1.5).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 30:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 21:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 25:
			await get_tree().create_timer(0.5).timeout
			var frostEnemy = frost_enemy.instantiate()
			add_child(frostEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 22:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 3:
			await get_tree().create_timer(1.5).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 40:
			ranGen.randomize()
			num = ranGen.randi_range(1,4)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 3 or num == 4:
				await get_tree().create_timer(0.25).timeout
				var frostEnemy = frost_enemy.instantiate()
				add_child(frostEnemy)
				GameManaging.enemies_left.append(1)
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 23:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 6:
			await get_tree().create_timer(1.5).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 70:
			ranGen.randomize()
			num = ranGen.randi_range(1,4)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 3 or num == 4:
				await get_tree().create_timer(0.25).timeout
				var frostEnemy = frost_enemy.instantiate()
				add_child(frostEnemy)
				GameManaging.enemies_left.append(1)
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 24:
		var finalBoss = boss_enemy.instantiate()
		add_child(finalBoss)
		next_wave.show()
		wave += 1
	elif wave > 24:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in (wave - 15):
			await get_tree().create_timer(1.5).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		if wave%2 == 0:
			await get_tree().create_timer(1.5).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in (70+wave):
			ranGen.randomize()
			num = ranGen.randi_range(1,4)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 3 or num == 4:
				await get_tree().create_timer(0.25).timeout
				var frostEnemy = frost_enemy.instantiate()
				add_child(frostEnemy)
				GameManaging.enemies_left.append(1)
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1

func _on_check_box_toggled(toggled_on: bool) -> void:
	var startt:bool
	if toggled_on == true:
		startt == true
	else:
		startt = false
	print(toggled_on)
	if toggled_on == true: #and startt == true:
		if wave == 1:
			GameManaging.money += 0
		else:
			GameManaging.money += 10 * (wave/2)
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 1:
			await get_tree().create_timer(2).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1


		$Labels/ApplePlaceButton.show()
		$Labels/AppleUnlock.hide()
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 5:
			await get_tree().create_timer(1.5).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1

		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 10:
			await get_tree().create_timer(1).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1

		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			await get_tree().create_timer(0.5).timeout
			var basicEnemy = basic_enemy.instantiate()
			add_child(basicEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1

		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 3:
			ranGen.randomize()
			num = ranGen.randi_range(1,2)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			next_wave.show()
			wave += 1

		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 5:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		ranGen.randomize()
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 10:
			ranGen.randomize()
			num = ranGen.randi_range(1,4)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num > 1:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 10:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 3:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			ranGen.randomize()
			num = ranGen.randi_range(1,5)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 4 or num == 2:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 20:
			ranGen.randomize()
			num = ranGen.randi_range(1,7)
			if num == 1:
				await get_tree().create_timer(0.2).timeout
				var basicEnemy = basic_enemy.instantiate()
				add_child(basicEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3 or num == 4:
				await get_tree().create_timer(0.4).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num < 4:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 25:
			ranGen.randomize()
			num = ranGen.randi_range(1,2)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			await get_tree().create_timer(0.2).timeout
			var speedEnemy = speedy_enemy.instantiate()
			add_child(speedEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 15:
			ranGen.randomize()
			num = ranGen.randi_range(1,2)
			if num == 1:
				await get_tree().create_timer(0.5).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.5).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 30:
			await get_tree().create_timer(0.2).timeout
			var regenEnemy = regen_enemy.instantiate()
			add_child(regenEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 1:
			await get_tree().create_timer(0.2).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 40:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.35).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.35).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 50:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		for i in 30:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 1:
			await get_tree().create_timer(1.5).timeout
			bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 30:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 3:
			await get_tree().create_timer(1.5).timeout
			bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 30:
			ranGen.randomize()
			num = ranGen.randi_range(1,3)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2 or num == 3:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
		bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 25:
			await get_tree().create_timer(0.5).timeout
			var frostEnemy = frost_enemy.instantiate()
			add_child(frostEnemy)
			GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	elif wave == 22:
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 3:
			await get_tree().create_timer(1.5).timeout
			var bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 40:
			ranGen.randomize()
			num = ranGen.randi_range(1,4)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 3 or num == 4:
				await get_tree().create_timer(0.25).timeout
				var frostEnemy = frost_enemy.instantiate()
				add_child(frostEnemy)
				GameManaging.enemies_left.append(1)
		var bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
	
		next_wave.hide()
		await get_tree().create_timer(0.0005).timeout
		for i in 6:
			await get_tree().create_timer(1.5).timeout
			bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
		for i in 70:
			ranGen.randomize()
			num = ranGen.randi_range(1,4)
			if num == 1:
				await get_tree().create_timer(0.25).timeout
				var speedEnemy = speedy_enemy.instantiate()
				add_child(speedEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 2:
				await get_tree().create_timer(0.25).timeout
				var regenEnemy = regen_enemy.instantiate()
				add_child(regenEnemy)
				GameManaging.enemies_left.append(1)
			elif num == 3 or num == 4:
				await get_tree().create_timer(0.25).timeout
				var frostEnemy = frost_enemy.instantiate()
				add_child(frostEnemy)
				GameManaging.enemies_left.append(1)
		bossEnemy = weak_boss.instantiate()
		add_child(bossEnemy)
		GameManaging.enemies_left.append(1)
		next_wave.show()
		wave += 1
		while toggled_on == true:
			next_wave.hide()
			await get_tree().create_timer(0.0005).timeout
			for i in (wave-20):
				await get_tree().create_timer(1.5).timeout
				bossEnemy = weak_boss.instantiate()
				add_child(bossEnemy)
				GameManaging.enemies_left.append(1)
			for i in (70+wave*2):
				ranGen.randomize()
				num = ranGen.randi_range(1,4)
				if num == 1:
					await get_tree().create_timer(0.25).timeout
					var speedEnemy = speedy_enemy.instantiate()
					add_child(speedEnemy)
					GameManaging.enemies_left.append(1)
				elif num == 2:
					await get_tree().create_timer(0.25).timeout
					var regenEnemy = regen_enemy.instantiate()
					add_child(regenEnemy)
					GameManaging.enemies_left.append(1)
				elif num == 3 or num == 4:
					await get_tree().create_timer(0.25).timeout
					var frostEnemy = frost_enemy.instantiate()
					add_child(frostEnemy)
					GameManaging.enemies_left.append(1)
			bossEnemy = weak_boss.instantiate()
			add_child(bossEnemy)
			GameManaging.enemies_left.append(1)
			next_wave.show()
			wave += 1
	else:
		pass
