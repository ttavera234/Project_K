extends CharacterBody3D


@export var player: CharacterBody3D

const SPEED = 2.0

var direction: Vector3
var Awakening: bool = false
var Attacking: bool = false
var health: int = 4
var damage: int = 2
var dying: bool = false
var just_hit: bool = false
var unaware: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	if player:
		direction = (player.global_transform.origin - self.global_transform.origin).normalized()
	move_and_slide()
	
	
func _ready() -> void:
	$StateMachineController.change_state("Idle")


func _on_just_hit_timeout() -> void:
	just_hit = false


func _on_chase_player_detection_body_entered(body: Node3D) -> void:
	if "Player" in body.name and not dying and unaware:
		$StateMachineController.change_state("Run")


func _on_chase_player_detection_body_exited(body: Node3D) -> void:
	if "Player" in body.name and not dying:
		$StateMachineController.change_state("Idle")


func _on_attack_player_detection_body_entered(body: Node3D) -> void:
	if "Player" in body.name and not dying:
		$StateMachineController.change_state("Attack")


func _on_attack_player_detection_body_exited(body: Node3D) -> void:
	if "Player" in body.name and not dying:
		$StateMachineController.change_state("Run")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "Skeletons_Awaken_Standing" in anim_name:
		Awakening = false
	elif "1H_Melee_Attack_Chop" in anim_name:
		if player in $AttackPlayerDetection.get_overlapping_bodies():
			$StateMachineController.change_state("Attack")
	elif "Death_A" in anim_name:
		self.queue_free()


func hit(damage: int):
	if $StateMachineController.get_state() == "Idle":
		unaware = false
		$StateMachineController.change_state("Run")
	
	if !just_hit:
		$JustHit.start()
		health -= damage
		just_hit = true
		if health <= 0:
			$StateMachineController.change_state("Death")

# Knockback logic, may implement in the future 
#func knockback() -> void:
	#$JustHit.start()
	#var tween := create_tween()
	#tween.tween_property(self, "global_position", global_position - (direction / 1.0), 0.2)


func _on_damage_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)
