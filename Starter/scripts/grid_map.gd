extends Node3D
class_name Map

@export var tile: PackedScene
@export var path_object_manager : PathObjectManager

# Grid positions
var instantiated_tiles: Dictionary
var tile_positions: Array[Vector3i]

var player_start_position: Vector3i
var goal_position: Vector3i

## Size of each tile, adjust manually if using larger or smaller tiles
var tile_size: int = 2

## Determines the width of the grid, tested with 6
## may need adjustments for the AIController obs as it captures
## 6 cells from the left and right of the player
var grid_size_x = 6

## Number of rows in the grid
var current_furthest_row = 0

const rows_behind_player = 2
const rows_infrontof_player = 6

var rng = RandomNumberGenerator.new()

## Removes all tile nodes on first launch (if any are added in the editor)
## and on subsequent calls, it hides all tiles
func remove_all_tiles():
	for tile in $Tiles.get_children():
		$Tiles.remove_child(tile)
	instantiated_tiles.clear()
	tile_positions.clear()
	current_furthest_row = 0
	for child in path_object_manager.get_children():
		child.queue_free()
	path_object_manager.cars.clear()
	path_object_manager.platforms.clear()

## Adds a tile to the grid, takes a scene containing the tile and grid position
func create_tile(tile_name: Tile.TileNames, grid_position: Vector3i, sibling: Tile = null):
	#if instantiated_tiles.has(grid_position):
		#instantiated_tiles[grid_position].set_tile(tile_name)
		#tile_positions.append(grid_position)
		#return

	var new_tile = tile.instantiate() as Tile
	if sibling:
		sibling.add_sibling(new_tile)
		$Tiles.remove_child(sibling)
	else:
		$Tiles.add_child(new_tile)
	new_tile.position = grid_position * tile_size
	new_tile.set_tile(tile_name)
	instantiated_tiles[Vector3i(grid_position)] = new_tile
	if not grid_position in tile_positions:
		tile_positions.append(grid_position)


func set_cells():
	remove_all_tiles()
	
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
	add_row(Tile.TileNames.orange)
	while current_furthest_row >= -rows_infrontof_player:
		create_random_row()
	set_player_position_to_grid_row(0)
	
func reset():
	if not is_node_ready():
		await ready
	set_cells()

func get_tile(grid_pos: Vector3i):
	if not grid_pos in tile_positions:
		return null
	return instantiated_tiles[Vector3i(grid_pos)]

func get_grid_position(global_pos: Vector3i):
	var grid_pos = Vector3i(to_local(global_pos) / 2.0)
	return grid_pos
	
func set_row_tiles(row: int, tile: Tile.TileNames, second_tile: Tile.TileNames = Tile.TileNames.orange, second_tile_count: int = 0, tile_type: int = 0):
	var first_tile_columns: Array = range(grid_size_x)
	 
	if second_tile_count:
		for i in second_tile_count:
			first_tile_columns.remove_at(randi_range(0, first_tile_columns.size() - 1))
	
	for column in range(grid_size_x):
		var tile_to_create: Tile.TileNames
		if column in first_tile_columns:
			tile_to_create = tile
		else:
			tile_to_create = second_tile
		var tile_grid_coords := Vector3i(column, 0, row)
		create_tile(tile_to_create, tile_grid_coords)

func update_layout(furthest_row_reached):
	# create new rows infront:
	# we add 1, bc "current furthest" actually means "next to be instantiated"
	while current_furthest_row + 1 > furthest_row_reached - rows_infrontof_player:
		create_random_row()
	# delete rows behind:
	for tile in $Tiles.get_children():
		if tile.position.z / 2 > furthest_row_reached + rows_behind_player:
			instantiated_tiles.erase(Vector3i(tile.position / 2))
			tile_positions.erase(Vector3i(tile.position / 2))
			$Tiles.remove_child(tile)
		else:
			break
	# delete path_objects that are out of bounds:
	for path_object in path_object_manager.get_children():
		if path_object.remove_on_row_deletion > furthest_row_reached + rows_behind_player:
			path_object_manager.remove_child(path_object)
			path_object_manager.cars.erase(path_object)
			path_object_manager.platforms.erase(path_object)
		
		

func add_row(tile: Tile.TileNames, second_tile: Tile.TileNames = Tile.TileNames.orange, second_tile_count: int = 0, tile_type: int = 0):
	set_row_tiles(current_furthest_row, tile, second_tile, second_tile_count, tile_type)
	current_furthest_row -= 1

func set_player_position_to_grid_row(row: int):
	player_start_position = to_global(Vector3i(rng.randi_range(0, grid_size_x - 1) * 2, 1.5, row * tile_size))
	
func swap_tile(old_tile, new_tile):
	create_tile(new_tile, old_tile.position / 2, old_tile)

func check_doors():
	var first_closed_door = null
	for tile in $Tiles.get_children():
		if tile.id == int(Tile.TileNames.door_closed):
			first_closed_door = tile
			break
	if first_closed_door == null:
		return
	for tile in $Tiles.get_children():
		if tile.id == int(Tile.TileNames.coin):
			if tile.position.z >= first_closed_door.position.z:
				return
	swap_tile(first_closed_door, Tile.TileNames.door_open)
	

func set_row_tiles_ordered(tiles):
	var first_tile_columns: Array = range(grid_size_x)
	for column in grid_size_x:
		var tile_grid_coords := Vector3i(column, 0, current_furthest_row)
		create_tile(tiles[column], tile_grid_coords)
	current_furthest_row -= 1
	
func create_random_row():
	var row_to_create: int
	if current_furthest_row > -20:
		# trees, water-holes and road
		row_to_create = rng.randi_range(0, 4)
	elif current_furthest_row > -40:
		# add maze
		row_to_create = rng.randi_range(0, 5)
	elif current_furthest_row > -60:
		# add coins
		row_to_create = rng.randi_range(0, 7)
	else:
		# add river platform
		row_to_create = rng.randi_range(0, 8)
		
	match row_to_create:
		0: # 2 rows of trees
			add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
			add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
		1: # 2 rows of water-holes
			add_row(Tile.TileNames.orange, Tile.TileNames.water, 2)
			add_row(Tile.TileNames.orange, Tile.TileNames.water, 2)
		2: # create road
			add_special_rows(4)
		3: # create road
			add_special_rows(4)
		4: # 1 row of water with a 1-tile-bridge
			add_row(Tile.TileNames.orange, Tile.TileNames.water, grid_size_x-1)
		5: # maze
			add_special_rows(2)
		6:# coins behind wall
			add_special_rows(0)
		7: # 1-5 coins infront of door
			add_special_rows(1)
		8: # create river with moving platform
			add_special_rows(3)
	add_row(Tile.TileNames.orange)
	
	
func add_special_rows(k):
	match k:
		0: # coins behind wall
			set_row_tiles_ordered([
				Tile.TileNames.orange,
				Tile.TileNames.tree,
				Tile.TileNames.tree,
				Tile.TileNames.tree,
				Tile.TileNames.orange,
				Tile.TileNames.tree,
				])
			set_row_tiles_ordered([
				Tile.TileNames.coin,
				Tile.TileNames.coin,
				Tile.TileNames.coin,
				Tile.TileNames.tree,
				Tile.TileNames.door_closed,
				Tile.TileNames.tree,
				])
			set_row_tiles_ordered([
				Tile.TileNames.tree,
				Tile.TileNames.tree,
				Tile.TileNames.tree,
				Tile.TileNames.tree,
				Tile.TileNames.orange,
				Tile.TileNames.tree,
				])
		1: # 1-5 coins infront of door
			add_row(Tile.TileNames.orange, Tile.TileNames.coin, rng.randi_range(1, grid_size_x))
			add_row(Tile.TileNames.tree, Tile.TileNames.door_closed, 1)
		2: # small maze (between 3 and 7 rows)
			_create_maze(rng.randi_range(2, 4))
		3: # create river with moving platform
			_create_platform(rng.randi_range(0, 2))
		4: # create circular road
			_create_road(rng.randi_range(0, 2))
		_:
			pass

func _create_maze(size: int):
	# size is the number of entrypoints (single-tile-rows).
	# between each two entrypoints there is a bridge, meaning that the total
	# number of rows will be size * 2 - 1
	# minimum size is 2 (= 3 rows)
	if size < 2:
		size = 2
	var entrypoints = []
	for i in size:
		entrypoints.append(rng.randi_range(0, grid_size_x - 1))
	# create entry row
	var previous = null
	for entrypoint in entrypoints:
		if not previous == null:
			var start_point = min(previous, entrypoint)
			var end_point = max(previous, entrypoint)
			var bridge = range(start_point, end_point + 1)
			set_row_tiles_ordered(_create_mixed_row(Tile.TileNames.orange, Tile.TileNames.water, bridge))
		previous = entrypoint
		set_row_tiles_ordered(_create_mixed_row(Tile.TileNames.orange, Tile.TileNames.water, [entrypoint]))
	
func _create_mixed_row(type1 : Tile.TileNames, type2 : Tile.TileNames, type1_indices):
	var tile_array = []
	for i in range(grid_size_x):
			if i in type1_indices:
				tile_array.append(type1)
			else:
				tile_array.append(type2)
	return tile_array
	
func _create_road(type : int):
	match type:
		0: # one road
			_create_path_object(
				0,
				Vector3(0, 0, current_furthest_row * 2),
				Vector3((grid_size_x -1) * 2, 0, current_furthest_row * 2),
			)
			add_row(Tile.TileNames.road)
			
		1: # two roads
			_create_path_object(
				0,
				Vector3(0, 0, current_furthest_row * 2),
				Vector3((grid_size_x - 1) * 2, 0, current_furthest_row * 2),
			)
			add_row(Tile.TileNames.road)
			_create_path_object(
				0,
				Vector3(0, 0, current_furthest_row * 2),
				Vector3((grid_size_x - 1) * 2, 0, current_furthest_row * 2),
			)
			add_row(Tile.TileNames.road)
		2: # move in a circle
			var length = rng.randi_range(1, 3)
			_create_path_object(
				0,
				Vector3(0, 0, current_furthest_row * 2),
				Vector3((grid_size_x - 1) * 2, 0, (current_furthest_row - length - 1) * 2),
			)
			add_row(Tile.TileNames.road2)
			for i in range(length):
				set_row_tiles_ordered(_create_mixed_row(Tile.TileNames.road2, Tile.TileNames.orange, [0, grid_size_x - 1]))
			add_row(Tile.TileNames.road2)
	
func _create_platform(type : int):
	match type:
		0: # move on x axis
			# create water
			var startpoint = rng.randi_range(0, grid_size_x - 1)
			var endpoint = rng.randi_range(0, grid_size_x - 1)
			set_row_tiles_ordered(_create_mixed_row(Tile.TileNames.orange, Tile.TileNames.water, [startpoint]))
			_create_path_object(
				1,
				Vector3(0, 0, current_furthest_row * 2),
				Vector3((grid_size_x - 1) * 2, 0, current_furthest_row * 2),
			)
			add_row(Tile.TileNames.water)
			set_row_tiles_ordered(_create_mixed_row(Tile.TileNames.orange, Tile.TileNames.water, [endpoint]))
		1: # move on z axis
			# create water
			var startpoint = rng.randi_range(0, grid_size_x - 1)
			var length = rng.randi_range(3, 4)
			_create_path_object(
				1,
				Vector3(startpoint * 2, 0, current_furthest_row * 2),
				Vector3(startpoint * 2, 0, (current_furthest_row - (length - 1)) * 2),
			)
			for i in range(length):
				add_row(Tile.TileNames.water)

		2: # move in circle
			# create water
			var startpoint = rng.randi_range(0, grid_size_x - 1)
			var endpoint = rng.randi_range(0, grid_size_x - 1)
			var length = rng.randi_range(2, 3)
			set_row_tiles_ordered(_create_mixed_row(Tile.TileNames.orange, Tile.TileNames.water, [startpoint]))
			_create_path_object(
				1,
				Vector3(startpoint * 2, 0, current_furthest_row * 2),
				Vector3(endpoint * 2, 0, (current_furthest_row - length) * 2),
			)
			for i in range(length):
				add_row(Tile.TileNames.water)
			add_row(Tile.TileNames.water)
			set_row_tiles_ordered(_create_mixed_row(Tile.TileNames.orange, Tile.TileNames.water, [endpoint]))
	
func _create_path_object(type : int, bottomleft : Vector3, topright : Vector3):
	var corners = []
	if bottomleft.x == topright.x or bottomleft.z == topright.z:
		corners = [bottomleft, topright]
	else:
		corners.append(bottomleft)
		# append bottomright
		corners.append(Vector3(topright.x, 0, bottomleft.z))
		corners.append(topright)
		# append topleft
		corners.append(Vector3(bottomleft.x, 0, topright.z))
	path_object_manager.create_path_object(corners, type)
	
func print_map():
	for key in instantiated_tiles.keys():
		print("%s: %s" % [key, instantiated_tiles[key].id])
	print("---")
	for p in tile_positions:
		print(p)
	print("-------------------------------------------")
