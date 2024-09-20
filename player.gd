extends CharacterBody2D

var Movement: int = 10  # Max movement range
var Abilities = [] # or a dictionary, depending on your needs
var StartPosition: Vector2i
var tile_map

var speed: float = 200.0  # Movement speed
var target_position: Vector2 = Vector2()  # Target position for movement
var is_moving: bool = false  # Track whether the character is moving

@onready var turn_counter = get_node("/root/Main/TurnCounter")

func _ready():
	tile_map = get_node("../tile_map")
	CharacterManager.update_camera()
	global_position = tile_map.map_to_local(StartPosition) # Start at the specified position
	target_position = global_position # Set the initial target to current position
	print(CharacterManager.active_player)

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
	# Move smoothly toward the target position
	var current_tile = tile_map.local_to_map(global_position)
	var target_tile = tile_map.local_to_map(target_position)
	var target_tile_x = Vector2i(target_tile.x, current_tile.y)
	var target_position_x = tile_map.map_to_local(target_tile_x)
	
	# Set the TurnCounter to be invisible at the beginning
	turn_counter.visible = false

	# Check if we have arrived at the target tile (using map coordinates)
	if current_tile == target_tile:
		# Snap to the target position and stop moving
		global_position = target_position
		is_moving = false
		CharacterManager.switch_to_next_player()
	elif current_tile.x != target_tile_x.x:
		# Interpolate position towards the target
		var direction = (target_position_x - global_position).normalized()
		global_position += direction * speed * delta
	else:
		# Interpolate position towards the target
		var direction = (target_position - global_position).normalized()
		global_position += direction * speed * delta

func MoveMouse():
	if Input.is_action_just_pressed("LeftClick") and not is_moving:
		if tile_map and tile_map.has_method("get_selected_tile"):
			var selected_tile = Vector2i(tile_map.get_selected_tile())

			# Convert the selected tile to local space and check walkability
			if tile_map.is_tile_walkable(selected_tile):
				var clicked_tile_position = tile_map.map_to_local(selected_tile)
				var current_tile = tile_map.local_to_map(global_position)
				var distance_to_tile = abs(selected_tile.x - current_tile.x) + abs(selected_tile.y - current_tile.y)
				# Check if the distance is within the allowed movement range
				if distance_to_tile <= Movement:
					# Set the target position and begin moving
					target_position = clicked_tile_position
					is_moving = true
