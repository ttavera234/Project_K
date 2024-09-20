extends CharacterBody3D


var active_character: String = "Knight"
@onready var player_mesh = $CharacterManager
@onready var camera_h_rotation = $CameraRoot/HorizontalCam

var knight_unlocked: bool = true
var mage_unlocked: bool = false
var rogue_unlocked: bool = false
var barbarian_unlocked: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

# Movement attributes
@export var gravity: float = 9.8
@export var jump_force: int = 9
@export var walk_speed: int = 3
@export var run_speed: int = 10

# State Machine Conditions
var is_attacking: bool
var is_walking: bool
var is_running: bool
var is_dying: bool
var on_floor: bool

# Animation Node Names
var idle_node_name: String = "Idle"
var walk_node_name: String = "Walking_A"
var run_node_name: String = "Running_A"
var jump_node_name: String = "Jump_Full_Long"
var death_node_name: String = "Death_A"
var knight_attack_node_name: String = "Knight_Attack"
var mage_attack_node_name: String = "Mage_Attack"
var rogue_attack_node_name: String = "Rogue_Attack"
var barbarian_attack_node_name: String = "Barbarian_Attack"

# Physics Values
var direction: Vector3
var horizontal_velocity: Vector3
var vertical_velocity: Vector3
var movement: Vector3
var movement_speed: int
var angular_acceleration: int
var acceleration: int
var aim_turn: float
var just_hit: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = Vector3.BACK.rotated(Vector3.UP, camera_h_rotation.global_transform.basis.get_euler().y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	on_floor = is_on_floor()
	
	
	# Handles movement of player while he is alive
	if not is_dying:
		attack()
		
		if not on_floor:
			vertical_velocity += Vector3.DOWN * gravity * 2 * delta
		else:
			vertical_velocity = Vector3.DOWN * gravity / 10
		
		if (Input.is_action_just_pressed("jump") and (not is_attacking) and on_floor):
			vertical_velocity = Vector3.UP * jump_force
		
		var h_rotation = camera_h_rotation.global_transform.basis.get_euler().y
		
		angular_acceleration = 10
		movement_speed = 0
		acceleration = 15
		
		if (knight_attack_node_name in playback.get_current_node()):
			is_attacking = true
		elif (mage_attack_node_name in playback.get_current_node()):
			is_attacking = true
		elif (rogue_attack_node_name in playback.get_current_node()):
			is_attacking = true
		elif (barbarian_attack_node_name in playback.get_current_node()):
			is_attacking = true
		else:
			is_attacking = false

		if (Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
			direction = Vector3(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"), 0.0, Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")).rotated(Vector3.UP, h_rotation).normalized()
			
			if Input.is_action_pressed("sprint") and (is_walking):
				movement_speed = run_speed
				is_running = true
			else:
				movement_speed = walk_speed
				is_walking = true
				is_running = false
		else:
			is_walking = false
			is_running = false
				
		if Input.is_action_pressed("aim"):
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, camera_h_rotation.rotation.y, delta * angular_acceleration)
		else:
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
		
		if is_attacking:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * 0.1, acceleration * delta)
		else:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * movement_speed, acceleration * delta)
		
		velocity.z = horizontal_velocity.z + vertical_velocity.z
		velocity.x = horizontal_velocity.x + vertical_velocity.x
		velocity.y = vertical_velocity.y
		
		move_and_slide()
		
	# Handles movement animations 
	animation_tree["parameters/conditions/IsOnFloor"] = on_floor
	animation_tree["parameters/conditions/IsInAir"] = not on_floor
	animation_tree["parameters/conditions/IsWalking"] = is_walking
	animation_tree["parameters/conditions/IsNotWalking"] = not is_walking
	animation_tree["parameters/conditions/IsRunning"] = is_running
	animation_tree["parameters/conditions/IsNotRunning"] = not is_running
	animation_tree["parameters/conditions/IsDying"] = is_dying


func attack() -> void:
	if (idle_node_name in playback.get_current_node()) or (walk_node_name in playback.get_current_node()):
		if Input.is_action_just_pressed("attack"):
			if not is_attacking:
				if active_character == "Knight":
					playback.travel(knight_attack_node_name)
				elif active_character == "Mage":
					playback.travel(mage_attack_node_name)
				elif active_character == "Rogue":
					playback.travel(rogue_attack_node_name)
				elif active_character == "Barbarian":
					playback.travel(barbarian_attack_node_name)


# Since the player makes the call, the current path is: root/DungeonFloor/Player
func switch_character(character_name: String) -> void:
	# Deactivate the current character
	get_node("CharacterManager/" + active_character).visible = false
	# Activate the new character
	animation_player.root_node = "../" + character_name
	get_node("CharacterManager/" + character_name).visible = true
	active_character = character_name
	# Adjust player properties (e.g., movement speed, attack power) based on the new character
	update_player_properties()


func update_player_properties() -> void:
	match active_character:
		"Knight":
			pass
		"Mage":
			pass
		"Rogue":
			pass
		"Barbarian":
			pass


func _input(event: InputEvent) -> void:
	if not is_attacking and on_floor:
		if event.is_action_pressed("switch_knight") and knight_unlocked:
			switch_character("Knight")
		elif event.is_action_pressed("switch_mage") and mage_unlocked:
			switch_character("Mage")
		elif event.is_action_pressed("switch_rogue") and rogue_unlocked:
			switch_character("Rogue")
		elif event.is_action_pressed("switch_barbarian") and barbarian_unlocked:
			switch_character("Barbarian")
		
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015
		
	if event.is_action_pressed("aim"):
		direction = camera_h_rotation.global_transform.basis.z


func _on_left_hand_damage_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Monster") and is_attacking:
		body.hit(1)
		#body.knockback()


func _on_right_hand_damage_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Monster") and is_attacking:
		body.hit(1)
		

func hit(damage: int):
	if not just_hit:
		$JustHit.start()
		Game.player_health -= damage
		just_hit = true
		if Game.player_health <= 0:
			is_dying = true
			playback.travel(death_node_name)
		
		# knockback
		#var tween := create_tween()
		#tween.tween_property(self, "global_position", global_position - (direction / 1.5), 0.2)


func _on_just_hit_timeout() -> void:
	just_hit = false


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "Death_A" in anim_name:
		await get_tree().create_timer(0.5).timeout
		$"../GameOverScreen".game_over()
