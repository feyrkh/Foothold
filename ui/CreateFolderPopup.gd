extends TreeItemAware

onready var FolderName:LineEdit = find_node('FolderName')
onready var OkButton:Button = find_node('OkButton')

func _ready() -> void:
	OkButton.disabled = true


func _on_CancelButton_pressed() -> void:
	queue_free()

func _on_OkButton_pressed() -> void:
	if !FolderName.text.strip_edges().empty():
		Events.emit_signal('create_tree_folder', get_parent_item(), FolderName.text)
		queue_free()


func _on_LineEdit_text_changed(new_text: String) -> void:
	if new_text.find('/') >= 0:
		FolderName.text = FolderName.text.replace('/', '\\')
		FolderName.caret_position = FolderName.text.length()
	OkButton.disabled = FolderName.text.strip_edges().empty()


func _on_LineEdit_text_entered(new_text: String) -> void:
	_on_OkButton_pressed()
