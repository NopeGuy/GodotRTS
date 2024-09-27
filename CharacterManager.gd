extends Node

var characters = [] # List of playable characters
var dead = [] # List of playable characters
var active_player = null # Reference to the current active player
var time_passed: float = 0
@onready var turn_counter = get_node("/root/Main/Overlay/Canvas/TurnCounter")
@onready var tile_map = get_node("/root/Main/tile_map")


func _ready():
	# Initialize the player list by adding the player nodes
	characters.append(get_node("/root/Main/Enemy"))
	characters.append(get_node("/root/Main/Player1"))
	characters.append(get_node("/root/Main/Player2"))
	characters.append(get_node("/root/Main/Player3"))
	
	# Assign unique start positions to each player
	characters[0].StartPosition = Vector2i(12, 12)
	characters[1].StartPosition = Vector2i(5, 5)
	characters[2].StartPosition = Vector2i(6, 5)
	characters[3].StartPosition = Vector2i(9, 5)

	characters[0].Movement = 10
	characters[1].Movement = 6 
	characters[2].Movement = 7
	characters[3].Movement = 5
	
	characters[1].HealthPos = Vector2i(35, 405)
	characters[2].HealthPos = Vector2i(35, 692)
	characters[3].HealthPos = Vector2i(35, 979)
	
	
	for player in characters:
		player.walkable_tiles = tile_map.is_tile_walkable(player.current_position, player.Movement)

	await get_tree().create_timer(0.001).timeout
	
	if characters.size() > 0:
		active_player = characters[0]
		switch_to_next_player(characters[0].current_position)

func shift_list(list):
		var first_player = list.pop_front()
		list.append(first_player)
		return list

# Function to switch to the next player in the list
func switch_to_next_player(target_tile):
	# Set the current player's position
	active_player.current_position = target_tile

	
	# Check if any characters are alive
	if characters.size() == 0:
		print("No characters left to switch to!")
		return
		
	shift_list(characters)
	
	var counter = 0

	for player in characters:
		counter+=1
		active_player = characters[0]
		if active_player.HP <= 0:
			shift_list(characters)
			if characters.size() == counter:
				print("No characters left to switch to!")
				return
		
	active_player = characters[0]  # The first player is always the active player
	active_player.walkable_tiles = tile_map.is_tile_walkable(active_player.current_position, active_player.Movement)
	
	# Update the turn counter
	turn_counter.update_turn_order()

	# Sync camera position to the active player
	var background = tile_map.get_node("background")  # Access the "background" child node
	var camera = get_node("/root/Main/Camera2D")

	if active_player != null:
		camera.position.x = active_player.global_position.x - 50
		camera.position.y = active_player.global_position.y - 30

	tile_map.clear_movement_tiles()
	tile_map.show_movement_tiles()
