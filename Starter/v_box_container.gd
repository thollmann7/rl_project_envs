extends VBoxContainer

@onready var player = $"../../Robot"

@onready var buttons = {
	1 : $HBoxContainer/panel_up,
	2 : $HBoxContainer2/panel_left,
	3 : $HBoxContainer2/panel_down,
	4 : $HBoxContainer2/panel_right,
}

var old_action = 0


func _process(delta: float) -> void:
	var new_action = player._ai_controller.last_action
	if new_action != old_action:
		if old_action != 0:
			buttons[old_action].set_filled(false)
		old_action = new_action
		if new_action != 0:
			buttons[new_action].set_filled(true)
