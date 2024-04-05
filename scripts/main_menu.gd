extends Node2D

var main_scene = "res://scenes/main.tscn"
var blinking = true

@onready var fx_slider = get_node("VolumeSliders/FxSlider")
@onready var fx_bus = AudioServer.get_bus_index("Fx")
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var music_slider = get_node("VolumeSliders/MusicSlider")
@onready var high_score_label = get_node("HighScoreLabel")
@onready var play_button = get_node("PlayButton")
@onready var main_menu_theme = get_node("MainMenuThemePlayer")

func _ready():
	Player.load()
	music_slider.value = AudioServer.get_bus_volume_db(music_bus)
	fx_slider.value = AudioServer.get_bus_volume_db(fx_bus)
	high_score_label.text = "HIGH SCORE: $" + str(Player.player["high_score"])
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


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, value)


func _on_fx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(fx_bus, value)
