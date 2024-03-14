extends Control

var main_menu = "res://scenes/main_menu.tscn"

@onready var start_button = get_node("VSplitContainer/HSplitContainer/StartScreenButton")
@onready var label = get_node("VSplitContainer/Label")

func _ready():
	get_tree().paused = false
	await get_tree().create_timer(0.5).timeout
	label.text = "Items Sold: " + str(Player.latest_items_done)
	await get_tree().create_timer(0.5).timeout
	label.text += "\nMoney Earned: $" + str(Player.latest_score)
	await get_tree().create_timer(0.5).timeout
	start_button.disabled = false

func _on_start_screen_button_pressed():
	print("press")
	get_tree().change_scene_to_file(main_menu)
