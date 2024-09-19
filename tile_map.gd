extends TileMap

var GridSize = 10
var Dic = {}
var selectedTile = Vector2i()

func _ready():
	for x in range(GridSize):
		for y in range(GridSize):
			Dic[str(Vector2(x, y))] = {
				"Type" : "Grass", # Set type as needed ("Grass", "Water", etc.)
				"Walkable": true,  # Add a walkable property
				"Position" : Vector2(x, y)
			}
			set_cell(1, Vector2i(x, y), 0, Vector2i(7, 3), 0) # Set initial tile on layer 0



func _process(delta):
	var tile = local_to_map(get_global_mouse_position())
	if selectedTile == tile:
		return
	erase_cell(0, selectedTile) # Ensure we use Vector2i for integer values
	selectedTile = tile

	# Set the new tile only if it's within the dictionary
	if Dic.has(str(tile)):
		set_cell(0, tile, 1, Vector2i(0, 0), 0) # Draw the new tile on layer 1
#		print(Dic[str(tile)])

# Return the selected tile position
func get_selected_tile():
	return selectedTile

# Check if the tile is walkable
func is_tile_walkable(tile_pos):
	var tile_key = str(tile_pos)
	if Dic.has(tile_key):
		return Dic[tile_key]["Walkable"] # Return if the tile is walkable
	return false
