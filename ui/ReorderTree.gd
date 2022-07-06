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

func check_is_ancestor_of(target_item, dropped_item):
	var ancestor = target_item.get_parent()
	while ancestor != null:
		if ancestor == dropped_item:
			return true
		ancestor = ancestor.get_parent()
	return false

func can_drop_on_top(dropped_item, target_item):
	print('candrop?')
	if target_item == null or dropped_item == null:
		print('candrop: one is null')
		return false
	var target_metadata = target_item.get_metadata(0)
	var dropped_metadata = dropped_item.get_metadata(0)
	if dropped_metadata == null or target_metadata == null:
		print('candrop: metadata is null')
		return false

	# You can't drop an item near one of its descendants
	if check_is_ancestor_of(target_item, dropped_item):
		print('candrop: no drop on descendant')
		set_drop_mode_flags(DROP_MODE_DISABLED)
		return false

	# Some items are locked to a particular owner - check to see if this is one of them and whether the target is a qualified owner
	var dropped_lock = dropped_item.get_metadata(0).get(CommandTree.KEY_OWNER_LOCK)
	if dropped_lock:
		var target_lock = target_item.get_metadata(0).get(CommandTree.KEY_OWNER_LOCK)
		if target_lock != dropped_lock: # and not (target_lock is Array and target_lock.has(dropped_lock)):
			set_drop_mode_flags(DROP_MODE_DISABLED)
			print('candrop: differing locks')
			return false

	# Each item has a type, and all items restrict what types of items they can contain
	# Check that the target can contain the item being dropped
	# There's a special case for folder-type items - any item can contain a folder, but
	# every type the folder can contain must also be containable by the target
	var allowed_types = target_metadata.get(CommandTree.KEY_ALLOWED_TYPES, [])
	var drop_type = dropped_metadata.get(CommandTree.KEY_ITEM_TYPE)
	if drop_type == CommandTree.ITEM_TYPE_FOLDER:
		var drop_allowed_types = dropped_metadata.get(CommandTree.KEY_ALLOWED_TYPES, [])
		for drop_allowed_type in drop_allowed_types:
			if !allowed_types.has(drop_allowed_type):
				print('candrop: mismatched allowed types; ', drop_allowed_type, ' vs ', allowed_types)
				return false
		print('candrop: matched allowed types')
		return true
	elif allowed_types != null and allowed_types.has(drop_type):
		return true
	else:
		print('candrop: disallowed types')
		return false

func check_drop_data_valid(position, dropped_item):
	var target_item:TreeItem = get_item_at_position(position)
	if dropped_item == null:
		print('chkdrop: no dropped item')
		return false
	if target_item == dropped_item:
		print('chkdrop: same dropped item')
		return false
	var dropped_item_parent:TreeItem = dropped_item.get_parent()
	if target_item == null:
		 # can drop it at the bottom of the list if you don't target any items
		set_drop_mode_flags(DROP_MODE_DISABLED)
		print('chkdrop: no target item')
		#return dropped_item_parent == get_root()
		return true

	if check_is_ancestor_of(target_item, dropped_item):
		print('chkdrop: dropped is ancestor of target')
		return false

	var dropped_on_parent:TreeItem = target_item.get_parent()
	var drop_offset = get_drop_section_at_position(position)
	print(drop_offset, '; candropontop? ', can_drop_on_top(dropped_item, target_item))
	var can_drop_on_target = can_drop_on_top(dropped_item, target_item)
	if drop_offset == 0 and can_drop_on_target:
		# dropping on top of an entry, and we're allowed
		set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
		print('chkdrop: ofs=0, candrop')
		return true
	elif dropped_item_parent == dropped_on_parent:
		# we already share a parent, and not trying to drop on top of a valid container, so we can drop in between
		if can_drop_on_target:
			set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
		else:
			set_drop_mode_flags(DROP_MODE_INBETWEEN)
		print('chkdrop: share parent')
		return true
	elif drop_offset != 0 and can_drop_on_top(dropped_item, dropped_on_parent):
		# we don't share a parent, but we're trying to drop in between something we're allowed to
		if can_drop_on_target:
			set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
		else:
			set_drop_mode_flags(DROP_MODE_INBETWEEN)
		print('chkdrop: can drop around, diff parent')
		return true
	else:
		print('chkdrop: nodrop')
		set_drop_mode_flags(DROP_MODE_DISABLED)


func drop_data(position, dropped_item):
	var dropped_on = get_item_at_position(position)
	var drop_offset = get_drop_section_at_position(position)
	move_item(dropped_item, dropped_on, drop_offset)
	set_drop_mode_flags(DROP_MODE_DISABLED)

func move_item(dropped_item, target_item, drop_offset):
	if drop_offset == 0 and !(drop_mode_flags & DROP_MODE_ON_ITEM):
		# Trying to drop on top of an item that we don't support dropping on top of, so try dropping above it instead
		drop_offset = -1
	if dropped_item == null:
		return
	if target_item == dropped_item:
		return

	var dropped_item_parent = dropped_item.get_parent()
	var dropped_on_parent
	if target_item == null and drop_offset == -100:
		# dropped on the bottom of the list, just add it to the end of the list
		dropped_item.move_to_bottom()
	elif drop_offset == 0:
		# dropping on top of a container - create a new item and move it to the top of the list
		var new_item = clone_item(target_item, dropped_item)
		new_item.move_to_top()
		free_item(dropped_item)
	else:
		# dropped above or below an entry
		dropped_on_parent = target_item.get_parent()
		# The two items share a parent - it's ok to reorder them
#		if dropped_item_parent == dropped_on_parent:
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
				if drop_offset < 0:
					original_items.append(new_child)
					original_items.append(cur_child)
				elif drop_offset == 0 and can_drop_on_top(dropped_item, target_item):
					pass # TODO: Drop inside a folder
				else:
					# There's different behavior for offset if you have children vs if you're a leaf node
					# Parent nodes can only drop items above themselves, not below.
					if target_item.get_children() == null:
						original_items.append(cur_child)
						original_items.append(new_child)
					else:
						original_items.append(new_child)
						original_items.append(cur_child)
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
		new_item.set_icon(i, item.get_icon(i))
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

