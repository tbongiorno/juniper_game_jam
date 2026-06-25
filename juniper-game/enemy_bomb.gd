extends CharacterBody3D

@export var curve: Curve
@export var stopping_distance: int = 0.2

var target = null
var target_position = null

var bomb_moving = false
@export var bomb_speed = 5
var bomb_direction = null

const HEALTH = 2
const DAMAGE = 5
const SPEED = 5


###BOMB PHYSICS
var gravity = 5
var bomb_velocity = Vector3(0, 5, 0)

func _ready():
	target = get_parent().get_node("player")

func _process(delta):
	target_position = target.global_position
	look_at(target_position - Vector3(0, target_position.y, 0) + Vector3(0, 1, 0))
	
	if bomb_moving:
		bomb_velocity.y -= gravity * delta
		$bomb.global_position -= (bomb_direction - bomb_velocity) * bomb_speed * delta

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_shot_timer_timeout():
	print($bomb.global_position)
	$bomb.position = Vector3(0, 0, -1)
	print("LOBBED")
	bomb_moving = true
	bomb_direction = global_position - target_position
	bomb_direction = Vector3(bomb_direction.x, 0, bomb_direction.z)
	bomb_velocity = bomb_direction.normalized() * 8
	bomb_velocity.y = 10
	
	print(bomb_direction)
	$bomb/CollisionShape3D2.disabled = false

func _on_bomb_body_entered(body):
	if body.name == "player":
		print("EXPLOSION")
		bomb_moving = false
		$bomb.position = Vector3(0, 0.5, 0)
		$bomb/CollisionShape3D2.disabled = true
