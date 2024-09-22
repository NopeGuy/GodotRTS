extends TileMap

var GridSize = 20
var Dic = {}
var selectedTile = Vector2i()
var previous_active_player = null  # Variable to track the previous active player

func _ready():
	for x in range(GridSize):
		for y in range(GridSize):
			# Check if we are on the outer rim (edges of the grid)
			var is_outer_rim = (x == 0 or y == 0 or x == GridSize - 1 or y == GridSize - 1)
			# Check if we are on the semi-outer rim (1 level inner from the edges)
			var is_semi_outer_rim = (x == 1 or y == 1 or x == GridSize - 2 or y == GridSize - 2)
			# Check if we are on the inner rim (2 levels inner from the edges)
			var is_inner_rim = (x == 2 or y == 2 or x == GridSize - 3 or y == GridSize - 3)
			
			# Outer rim: Fill with water
			if is_outer_rim:
				Dic[str(Vector2(x, y))] = {
					"Type": "Water",
					"Walkable": false,  # Water is not walkable
					"Position": Vector2(x, y)
				}
				set_cell(0, Vector2i(x, y), 0, Vector2i(6, 8), 0)  # Set water tile on layer 1
			
			# Semi-outer rim: Place statues every 2 blocks
			elif is_semi_outer_rim:
					# Fill remaining with water if not placing statues
					Dic[str(Vector2(x, y))] = {
						"Type": "Water",
						"Walkable": false,  # Water is not walkable
						"Position": Vector2(x, y)
					}
					set_cell(0, Vector2i(x, y), 0, Vector2i(6, 8), 0)
			
			# Inner rim: Fill with stone
			elif is_inner_rim:
				Dic[str(Vector2(x, y))] = {
					"Type": "Stone",
					"Walkable": true,  # Stone is walkable
					"Position": Vector2(x, y)
				}
				set_cell(0, Vector2i(x, y), 0, Vector2i(4, 6), 0)
		
			elif (x == 7 and y == 7):
				Dic[str(Vector2(x, y))] = {
					"Type": "Statue",
					"Walkable": false,  # Statues are not walkable
					"Position": Vector2(x, y)
				}
				# Stone
				set_cell(0, Vector2i(x, y), 0, Vector2i(3, 6), 0)
				# Statue
				set_cell(3, Vector2i(x, y), 0, Vector2i(10, 8), 0)
			# Rest of the grid: Fill with grass
			else:
				Dic[str(Vector2(x, y))] = {
					"Type": "Grass",
					"Walkable": true,  # Grass is walkable
					"Position": Vector2(x, y)
				}
				set_cell(0, Vector2i(x, y), 0, Vector2i(7, 3), 0)
				if ((x == 5 and y == 7) or (x == 9 and y == 4)):
					Dic[str(Vector2(x, y))] = {
						"Type": "Tree",
						"Walkable": false,  # Statues are not walkable
						"Position": Vector2(x, y)
					}
					set_cell(3, Vector2i(x, y), 2, Vector2i(4, 4), 0)
					
				if (x == 5 and y == 8):
					Dic[str(Vector2(x, y))] = {
						"Type": "Block",
						"Walkable": false,  # Statues are not walkable
						"Position": Vector2(x, y)
					}
					set_cell(3, Vector2i(x, y), 4, Vector2i(0, 0), 0)

func _process(delta):
	var tile = local_to_map(get_global_mouse_position())
	
	# Check if the active player has changed
#	if CharacterManager.active_player != previous_active_player:
#		# Update the currentCharTile when the active player changes
#		clear_movement_tiles()
#		previous_active_player = CharacterManager.active_player  # Update the previous active player
#		show_movement_tiles()

	clear_movement_tiles()
	show_movement_tiles()
	
	# Only proceed if the selectedTile is different from the hovered tile
	if selectedTile == tile:
		return
	
	# Erase the previously highlighted tile
	erase_cell(1, selectedTile)
	
	# Set the new selectedTile to the currently hovered tile
	selectedTile = tile
	
	# Highlight the new tile if it's in the dictionary
	if Dic.has(str(tile)):
		set_cell(1, tile, 3, Vector2i(0, 0), 0)
		
	
var highlighted_tiles = []  # Keep track of highlighted tiles

func clear_movement_tiles():
	# Clear only the previously highlighted tiles
	for tile in highlighted_tiles:
		erase_cell(4, tile)  # Clear the highlighted tile layer
	highlighted_tiles.clear()  # Clear the list after erasing

func show_movement_tiles():
	if CharacterManager.active_player != null:
		# Get the movement range of the active player
		var movement_range = CharacterManager.active_player.Movement 
		var current_position = CharacterManager.active_player.current_position
		
		# Highlight the movement tiles based on the movement range
		for dx in range(-movement_range, movement_range + 1):
			for dy in range(-movement_range, movement_range + 1):
				var target_tile = Vector2i(current_position) + Vector2i(dx, dy)
				if (abs(dx) + abs(dy)) <= movement_range:  # Check if within the movement range
					if is_tile_walkable(target_tile):
						set_cell(4, target_tile, 5, Vector2i(0, 0), 0)  # Highlight the tile
						highlighted_tiles.append(target_tile)  # Track the highlighted tile



# Return the selected tile position
func get_selected_tile():
	return selectedTile

# Check if the tile is walkable
func is_tile_walkable(tile_pos):
	var tile_key = str(tile_pos)
	if Dic.has(tile_key):
		for character in CharacterManager.alive_characters:
			if Vector2i(character.current_position) == tile_pos:
				return false  # Tile is occupied by another character
		return Dic[tile_key]["Walkable"]  # Tile is unoccupied
	return false
