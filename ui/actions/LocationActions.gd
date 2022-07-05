extends TreeItemAware

onready var LocationName:Label = find_node('LocationName')
onready var RenameFolderButton:TreeItemAware = find_node('RenameFolderButton')
onready var CreateFolderButton:TreeItemAware = find_node('CreateFolderButton')

func set_parent_item(command_tree, item_id):
	.set_parent_item(command_tree, item_id)
	RenameFolderButton.set_parent_item(command_tree, item_id)
	CreateFolderButton.set_parent_item(command_tree, item_id)
	LocationName.text = get_parent_item().get_text(0)
