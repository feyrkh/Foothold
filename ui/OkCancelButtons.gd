extends HBoxContainer

signal ok_button_pressed()
signal cancel_button_pressed()

onready var OkButton = find_node('OkButton')

func set_ok_disabled(val):
	OkButton.disabled = val

func get_ok_disabled():
	return OkButton.disabled

func _on_CancelButton_pressed() -> void:
	emit_signal("cancel_button_pressed")

func _on_OkButton_pressed() -> void:
	emit_signal("ok_button_pressed")
