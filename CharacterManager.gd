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
	players[3].Movement = 10
	
	players[0].HealthPos = Vector2i(40, 300)
	players[1].HealthPos = Vector2i(40, 500)
	players[2].HealthPos = Vector2i(40, 700)

	if players.size() > 0:
		active_player = players[0] # Set the first player as the active one
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
	var current_index = players.find(active_player)

	# Move to the next player, and find the first one with HP > 0
	var found_active_player = false
	var start_index = current_index + 1

	# Loop through players starting from the next one
	while not found_active_player:
		# If we've gone past the end of the list, loop back to the start
		if start_index >= players.size():
			start_index = 0  # Loop back to the first player

		# Check if the player has HP > 0
		if players[start_index].HP > 0:
			active_player = players[start_index]
			found_active_player = true
		else:
			start_index += 1  # Move to the next player

	print(players)
	# Reset the time passed and update camera
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
		camera.position.x = active_player.global_position.x - 150
		camera.position.y = active_player.global_position.y
	background.position = camera.position
