extends TreeItemAware
class_name ActionPanelContents

func _ready():
	var header = find_node('ActionPanelHeader')
	if header:
		header.set_parent_item(parent_tree, parent_item_id)
