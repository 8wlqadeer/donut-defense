extends Node2D
@onready var animated_sprite_2d = $Area2D/AnimatedSprite2D
@onready var area_2d = $Area2D
@onready var tower_1 = $"."
var move = 0
func _process(delta):
	if move == 0:
		area_2d.global_position = get_global_mouse_position()
	
func _input(event):
	if event.is_action_pressed("place"):
		move = 1
	elif event.is_action_pressed("pick"):
		move = 0
func _on_area_2d_mouse_entered():
	animated_sprite_2d.play("attack")

func _on_area_2d_mouse_exited():
	animated_sprite_2d.play("idle")
