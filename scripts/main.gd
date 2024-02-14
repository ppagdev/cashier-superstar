extends Node2D

var bread_scene = preload("res://scenes/bread.tscn")
var treadmill_speed = 200
var instanstiated_items = []

# Called when the node enters the scene tree for the first time.
func _ready():
	create_item(bread_scene)

func create_item(item_scene):
	var item = item_scene.instantiate()
	item.position = Vector2(0,360)
	add_child(item)
	instanstiated_items.append(item)

func treadmill(delta):
	for item in instanstiated_items:
		item.position += Vector2(treadmill_speed * delta,  0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	treadmill(delta)
