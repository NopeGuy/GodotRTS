extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")
@onready var collision_shape = get_node("CollisionShape2D")

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
