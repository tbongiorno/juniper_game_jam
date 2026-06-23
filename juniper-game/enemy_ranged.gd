extends CharacterBody3D

var target = null
var target_position = null

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	target = get_parent().get_node("player")
	
func _process(_delta):
	target_position = target.global_position
	look_at(target_position - Vector3(0, target_position.y, 0) + Vector3(0, 1, 0))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(target.global_position.x, 0, target.global_position.y)).normalized()
	#print(direction)
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_shot_timer_timeout():
	$bullet.global_position = Vector3(0, 0, -1)
	await get_tree().create_timer(2).timeout
	print("FIRED")
	#$bullet.global_position.move_toward(target_position, SPEED)
	$bullet.global_position = target_position
	
	$shotTimer.start()


func _on_bullet_body_entered(body):
	if body.name == "player":
		print("SHOT")
