extends Node

var players = [] # List of playable characters
var active_player = null # Reference to the current active player
var time_passed: float = 0
@onready var turn_counter = get_node("/root/Main/TurnCounter")

# Use @onready to delay initialization until the scene is ready

func _ready():
	# Initialize the player list by adding the player nodes
	players.append(get_node("/root/Main/Player1"))
	players.append(get_node("/root/Main/Player2"))
	
	# Assign unique start positions to each player
	players[0].StartPosition = Vector2i(9, 5)  # Example: Player 1 starts at tile (0, 0)
	players[1].StartPosition = Vector2i(5, 5)  # Example: Player 2 starts at tile (5, 5)

	# Debugging: Print the list of players to verify initialization
	print(str(players))

	if players.size() > 0:
		active_player = players[0] # Set the first player as the active one
		update_camera()

# Function to switch to the next player in the list
func switch_to_next_player(target_tile):
	var current_index = players.find(active_player)
	active_player.current_position = target_tile
	current_index += 1

	if current_index >= players.size():
		current_index = 0 # Loop back to the first player

	active_player = players[current_index]
	time_passed = 0
	update_camera()
	turn_counter.update_turn()

# Ensure the global camera follows the current active player
func update_camera():
	var tile_map = get_node("/root/Main/tile_map")
	var background = tile_map.get_node("background")  # Access the "background" child node
	var camera = get_node("/root/Main/Camera2D")
	
	# Update camera position
	camera.position = active_player.global_position
	turn_counter.position = active_player.global_position  # Update TurnCounter position to match player
	background.position = camera.position
	
	# Make the TurnCounter visible again after updating the camera
	turn_counter.visible = true
