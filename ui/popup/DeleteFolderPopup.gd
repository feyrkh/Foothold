extends TreeItemAware

onready var OkCancelButtons = find_node('OkCancelButtons')

func _ready() -> void:
	OkCancelButtons.set_ok_disabled(true)
	OkCancelButtons.connect("cancel_button_pressed", self, "cancel_button_pressed")
	OkCancelButtons.connect("ok_button_pressed", self, "ok_button_pressed")

func cancel_button_pressed() -> void:
	queue_free()

func ok_button_pressed() -> void:
	Events.emit_signal('delete_tree_folder', get_parent_item())
	queue_free()
