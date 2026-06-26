extends CharacterBody3D

var target = null
var target_position = null

var HEALTH = 1
var DAMAGE = 3
var SPEED = 5

var add_speed = 0

func _ready():
	target = get_parent().get_parent().get_node("player")

func _process(delta):
	# CHANGE TO FLY
	target_position = target.global_position
	#look_at(target_position - Vector3(0, target_position.y, 0) + Vector3(0, 1, 0))
	look_at(target_position)
	global_position = global_position.move_toward(target_position, delta * (SPEED + add_speed))

func _physics_process(delta):
	move_and_slide()

func set_add_speed(speed):
	add_speed = speed


func _on_fly_area_body_entered(body):
	if body.name == "player":
		target.damage_player(DAMAGE)
