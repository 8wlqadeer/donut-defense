extends Label

@onready var health = $"."

# Called every frame. 'delta' is the elapsed time since the previous frame.
#Displays health
func _process(delta):
	health.text = "Health: " + str(GameManaging.health)
