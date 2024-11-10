extends Area3D
class_name Seed
@onready var basic_enemy = $"."
var starting_position:Vector3
var target:Node3D
var damage:int
@export var speed:float = 2
var lerp_pos:float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = starting_position
	await get_tree().create_timer(1).timeout
	print("deleted")
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	damage = GameManaging.seed_damage
	if target != null:
		global_position = starting_position.lerp(target.global_position, lerp_pos)
		lerp_pos += delta * speed
	if target == null and lerp_pos < 1:
		queue_free()

func _on_area_exited(area):
	await get_tree().create_timer(0.5).timeout
	print("deleted")
	queue_free()
