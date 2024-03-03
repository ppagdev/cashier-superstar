extends Node2D

var life_scene = preload("res://scenes/life.tscn")
var lose_screen_scene = "res://scenes/lose_screen.tscn"
var bread_scene = preload("res://scenes/bread.tscn")
var milk_carton_scene = preload("res://scenes/milk_carton.tscn")

var combo = 0
var money_earned = 0.0
var time_elapsed = 0.0
var items_done = 0
var difficulty_modifier = 1.1
var difficulty = 1
var lives = 3
var base_treadmill_speed = 100.0
var treadmill_speed = base_treadmill_speed
var base_spawn_time = 3.0
var instanstiated_items = []
var available_lives = []

@onready var spawn_timer = get_node("SpawnTimer")
@onready var time_elapsed_label = get_node("TimeElapsed")
@onready var lives_zone_area = get_node("LivesZone/CollisionShape2D")
@onready var spawn_zone_area = get_node("SpawnZone/CollisionShape2D")
@onready var end_zone = get_node("EndZone")

# Called when the node enters the scene tree for the first time.
func _ready():
	display_lives()
	spawn_timer.wait_time = base_spawn_time

func get_score():
	var score = (difficulty * money_earned) * 0.2
	return snapped(score,0.01)

func increase_difficulty():
	difficulty += 1
	print("Difficulty " + str(difficulty))
	treadmill_speed *= difficulty_modifier
	spawn_timer.wait_time /= difficulty_modifier

func create_item(item_scene):
	var item = item_scene.instantiate()
	item.position = spawn_zone_area.position
	add_child(item)
	instanstiated_items.append(item)

func choose_item():
	var random_float = randf()
	if random_float < 0.5:
		return bread_scene
	else:
		return milk_carton_scene

func spawn_item():
	var item_scene = choose_item()
	create_item(item_scene)

func treadmill(delta):
	# move items
	for item in instanstiated_items:
		item.position.y = spawn_zone_area.position.y
		if !item.done:
			item.position += Vector2(treadmill_speed * delta,  0)

func lose():
	var score = get_score()
	Player.latest_score = score
	Player.money += score
	print("You made $" + str(score))
	print("You now have $" + str(Player.money))
	get_tree().change_scene_to_file(lose_screen_scene)

func display_lives():
	for c in available_lives:
		c.queue_free()
		available_lives.erase(c)
	for i in lives:
		var life = life_scene.instantiate()
		life.position.x = lives_zone_area.position.x + (i-1) * 70
		life.position.y = lives_zone_area.position.y
		add_child(life)
		available_lives.append(life)

func display_time():
	var minutes = time_elapsed / 60
	var seconds = fmod(time_elapsed,60)
	time_elapsed_label.text = "%02d:%02d" % [minutes, seconds]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	display_time()
	treadmill(delta)
	for item in instanstiated_items:
		if item.dragging:
			for i in instanstiated_items:
				if i == item:
					continue
				i.dragging_disabled = true
		item.dragging_disabled = false
	
	# lose game
	if lives <= 0:
		lose()

func _on_end_zone_area_entered(area):
	if area.get_parent().scanned:
		area.get_parent().done = true
		instanstiated_items.erase(area)
		area.queue_free()
		items_done += 1
		money_earned += area.get_parent().price
		combo += 1
		# up difficulty based on combo score
		if (combo % 3) == 0 and combo != 0:
			increase_difficulty()
		return
	instanstiated_items.erase(area)
	area.queue_free()
	lives -= 1
	display_lives()
	combo = 0


func _on_scanner_zone_area_entered(area):
	area.get_parent().scanned = true


func _on_button_toggled(toggled_on):
	get_tree().paused = toggled_on


func _on_spawn_timer_timeout():
	spawn_item()
	spawn_timer.start()
