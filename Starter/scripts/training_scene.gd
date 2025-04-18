extends Node3D

@export var scene_count = 1
@export var game_scene : PackedScene

func _ready() -> void:
	var args = Array(OS.get_cmdline_args())
	
	Global.game_mode = Global.GameMode.EVAL if args.has("--eval=True") else Global.GameMode.TRAIN

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
	else:
		Global.game_content = Global.GameContent.ALL
	
	if args.has("--one_scn=True"):
		scene_count = 1
	
	for i in range(scene_count):
		var scene_instance = game_scene.instantiate()
		scene_instance.position = Vector3(i * 50, 0, 0)
		add_child(scene_instance)
