extends CharacterBody3D

var target = null
var target_position = null

var bomb_placed = false

var HEALTH = 2
var DAMAGE = 5
var SPEED = 3

var add_speed = 0


func _ready():
	target = get_parent().get_parent().get_node("player")
	$placeTimer.start()

func _process(delta):
	target_position = target.global_position
	look_at(target_position - Vector3(0, target_position.y / 2, 0))
	
	if bomb_placed:
		$bomb.global_position = $bomb.global_position
		$bomb.look_at(Vector3(0, 0, 0))
		
		$explosion.global_position = $explosion.global_position
		$explosion.look_at(Vector3(0, 0, 0))
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()


func _on_bomb_body_entered(body):
	if body.name == "player" and bomb_placed:
		$placeTimer.stop()
		explode_bomb()
		
		

func set_add_speed(speed):
	add_speed = speed

func explode_bomb():
	print("EXPLOSION")
	$explosion.show()
	
	for body in $explosion.get_overlapping_bodies():
		if body.name == "player":
			print("BLOWN UP")
			target.damage_player(DAMAGE)
	
	$explosion.hide()
	$bomb/bombCollision.hide()
	$bomb.hide()
	
	$bomb.position = Vector3(0, 0, 0)
	bomb_placed = false
	$placeTimer.start()
	

func _on_place_timer_timeout():
	print("PLACED")
	$bomb.show()
	$bomb/bombCollision.show()
	bomb_placed = true
	await get_tree().create_timer(3).timeout
	
	explode_bomb()
