extends Camera3D

@export var player : Player

var follow_distance = 15

func _process(delta: float) -> void:
	if abs(player.position.z - position.z) > 5:
		position.z -= 2
