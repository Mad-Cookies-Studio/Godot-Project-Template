class_name GameSettings
extends Resource

### Game settings. This resource is used to persistently store settings choen for the game
### ALternatively it can be loaded up anew to restore default ones

const SAVE_PATH : String = "user://Settings.tres"

# video
export(bool) var fullscreen : = true
export(bool) var vsync : = true
export(bool) var fxaa : = true
export(bool) var ssao : = true
export(bool) var whirl_effect : = true
export(bool) var glow : = true
export(int) var shadow_quality : = 2 # list options here to know what to do

# general
export(bool)var show_fps : bool = false

# audio
export(bool) var music : = true
export(float) var music_vol : = 1.0
export(bool) var sfx : = true
export(float) var sfx_vol : = 1.0

# camera
export(float) var fov : float = 80.0

# gameplay
export(float) var mouse_sensitivity : float = 1.55
export(float) var mouse_smooth : float = 0.66

func change() -> void:
	SignalBus.emit_signal("settings_changed")


func save() -> void:
	var err : int = ResourceSaver.save(SAVE_PATH, self)
	if err == OK:
		SignalBus.emit_signal("settings_saved")
	else:
		SignalBus.emit_signal("settings_save_problem")
