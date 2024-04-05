extends Node2D

var latest_score = 0.0
var latest_items_done = 0.0

var player = {
	"high_score" : 0.0,
}

func save():
	var json_string = JSON.stringify(player)
	var save_file = FileAccess.open("user://player.save", FileAccess.WRITE)
	save_file.store_string(json_string)
	print("Game saved successfully.")

func load():
	if not FileAccess.file_exists("user://player.save"):
		print("No save file found.")
		return
	var load_file = FileAccess.open("user://player.save", FileAccess.READ)
	var json = JSON.new()
	var json_data = load_file.get_as_text()
	var _parse_result = json.parse(json_data)
	var player_data = json.get_data()
	load_file.close()
	if player_data is Dictionary:
		for k in player_data.keys():
			player[k] = player_data[k]
		print("Game loaded successfully.")
	else:
		print("Failed to load game data.")
