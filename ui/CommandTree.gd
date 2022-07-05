extends Control
class_name CommandTree

signal item_selected(tree_item)

const KEY_ITEM_ID='_' # Unique ID for every TreeItem
const KEY_ITEM_TYPE='T' # ID for the type of item this is; see ITEM_TYPE_* constants
const KEY_ALLOWED_TYPES='a' # Array of ITEM_TYPE_* values which are allowed for this entry
const KEY_OWNER_LOCK='O' # ID of the owner of this container or entry - if set on an item, items can't be moved outside of the owning container. Creating a new container duplicates inside an existing container will duplicate its owner ID.

const ITEM_TYPE_LOCATION='l' # A physical place

const ITEM_AMOUNT='A'

var tree:Tree
var __next_id = 0
var id_map = {}
func get_next_id():
	var retval = __next_id
	__next_id += 1
	return retval

func get_item_by_id(item_id):
	return id_map[item_id]

func _ready() -> void:
	Events.connect('create_tree_folder', self, 'create_tree_folder')

	tree = $Tree
	tree.connect('recreated_tree_item', self, 'recreated_tree_item')
	tree.set_column_expand(0, true)
	#tree.set_column_expand(1, true)
	#tree.set_column_expand(2, true)
	tree.set_column_title(0, 'Name')
	#tree.set_column_title(1, 'Amt')
	#tree.set_column_title(2, 'Change')
	tree.set_column_titles_visible(false)
	tree.set_column_min_width(0, 5)
	#tree.set_column_min_width(1, 1)
	#tree.set_column_min_width(2, 1)

	tree.connect("item_selected", self, "item_selected")

	# TEMP
	var root = tree.create_item()
	root.set_metadata(0, {KEY_ALLOWED_TYPES: []})
	add_item("Wizard's Tower", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, KEY_ALLOWED_TYPES: [ITEM_TYPE_LOCATION], KEY_OWNER_LOCK: 'wiztow'})
	add_item("Wizard's Tower/Small Stone Chamber", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, KEY_ALLOWED_TYPES: ['sin'], ITEM_AMOUNT: 1, KEY_OWNER_LOCK: 'wiztow'})
	add_item("Wizard's Tower/Tower Roof", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1, KEY_OWNER_LOCK: 'wiztow'})
	add_item("Wizard's Tower/Kitchen", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1, KEY_OWNER_LOCK: 'wiztow'})
	add_item("Spine Foothills", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, KEY_ALLOWED_TYPES: [ITEM_TYPE_LOCATION], KEY_OWNER_LOCK: 'sphill'})
	add_item("Spine Foothills/Farmland", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 5, KEY_OWNER_LOCK: 'sphill'})
	add_item("Spine Foothills/Goblin Caves", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1, KEY_OWNER_LOCK: 'sphill'})
	add_item("Astral Plane", {KEY_ITEM_TYPE: ITEM_TYPE_LOCATION, KEY_ALLOWED_TYPES: ['soul']})
	add_item("Astral Plane/Your Soul", {KEY_ITEM_TYPE: 'soul', KEY_ALLOWED_TYPES: ['sin'], KEY_OWNER_LOCK: 'soul1'})
	add_item("Astral Plane/Your Soul/My Greed", {KEY_ITEM_TYPE: 'sin', KEY_OWNER_LOCK: 'soul1', ITEM_AMOUNT: 1})
	add_item("Astral Plane/Your Soul/My Envy", {KEY_ITEM_TYPE: 'sin', KEY_OWNER_LOCK: 'soul1', ITEM_AMOUNT: 1})
	add_item("Astral Plane/Other Soul", {KEY_ITEM_TYPE: 'soul', KEY_ALLOWED_TYPES: ['sin'], KEY_OWNER_LOCK: 'soul2'})
	add_item("Astral Plane/Other Soul/Greed", {KEY_ITEM_TYPE: 'sin', ITEM_AMOUNT: 1})
	add_item("Astral Plane/Other Soul/Envy", {KEY_ITEM_TYPE: 'sin', ITEM_AMOUNT: 1})
	add_item("Astral Plane/Final Soul", {KEY_ITEM_TYPE: 'soul', KEY_ALLOWED_TYPES: ['sin'], KEY_OWNER_LOCK: 'soul3'})
	add_item("Astral Plane/Final Soul/Greed", {KEY_ITEM_TYPE: 'sin', ITEM_AMOUNT: 1})
	add_item("Astral Plane/Final Soul/Envy", {KEY_ITEM_TYPE: 'sin', ITEM_AMOUNT: 1})

func item_selected():
	var selected_item = tree.get_selected()
	emit_signal("item_selected", selected_item)

func recreated_tree_item(item:TreeItem):
	var metadata = item.get_metadata(0)
	if metadata:
		id_map[metadata[KEY_ITEM_ID]] = item

func add_item(loc_name, loc_metadata={}, root=tree.get_root()):
	if loc_metadata.get(KEY_ITEM_ID) == null:
		loc_metadata[KEY_ITEM_ID] = get_next_id()
	var name_chunks = loc_name.split('/')
	var confirmed_name = ''
	for i in range(name_chunks.size()-1):
		var new_root = find_item_by_path(name_chunks[i], root)
		if new_root == null:
			new_root = add_item(name_chunks[i], {}, root)
		else:
			if confirmed_name != '':
				confirmed_name += '/'
			confirmed_name = confirmed_name+name_chunks[i]
		root = new_root
	var existing_item = find_item_by_path(name_chunks[-1], root)
	if existing_item != null:
		return combine_item(existing_item, loc_metadata)
	else:
		var new_item = tree.create_item(root)
		configure_item(new_item, name_chunks[-1], loc_metadata)
		id_map[loc_metadata.get(KEY_ITEM_ID)] = new_item
		return new_item

func configure_item(new_item, item_name, metadata):
	new_item.set_metadata(0, metadata)
	new_item.set_text(0, item_name)
	match(metadata.get(KEY_ITEM_TYPE, '')):
		ITEM_TYPE_LOCATION:
			configure_location(new_item, metadata)
	return new_item

func configure_location(new_item, metadata):
	pass

func combine_item(existing_item, new_metadata):
	push_error("Unable to combine metadata for item of type '"+str(existing_item.get_metadata(0).get(KEY_ITEM_TYPE))+'"')
	return existing_item

func find_item_by_path(loc_name, root=tree.get_root()):
	var name_chunks = loc_name.split('/')
	for name_chunk in name_chunks:
		var cur_child = root.get_children()
		var new_root = null
		while cur_child != null:
			if cur_child.get_text(0) == name_chunk:
				new_root = cur_child
				break
			cur_child = cur_child.get_next()
		if new_root == null:
			return null # couldn't find
		root = new_root
	return root

func can_drop_data(position, data):
	return true # hack to avoid the ugly "can't drop here" mouse cursor

func create_tree_folder(parent_tree_item, folder_name):
	var md = parent_tree_item.get_metadata(0)
	var allowed_types = md.get(KEY_ALLOWED_TYPES)
	var owner_lock = md.get(KEY_OWNER_LOCK)
	var new_md = {}
	if allowed_types:
		new_md[KEY_ALLOWED_TYPES] = allowed_types
	if owner_lock:
		new_md[KEY_OWNER_LOCK] = owner_lock
	var new_item:TreeItem = add_item(folder_name, new_md, parent_tree_item)
	tree.scroll_to_item(new_item)
