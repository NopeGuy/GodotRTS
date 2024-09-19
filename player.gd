extends CharacterBody2D

var Movement: int
var Abilities = [] # or a dictionary, depending on your needs
var tile_map

func _ready():
	tile_map = get_node("../tile_map")
	CharacterManager.update_camera()
	global_position = tile_map.map_to_local(Vector2i(5, 5)) # Use Vector2 if needed
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
			if tile_map.is_tile_walkable(selected_tile):
				global_position = tile_map.map_to_local(selected_tile) # Convert tile to world position
				CharacterManager.switch_to_next_player()
