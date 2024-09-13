extends Camera2D

var mousePos = Vector2()
var mousePosGlobal = Vector2()
var start = Vector2()
var startV = Vector2()
var end = Vector2()
var endV = Vector2()
var isDragging = false

signal area_selected

func _process(delta):
	# Start dragging when the left mouse button is pressed
	if Input.is_action_just_pressed("LeftClick"):
		start = mousePosGlobal
		startV = mousePos
		isDragging = true
		draw_area(true)  # Show the area panel when dragging starts
	
	# Update the drag area while the mouse is held down
	if isDragging:
		end = mousePosGlobal
		endV = mousePos
		draw_area(true)  # Continue drawing the area while dragging
	
	# Stop dragging and hide the panel when the left mouse button is released
	if Input.is_action_just_released("LeftClick"):
		if startV.distance_to(mousePos) > 20:  # Check if dragging distance is significant
			end = mousePosGlobal
			endV = mousePos
			emit_signal("area_selected", start, end)  # Emit the area_selected signal
		isDragging = false
		draw_area(false)  # Hide the area panel after releasing the mouse


func _input(event):
	# Track mouse position
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()

func draw_area(visible):
	var panel = get_node("../Panel")
	
	if visible:
		# Update size and position only when visible
		var width = abs(startV.x - endV.x)
		var height = abs(startV.y - endV.y)
		panel.size = Vector2(width, height)
		
		# Calculate position for the top-left corner of the panel
		var pos = Vector2(min(startV.x, endV.x), min(startV.y, endV.y))
		panel.position = pos

	# Toggle visibility of the panel
	panel.visible = visible
