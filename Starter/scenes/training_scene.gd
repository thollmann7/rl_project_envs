extends Node3D

func _ready() -> void:
	var args = Array(OS.get_cmdline_args())
	Global.game_content = Global.GameContent.ALL
	Global.game_mode = Global.GameMode.TRAIN
	if args.has("-e"):
		Global.game_mode = Global.GameMode.EVAL
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
