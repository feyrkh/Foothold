extends Tree

signal recreated_tree_item(tree_item)

func get_drag_data(position: Vector2):
	if !get_selected():
		return
	set_drop_mode_flags(DROP_MODE_INBETWEEN)
	var drag_preview = Label.new()
	drag_preview.text = get_selected().get_text(0)
	set_drag_preview(drag_preview)

	return get_selected()

func can_drop_data(position, data):
	return data is TreeItem

func drop_data(position, dropped_item):
	var dropped_on = get_item_at_position(position)
	var drop_offset = get_drop_section_at_position(position)
	move_item(dropped_item, dropped_on, drop_offset)
	set_drop_mode_flags(DROP_MODE_DISABLED)

func move_item(dropped_item, target_item, drop_offset):
	if target_item == null or dropped_item == null:
		return
	if target_item == dropped_item:
		return
	var dropped_item_parent = dropped_item.get_parent()
	var dropped_on_parent = target_item.get_parent()
	# The two items share a parent - it's ok to reorder them
	if dropped_item_parent == dropped_on_parent:
		clone_item_list(dropped_on_parent, dropped_item, target_item, drop_offset)
#		dropped_item_parent.move_child(dropped_item, max(0, target_item.get_position_in_parent() + drop_offset))
	# The target item is the parent of the dropped item - ok to drop if the offset is >= 0, it goes to the top; otherwise not ok
	if dropped_item_parent == get_root():
	# The dropped item is a top-level item, and the target item last item of the whole tree - ok to drop if the offset is >= 0, it goes to the bottom of the current list
		var is_last_item_of_whole_tree = true
		var cur_item = target_item
		while cur_item != null:
			if cur_item.get_next() != null:
				is_last_item_of_whole_tree = false
				break
			cur_item = cur_item.get_parent()
		if is_last_item_of_whole_tree:
			dropped_item.move_to_bottom()

func clone_item_list(dropped_on_parent, dropped_item, target_item, drop_offset):
	var original_items = []
	var cur_child = dropped_on_parent.get_children()
	if cur_child == null: # must have been dropped on the parent
		original_items = [dropped_item]
	else:
		while cur_child != null:
			if cur_child == target_item:
				if drop_offset <= 0:
					original_items.append(dropped_item)
					original_items.append(cur_child)
				else:
					original_items.append(cur_child)
					original_items.append(dropped_item)
			elif cur_child == dropped_item:
				pass
			else:
				original_items.append(cur_child)
			dropped_on_parent.remove_child(cur_child)
			var old_child = cur_child
			cur_child = cur_child.get_next()
	yield(get_tree(), "idle_frame")
	for item in original_items:
		print("Rendering TreeItem: ", item.get_text(0))
		clone_item(dropped_on_parent, item)
		item.free()
	update()

func clone_item(item_parent, item):
	print("Cloning item ", item.get_text(0), " under parent ", item_parent.get_text(0))
	var new_item = create_item(item_parent, 0)
	for i in range(columns):
		new_item.set_metadata(i, item.get_metadata(i))
		new_item.set_text(i, item.get_text(i))
	new_item.disable_folding = item.disable_folding
	new_item.collapsed = item.collapsed
	new_item.custom_minimum_height = item.custom_minimum_height
	new_item.move_to_bottom()
	emit_signal('recreated_tree_item', new_item)
	var child = item.get_children()
	while child != null:
		clone_item(new_item, child)
		var old_child = child
		child = old_child.get_next()
		old_child.free()

