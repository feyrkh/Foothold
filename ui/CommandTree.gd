extends Control
class_name CommandTree

const ITEM_ID_KEY='_'
const ITEM_TYPE_KEY='T'
const ITEM_TYPE_LOCATION='l'

const ITEM_AMOUNT='A'

var tree
var __next_id = 0
var id_map = {}
func get_next_id():
	var retval = __next_id
	__next_id += 1
	return retval

func _ready() -> void:
	tree = $Tree
	tree.connect('recreated_tree_item', self, 'recreated_tree_item')
	tree.set_column_expand(0, true)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, true)
	tree.set_column_title(0, 'Name')
	tree.set_column_title(1, 'Amt')
	tree.set_column_title(2, 'Change')
	tree.set_column_titles_visible(true)
	tree.set_column_min_width(0, 5)
	tree.set_column_min_width(1, 1)
	tree.set_column_min_width(2, 1)

	tree.connect("item_selected", self, "item_selected")

	# TEMP
	var root = tree.create_item()
	add_item("Wizard's Tower/Small Stone Chamber", {ITEM_TYPE_KEY: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1})
	add_item("Wizard's Tower/Tower Roof", {ITEM_TYPE_KEY: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1})
	add_item("Spine Foothills/Farmland", {ITEM_TYPE_KEY: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 5})
	add_item("Spine Foothills/Goblin Caves", {ITEM_TYPE_KEY: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1})
	add_item("Astral Plane/Your Soul/Greed", {ITEM_TYPE_KEY: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1})
	add_item("Astral Plane/Your Soul/Envy", {ITEM_TYPE_KEY: ITEM_TYPE_LOCATION, ITEM_AMOUNT: 1})

func item_selected():
	var selected_item = tree.get_selected()



func recreated_tree_item(item:TreeItem):
	var metadata = item.get_metadata(0)
	if metadata:
		id_map[metadata[ITEM_ID_KEY]] = item

func add_item(loc_name, loc_metadata={}, root=tree.get_root()):
	if loc_metadata.get(ITEM_ID_KEY) == null:
		loc_metadata[ITEM_ID_KEY] = get_next_id()
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
		id_map[loc_metadata.get(ITEM_ID_KEY)] = new_item
		return new_item

func configure_item(new_item, item_name, metadata):
	new_item.set_metadata(0, metadata)
	new_item.set_text(0, item_name)
	match(metadata.get(ITEM_TYPE_KEY, '')):
		ITEM_TYPE_LOCATION:
			configure_location(new_item, metadata)
	return new_item

func configure_location(new_item, metadata):
	pass

func combine_item(existing_item, new_metadata):
	push_error("Unable to combine metadata for item of type '"+str(existing_item.get_metadata(0).get(ITEM_TYPE_KEY))+'"')
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
