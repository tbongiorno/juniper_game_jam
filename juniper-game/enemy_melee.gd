extends CharacterBody3D

var target = null
var target_position = null

var HEALTH = 5
var DAMAGE = 5
var SPEED = 3.5

var add_speed = 0

func _ready():
	target = get_parent().get_parent().get_node("player")

func _process(delta):
	target_position = target.global_position
	look_at(target_position - Vector3(0, target_position.y / 2, 0))
	global_position = global_position.move_toward(target_position, delta * (SPEED + add_speed))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func set_add_speed(speed):
	add_speed = speed


func _on_melee_area_body_entered(body):
	if body.name == "player":
		target.damage_player(DAMAGE)
