extends Node2D

var units = []

func _ready():
	units = get_tree().get_nodes_in_group("units")

func _on_area_selected(area_data):
	var start = area_data.start
	var end = area_data.end
	var add_to_selection = area_data.get("add_to_selection", false)
	var area = Rect2(Vector2(min(start.x, end.x), min(start.y, end.y)), Vector2(abs(start.x - end.x), abs(start.y - end.y)))
	if add_to_selection:
		# Add to selection and deselect units in the area if they are already selected
		update_selection_in_area(area, true)
	else:
		# Replace selection
		select_units_in_area(area)

func _on_unit_clicked(global_mouse_pos, add_to_selection: bool):
	var clicked_unit = get_unit_at_position(global_mouse_pos)
	if clicked_unit:
		if add_to_selection:
			# If Ctrl is pressed and the unit is already selected, deselect it
			if clicked_unit.selected:
				clicked_unit.set_selected(false)
			else:
				clicked_unit.set_selected(true)  # Add to selection
		else:
			# Deselect all units and select the clicked unit
			deselect_all_units()
			clicked_unit.set_selected(true)
	else:
		if not add_to_selection:
			deselect_all_units()

func select_units_in_area(area: Rect2):
	for unit in units:
		unit.set_selected(false)
	for unit in get_units_in_area(area):
		unit.set_selected(true)

func update_selection_in_area(area: Rect2, add_to_selection: bool):
	for unit in units:
		if area.intersects(unit.get_global_rect()):
			if add_to_selection:
				unit.set_selected(true)
			else:
				unit.set_selected(false)

func get_units_in_area(area: Rect2) -> Array:
	var result = []
	for unit in units:
		if area.intersects(unit.get_global_rect()):
			result.append(unit)
	return result

func get_unit_at_position(global_pos: Vector2) -> Node:
	for unit in units:
		if unit.get_global_rect().has_point(global_pos):
			return unit
	return null

func deselect_all_units():
	for unit in units:
		unit.set_selected(false)
