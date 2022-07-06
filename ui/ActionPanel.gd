extends Panel

const action_panel_map = {
	CommandTree.ITEM_TYPE_LOCATION: preload("res://ui/actions/LocationActions.tscn"),
	CommandTree.ITEM_TYPE_FOLDER: preload("res://ui/actions/FolderActions.tscn"),
}

func load_actions(tree_item:TreeItem, command_tree:CommandTree):
	var panel_scene = action_panel_map.get(tree_item.get_metadata(0).get(CommandTree.KEY_ITEM_TYPE))
	var tree_item_id =  tree_item.get_metadata(0).get(CommandTree.KEY_ITEM_ID)
	Util.delete_children(self)
	if panel_scene:
		var panel_instance = panel_scene.instance()
		panel_instance.set_parent_item(command_tree, tree_item_id)
		add_child(panel_instance)

