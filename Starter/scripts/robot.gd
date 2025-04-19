extends Node3D
class_name Player

## Whether to print the game success/failed messsages to console
@export var print_game_status_enabled: bool

## How far the robot can move per step
@export var movement_step := 2.0

@export var map: Map
@export var camera: Camera3D
@export var path_object_manager : PathObjectManager

@onready var _ai_controller := $AIController3D
@onready var visual_robot: Node3D = $robot

var furthest_z_reached = 0
@export var max_steps_without_progress = 200
var current_steps_without_progress = 0

var on_platform = null

#region Set by AIController
var requested_movement: Vector3
#endregion


func _ready():
	reset()

func _physics_process(delta):
	# reward of -1 per step
	if Global.game_mode == Global.GameMode.TRAIN:
		_ai_controller.reward -= 1
	# negative, bc we go towards negative zw
	if position.z < furthest_z_reached:
		furthest_z_reached = position.z
		# reward of +10 per new row
		if Global.game_mode == Global.GameMode.TRAIN:
			_ai_controller.reward += 20
		else:
			_ai_controller.reward += 1
		map.update_layout(furthest_z_reached / 2)
		current_steps_without_progress = 0
	else:
		if Global.game_mode == Global.GameMode.EVAL:
			current_steps_without_progress += 1
	if current_steps_without_progress > max_steps_without_progress:
		game_over(0)
	if _ai_controller.needs_reset:
		game_over(0)
	_process_movement(delta)


func _process_movement(_delta):
	for car in path_object_manager.cars:
		if get_grid_position() == map.get_grid_position(car.global_position):
			# If a car has moved to the current player position, end episode
			game_over()

	if requested_movement:
		var delayed_platform_reward = 0
		if map.instantiated_tiles.size() != map.tile_positions.size():
			map.print_map()
		# Move the robot to the requested position
		global_position += (requested_movement * movement_step)
		# Update the visual rotation of the robot to look toward the direction of last requested movement
		visual_robot.global_rotation_degrees.y = rad_to_deg(atan2(-requested_movement.x, -requested_movement.z))
		
		var grid_position: Vector3i = get_grid_position()
		var tile: Tile = map.get_tile(grid_position)
				
		if not tile:
			# Push the robot back if there's no tile to move to (out of map boundary)
			global_position -= (requested_movement * movement_step)
		else:
			# queue a reward for stepping off of a platform onto a tile.
			# does NOT get paid if robot steps into water
			if not on_platform == null:
				on_platform = null
				for platform in path_object_manager.platforms:
					if platform.position.z > global_position.z:
						delayed_platform_reward = 50
			match tile.id:
				tile.TileNames.tree:
					# Push the robot back if it has moved to a tree tile
					global_position -= (requested_movement * movement_step)
				tile.TileNames.door_closed:
					# Push the robot back if it has moved to a closed_door tile
					global_position -= (requested_movement * movement_step)
				tile.TileNames.water:
					for platform in path_object_manager.platforms:
						if tile.position == platform.position:
							on_platform = platform
							platform.waiting = false
							# reward for stepping onto platform
							if Global.game_mode == Global.GameMode.TRAIN:
								_ai_controller.reward += 100
							break
						else:
							on_platform = null
					# die if step in water
					if on_platform == null:
						# punish for stepping into water
						delayed_platform_reward = 0
						if Global.game_mode == Global.GameMode.TRAIN:
							_ai_controller.reward -= 50
						game_over()
				tile.TileNames.coin:
					# change coin to orange tile
					map.swap_tile(tile, Tile.TileNames.orange)
					map.check_doors()
				_:
					for car in path_object_manager.cars:
						if get_grid_position() == map.get_grid_position(car.global_position):
							# If the robot moved to a car's current position, end episode
							game_over()
							
		if Global.game_mode == Global.GameMode.TRAIN:
			_ai_controller.reward += delayed_platform_reward

		# After processing the move, zero the movement for the next step
		# (only in case of human control)
		if _ai_controller.control_mode == AIController3D.ControlModes.HUMAN:
			requested_movement = Vector3.ZERO 
	else:
		if not on_platform == null:
			global_position.x = on_platform.position.x
			global_position.z = on_platform.position.z




func get_grid_position() -> Vector3i:
	return map.get_grid_position(global_position)

func game_over(reward = 0.0):
	_ai_controller.done = true
	_ai_controller.reward += reward
	_ai_controller.reset()
	reset()

func reset():
	current_steps_without_progress = 0
	furthest_z_reached = 0
	# Order of resetting is important:
	# We reset the map first, which sets a new player start position
	# and the road segments (needed to know where to spawn the cars)
	map.reset()
	# after that, we can set the player position
	global_position = Vector3(map.player_start_position)
	# reset camera to initial position
	camera.reset()
	_ai_controller.last_observations = null

func print_game_status(message: String):
	if print_game_status_enabled:
		print(message)
