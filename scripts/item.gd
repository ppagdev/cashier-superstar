extends Node2D

var dragging = false
var dragging_disabled = false
var done = false
var scanned = false
@export var price = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		self.position = Vector2(mouse_pos.x, mouse_pos.y)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if done or dragging_disabled:
		dragging = false
		return
	if event is InputEventScreenTouch:
		if event.is_pressed():
			dragging = true
		else:
			dragging_disabled = false
			dragging = false
