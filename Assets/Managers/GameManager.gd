extends Node

# Game manager. A singleton scripts for managing game states and dependencies

# camera
var camera_transform : Transform

# save game resource
const GAME_SAVE_PATH : String = "user://GameSave.tres"
var game_save : GameSave


func _ready() -> void:
	load_save_game()
	
	
func load_save_game() -> void:
	var dir : Directory = Directory.new()
	if dir.file_exists(GAME_SAVE_PATH):
		game_save = load(GAME_SAVE_PATH)
	else:
		game_save = GameSave.new()
