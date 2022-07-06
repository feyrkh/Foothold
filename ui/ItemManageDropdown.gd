extends TreeItemAware

const CMD_RENAME = 1
const CMD_NEW_FOLDER = 2
const CMD_DELETE_FOLDER = 3

func set_parent_item(command_tree:CommandTree, item_id):
	.set_parent_item(command_tree, item_id)
	add_item('Rename', CMD_RENAME)
	add_item('New folder', CMD_NEW_FOLDER)
	if get_parent_item_type() == CommandTree.ITEM_TYPE_FOLDER:
		add_item('Delete folder', CMD_DELETE_FOLDER)
	connect('pressed', self, '_on_Button_pressed')

func add_item(label, cmd_id):
	$Popup.add_item(label)
	$Popup.set_item_metadata($Popup.get_item_count()-1, cmd_id)

func _on_Button_pressed() -> void:
	$Popup.popup()
	$Popup.rect_global_position = rect_global_position + Vector2(0, rect_size.y)

func _on_Popup_id_pressed(id: int) -> void:
	var cmd_id = $Popup.get_item_metadata(id)
	match cmd_id:
		CMD_NEW_FOLDER:
			var popup:PopupPanel = preload("res://ui/CreateFolderPopup.tscn").instance()
			popup.set_parent_item(parent_tree, parent_item_id)
			add_child(popup)
			popup.popup_centered()
