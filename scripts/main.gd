extends Node2D

var bread_scene = preload("res://scenes/bread.tscn")
var milk_carton_scene = preload("res://scenes/milk_carton.tscn")

var treadmill_speed = 100
var spawn_time = 3
var instanstiated_items = []
@onready var spawn_zone_area = get_node("SpawnZone/CollisionShape2D")
@onready var end_zone = get_node("EndZone")

# Called when the node enters the scene tree for the first time.
func _ready():
	item_spawner()

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

func item_spawner():
	while true:
		var item_scene = choose_item()
		create_item(item_scene)
		await get_tree().create_timer(spawn_time).timeout

func treadmill(delta):
	# move items
	for item in instanstiated_items:
		item.position += Vector2(treadmill_speed * delta,  0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	treadmill(delta)



func _on_end_zone_area_entered(area):
	area.queue_free()
	instanstiated_items.erase(area)
