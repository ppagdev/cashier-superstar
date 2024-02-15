extends Node2D

@onready var area2d = get_node("Area2D")
var dragging = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		self.position = Vector2(mouse_pos.x, mouse_pos.y)


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			dragging = true
		else:
			dragging = false
