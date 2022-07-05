extends Button

var parent_item:TreeItem

func _on_CreateFolder_pressed() -> void:
	var popup:PopupPanel = preload("res://ui/CreateFolderPopup.tscn").instance()
	add_child(popup)
	popup.popup_centered()
