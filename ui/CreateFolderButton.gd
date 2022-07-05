extends TreeItemAware

func _on_CreateFolder_pressed() -> void:
	var popup:PopupPanel = preload("res://ui/CreateFolderPopup.tscn").instance()
	popup.set_parent_item(parent_tree, parent_item_id)
	add_child(popup)
	popup.popup_centered()
