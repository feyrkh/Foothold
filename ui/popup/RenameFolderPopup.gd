extends TreeItemAware

onready var FolderName:LineEdit = find_node('FolderName')
onready var OkCancelButtons = find_node('OkCancelButtons')

func _ready() -> void:
	OkCancelButtons.set_ok_disabled(true)
	OkCancelButtons.connect("cancel_button_pressed", self, "cancel_button_pressed")
	OkCancelButtons.connect("ok_button_pressed", self, "ok_button_pressed")

func _on_LineEdit_text_changed(new_text: String) -> void:
	if new_text.find('/') >= 0:
		FolderName.text = FolderName.text.replace('/', '\\')
		FolderName.caret_position = FolderName.text.length()
	OkCancelButtons.set_ok_disabled(FolderName.text.strip_edges().empty())

func _on_LineEdit_text_entered(new_text: String) -> void:
	if !OkCancelButtons.get_ok_disabled():
		ok_button_pressed()

func cancel_button_pressed() -> void:
	queue_free()

func ok_button_pressed() -> void:
	if !FolderName.text.strip_edges().empty():
		Events.emit_signal('rename_tree_folder', get_parent_item(), FolderName.text)
		queue_free()
