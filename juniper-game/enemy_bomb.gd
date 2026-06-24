extends CharacterBody3D

var target = null
var target_position = null

const HEALTH = 2
const DAMAGE = 5
const SPEED = 5.0

func _ready():
	target = get_parent().get_node("player")

func _process(delta):
	target_position = target.global_position
	look_at(target_position - Vector3(0, target_position.y, 0) + Vector3(0, 1, 0))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_shot_timer_timeout():
	$bomb.position = Vector3(0, 0, -1)
	print("LOBBED")
	
	$bomb/CollisionShape3D2.disabled = false
	$bomb.global_position = $bomb.global_position.move_toward(target_position, 10)
	$shotTimer.start()


func _on_bomb_body_entered(body):
	if body.name == "player":
		print("EXPLOSION")
		$bomb.position = Vector3(0, 0, -1)
		$bomb/CollisionShape3D2.disabled = true
