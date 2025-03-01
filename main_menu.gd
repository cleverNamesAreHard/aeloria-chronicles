extends Control



func get_text_file_content(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content

func get_player_config():
	var player_config = get_text_file_content("res://game_config.json")
	var json_as_dict = JSON.parse_string(player_config)
	return json_as_dict

func _on_play_pressed():
	var player_config = get_player_config()
	if player_config["main_menu"]["new_player"] == true:
		print("Going to player create screen")
		get_tree().change_scene_to_file("res://player_create.tscn")
	else:
		get_tree().change_scene_to_file("res://game_home.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://options.tscn")

func _on_ready():
	pass # Replace with function body.
