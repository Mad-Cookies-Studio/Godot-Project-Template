extends Node

# Game manager. A singleton scripts for managing game states and dependencies

# camera
var camera_transform : Transform

# save game resource
const GAME_SAVE_PATH : String = "user://GameSave.tres"
const SETTINGS_PATH : String = "user://Settings.tres"
var game_save : GameSave
var game_settings : GameSettings


func _ready() -> void:
	load_save_game()
	load_settings()
	
	
func load_save_game() -> void:
	var dir : Directory = Directory.new()
	if dir.file_exists(GAME_SAVE_PATH):
		game_save = load(GAME_SAVE_PATH)
	else:
		game_save = GameSave.new()


func load_settings() -> void:
	var dir : Directory = Directory.new()
	if dir.file_exists(SETTINGS_PATH):
		game_settings = load(SETTINGS_PATH)
	else:
		game_settings = GameSettings.new()
