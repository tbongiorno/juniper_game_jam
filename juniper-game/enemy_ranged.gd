extends CharacterBody3D

var target = null
var target_position = null

var bullet_moving = false
var bullet_speed = 8
var bullet_direction = null

var HEALTH = 3
var DAMAGE = 3
var SPEED = 2.5
var POINTS = 2

var add_speed = 0

func _ready():
	target = get_parent().get_parent().get_node("player")

func _process(delta):
	target_position = target.global_position
	look_at(target_position - Vector3(0, target_position.y / 2, 0))
	#global_position = global_position.move_toward(target_position, delta * (SPEED + add_speed))
	
	if bullet_moving:
		$bullet.global_position -= bullet_direction * bullet_speed * delta

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_shot_timer_timeout():
	$bullet.position = Vector3(0, 0.5, 0)
	print("FIRED")
	bullet_moving = true
	bullet_direction = (global_position - target_position).normalized()
	bullet_direction.y /= 4
	print(bullet_direction)
	$bullet/CollisionShape3D2.disabled = false

func _on_bullet_body_entered(body):
	if body.name == "player":
		target.damage_player(DAMAGE)
		print("SHOT")
		bullet_moving = false
		$bullet.position = Vector3(0, 0.5, 0)
		$bullet/CollisionShape3D2.disabled = true


func set_add_speed(speed):
	add_speed = speed

func take_damage(damage):
	print("DAMAGED")
	HEALTH -= damage
	$Sprite3D.texture = load("res://images/ranged_damage.png")
	$Sprite3D.modulate = Color(255, 60, 60)
	SPEED *= 0.75
	
	if HEALTH <= 0:
		self.queue_free()
		return POINTS
	else:
		$Sprite3D.texture = load("res://images/clean_range_sprite.png")
		$Sprite3D.modulate = Color(255, 255, 255)
		SPEED /= 0.75
		return 0
