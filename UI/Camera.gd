extends Camera2D

var mouse_pos = Vector2()
var mouse_pos_global = Vector2()
var start = Vector2()
var start_v = Vector2()
var end = Vector2()
var end_v = Vector2()
var is_dragging = false
var has_moved = false

signal area_selected
signal unit_clicked

@onready var box = get_node("../UI/Panel")

func _ready():
	if not box:
		print("Panel not found! Check the node path.")
	connect("area_selected", Callable(get_parent(), "_on_area_selected"))
	connect("unit_clicked", Callable(get_parent(), "_on_unit_clicked"))
	set_process_input(true)
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("LeftClick"):
		start = mouse_pos_global
		start_v = mouse_pos
		is_dragging = true
		has_moved = false
		draw_area(false)
	
	if is_dragging:
		end = mouse_pos_global
		end_v = mouse_pos
		if start_v.distance_to(mouse_pos) > 5:
			has_moved = true
			draw_area(true)
		else:
			draw_area(false)
	
	if Input.is_action_just_released("LeftClick"):
		if has_moved and start_v.distance_to(mouse_pos) > 20:
			end = mouse_pos_global
			end_v = mouse_pos
			emit_signal("area_selected", {"start": start, "end": end, "add_to_selection": Input.is_action_pressed("Ctrl")})
		else:
			emit_signal("unit_clicked", mouse_pos_global, Input.is_action_pressed("Ctrl"))
		is_dragging = false
		draw_area(false)

func _input(event):
	if event is InputEventMouse:
		mouse_pos = event.position
		mouse_pos_global = get_global_mouse_position()

func draw_area(visible):
	if box:
		if visible:
			var width = abs(start_v.x - end_v.x)
			var height = abs(start_v.y - end_v.y)
			box.size = Vector2(width, height)
			box.position = Vector2(min(start_v.x, end_v.x), min(start_v.y, end_v.y))
		box.visible = visible
