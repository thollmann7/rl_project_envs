extends Node3D
class_name Map

@export var tile: PackedScene
@export var car_manager : CarManager

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
var road_rows: Array[Vector2]

const rows_behind_player = 2
const rows_infrontof_player = 6

## Removes all tile nodes on first launch (if any are added in the editor)
## and on subsequent calls, it hides all tiles
func remove_all_tiles():
	for tile in $Tiles.get_children():
		$Tiles.remove_child(tile)
	instantiated_tiles.clear()
	tile_positions.clear()
	road_rows.clear()
	current_furthest_row = 0

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
	instantiated_tiles[grid_position] = new_tile
	tile_positions.append(grid_position)

func _ready():
	set_cells()


func set_cells():
	remove_all_tiles()
	
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange)
	add_special_rows(0)

	
	#add_row(Tile.TileNames.orange)
	#add_row(Tile.TileNames.road)
	#add_row(Tile.TileNames.tree)
	#add_row(Tile.TileNames.coin)
	#add_row(Tile.TileNames.bridge)
	#add_row(Tile.TileNames.water)
	#add_row(Tile.TileNames.door_closed)
	#add_row(Tile.TileNames.door_open)
	set_player_position_to_grid_row(0)
	
func reset():
	if not is_node_ready():
		await ready
	set_cells()

func get_tile(grid_pos: Vector3i):
	if not grid_pos in tile_positions:
		return null
	return instantiated_tiles[grid_pos]

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
		
	if tile == Tile.TileNames.road:
		road_rows.append(Vector2(row, tile_type))
		car_manager.update_cars()

func update_layout(furthest_row_reached):
	# create new rows infront:
	# we add 1, bc "current furthest" actually means "next to be instantiated"
	while current_furthest_row + 1 > furthest_row_reached - rows_infrontof_player:
		add_row(Tile.TileNames.orange)
	# delete rows behind:
	var update_roads = false
	for tile in $Tiles.get_children():
		if tile.position.z / 2 > furthest_row_reached + rows_behind_player:
			if tile.id == int(Tile.TileNames.road):
				update_roads = true
			instantiated_tiles.erase(tile.position)
			tile_positions.erase(tile.position)
			$Tiles.remove_child(tile)
		else:
			break
	if update_roads:
		road_rows.remove_at(0)
		car_manager.update_cars()
		

func add_row(tile: Tile.TileNames, second_tile: Tile.TileNames = Tile.TileNames.orange, second_tile_count: int = 0, tile_type: int = 0):
	set_row_tiles(current_furthest_row, tile, second_tile, second_tile_count, tile_type)
	current_furthest_row -= 1

func set_player_position_to_grid_row(row: int):
	player_start_position = to_global(Vector3i(range(0, grid_size_x - 1, 2).pick_random(), 1.5, row * tile_size))
	
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
	
func add_special_rows(k):
	match k:
		0:
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
		_:
			pass
		

func set_row_tiles_ordered(tiles: Array[Tile.TileNames]):
	var first_tile_columns: Array = range(grid_size_x)
	for column in grid_size_x:
		var tile_grid_coords := Vector3i(column, 0, current_furthest_row)
		create_tile(tiles[column], tile_grid_coords)
	current_furthest_row -= 1
