extends Node
class_name TreeItemUtil

static func get_item_metadata(tree_item):
	return tree_item.get_metadata(0)

static func get_item_id(tree_item):
	return get_item_metadata(tree_item).get(CommandTree.KEY_ITEM_ID)
