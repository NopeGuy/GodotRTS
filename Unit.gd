extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")
@onready var collision_shape = get_node("CollisionShape2D")

var currPos = Vector2(581, 292)  # Use Vector2 instead of array for position

func _ready():
	set_selected(selected)

func set_selected(value):
	selected = value
	box.visible = value

func get_global_rect() -> Rect2:
	if collision_shape.shape is RectangleShape2D:
		var shape = collision_shape.shape as RectangleShape2D
		var size = shape.extents * 2  # Full size from extents
		return Rect2(global_position - size / 2, size)  # Use global_position
	return Rect2()

func _input(event):
	# Handle input without rotating the sprite
	if event.is_action_pressed("ui_right"):
		currPos.x += 54  # Move right by 32 pixels
		currPos.y += 29  # Move down by 32 pixels
	elif event.is_action_pressed("ui_left"):
		currPos.x -= 54  # Move left by 32 pixels
		currPos.y -= 29  # Move up by 32 pixels
	elif event.is_action_pressed("ui_up"):
		currPos.y -= 29  # Move up by 32 pixels
		currPos.x += 54  # Move right by 32 pixels
	elif event.is_action_pressed("ui_down"):
		currPos.y += 29  # Move down by 32 pixels
		currPos.x -= 54  # Move left by 32 pixels

	# Update the player's position without affecting rotation
	self.position = currPos
