extends Control
class_name TreeItemAware

var parent_tree:CommandTree
var parent_item_id

func set_parent_item(command_tree:CommandTree, item_id):
	parent_tree = command_tree
	parent_item_id = item_id

func get_parent_item():
	return parent_tree.get_item_by_id(parent_item_id)
