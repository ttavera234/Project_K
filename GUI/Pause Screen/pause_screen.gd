extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
