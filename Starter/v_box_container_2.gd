extends VBoxContainer

@onready var player = $"../../Robot"

func _process(delta: float) -> void:
	$current_row_label.text = str((player.furthest_z_reached * -1) / 2)
