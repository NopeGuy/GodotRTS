extends CharacterBody2D

var Movement: int
var Abilities = [] # or a dictionary, depending on your needs
var StartPosition:Vector2i
var tile_map

func _ready():
	tile_map = get_node("../tile_map")
	CharacterManager.update_camera()
	global_position = tile_map.map_to_local(StartPosition) # Use Vector2 if needed
	print(CharacterManager.active_player)

func _physics_process(delta):
	# Check if this player is the active one before allowing movement
	if CharacterManager.time_passed <= 0.05:
		CharacterManager.time_passed += delta
		return

	if CharacterManager.active_player == self:
		MoveMouse()

func MoveMouse():
	if Input.is_action_just_pressed("LeftClick"):
		if tile_map and tile_map.has_method("get_selected_tile"):
			var selected_tile = Vector2i(tile_map.get_selected_tile())

			# Check if the tile is walkable
			Movement = 5
			
			# Convert the current global position back to tile map coordinates
			var current_tile = tile_map.local_to_map(global_position)
			print("Current Tile (Grid):", current_tile)

			# Calculate the distance from the current position to the clicked tile
			var distance_to_tile = abs(selected_tile.x - current_tile.x) + abs(selected_tile.y - current_tile.y)
			print("Distance to Tile:", distance_to_tile)

			# Check if the tile is walkable and if the distance is within movement range
			if tile_map.is_tile_walkable(selected_tile) and distance_to_tile <= Movement:
				global_position = tile_map.map_to_local(selected_tile)  # Move to the clicked tile position
				CharacterManager.switch_to_next_player()
