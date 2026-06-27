extends Node3D

var spawn_area = null
var curr_add_speed = 0

var random = RandomNumberGenerator.new()

var melee = load("res://enemy_melee.tscn")
var ranged = load("res://enemy_ranged.tscn")
var bomb = load("res://enemy_bomb.tscn")
var fly = load("res://enemy_fly.tscn")
var brute = load("res://enemy_brute.tscn")

var startScreen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_area = $enemy_spawn_area
	$musicPlayer.playing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if startScreen:
		var tween = create_tween()
		$startScreen/Button.visible = false
		tween.tween_property($startScreen/ColorRect, "color", Color.TRANSPARENT, 1)
		await tween.finished
		


func spawn_enemy():
	print("SPAWNING ENEMY")
	var random_float = random.randf()
	var new_enemy = null
	var flyer = false
	
	if random_float <= 0.3:
		new_enemy = melee.instantiate()
	elif random_float <= 0.55:
		new_enemy = ranged.instantiate()
	elif random_float <= 0.75:
		new_enemy = fly.instantiate()
		flyer = true
	elif random_float <= 0.9:
		new_enemy = bomb.instantiate()
	else:
		new_enemy = brute.instantiate()
	$enemies.add_child(new_enemy)
	
	if not flyer:
		new_enemy.global_position = Vector3(random.randi_range(-20, 20), 1.5, random.randi_range(-20, 20))
	else:
		new_enemy.global_position = Vector3(random.randi_range(-20, 20), random.randi_range(5, 20), random.randi_range(-20, 20))
	
	print(new_enemy.global_position)

func _on_timer_timeout():
	curr_add_speed += 0.2
	$enemy_timer.stop()
	$enemy_timer.wait_time *= 0.95
	for enemy in $enemies.get_children():
		enemy.set_add_speed(curr_add_speed)
	$enemy_timer.start()


func _on_enemy_timer_timeout():
	spawn_enemy()
	


func _on_button_pressed() -> void:
	startScreen = true
	
