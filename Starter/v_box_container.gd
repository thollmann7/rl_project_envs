extends VBoxContainer

@onready var player = $"../../Robot"

func _process(delta: float) -> void:
	$action_1.text = player._ai_controller.last_actions[4]
	$action_2.text = player._ai_controller.last_actions[3]
	$action_3.text = player._ai_controller.last_actions[2]
	$action_4.text = player._ai_controller.last_actions[1]
	$action_5.text = player._ai_controller.last_actions[0]
