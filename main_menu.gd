extends Control



func get_text_file_content(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content

func get_next_scene():
	var player_config = get_text_file_content("res://player/player_config.json")
	var json_as_dict = JSON.parse_string(player_config)
	if json_as_dict["player_id"]:
		var next_scene = "res://" + json_as_dict["current_scene"]
		get_tree().change_scene_to_file(next_scene)
	else:
		get_tree().change_scene_to_file("res://player_create.tscn")

func _on_play_pressed():
		get_next_scene()

func _on_options_pressed():
	get_tree().change_scene_to_file("res://options.tscn")

func _on_ready():
	pass # Replace with function body.
