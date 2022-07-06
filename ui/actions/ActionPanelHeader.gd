extends TreeItemAware

onready var LocationName:Label = find_node('LocationName')
onready var ItemManageDropdown:TreeItemAware = find_node('ItemManageDropdown')

func _ready():
	Events.connect('rename_tree_folder', self, 'rename_tree_folder')

func set_parent_item(command_tree:CommandTree, item_id):
	.set_parent_item(command_tree, item_id)
	ItemManageDropdown.set_parent_item(command_tree, item_id)
	LocationName.text = get_parent_item().get_text(0)

func rename_tree_folder(tree_item, new_name):
	if tree_item and TreeItemUtil.get_item_id(tree_item) == self.parent_item_id:
		LocationName.text = get_parent_item().get_text(0)
