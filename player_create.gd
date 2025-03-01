extends Node2D


@onready var content_panel: PanelContainer = $Content_PanelContainer
@onready var content_title_lable: Label = $Content_PanelContainer/VBoxContainer/Content_Title_Label
@onready var content_text_lable: Label = $Content_PanelContainer/VBoxContainer/Content_Text_Label

# Option Buttons
@onready var class_option: OptionButton = $ScrollContainer/Character_Options_VBoxContainer/Class_OptionButton
@onready var area_option: OptionButton = $ScrollContainer/Character_Options_VBoxContainer/Area_OptionButton
@onready var background_option: OptionButton = $ScrollContainer/Character_Options_VBoxContainer/Background_OptionButton
@onready var race_option: OptionButton = $ScrollContainer/Character_Options_VBoxContainer/Race_OptionButton
@onready var faction_option: OptionButton = $ScrollContainer/Character_Options_VBoxContainer/Faction_OptionButton

# Launch Button
@onready var launch_panel: PanelContainer = $Launch_PanelContainer
@onready var launch_label: Label = $Launch_PanelContainer/VBoxContainer/Launch_Label
@onready var launch_button: Button = $Launch_PanelContainer/VBoxContainer/LaunchButton

func _on_scroll_container_ready():
	populate_option_buttons()

func get_text_file_content(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content

func get_config(config_type, selected_option):
	if selected_option != "":
		var player_config = get_text_file_content("res://player_creation/player_" + config_type + ".json")
		var config_as_json = JSON.parse_string(player_config)[selected_option]
		return config_as_json
	else:
		content_panel.hide()

func configure(config_type, selected_option):
	launch_panel.hide()
	if selected_option != "":
		var config = get_config(config_type, selected_option)
		content_title_lable.text = selected_option
		content_text_lable.text = config["description"]
		content_panel.show()
	else:
		content_panel.hide()

func populate_option_buttons():
	# Don't forget to add them to the @onready section up top. They're needed in the item_selected functions
	var option_button_map = {
		"classes": $ScrollContainer/Character_Options_VBoxContainer/Class_OptionButton,
		"area": $ScrollContainer/Character_Options_VBoxContainer/Area_OptionButton,
		"backgrounds": $ScrollContainer/Character_Options_VBoxContainer/Background_OptionButton,
		"race": $ScrollContainer/Character_Options_VBoxContainer/Race_OptionButton,
		"factions": $ScrollContainer/Character_Options_VBoxContainer/Faction_OptionButton
	}
	for config_type in option_button_map:
		var config_as_json = JSON.parse_string(get_text_file_content("res://player_creation/player_" + config_type + ".json"))
		option_button_map[config_type].add_item("")
		for option in config_as_json:
			option_button_map[config_type].add_item(option)

func _on_starting_class_option_button_item_selected(index):
	var config_type = "classes"
	var selected_option = class_option.text
	configure(config_type, selected_option)

func _on_starting_area_option_button_item_selected(index):
	var config_type = "area"
	var selected_option = area_option.text
	configure(config_type, selected_option)

func _on_starting_background_option_button_item_selected(index):
	var config_type = "backgrounds"
	var selected_option = background_option.text
	configure(config_type, selected_option)

func _on_starting_race_option_button_item_selected(index):
	var config_type = "race"
	var selected_option = race_option.text
	configure(config_type, selected_option)

func _on_starting_faction_option_button_item_selected(index):
	var config_type = "factions"
	var selected_option = faction_option.text
	configure(config_type, selected_option)

func _ready():
	var http_request: HTTPRequest = $ScrollContainer/Character_Options_VBoxContainer/HTTPRequest
	http_request.request_completed.connect(_on_request_completed)

func _on_name_entered(new_text):
	check_character_name_availability(new_text)

func check_character_name_availability(character_name=""):
	if character_name == "":
		return false
	# Construct request URL with the character name
	var url = "http://127.0.0.1:5000/check_name_avail?name=" + character_name
	
	# Send the request
	$ScrollContainer/Character_Options_VBoxContainer/HTTPRequest.request(url)

func validate_option_buttons():
	if class_option.text == "":
		return false
	if area_option.text == "":
		return false
	if race_option.text == "":
		return false
	if faction_option.text == "":
		return false
	if background_option.text == "":
		return false
	return true

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Error: Failed to check name availability. Response code:", response_code)
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json and json.has("available"):
		if json["available"]:
			content_panel.hide()
			
			if validate_option_buttons():
				print("Passed field validation")
				launch_label.text = "Are you sure you wish to proceed with the username " + $ScrollContainer/Character_Options_VBoxContainer/Name_TextEdit.text
				launch_panel.show()
				launch_button.show()
			else:
				print("Failed field validation")
				launch_label.text = "Please select an option for each choice to the left."
				launch_panel.show()
				launch_button.hide()
		else:
			return false
	else:
		return false

func _on_create_character_button_pressed():
	var character_name = $ScrollContainer/Character_Options_VBoxContainer/Name_TextEdit.text.strip_edges()
	check_character_name_availability(character_name)

func _on_launch_button_pressed():
	# Create a new HTTPRequest node dynamically
	var http_request = HTTPRequest.new()
	add_child(http_request)  # Attach to scene so it runs
	http_request.request_completed.connect(_on_request_completed)

	var character_name = $ScrollContainer/Character_Options_VBoxContainer/Name_TextEdit.text.strip_edges()
	var selected_class = class_option.text
	var selected_area = area_option.text
	var selected_background = background_option.text
	var selected_race = race_option.text
	var selected_faction = faction_option.text
	
	# Construct the JSON payload
	var character_data = {
		"name": character_name,
		"class": selected_class,
		"area": selected_area,
		"background": selected_background,
		"race": selected_race,
		"faction": selected_faction
	}

	var json_data = JSON.stringify(character_data)
	var url = "http://127.0.0.1:5000/create_character"
	var headers = ["Content-Type: application/json"]
	
	# Send the POST request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		print("❌ Error: Failed to send character creation request. Error Code: ", error)
	else:
		get_tree().change_scene_to_file("res://story_scenes/story_intro.tscn")
