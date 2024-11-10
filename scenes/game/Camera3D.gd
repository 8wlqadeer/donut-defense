extends Camera3D
@onready var cam = $"."

var melon = preload("res://scenes/game/watermelon.tscn")

var RAYCAST_LENGTH = 1000
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
			#_on_main_mouse_hit(co)
			#
#func _on_main_mouse_hit(watermelon:CollisionObject3D):
	#print("We have position!")

#func _on_main_mouse_hit(watermelon:CollisionObject3D):
	#var instance = melon.instantiate()
	
#func _process(delta):
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#_shoot_ray()
#
#func _shoot_ray():
	#var mouse_pos = get_viewport().get_mouse_position()
	#var ray_length = 1000
	#var from = project_ray_origin(mouse_pos)
	#var to = from + project_ray_normal(mouse_pos)*ray_length
	#var space = get_world_3d().direct_space_state
	#var ray_query = PhysicsRayQueryParameters3D.create(from,to)
	#var raycast_result = space.intersect_ray(ray_query)
	#ray_query.collide_with_areas = true
	#print(raycast_result)
	#var co:CollisionObject3D = raycast_result.get("collider")
	#var instance = melon.instantiate()
	#instance.global_position = raycast_result
	#$"..".add_child(instance)
