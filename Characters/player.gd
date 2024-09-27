extends CharacterBody2D

var Movement: int = 10  # Max movement range
var HP: int = 100  # Health Points
var Abilities = []
var StartPosition: Vector2i
var HealthPos: Vector2i
var tile_map

var speed: float = 200.0  # Movement speed
var target_position: Vector2 = Vector2()  # Target position for movement
var current_position: Vector2 = Vector2()  # Target position for movement
var is_moving: bool = false  # Track whether the character is moving
var walkable_tiles
var path

@onready var sprite = get_node("Sprite2D")
@onready var health_bar = get_node("CanvasLayer/HealthBar")

func _ready():
	tile_map = get_node("../tile_map")
	global_position = tile_map.map_to_local(StartPosition) # Start at the specified position
	target_position = global_position # Set the initial target to current position
	current_position = StartPosition
	health_bar.init_health(HP, HealthPos)
	

func _physics_process(delta):
	# Check if this player is the active one before allowing movement
	if CharacterManager.time_passed <= 0.05:
		CharacterManager.time_passed += delta
		return

	if CharacterManager.active_player == self:
		MoveMouse()

	# If moving, smoothly move toward the target position
	if is_moving:
		move_toward_target(delta)

func move_toward_target(delta):
	if path.size() == 0:  # If there are no more tiles in the path, exit the function
		return

	# Get the current tile and the next target tile from the path
	var current_tile = tile_map.local_to_map(global_position)
	var next_target_tile = path[0]
	var next_target_position = tile_map.map_to_local(next_target_tile)

	# Check if we have arrived at the next target tile
	if current_tile == next_target_tile:
		# Snap to the target position
		global_position = next_target_position
		path.remove_at(0)  # Remove the reached tile from the path

		# If there are no more tiles in the path, stop moving
		if path.size() == 0:
			is_moving = false
			CharacterManager.switch_to_next_player(next_target_tile)  # Notify that we've reached the final target
	else:
		# Calculate direction and move towards the next target position
		var direction = (next_target_position - global_position).normalized()
		global_position += direction * speed * delta


func MoveMouse():
	if Input.is_action_just_pressed("LeftClick") and not is_moving:
		if tile_map and tile_map.has_method("get_selected_tile"):
			var selected_tile = Vector2i(tile_map.get_selected_tile())

			# Check if the selected tile is in the list of walkable tiles
			if selected_tile in walkable_tiles:
				var clicked_tile_position = tile_map.map_to_local(selected_tile)
				var current_tile = tile_map.local_to_map(global_position)
				
				# Set the target position and begin moving
				target_position = clicked_tile_position
				current_position = current_tile
				path = tile_map.find_path(current_tile, selected_tile, walkable_tiles)
				is_moving = true
				
				# Example of HP reduction, you can change this logic as needed
				HP -= 60
				if HP <= 0:
					sprite.set_frame(2)
				health_bar.health = HP
