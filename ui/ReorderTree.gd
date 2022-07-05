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
	if  !(data is TreeItem):
		return false
	if check_drop_data_valid(position, data):
		return true
	else:
		set_drop_mode_flags(DROP_MODE_DISABLED)
		return false

func can_drop_on_top(dropped_item, target_item):
	if target_item == null or dropped_item == null:
		return false
	var target_metadata = target_item.get_metadata(0)
	var dropped_metadata = dropped_item.get_metadata(0)
	if dropped_metadata == null or target_metadata == null:
		return false
	var allowed_types = target_metadata.get(CommandTree.KEY_ALLOWED_TYPES)
	var drop_type = dropped_metadata.get(CommandTree.KEY_ITEM_TYPE)
	if allowed_types != null and allowed_types.has(drop_type):
		return true

func check_drop_data_valid(position, dropped_item):
	var target_item:TreeItem = get_item_at_position(position)
	if dropped_item == null:
		return false
	if target_item == dropped_item:
		return false
	var dropped_item_parent:TreeItem = dropped_item.get_parent()
	if target_item == null:
		 # can drop it at the bottom of the list if you don't target any items and you're a top-level entry
		set_drop_mode_flags(DROP_MODE_DISABLED)
		return dropped_item_parent == get_root()
	if can_drop_on_top(dropped_item, target_item):
		set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
	else:
		set_drop_mode_flags(DROP_MODE_INBETWEEN)
	var dropped_on_parent:TreeItem = target_item.get_parent()
	var drop_offset:int = get_drop_section_at_position(position)
	# The two items share a parent
	if dropped_item_parent == dropped_on_parent:
			return true

func drop_data(position, dropped_item):
	var dropped_on = get_item_at_position(position)
	var drop_offset = get_drop_section_at_position(position)
	move_item(dropped_item, dropped_on, drop_offset)
	set_drop_mode_flags(DROP_MODE_DISABLED)

func move_item(dropped_item, target_item, drop_offset):
	if dropped_item == null:
		return
	if target_item == dropped_item:
		return

	var dropped_item_parent = dropped_item.get_parent()
	var dropped_on_parent
	if target_item == null and drop_offset == -100:
		# dropped on the bottom of the list, just add it to the end of the list
		dropped_item.move_to_bottom()
	else:
		# dropped on an actual entry
		dropped_on_parent = target_item.get_parent()
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
	var new_child
	if cur_child == null: # must have been dropped on the parent
		original_items = [dropped_item]
	else:
		while cur_child != null:
			if cur_child == target_item:
				new_child = clone_item(dropped_on_parent, dropped_item)
				# There's different behavior for offset if you have children vs if you're a leaf node
				# Parent nodes can only drop items above themselves, not below.
				if drop_offset <= 0 or !can_drop_on_top(dropped_item, target_item):
					original_items.append(new_child)
					original_items.append(cur_child)
				else:
					original_items.append(cur_child)
					original_items.append(new_child)
			elif cur_child == dropped_item:
				pass
			elif cur_child == new_child:
				pass
			else:
				original_items.append(cur_child)
			#dropped_on_parent.remove_child(cur_child)
			var old_child = cur_child
			cur_child = cur_child.get_next()
	yield(get_tree(), "idle_frame")
	for item in original_items:
		print("Rendering TreeItem: ", item.get_text(0))
		#clone_item(dropped_on_parent, item)
		item.move_to_bottom()
	dropped_item.get_parent().remove_child(dropped_item)
	free_item(dropped_item)
	update()

func free_item(item):
	if !item:
		return
	var child = item.get_children()
	while child:
		var to_free = child
		child = child.get_next()
		free_item(to_free)
	item.free()

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
	return new_item

