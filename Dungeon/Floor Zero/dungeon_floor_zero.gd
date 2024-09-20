extends Node3D


@export var pause_target: Node


func toggle_pause() -> void:
	if pause_target.process_mode != Node.PROCESS_MODE_DISABLED:
		pause_target.process_mode = Node.PROCESS_MODE_DISABLED
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Pausable/PauseScreen.visible = true
	else:
		pause_target.process_mode = Node.PROCESS_MODE_INHERIT
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$Pausable/PauseScreen.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
