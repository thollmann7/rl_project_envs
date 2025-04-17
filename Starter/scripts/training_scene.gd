extends Node3D

@export var game_mode = Global.GameMode.TRAIN
@export var scene_count = 1

func _ready() -> void:
	Global.game_mode = game_mode
	var args = Array(OS.get_cmdline_args())
	Global.game_content = Global.GameContent.ALL
	if args.has("--c1=True"):
		Global.game_content = Global.GameContent.TREES_WATER
	elif args.has("--c2=True"):
		Global.game_content = Global.GameContent.ROADS
	elif args.has("--c3=True"):
		Global.game_content = Global.GameContent.BRIDGES
	elif args.has("--c4=True"):
		Global.game_content = Global.GameContent.COINS
	elif args.has("--c5=True"):
		Global.game_content = Global.GameContent.PLATFORMS
		
	
	var game_scene = load("res://scenes/game_scene.tscn")
	
	for i in scene_count:
		var scene_instance = game_scene.instantiate()
		add_child(scene_instance)
		scene_instance.position = Vector3(i * 50, 0, 0)
		
	
