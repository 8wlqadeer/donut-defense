extends ProgressBar
@onready var basic_enemy = $"../.."

@onready var progress_bar = $"."


# Called when the node enters the scene tree for the first time.
func _ready():
	progress_bar.value = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress_bar.value = basic_enemy.enemy_health
