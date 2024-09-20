extends Node


var state = {
	"Idle": preload("res://Enemies/State Machine Scripts/IdleState.gd"),
	"Run": preload("res://Enemies/State Machine Scripts/RunState.gd"),
	"Attack": preload("res://Enemies/State Machine Scripts/AttackState.gd"),
	"Death": preload("res://Enemies/State Machine Scripts/DeathState.gd")
}


func change_state(new_state: String) -> void:
	if get_child_count() != 0:
		get_child(0).queue_free()
	
	if state.has(new_state):
		var state_temp = state[new_state].new()
		state_temp.name = new_state
		add_child(state_temp)


func get_state() -> String:
	return get_child(0).name
	
