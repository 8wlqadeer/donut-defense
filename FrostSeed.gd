extends Area3D
class_name FrostSeed
@onready var basic_enemy = $"."

var starting_position:Vector3
var target:Node3D
@export var damage:int = 3
@export var speed:float = 2
var lerp_pos:float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = starting_position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		global_position = starting_position.lerp(target.global_position, lerp_pos)
		lerp_pos += delta * speed
	if target == null and lerp_pos < 1:
		queue_free()

func _on_area_exited(area):
	await get_tree().create_timer(0.5).timeout
	queue_free()
