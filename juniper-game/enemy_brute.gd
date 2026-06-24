extends CharacterBody3D

var target = null
var target_position = null

const HEALTH = 10
const DAMAGE = 7
const SPEED = 5.0

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

	move_and_slide()
