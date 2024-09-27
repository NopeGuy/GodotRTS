extends TileMap

var GridSize = 20
var Dic = {}
var selectedTile = Vector2i()
var previous_active_pos = Vector2i()  # Variable to track the previous active player

func _ready():
	for x in range(GridSize):
		for y in range(GridSize):
			# Check if we are on the outer rim (edges of the grid)
			var is_outer_rim = (x == 0 or y == 0 or x == GridSize - 1 or y == GridSize - 1)
			# Check if we are on the semi-outer rim (1 level inner from the edges)
			var is_semi_outer_rim = (x == 1 or y == 1 or x == GridSize - 2 or y == GridSize - 2)
			# Check if we are on the inner rim (2 levels inner from the edges)
			var is_inner_rim = (x == 2 or y == 2 or x == GridSize - 3 or y == GridSize - 3)
			
			# Outer rim: Fill with water
			if is_outer_rim:
				Dic[str(Vector2(x, y))] = {
					"Type": "Water",
					"Walkable": false,  # Water is not walkable
					"Position": Vector2(x, y)
				}
				set_cell(0, Vector2i(x, y), 0, Vector2i(6, 8), 0)  # Set water tile on layer 1
			
			# Semi-outer rim: Place statues every 2 blocks
			elif is_semi_outer_rim:
					# Fill remaining with water if not placing statues
					Dic[str(Vector2(x, y))] = {
						"Type": "Water",
						"Walkable": false,  # Water is not walkable
						"Position": Vector2(x, y)
					}
					set_cell(0, Vector2i(x, y), 0, Vector2i(6, 8), 0)
			
			# Inner rim: Fill with stone
			elif is_inner_rim:
				Dic[str(Vector2(x, y))] = {
					"Type": "Stone",
					"Walkable": true,  # Stone is walkable
					"Position": Vector2(x, y)
				}
				set_cell(0, Vector2i(x, y), 0, Vector2i(4, 6), 0)
		
			elif (x == 7 and y == 7):
				Dic[str(Vector2(x, y))] = {
					"Type": "Statue",
					"Walkable": false,  # Statues are not walkable
					"Position": Vector2(x, y)
				}
				# Stone
				set_cell(0, Vector2i(x, y), 0, Vector2i(3, 6), 0)
				# Statue
				set_cell(3, Vector2i(x, y), 0, Vector2i(10, 8), 0)
			# Rest of the grid: Fill with grass
			else:
				Dic[str(Vector2(x, y))] = {
					"Type": "Grass",
					"Walkable": true,  # Grass is walkable
					"Position": Vector2(x, y)
				}
				set_cell(0, Vector2i(x, y), 0, Vector2i(7, 3), 0)
				if ((x == 5 and y == 7) or (x == 6 and y == 7) or (x == 4 and y == 7)):
					Dic[str(Vector2(x, y))] = {
						"Type": "Tree",
						"Walkable": false,  # Statues are not walkable
						"Position": Vector2(x, y)
					}
					set_cell(3, Vector2i(x, y), 2, Vector2i(4, 4), 0)
					
				if (x == 5 and y == 8):
					Dic[str(Vector2(x, y))] = {
						"Type": "Block",
						"Walkable": false,  # Statues are not walkable
						"Position": Vector2(x, y)
					}
					set_cell(3, Vector2i(x, y), 4, Vector2i(0, 0), 0)

func _process(delta):
	var tile = local_to_map(get_global_mouse_position())
	
	# Only proceed if the selectedTile is different from the hovered tile
	if selectedTile == tile:
		return
	
	# Erase the previously highlighted tile
	erase_cell(1, selectedTile)
	
	# Set the new selectedTile to the currently hovered tile
	selectedTile = tile
	
	# Highlight the new tile if it's in the dictionary
	if Dic.has(str(tile)):
		set_cell(1, tile, 3, Vector2i(0, 0), 0)
		
	
var highlighted_tiles = []  # Keep track of highlighted tiles

func clear_movement_tiles():
	# Clear only the previously highlighted tiles
	for tile in highlighted_tiles:
		erase_cell(4, tile)  # Clear the highlighted tile layer
	highlighted_tiles.clear()  # Clear the list after erasing
	erase_cell(4, previous_active_pos)  # Clear the highlighted tile layer

func show_movement_tiles():
	if CharacterManager.active_player != null:
		# Get the movement range and current position of the active player
		var walkable_tiles = CharacterManager.active_player.walkable_tiles
		var current_position = CharacterManager.active_player.current_position
		
		# Highlight each walkable tile
		for tile in walkable_tiles:
			set_cell(4, tile, 5, Vector2i(0, 0), 0)  # Highlight the tile
			highlighted_tiles.append(tile)  # Track the highlighted tile
		previous_active_pos = current_position
		set_cell(4, current_position, 6, Vector2i(0, 0), 0)  # Highlight the tile


# Return the selected tile position
func get_selected_tile():
	return selectedTile

# Check if the tile is walkable and return a list of reachable tiles within the movement range
func is_tile_walkable(current: Vector2i, movement: int) -> Array:
	var visited = {}
	var walkable_tiles = []
	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]  # 4 directions (up, down, left, right)
	var queue = []
	
	# Start BFS from the current position
	queue.append({"position": current, "steps": 0})
	visited[str(current)] = true
	
	while queue.size() > 0:
		var current_node = queue.pop_front()
		var current_position = current_node["position"]
		var steps = current_node["steps"]

		# Add the current position to walkable tiles
		if steps <= movement:
			walkable_tiles.append(current_position)
		else:
			# Prune if we've gone beyond the movement range
			continue

		# Explore adjacent tiles in 4 directions (up, down, left, right)
		for direction in directions:
			var next_position = current_position + direction
			var next_key = str(next_position)

			# Make sure the tile is within the grid and hasn't been visited
			if !visited.has(next_key) and Dic.has(next_key):
				# Manhattan distance to prune paths that go beyond the movement range early
				var manhattan_distance = abs(next_position.x - current.x) + abs(next_position.y - current.y)
				if manhattan_distance > movement:
					continue  # Prune this path since it's out of range
				
				# Check if the tile is walkable
				if Dic[next_key]["Walkable"] and (steps + 1 <= movement):
					# Prune exploration of occupied tiles (another character is there)
					var occupied = false
					for character in CharacterManager.characters:
						if Vector2i(character.current_position) == next_position:
							occupied = true
							break
					for character in CharacterManager.dead:
						if Vector2i(character.current_position) == next_position:
							occupied = true
							break
					if occupied:
						continue  # Prune if tile is occupied
					
					# Add to the queue and mark as visited
					visited[next_key] = true
					queue.append({"position": next_position, "steps": steps + 1})
	# Remove current tile from list
	walkable_tiles.remove_at(0)
	return walkable_tiles

# Calculate the path from the current position to the target position
func find_path(current_position: Vector2i, target_position: Vector2i, walkable_tiles: Array) -> Array:
	var open_set = []  # Nodes to be evaluated
	var came_from = {}  # For reconstructing the path
	var g_score = {}  # Cost from start to a node
	var f_score = {}  # Total cost from start to goal through the node
	
	# Initialize scores for all walkable tiles
	for tile in walkable_tiles:
		g_score[str(tile)] = INF  # Set to infinity
		f_score[str(tile)] = INF
	
	g_score[str(current_position)] = 0
	f_score[str(current_position)] = heuristic(current_position, target_position)
	open_set.append(current_position)

	while open_set.size() > 0:
		# Get the node in open_set with the lowest f_score
		var current = get_lowest_f_score(open_set, f_score)

		# Check if we reached the target
		if current == target_position:
			return reconstruct_path(came_from, current)

		open_set.erase(current)  # Remove current from open_set

		# Check the neighbors
		for direction in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var neighbor = current + direction
			
			# Ensure neighbor is a walkable tile and not occupied
			if Dic.has(str(neighbor)) and Dic[str(neighbor)]["Walkable"]:
				var occupied = false
				for character in CharacterManager.characters:
					if Vector2i(character.current_position) == neighbor:
						occupied = true
						break
				if occupied:
					continue  # Skip this neighbor if occupied

				var tentative_g_score = g_score[str(current)] + 1  # Base cost for moving
				var current_direction = get_direction(current, neighbor)

				# Add turn penalty if direction changes
				if came_from.has(str(current)):
					var previous_direction = get_direction(came_from[str(current)], current)
					if current_direction != previous_direction:
						tentative_g_score += 1  # Add penalty for turning

				# Debugging output
#				print("Current: ", str(current), " Neighbor: ", str(neighbor), " Tentative G Score: ", tentative_g_score)

				# Ensure that g_score for neighbor is initialized
				if !g_score.has(str(neighbor)):
#					print("Warning: g_score does not have key: ", str(neighbor))
					g_score[str(neighbor)] = INF  # Default to INF to avoid access errors

				if tentative_g_score < g_score[str(neighbor)]:
					# This path is the best until now, record it
					came_from[str(neighbor)] = current
					g_score[str(neighbor)] = tentative_g_score
					f_score[str(neighbor)] = g_score[str(neighbor)] + heuristic(neighbor, target_position)

					if not open_set.has(neighbor):
						open_set.append(neighbor)

	return []  # Return empty array if no path is found

# Helper function to calculate heuristic (Manhattan distance)
func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

# Helper function to get the node with the lowest f_score
func get_lowest_f_score(open_set: Array, f_score: Dictionary) -> Vector2i:
	var lowest = open_set[0]
	for node in open_set:
		if f_score[str(node)] < f_score[str(lowest)]:
			lowest = node
	return lowest

# Helper function to reconstruct the path from came_from
func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
	var total_path = []
	total_path.append(current)

	while came_from.has(str(current)):
		current = came_from[str(current)]
		total_path.append(current)

	total_path.reverse()  # Reverse the path to start from the beginning
	return total_path

# Helper function to get the direction between two tiles
func get_direction(from: Vector2i, to: Vector2i) -> Vector2i:
	return (to - from)
