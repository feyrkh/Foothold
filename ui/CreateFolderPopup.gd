extends TreeItemAware

onready var FolderName:LineEdit = find_node('FolderName')

func _on_CancelButton_pressed() -> void:
	queue_free()


func _on_OkButton_pressed() -> void:
	Events.emit_signal('create_tree_folder', get_parent_item(), FolderName.text)
	queue_free()


func _on_LineEdit_text_changed(new_text: String) -> void:
	if new_text.find('/') >= 0:
		FolderName.text = FolderName.text.replace('/', '\\')
		FolderName.caret_position = FolderName.text.length()


func _on_LineEdit_text_entered(new_text: String) -> void:
	_on_OkButton_pressed()
