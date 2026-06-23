extends CharacterBody3D

var target = null
var target_position = null

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

func _ready():
	target = get_parent().get_node("player")


func _process(delta):
	target_position = target.global_position
	look_at(target_position - Vector3(0, target_position.y, 0) + Vector3(0, 1, 0))
	global_position = global_position.move_toward(target_position, delta * SPEED)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
