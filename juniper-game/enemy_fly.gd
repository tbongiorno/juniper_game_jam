extends CharacterBody3D

var target = null
var target_position = null

const HEALTH = 1
const DAMAGE = 3
const SPEED = 4.5

func _ready():
	target = get_parent().get_node("player")

func _process(delta):
	# CHANGE TO FLY
	target_position = target.global_position
	#look_at(target_position - Vector3(0, target_position.y, 0) + Vector3(0, 1, 0))
	look_at(target_position)
	global_position = global_position.move_toward(target_position, delta * SPEED)

func _physics_process(delta):
	move_and_slide()
