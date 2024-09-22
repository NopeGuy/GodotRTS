extends Node

var players = [] # List of playable characters
var alive_characters = [] # List of alive characters
var active_player = null # Reference to the current active player
var time_passed: float = 0
@onready var turn_counter = get_node("/root/Main/Overlay/TurnCounter")

# Use @onready to delay initialization until the scene is ready

func _ready():
	# Initialize the player list by adding the player nodes
	players.append(get_node("/root/Main/Player1"))
	players.append(get_node("/root/Main/Player2"))
	players.append(get_node("/root/Main/Player3"))
	players.append(get_node("/root/Main/Enemy"))
	
	# Assign unique start positions to each player
	players[0].StartPosition = Vector2i(9, 5)
	players[1].StartPosition = Vector2i(5, 5)
	players[2].StartPosition = Vector2i(6, 5)
	players[3].StartPosition = Vector2i(12, 12)

	players[0].Movement = 5
	players[1].Movement = 6 
	players[2].Movement = 7
	players[3].Movement = 5
	
	players[0].HealthPos = Vector2i(40, 200)
	players[1].HealthPos = Vector2i(40, 330)
	players[2].HealthPos = Vector2i(40, 460)
	
	alive_characters = players
	
	# Debugging: Print the list of players to verify initialization
	print(str(alive_characters))

	if alive_characters.size() > 0:
		active_player = alive_characters[0] # Set the first player as the active one
		update_camera()

# Function to switch to the next player in the list
func switch_to_next_player(target_tile):
	# Set the current player's position
	active_player.current_position = target_tile
	
	# Remove players with 0 or less HP from the alive_characters list
	for i in range(alive_characters.size() - 1, -1, -1):  # Iterate backwards
		if alive_characters[i].HP <= 0:
			alive_characters.remove_at(i)

	# Find the index of the current active player
	var current_index = alive_characters.find(active_player)

	# Move to the next player
	current_index += 1

	# If we've gone past the end of the list, loop back to the start
	if current_index >= alive_characters.size():
		current_index = 0  # Loop back to the first player

	# Set the new active player
	if alive_characters.size() > 0:
		active_player = alive_characters[current_index]
	else:
		active_player = null  # No players left

	time_passed = 0
	update_camera()
	turn_counter.update_turn()


# Ensure the global camera follows the current active player
func update_camera():
	var tile_map = get_node("/root/Main/tile_map")
	var background = tile_map.get_node("background")  # Access the "background" child node
	var camera = get_node("/root/Main/Camera2D")
	
	# Update camera position
	if active_player != null:
		camera.position = active_player.global_position
	background.position = camera.position
