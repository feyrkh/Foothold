extends TreeItemAware

onready var LocationName:Label = find_node('LocationName')
onready var ItemManageDropdown:TreeItemAware = find_node('ItemManageDropdown')

func set_parent_item(command_tree:CommandTree, item_id):
	.set_parent_item(command_tree, item_id)
	ItemManageDropdown.set_parent_item(command_tree, item_id)
	LocationName.text = get_parent_item().get_text(0)
