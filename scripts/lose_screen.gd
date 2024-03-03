extends Control

@onready var label = get_node("VSplitContainer/Label")

func _ready():
	label.text = "You earned: $" + str(Player.latest_score)

func _on_play_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_start_screen_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
