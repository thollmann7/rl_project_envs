extends Node

func _ready() -> void:
	var args = Array(OS.get_cmdline_args())
	Global.game_content = Global.GameContent.ALL
	if args.has("-e"):
		Global.game_mode = Global.GameMode.EVAL
		get_tree().change_scene("res://scenes/eval_scene.tscn")
	elif args.has("-c1"):
		Global.game_content = Global.GameContent.TREES_WATER
	elif args.has("-c2"):
		Global.game_content = Global.GameContent.ROADS
	elif args.has("-c3"):
		Global.game_content = Global.GameContent.BRIDGES
	elif args.has("-c4"):
		Global.game_content = Global.GameContent.COINS
	elif args.has("-c5"):
		Global.game_content = Global.GameContent.PLATFORMS
		
	get_tree().change_scene_to_file("res://scenes/training_scene.tscn")
	Global.game_mode = Global.GameMode.EVAL
