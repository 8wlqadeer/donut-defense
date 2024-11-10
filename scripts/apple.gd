extends Node3D
var enemies_in_range:Array[Node3D]
var current_enemy:Node3D = null
var acquire_slerp_progress:float = 0
var current_enemy_targetted:bool = false
var last_fire_time: int
var cam: Camera3D
var fire:bool = true
var hit_damage = false
var hit_reload = false
var hit_range = false
var range_count = 0
var reload_count = 0
var deleted = false
@export var fire_rate_ms:int = 10
@export var projectile_type:PackedScene
#same script as watermelon.gd
func _ready():
	cam = get_viewport().get_camera_3d()
	$ExtraDamageUpgrade.hide()
	$ExtraReloadUpgrade.hide()
	$ExtraRangeUpgrade.hide()
var RAYCAST_LENGTH = 1000
func _physics_process(_delta):
	if Input.is_action_just_pressed("delete"):
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
			_on_main_mouse_hit(co)
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
			_on_main_mouse_hit_upgrade(co)
func _on_main_mouse_hit(apple:CollisionObject3D):
	print("raycast  position",apple.global_position )
	if $".".global_position == Vector3(apple.global_position.x, 0.2, apple.global_position.z):
		GameManaging.money += 100
		deleted = true
		$".".visible = false
		fire = false
func _on_main_mouse_hit_upgrade(apple:CollisionObject3D):
	print("raycast  position",apple.global_position )
	if $".".global_position == Vector3(apple.global_position.x, 0.2, apple.global_position.z):
		$ExtraDamageUpgrade.show()
		$ExtraReloadUpgrade.show()
		$ExtraRangeUpgrade.show()
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
				$ExtraRangeUpgrade.hide()
func _on_patrol_zone_area_entered(area):
	if current_enemy == null:
		current_enemy = area
	enemies_in_range.append(area)
	
func _on_patrol_zone_area_exited(area):
	enemies_in_range.erase(area)
func set_patrolling(patrolling: bool):
	$PatrolZone.monitoring = patrolling

func rotate_towards_target(rtarget, delta):
	var target_Vector = $apple.global_position.direction_to(Vector3(rtarget.global_position.x,global_position.y,rtarget.global_position.z))
	var target_basis: Basis = basis.looking_at(target_Vector)
	$apple.basis = $apple.basis.slerp(target_basis, acquire_slerp_progress)
	acquire_slerp_progress += delta
	if acquire_slerp_progress > 1:
		$StateChart.send_event("to_attacking_state")

func _on_patrolling_state_state_processing(delta):
	if enemies_in_range.size() > 0:
		current_enemy = enemies_in_range[0]
		acquire_slerp_progress = 0
		$StateChart.send_event("to_acquiring_state")

func _on_acquiring_state_state_entered():
	current_enemy_targetted = false
	acquire_slerp_progress = 0

func _on_acquiring_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$apple.look_at(current_enemy.global_position)
	else:
		$StateChart.send_event("to_patrolling_state")
	rotate_towards_target(current_enemy,delta)

func _on_attacking_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$apple.look_at(current_enemy.global_position)
		if fire == true:
			_maybe_fire()
	else:
		$StateChart.send_event("to_patrolling_state")
func _maybe_fire():
	if Time.get_ticks_msec()>(last_fire_time+fire_rate_ms):
		var projectile:ToxicProjectile = projectile_type.instantiate()
		projectile.starting_position = $apple/projectile_spawn.global_position
		projectile.target = current_enemy
		add_child(projectile)
		last_fire_time = Time.get_ticks_msec()
		
#for testing, lets us know it is attacking
func _on_attacking_state_state_entered():
	last_fire_time = 0

func _on_extra_damage_upgrade_pressed():
	if GameManaging.money >= 1000:
		GameManaging.money -= 1000
		GameManaging.toxic_damage += 10

func _on_extra_reload_upgrade_pressed():
	if GameManaging.money >= 200:
		if hit_reload == false:
			if reload_count == 1:
				$ExtraReloadUpgrade.text = "Upgrade Maxed"
			reload_count += 1
			if reload_count == 2:
				hit_reload = true
			GameManaging.money -= 200
			fire_rate_ms -= 250
		else:
			$ExtraReloadUpgrade.text = "Upgrade Maxed"

func _on_extra_range_upgrade_pressed():
	if GameManaging.money >= 300:
		$ExtraRangeUpgrade.text = "Upgrade Maxed"
		if hit_range == false:
			hit_range = true
			GameManaging.money -= 300
			$PatrolZone.scale = Vector3(3,3,3)
		else:
			$ExtraRangeUpgrade.text = "Upgrade Maxed"
func _process(delta):
	if deleted == true:
		$ExtraDamageUpgrade.hide()
		$ExtraRangeUpgrade.hide()
		$ExtraReloadUpgrade.hide()
