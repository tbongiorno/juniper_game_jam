@tool
extends CharacterBody3D


var BasicFPSPlayerScene : PackedScene = preload("basic_player_head.tscn")
var addedHead = false

var rand = RandomNumberGenerator

var buttonEntered = false
var buttonLeft = false

var pressedHand = preload("res://images/big hand_pressed.png")
var hand = preload("res://images/big hand.png")

var shootAvailable = true
signal damageSignal

var inHud = false

var wheelWinner = null

func _enter_tree():
	
	if find_child("Head"):
		addedHead = true
	
	if Engine.is_editor_hint() && !addedHead:
		var s = BasicFPSPlayerScene.instantiate()
		add_child(s)
		s.owner = get_tree().edited_scene_root
		addedHead = true

## PLAYER MOVMENT SCRIPT ##
###########################

@export_category("Mouse Capture")
@export var CAPTURE_ON_START := true

@export_category("Movement")
@export_subgroup("Settings")
@export var SPEED := 5.0
@export var ACCEL := 50.0
@export var IN_AIR_SPEED := 5.0
@export var IN_AIR_ACCEL := 70.0
@export var JUMP_VELOCITY := 4.5
@export @onready var current_bhop_frames = 0

@export_subgroup("Head Bob")
@export var HEAD_BOB := true
@export var HEAD_BOB_FREQUENCY := 0.3
@export var HEAD_BOB_AMPLITUDE := 0.01
@export_subgroup("Clamp Head Rotation")
@export var CLAMP_HEAD_ROTATION := true
@export var CLAMP_HEAD_ROTATION_MIN := -90.0
@export var CLAMP_HEAD_ROTATION_MAX := 90.0

@export_category("Key Binds")
@export_subgroup("Mouse")
@export var MOUSE_ACCEL := true
@export var KEY_BIND_MOUSE_SENS := 0.005
@export var KEY_BIND_MOUSE_ACCEL := 50
@export_subgroup("Movement")
@export var KEY_BIND_UP := "forward"
@export var KEY_BIND_LEFT := "left"
@export var KEY_BIND_RIGHT := "right"
@export var KEY_BIND_DOWN := "backward"
@export var KEY_BIND_JUMP := "jump"

@export_category("Advanced")
@export var UPDATE_PLAYER_ON_PHYS_STEP := true	# When check player is moved and rotated in _physics_process (fixed fps)
												# Otherwise player is updated in _process (uncapped)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# To keep track of current speed and acceleration
var speed = SPEED
var accel = ACCEL

var bhopBool = false

var oldVelocity
var slideCooldown

var bhopUnlocked = false
var rocketShotUnlocked = false

var fireRate = 1


# Used when lerping rotation to reduce stuttering when moving the mouse
var rotation_target_player : float
var rotation_target_head : float

# Used when bobing head
var head_start_pos : Vector3

var canSpin = true

# Current player tick, used in head bob calculation
var tick = 0

# GAMEPLAY STUFF
var health = 100
var damage = 5
var points = 0

var count = 1


func _ready():
	set_process_input(not Engine.is_editor_hint())
	
	if Engine.is_editor_hint():
		return
 
	# Capture mouse if set to true
	if CAPTURE_ON_START and not inHud:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head_start_pos = $Head.position

func returnMouseMode():
	if count == 1:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		count = 0
	pass

func _physics_process(delta):
	
	if health >= 1:
		$RayCast3D.rotation.x = rotation_target_head
		$RayCast3D.position = head_start_pos
		
		
		
		if Engine.is_editor_hint():
			return
			
		if Input.is_action_just_pressed("shoot") and shootAvailable and not inHud:
			$AudioStreamPlayer3D2.play()
			shootAvailable = false
			$RayCast3D.enabled = true
			print($RayCast3D.get_collision_point())
			
			
			if $RayCast3D.get_collider() != null:
				var collider = $RayCast3D.get_collider()
				print(collider.name)

				if collider.name.left(5) == "enemy":
					points += collider.take_damage(damage)
					print(points)
					
			if rocketShotUnlocked == true:
				if global_position.distance_to($explosion.global_position) <= 1.5:
					velocity += Vector3(0, 10, 0)
			
			if $RayCast3D.is_colliding():
				var point = $RayCast3D.get_collision_point()
				$explosion.global_position = point
				print($explosion.global_position)
				$explosion.visible = true
				$Control/gun.visible = false
				$Control/shoot.visible = true
			
			$shootTimer.start(fireRate)
			await get_tree().create_timer(.1).timeout
			$explosion.visible = false
			
			
		
		# Increment player tick, used in head bob motion
		tick += 1
		
		if UPDATE_PLAYER_ON_PHYS_STEP:
			move_player(delta)
			rotate_player(delta)
		
		if HEAD_BOB:
			# Only move head when on the floor and moving
			if velocity && is_on_floor():
				head_bob_motion()
			reset_head_bob(delta)

var i = 0
func _process(delta):
	if health < 1:
		get_parent().get_node("endScreen").visible = true
		get_parent().get_node("startScreen/ColorRect").color = Color.WHITE
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var newTween = create_tween()
		
		newTween.tween_property($"../endScreen/ColorRect", "color", Color.BLACK	, 10)
		if get_parent().get_node("enemies").get_child(i) != null:
			get_parent().get_node("enemies").remove_child(i)
			i = i + 1
		else:
			i = 0
		
		self.position = Vector3(0, 0, 0)
		get_parent().get_node("endScreen").visible = false
		get_parent().get_node("endScreen/ColorRect").color = Color.BLACK
		get_parent().get_node("startScreen").visible = true
		await newTween.finished
		var bhopBool = false
		var bhopUnlocked = false
		var rocketShotUnlocked = false
		var fireRate = 1
		var canSpin = true
		var tick = 0
		var health = 100
		var damage = 5
		var points = 0
		var count = 1
		
	else:
	
	
		if Input.is_action_pressed("hud"):
			inHud = true
			count = 1
		else:
			inHud = false
		
		if buttonEntered == true and buttonLeft == false and Input.is_action_just_pressed("click") and canSpin:
			print("im pressed")
			canSpin = false
			$gamblingHud/handOverlay.texture = pressedHand
			rotateWheel()
			await get_tree().create_timer(8).timeout
			canSpin = true
			$gamblingHud/handOverlay.texture = hand
		
		if inHud:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
			$Control.visible = false
			$gamblingHud/pointerFinger.visible = true
			var tween = create_tween()
			tween.tween_property($gamblingHud/handOverlay, "global_position", Vector2(577, 323), 0.5)
			$gamblingHud/pointerFinger.global_position = $gamblingHud.get_global_mouse_position()
		else:
			$Control.visible = true
			$gamblingHud/pointerFinger.visible = false
			returnMouseMode()
			var tween = create_tween()
			tween.tween_property($gamblingHud/handOverlay, "global_position", Vector2(-575, 323), 0.15)
		
		if Engine.is_editor_hint(): 
			return
		
		if Input.is_action_just_pressed("exit"):
			get_tree().quit()
		
		if Engine.is_editor_hint():
			return

		if !UPDATE_PLAYER_ON_PHYS_STEP:
			move_player(delta)
			rotate_player(delta)

func _input(event):
	if Engine.is_editor_hint():
		return
		
	# Listen for mouse movement and check if mouse is captured
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		set_rotation_target(event.relative)

func set_rotation_target(mouse_motion : Vector2):
	# Add player target to the mouse -x input
	rotation_target_player += -mouse_motion.x * KEY_BIND_MOUSE_SENS
	# Add head target to the mouse -y input
	rotation_target_head += -mouse_motion.y * KEY_BIND_MOUSE_SENS
	# Clamp rotation
	if CLAMP_HEAD_ROTATION:
		rotation_target_head = clamp(rotation_target_head, deg_to_rad(CLAMP_HEAD_ROTATION_MIN), deg_to_rad(CLAMP_HEAD_ROTATION_MAX))
	
func rotate_player(delta):
	if MOUSE_ACCEL:
		# Shperical lerp between player rotation and target
		quaternion = quaternion.slerp(Quaternion(Vector3.UP, rotation_target_player), KEY_BIND_MOUSE_ACCEL * delta)
		# Same again for head
		$Head.quaternion = $Head.quaternion.slerp(Quaternion(Vector3.RIGHT, rotation_target_head), KEY_BIND_MOUSE_ACCEL * delta)
	else:
		# If mouse accel is turned off, simply set to target
		quaternion = Quaternion(Vector3.UP, rotation_target_player)
		$Head.quaternion = Quaternion(Vector3.RIGHT, rotation_target_head)
	
func move_player(delta):
	if bhopUnlocked:
		print("bhopping")
		if current_bhop_frames == 0:
			SPEED = 5
			ACCEL = 50
			IN_AIR_ACCEL = 80
			IN_AIR_SPEED = 5
		elif current_bhop_frames == 1:
			SPEED = 8
			ACCEL = 60
			IN_AIR_ACCEL = 90
			IN_AIR_SPEED = 8
		elif current_bhop_frames == 2:
			SPEED = 10
			ACCEL = 80
			IN_AIR_ACCEL = 120
			IN_AIR_SPEED = 10
		elif current_bhop_frames > 2:
			SPEED = 15
			ACCEL = 100
			IN_AIR_ACCEL = 130
			IN_AIR_SPEED = 15
	# Check if not on floor
	if not is_on_floor():
		# Reduce speed and accel
		speed = IN_AIR_SPEED
		accel = IN_AIR_ACCEL
		# Add the gravity
		velocity.y -= gravity * delta
	else:
		# Set speed and accel to defualt
		speed = SPEED
		accel = ACCEL

	# hanles the slide
	if Input.is_action_just_pressed("slide") and not slideCooldown:
		slideCooldown = true
		oldVelocity = SPEED
		SPEED = SPEED * 2
		$SlideTimer.start(1)
		
	# Handle Jump.
	if Input.is_action_just_pressed(KEY_BIND_JUMP) and is_on_floor():
		$bhopTimer.start(1.35)
		current_bhop_frames = current_bhop_frames + 1
		print(current_bhop_frames)
		velocity.y = JUMP_VELOCITY
	

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_UP, KEY_BIND_DOWN)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)

	move_and_slide()

func head_bob_motion():
	var pos = Vector3.ZERO
	pos.y += sin(tick * HEAD_BOB_FREQUENCY) * HEAD_BOB_AMPLITUDE
	pos.x += cos(tick * HEAD_BOB_FREQUENCY/2) * HEAD_BOB_AMPLITUDE * 2
	$Head.position += pos

func reset_head_bob(delta):
	# Lerp back to the staring position
	if $Head.position == head_start_pos:
		pass
	$Head.position = lerp($Head.position, head_start_pos, 2 * (1/HEAD_BOB_FREQUENCY) * delta)
	
	
func rotateWheel():
	if $Control/directions.visible_ratio == 1:
		await get_tree().create_timer(1).timeout
		var tween = get_tree().create_tween()
		tween.tween_property($Control/directions, "visible_ratio", 0, 0.5)

	var rotateTween = create_tween()
	var randi = randi_range(100, 360)
	rotateTween.tween_property($gamblingHud/handOverlay/wheel, "rotation", $gamblingHud/handOverlay/wheel.rotation + randi, 8).set_trans(Tween.TRANS_SINE)
	$AudioStreamPlayer3D.playing = true
	await rotateTween.finished
	$AudioStreamPlayer3D.playing = false
	$AudioStreamPlayer2D.play()
	if wheelWinner == $gamblingHud/handOverlay/wheel/Area2D4:
		if bhopUnlocked == false:
			$reward.text = "BHOP UNLOCKED"
			bhopUnlocked = true
			print("bhop unlocked")
		else:
			get_parent().get_node("enemy_timer").start(10)
			$reward.text = "MORE ENEMIES SPAWNED"
	elif wheelWinner == $gamblingHud/handOverlay/wheel/Area2D2:
		$reward.text = "FIRE RATE INCREASED"
		print("fire rate increased")
		fireRate -= 0.1
	elif wheelWinner == $gamblingHud/handOverlay/wheel/Area2D3:
		$reward.text = "HEALTH INCREASED"
		print("increased health")
		health += 10
	elif wheelWinner == $gamblingHud/handOverlay/wheel/Area2D5:
		$reward.text = "PLAYER SPEED INCREASED"
		print("speed increased")
		if SPEED != 5:
			SPEED = 6
		else:
			$reward.text = "MORE ENEMIES SPAWNED"
			get_parent().get_node("enemy_timer").start(10)
	elif wheelWinner == $gamblingHud/handOverlay/wheel/Area2D:
		$reward.text = "LOTS MORE ENEMIES SPAWNED"
		get_parent().get_node("enemy_timer").start(.1)
	elif wheelWinner == $gamblingHud/handOverlay/wheel/Area2D6:
		$reward.text = "LOTS MORE ENEMIES SPAWNED"
		get_parent().get_node("enemy_timer").start(.1)
	elif wheelWinner == $gamblingHud/handOverlay/wheel/Area2D7:
		if rocketShotUnlocked == false:
			$reward.text = "ROCKET BOOST UNLOCKED"
			rocketShotUnlocked = true
		else:
			$reward.text = "MORE NEMIES SPAWNED"
			get_parent().get_node("enemy_timer").start(10)
	
	$reward.visible_ratio = 1
	await get_tree().create_timer(2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property($reward, "visible_ratio", 0, 0.5)


func _on_slide_timer_timeout() -> void:
	SPEED = oldVelocity
	slideCooldown = false
	pass # Replace with function body.


func _on_bhop_timer_timeout() -> void:
	current_bhop_frames = 0
	print("FLIP IT RESET BOUNCE")
	pass # Replace with function body.


func damage_player(damage):
	print("taking damage")
	health -= damage
	print(str(health))
	if health <= 0:
		print("DEAD")
		



func _on_shoot_timer_timeout() -> void:
	shootAvailable =  true
	$Control/shoot.visible = false
	$Control/gun.visible = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("im in")
	buttonLeft = false
	buttonEntered = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	buttonEntered = false
	buttonLeft = true
	pass # Replace with function body.


func _on_area_2d_area_spinner_hand_entered(area: Area2D) -> void:
	wheelWinner = area
	pass # Replace with function body.
