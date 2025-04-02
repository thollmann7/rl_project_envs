extends Camera3D

@export var player : Player

@onready var init_position = position
var follow_distance = 3


func _process(delta: float) -> void:
	if abs(player.position.z - position.z) > follow_distance:
		position.z -= 2
		
func reset():
	position = init_position
	
