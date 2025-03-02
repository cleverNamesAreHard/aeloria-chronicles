extends Node2D


# Content Panel nodes
@onready var content_panel: PanelContainer = $Content_PanelContainer
@onready var content_title_label: Label = $Content_PanelContainer/VBoxContainer/Content_Title_Label
@onready var content_text_label: Label = $Content_PanelContainer/VBoxContainer/Content_Text_Label

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

var character_id = null

func _on_scroll_container_ready():
	# We populate the OptionButton node contents dynamically so new content can be added without needing code changes
	populate_option_buttons()

func get_text_file_content(filePath) -> String:
	if not FileAccess.file_exists(filePath):
		print("❌ Error: File not found:", filePath)
		return ""
	var file = FileAccess.open(filePath, FileAccess.READ)
	if not file:
		print("❌ Error: Could not open file:", filePath)
		return ""
	return file.get_as_text()

func set_text_file_content(filePath, updated_content):
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	if not file:
		print("❌ Error: Could not write to file:", filePath)
		return
	file.store_string(updated_content)

func get_config(config_type, selected_option):
	# Pull and parse the selected option from the relevant config file
	if selected_option != "":
		var player_config = get_text_file_content("res://player_creation/player_" + config_type + ".json")
		var config_as_json = JSON.parse_string(player_config)[selected_option]
		return config_as_json
	else:
		content_panel.hide()

func configure(config_type, selected_option):
	# Update the content panel to show the summary of the selected option
	launch_panel.hide()
	if selected_option != "":
		var config = get_config(config_type, selected_option)
		content_title_label.text = selected_option
		content_text_label.text = config["description"]
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

# Display the summary of the selected option for all option types
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
	# Connect HTTPRequest to the _on_request_completed() function
	var http_request: HTTPRequest = $ScrollContainer/Character_Options_VBoxContainer/HTTPRequest
	http_request.request_completed.connect(_on_request_completed)

func _on_name_entered(new_text):
	check_character_name_availability(new_text)

func check_character_name_availability(character_name=""):
	if character_name == "":
		return false
	
	var url = "http://127.0.0.1:5000/check_name_avail?name=" + character_name
	var http_request = $ScrollContainer/Character_Options_VBoxContainer/HTTPRequest

	# Disconnect previous signal (if any) to avoid duplicate connections
	if http_request.request_completed.is_connected(_on_request_completed):
		http_request.request_completed.disconnect(_on_request_completed)

	http_request.request_completed.connect(_on_request_completed.bind("check_name_avail"))
	# See __on_request_completed() for response parsing
	http_request.request(url)

func validate_option_buttons():
	# See also populate_option_buttons()
	var required_options = {
		"Class": class_option.text,
		"Area": area_option.text,
		"Race": race_option.text,
		"Faction": faction_option.text,
		"Background": background_option.text
	}

	for key in required_options:
		if required_options[key] == "":
			print("❌ %s not selected" % key)
			return false
	return true

func parse_check_name_available(response_code, json):
	# /check_name_avail returns 200 whether the name was found or not, but only if the query actually runs.
	# If the query fails the endpoint will not return a 200, and we know there was an issue server-side.
	if response_code != 200:
		print("❌ Error: Failed to check name availability. Response code:", response_code)
		return
		
	# We use the launch panel to allow the player to create their character and move forward, as well as to
	#   display errors that may have occured in the process to create the character.
	if json and json.has("available"):
		if json["available"]:
			content_panel.hide()
			launch_panel.show()
			if validate_option_buttons():
				launch_label.text = "Are you sure you wish to proceed with the username " + $ScrollContainer/Character_Options_VBoxContainer/Name_TextEdit.text
				launch_button.show()
			else:
				print("❌ Failed field validation")
				launch_label.text = "Please select an option for each choice to the left."
				launch_button.hide()
		else:
			print("❌ Name is taken.")
	else:
		print("❌ Error: Unexpected server response for name check.")

func parse_create_character(response_code, json):
	# /create_character (game_server.py) returns a 201 on successful character creation
	if response_code != 201:
		print("❌ Error: Failed to create character. Response code:", response_code)
		return
	# The player/player_config.json file contains the player_id field, which will be used to validate player states,
	#   etc. with the server.  Short-term it will only be used to bypass the character creation screen while ensuring
	#   we maintain access to a valid record in the database
	if json and json.has("character_id"):
		character_id = json["character_id"]
		store_character_id()
		get_tree().change_scene_to_file("res://story_scenes/story_intro.tscn")
	else:
		print("⚠️ Warning: Response missing character_id")

func _on_request_completed(result, response_code, headers, body, request_type = "UNKNOWN"):
	# Functions check_character_name_availability() and _on_launch_button_pressed() generate HTTPRequest calls
	# This function parses out the requests and performs functionality based on the responses.
	# See parse_check_name_available() and <> for parsing details
	# See game_server.py as a starting point for API calls
	var json = JSON.parse_string(body.get_string_from_utf8())

	if request_type == "UNKNOWN":
		print("❌ Error: request_type is missing or incorrect!")
		return

	# TODO: Replace this with entire "if-else" to an external function so it's more modular, and easy to target functionality
	if request_type == "check_name_avail":
		parse_check_name_available(response_code, json)
	elif request_type == "create_character":
		parse_create_character(response_code, json)

func _on_create_character_button_pressed():
	var character_name = $ScrollContainer/Character_Options_VBoxContainer/Name_TextEdit.text.strip_edges()
	check_character_name_availability(character_name)

func store_character_id():
	var player_config_file = "res://player/player_config.json"
	var config_as_json = JSON.parse_string(get_text_file_content(player_config_file))
	config_as_json["player_id"] = character_id
	config_as_json["current_scene"] = "story_scenes/story_intro.tscn"
	set_text_file_content(player_config_file, JSON.stringify(config_as_json))

func _on_launch_button_pressed():
	# Prep HTTP Request
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(_on_request_completed.bind("create_character"))  

	var character_name = $ScrollContainer/Character_Options_VBoxContainer/Name_TextEdit.text.strip_edges()
	var selected_class = class_option.text
	var selected_area = area_option.text
	var selected_background = background_option.text
	var selected_race = race_option.text
	var selected_faction = faction_option.text
	
	# JSON-formatted payload
	var character_data = {
		"name": character_name,
		"class": selected_class,
		"area": selected_area,
		"background": selected_background,
		"race": selected_race,
		"faction": selected_faction
	}

	# See _on_request_completed() to see functionality for the "create_character" option
	var json_data = JSON.stringify(character_data)
	var url = "http://127.0.0.1:5000/create_character"
	var headers = ["Content-Type: application/json"]
	var res = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if res != OK:
		print("❌ Error: Failed to send character creation request. Error Code:", res)
