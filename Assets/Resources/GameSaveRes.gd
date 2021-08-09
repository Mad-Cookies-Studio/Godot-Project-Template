class_name GameSave
extends Resource

const SAVE_PATH : String = "user://GameSave.tres"

export(String) var player_name : String = ""


func save() -> void:
	ResourceSaver.save(SAVE_PATH, self)
