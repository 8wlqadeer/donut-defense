extends Node3D
#sets up the variables
var enemies_in_range:Array[Node3D]
var current_enemy:Node3D = null
var acquire_slerp_progress:float = 0
var current_enemy_targetted:bool = false
var last_fire_time: int
var cam: Camera3D
var fire = true
var weapon_type = "fireseed"
var hit_once = false
var hit_damage = false
var hit_reload = false
var hit_range = false
var damage_count = 0
var reload_count = 0
var deleted:bool = false
@export var fire_rate_ms:int = 1000
@export var projectile_type:PackedScene
@export var frosty_seed:PackedScene
@onready var watermelon_place_button = $"."
@onready var seed = $"."

func _ready():
	cam = get_viewport().get_camera_3d()
	$ExtraDamageUpgrade.hide()
	$ExtraReloadUpgrade.hide()
	$RangeUpgrade.hide()
# how long raycast is
var RAYCAST_LENGTH = 1000
func _physics_process(_delta):
	# runs every frame
	# only activates when x is pressed. delete is set to x on the input map
	if Input.is_action_just_pressed("delete"):
		# creates space state
		var space_state = get_world_3d().direct_space_state
		# gets the position of the mouse pointer
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		# lets the ray know where to start from
		var origin:Vector3 = cam.project_ray_origin(mouse_pos)
		# lets the ray know when to end
		var end:Vector3 = origin + cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		# creates the ray
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		# lets the ray collide whith areas
		query.collide_with_areas = true
		# lets us get information when the ray hits something
		var rayResult:Dictionary = space_state.intersect_ray(query)
		# if there is something in the array
		if rayResult.size() > 0:
			# creates a variable to get collider
			var co:CollisionObject3D = rayResult.get("collider")
			# print here for testing
			print("watermeoln  position",$".".global_position )
			# calls main mouse hit function
			_on_main_mouse_hit(co)
			
	# raycast for upgrading
	if Input.is_action_just_pressed("upgrade"):
		var space_state = get_world_3d().direct_space_state
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		var origin:Vector3 = cam.project_ray_origin(mouse_pos)
		var end:Vector3 = origin + cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var rayResult:Dictionary = space_state.intersect_ray(query)
		if rayResult.size() > 0:
			var co:CollisionObject3D = rayResult.get("collider")
			print("watermeoln  position",$".".global_position )
			# call the same function but for upgrades rather than deletion
			_on_main_mouse_hit_upgrade(co)
			
func _on_main_mouse_hit(watermelon:CollisionObject3D):
	# since tiles are at Y 0.2 and not 0, we must use Vector3 and not just watermelon.global_postiotn
	if $".".global_position == Vector3(watermelon.global_position.x, 0.2, watermelon.global_position.z):
		# money increases by 70 as it does so over two ticks
		# removes watermelon and makes it no longer fire
		GameManaging.money += 35
		$".".visible = false
		deleted = true
		fire = false
func _on_main_mouse_hit_upgrade(watermelon:CollisionObject3D):
	# print is for testing
	print("raycast  position",watermelon.global_position )
	if $".".global_position == Vector3(watermelon.global_position.x, 0.2, watermelon.global_position.z):
		# when you right click and you are on a melon, upgrades show
		$ExtraDamageUpgrade.show()
		$ExtraReloadUpgrade.show()
		$RangeUpgrade.show()
	# if it is pressed where a watermelon isn't pressed it hides the upgrades.
	if Input.is_action_just_pressed("upgrade"):
		var space_state = get_world_3d().direct_space_state
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		var origin:Vector3 = cam.project_ray_origin(mouse_pos)
		var end:Vector3 = origin + cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var rayResult:Dictionary = space_state.intersect_ray(query)
		if rayResult.size() > 0:
			var co:CollisionObject3D = rayResult.get("collider")
			if $".".global_position != Vector3(co.global_position.x, 0.2, co.global_position.z):
				$ExtraDamageUpgrade.hide()
				$ExtraReloadUpgrade.hide()
				$RangeUpgrade.hide()
#when the area body 3d is entered, increases array size by one
func _on_patrol_zone_area_entered(area):
	if current_enemy == null:
		current_enemy = area
	enemies_in_range.append(area)
#when the area body 3d is exited, decreases array size by one
func _on_patrol_zone_area_exited(area):
	enemies_in_range.erase(area)
#sets patrolling to true
func set_patrolling(patrolling: bool):
	$PatrolZone.monitoring = patrolling
#rotation script
func rotate_towards_target(rtarget, delta):
	# gets the position of the target and rotates towards its target.
	var target_Vector = $dragonShape.global_position.direction_to(Vector3(rtarget.global_position.x,global_position.y,rtarget.global_position.z))
	var target_basis: Basis = basis.looking_at(target_Vector)
	$dragonShape.basis = $dragonShape.basis.slerp(target_basis, acquire_slerp_progress)
	acquire_slerp_progress += delta
	if acquire_slerp_progress > 1:
		$StateChart.send_event("to_attacking_state")

#when in the patrolling state, decides which enemy to attack
func _on_patrolling_state_state_processing(delta):# run every frame
	if enemies_in_range.size() > 0:# enemies 
		current_enemy = enemies_in_range[0]
		acquire_slerp_progress = 0
		$StateChart.send_event("to_acquiring_state")

#when in acquirirng state sets slerp to 0 and makes sure no targetting yet
func _on_acquiring_state_state_entered():
	current_enemy_targetted = false
	acquire_slerp_progress = 0

#when in acquiring state checks that enemies are still in range
func _on_acquiring_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$dragonShape.look_at(current_enemy.global_position)
	else:
		$StateChart.send_event("to_patrolling_state")
	rotate_towards_target(current_enemy,delta)
#when in attacking state, looks towards enemies
func _on_attacking_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$dragonShape.look_at(current_enemy.global_position)
		if fire == true:
			# calls maybe fire function
			
			_maybe_fire()
	else:
		$StateChart.send_event("to_patrolling_state")
func _maybe_fire():
	if weapon_type == "fireseed":
		if Time.get_ticks_msec()>(last_fire_time+fire_rate_ms):
			print("fire")
			var projectile:FireSeed = projectile_type.instantiate()
			projectile.starting_position = $dragonShape/projectile_spawn.global_position
			projectile.target = current_enemy
			add_child(projectile)
			last_fire_time = Time.get_ticks_msec()
	elif weapon_type == "frostySeed":
		if Time.get_ticks_msec()>(last_fire_time+fire_rate_ms):
			var projectile:FrostSeed = frosty_seed.instantiate()
			projectile.starting_position = $dragonShape/projectile_spawn.global_position
			projectile.target = current_enemy
			add_child(projectile)
			last_fire_time = Time.get_ticks_msec()

func _process(delta):
	$dragonShape.scale = Vector3(0.1,0.1,0.1)
	if deleted == true:
		$RangeUpgrade.hide()
		$ExtraReloadUpgrade.hide()
		$ExtraDamageUpgrade.hide()
func _on_attacking_state_state_entered():
	last_fire_time = 0
# upgrade menu
func _on_extra_reload_upgrade_pressed():
	if GameManaging.money >= 100:
		if hit_reload == false:
			if reload_count == 1:
				$ExtraReloadUpgrade.text = "Upgrade Maxed"
			reload_count += 1
			if reload_count == 2:
				hit_reload = true
			GameManaging.money -= 100
			fire_rate_ms -= 250
		else:
			$ExtraReloadUpgrade.text = "Upgrade Maxed"


func _on_extra_damage_upgrade_pressed():
	if GameManaging.money >= 1000:
		GameManaging.money -= 1000
		GameManaging.fire_damage += 20


func _on_range_upgrade_pressed() -> void:
	if GameManaging.money >= 300:
		$RangeUpgrade.text = "Upgrade Maxed"
		if hit_range == false:
			hit_range = true
			GameManaging.money -= 300
			$PatrolZone.scale = Vector3(3,3,3)
		else:
			$RangeUpgrade.text = "Upgrade Maxed"
