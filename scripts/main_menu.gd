extends Node2D

var main_scene = "res://scenes/main.tscn"
var blinking = true

@onready var play_button = get_node("PlayButton")
@onready var main_menu_theme = get_node("MainMenuThemePlayer")

func _ready():
	intermitent_opacity()

func intermitent_opacity():
	while blinking:
		await get_tree().create_timer(0.005).timeout
		while play_button.modulate.a8 < 255:
			play_button.modulate.a8 += 5
			await get_tree().create_timer(0.005).timeout
		while play_button.modulate.a8 > 0:
			play_button.modulate.a8 -= 5
			await get_tree().create_timer(0.005).timeout

func _on_play_button_pressed():
	blinking = false
	main_menu_theme.stop()
	get_tree().change_scene_to_file(main_scene)
