extends Node

var chars = []

func _ready():
	# Initialize the UI for the turn order display
	update_turn_order()

# Function to update the turn order display in the Panel
func update_turn_order():
	# Get the Panel and HBoxContainer node (use HBoxContainer for side-by-side display)
	var panel = get_node("Panel")
	var container = panel.get_node("HBoxContainer")

	# Clear previous labels
	_clear_container(container)

	# Clear the chars array to avoid duplication
	chars.clear()

	for player in CharacterManager.characters:
		if player.HP > 0:
			chars.append(player.name)

	# Loop through the chars list and create a label for each name
	for char in chars:
		var label = Label.new()  # Create a new Label node
		label.text = char  # Set the text to the player's name
		container.add_child(label)  # Add the label to the HBoxContainer

# Function to remove all children from the container
func _clear_container(container):
	for child in container.get_children():
		child.queue_free()  # Remove and free each child
