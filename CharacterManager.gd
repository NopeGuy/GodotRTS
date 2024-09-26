extends Node

var players = [] # List of playable characters
var alive_characters = [] # List of alive characters
var active_player = null # Reference to the current active player
var time_passed: float = 0
@onready var turn_counter = get_node("/root/Main/Overlay/TurnCounter")
@onready var tile_map = get_node("/root/Main/tile_map")


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
	
	
	for player in players:
		player.walkable_tiles = tile_map.is_tile_walkable(player.current_position, player.Movement)

	await get_tree().create_timer(0.1).timeout
	
	 # Add all alive players to alive_characters
	alive_characters = players.filter(func(p): return p.HP > 0)
	if players.size() > 0:
		active_player = players[players.size() - 1] # Set the last player as active
		switch_to_next_player(players[players.size() - 1].current_position)

# Function to switch to the next player in the list
func switch_to_next_player(target_tile):
	# Set the current player's position
	active_player.current_position = target_tile

	# Remove players with 0 or less HP from the alive_characters list
	alive_characters = alive_characters.filter(func(p): return p.HP > 0)

	# Find the index of the current active player
	var current_index = players.find(active_player)

	# Move to the next player, and find the first one that is still alive
	current_index = (current_index + 1) % players.size()
	while players[current_index].HP <= 0:
		current_index = (current_index + 1) % players.size()

	# Set the next active player
	active_player = players[current_index]

	# Update the turn counter
	turn_counter.update_turn_order()

	# Sync camera position to the active player
	var background = tile_map.get_node("background") # Access the "background" child node
	var camera = get_node("/root/Main/Camera2D")

	
	if active_player != null:
		camera.position.x = active_player.global_position.x - 150
		camera.position.y = active_player.global_position.y
	background.position = camera.position

	tile_map.clear_movement_tiles()
	tile_map.show_movement_tiles()
