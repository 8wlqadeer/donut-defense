extends Button
# sets up variables
@export var button_icon:Texture2D
@export var button_object:PackedScene
#gets reference
@onready var no_money = $"../NoMoney"


var cam:Camera3D
var action_object:Node

var RAYCAST_LENGTH:int = 100

var placed:bool = false
var _is_dragging:bool = false
var _is_valid_location:bool = false
var _last_valid_location:Vector3
var _drag_alpha:float = 0.5

@onready var error_mat:BaseMaterial3D = preload("res://assets/red_transparent.material")

# Called when the node enters the scene tree for the first time.
func _ready():
	#sets up the scene
	no_money.visible = false
	icon = button_icon
	action_object = button_object.instantiate()
	action_object.set_patrolling(false)
	add_child(action_object)
	action_object.visible = false
	cam = get_viewport().get_camera_3d()

#raycast code
func _physics_process(_delta): #fires a ray to nearest objects to get information from it e.g colliders, whether its 3d , its position , colour
	if _is_dragging and GameManaging.money >= 100: #dragging character and money greater than 100
		var space_state = action_object.get_world_3d().direct_space_state #creates world which raycast can exist in
		var mouse_pos:Vector2 = get_viewport().get_mouse_position() #gets position of mouse , vector 2 tells you it is 2 dimension
		var origin:Vector3 = cam.project_ray_origin(mouse_pos)  # tells ray where its firing from or where ray starts in this case the mouse pointer
		var end:Vector3 = origin + cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH # where ray ends (origin) , cam is a camera. RAYCAST length is 1000 pixels, declared earlier
		var query = PhysicsRayQueryParameters3D.create(origin, end) #quesry is actual ray itself , this creates ray
		query.collide_with_areas = true #can collide with area 3ds so it does not go through them but just touches
		var rayResult:Dictionary = space_state.intersect_ray(query) #store ray results
		if rayResult.size() > 0:
			var co:CollisionObject3D = rayResult.get("collider") # gets collider of thing it touches - tells you what the object is
			_on_main_mouse_hit(co)
		else:
			action_object.visible = false # sets action object to false (hides object) = off the grid
			_is_valid_location = false #cannot be placed here
#checks if another tower placed on tile already
func set_child_mesh_alphas(n:Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			set_mesh_alpha(c)
		
		if c is Node and c.get_child_count() > 0:
			set_child_mesh_alphas(c)
# changes colour to red
func set_mesh_alpha(mesh_3d:MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, mesh_3d.mesh.surface_get_material(si).duplicate(true))
		mesh_3d.get_surface_override_material(si).transparency = 1
		mesh_3d.get_surface_override_material(si).albedo_color.a = _drag_alpha
#testing code
#		mesh_3d.mesh.surface_set_material(si, mesh_3d.mesh.surface_get_material(si).duplicate())
#		mesh_3d.mesh.surface_get_material(si).transparency = 1 # 1 = TRANSPARENCY_ALPHA
#		mesh_3d.mesh.surface_get_material(si).albedo_color.a = alpha
# displays colour red
func set_child_mesh_error(n:Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			set_mesh_error(c)
		
		if c is Node and c.get_child_count() > 0:
			set_child_mesh_error(c)
# sets colour to red if placing on a bad tile
func set_mesh_error(mesh_3d:MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, error_mat)
# changing material back
func clear_material_overrides(n:Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			clear_material_override(c)
		
		if c is Node and c.get_child_count() > 0:
			clear_material_overrides(c)
# changing material back
func clear_material_override(mesh_3d:MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, null)
#checks if can be placed on tiles (can only be placed on empty tiles)
func _on_main_mouse_hit(tile:CollisionObject3D):
	action_object.visible = true
	
	if tile.get_groups()[0].begins_with("grid_empty"): # only tile that it can be placed on
		set_child_mesh_alphas(action_object) #removes red colour (when its not on a good tile it is red)
		action_object.global_position = Vector3(tile.global_position.x, 0.2, tile.global_position.z) #tiles are not on 0 but on 0.2 so need same x and z, y goes up to 0.2.
		_last_valid_location = action_object.global_position # cannot place multiple on same tile
		_is_valid_location = true
	else:
		set_child_mesh_error(action_object) #otherwise sets colour to red as it should not be on that tile
		action_object.global_position = Vector3(tile.global_position.x, 0.2, tile.global_position.z)
		_is_valid_location = false
# when the button is presses, tower is placed
func _on_button_down():
	_is_dragging = true
	_is_valid_location = false
# when the button is up, lose money and sets tile to invalid and places tower
func _on_button_up():
	if GameManaging.money >= 100 and _is_valid_location == true:
		GameManaging.money -= 100
		
		no_money.visible = false
		placed = true
	elif _is_valid_location == false:
		action_object.visible = false
	else:
		no_money.text = "Not enough money, need " + str(100 - GameManaging.money)+ " more to buy"
		no_money.visible = true
		await get_tree().create_timer(2).timeout
		no_money.visible = false
		
	_is_dragging = false
	action_object.visible = false
	
	if _is_valid_location:
		var new_object:Node3D = button_object.instantiate()
		get_viewport().add_child(new_object)
		new_object.global_position = _last_valid_location
#		set_child_mesh_alphas(action_object, 1)
