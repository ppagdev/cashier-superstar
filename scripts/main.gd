extends Node2D

var life_scene = preload("res://scenes/life.tscn")
var lose_screen_scene = "res://scenes/lose_screen.tscn"
var bread_scene = preload("res://scenes/bread.tscn")
var milk_carton_scene = preload("res://scenes/milk_carton.tscn")

var good_messages = [
	"WELL DONE!",
	"ALRIGHT!",
	"WOW!!!",
	"AMAZING!",
	"GOOD JOB!",
]

var bad_messages = [
	"OH NO!",
	"TOO BAD!",
	"NOT GOOD!",
	"BAD! BAD!",
]

var scanner_off = false
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

@onready var shutter = get_node("MetalShutter")
@onready var blur_effect = get_node("BlurEffect").material
@onready var scanner_light = get_node("ScannerLight")
@onready var item_code_label = get_node("ItemCodeLabel")
@onready var scanner_label = get_node("ScannerLabel")
@onready var spawn_timer = get_node("SpawnTimer")
@onready var time_elapsed_label = get_node("TimeElapsed")
@onready var scanner_zone_area = get_node("ScannerZone/CollisionShape2D")
@onready var lives_zone_area = get_node("LivesZone/CollisionShape2D")
@onready var spawn_zone_area = get_node("SpawnZone/CollisionShape2D")
@onready var end_zone = get_node("EndZone")

# Called when the node enters the scene tree for the first time.
func _ready():
	await decrease_blur()
	connect_buttons()
	display_lives()
	spawn_timer.wait_time = base_spawn_time

func decrease_blur():
	while blur_effect.get_shader_parameter("lod") > 0.0:
		blur_effect.set_shader_parameter("lod", blur_effect.get_shader_parameter("lod") - 0.1)
		await get_tree().create_timer(0.01).timeout

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

func shutter_animation():
	get_node("GarageDoorSound").play()
	while shutter.position.y < -240:
		shutter.position.y += 5
		await get_tree().create_timer(0.01).timeout

func lose():
	display_lives()
	get_tree().paused = true
	var score = get_score()
	Player.latest_items_done = items_done
	Player.latest_score = score
	Player.money += score
	print("You made $" + str(score))
	print("You now have $" + str(Player.money))
	await shutter_animation()
	await get_tree().create_timer(1.5).timeout
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

func scroll_label():
	if len(scanner_label.text) <= 6:
		return
	else:
		var first_letters = scanner_label.text.left(8)
		var remaining_letters = scanner_label.text.substr(8,)
		scanner_label.text = first_letters
		for letter in remaining_letters:
			await get_tree().create_timer(0.2).timeout
			if scanner_off:
				return
			scanner_label.text = scanner_label.text.substr(1,)
			scanner_label.text += letter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	display_time()
	treadmill(delta)
	if !scanner_off:
		scroll_label()
	for item in instanstiated_items:
		if item.scanning:
			item.position = scanner_zone_area.position
			if scanner_label.text == item.code:
				item.scanning = false
				item.scanned = true
				scanner_off = false
				item_code_label.hide()
		if item.dragging:
			for i in instanstiated_items:
				if i == item:
					continue
				i.dragging_disabled = true
		item.dragging_disabled = false
	
	# lose game
	if lives <= 0:
		lose()

func get_good_message():
	return good_messages.pick_random()

func get_bad_message():
	return bad_messages.pick_random()

func checkout(area):
	# play cha ching sound effect
	get_node("CashRegisterSound").play()
	
	# handle item
	area.get_parent().done = true
	instanstiated_items.erase(area)
	area.queue_free()
	
	# update score
	items_done += 1
	money_earned += area.get_parent().price
	combo += 1
	
	# print good message
	if !scanner_off:
		scanner_label.text = get_good_message()
	
	# update difficulty based on combo score
	if (combo % 3) == 0 and combo != 0:
		increase_difficulty()

func strike(area):
	# error sound effect
	get_node("ErrorSound").play()
	
	instanstiated_items.erase(area)
	area.queue_free()
	lives -= 1
	display_lives()
	# print bad message
	if !scanner_off:
		scanner_label.text = get_bad_message()
	combo = 0

func _on_end_zone_area_entered(area):
	if area.get_parent().scanned:
		checkout(area)
		return
	strike(area)

func scanner_light_animation():
	while scanner_light.energy < 3:
		scanner_light.energy += 1
	await get_tree().create_timer(0.5).timeout
	while scanner_light.energy > 1:
		scanner_light.energy -= 1

func _on_scanner_zone_area_entered(area):
	if scanner_off or area.get_parent().scanned:
		return
	
	if randi_range(0,3) == 1:
		get_node("ScannerMalfunctionSound").play()
		var item = area.get_parent()
		item.scanning = true
		scanner_off = true
		scanner_label.text = ""
		item_code_label.text = item.code
		item_code_label.show()
		return
	
	get_node("ScannerBeepSound").play()
	scanner_light_animation()
	
	area.get_parent().scanned = true


func _on_button_toggled(toggled_on):
	get_tree().paused = toggled_on


func _on_spawn_timer_timeout():
	spawn_item()
	spawn_timer.start()

func connect_buttons():
	for button in get_tree().get_nodes_in_group("keyboard_buttons"):
		button.pressed.connect(_on_button_pressed.bind(button.get_child(0).text))

func _on_button_pressed(arg):
	get_node("KeyPressSound").play()
	if arg == "C":
		scanner_label.text = ""
		return
	if len(scanner_label.text) > 3:
		return
	scanner_label.text += arg
