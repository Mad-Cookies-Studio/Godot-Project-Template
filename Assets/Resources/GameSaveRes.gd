class_name GameSave
extends Resource

const SAVE_PATH : String = "user://GameSave.tres"

export(String) var player_name : String = ""

func save() -> void:
	var err : int = ResourceSaver.save(SAVE_PATH, self)
	if err == OK:
		SignalBus.emit_signal("game_saved")
	else:
		SignalBus.emit_signal("game_save_problem")
	
