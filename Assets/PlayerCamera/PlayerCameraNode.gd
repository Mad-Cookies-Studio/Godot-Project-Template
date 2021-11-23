extends Spatial

const ROT_LIMIT_MAX : int = 85
const ROT_LIMIT_MIN : int = -85

const MIN_ZOOM : float = 0.5
const MAX_ZOOM : float = 1000.0

const MAX_SMOOTH : float = 35.0

var mouse_speed : Vector2
var mouse_sensitivity : float = 0.8
## 35 is none
## 12 is default
## 0 is max
var mouse_smooth_amount : float = 12.0
var game_pad_sensitivity : float = 3.0
var smooth_mouse : Vector2

var target = null
var previous_target = null
export(float) var lerp_speed : float = 1.0

var zoom_distance : float = 1.5

onready var camera : ClippedCamera = $PivotY/PivotX/ClippedCamera

onready var pivot_y : Spatial = $PivotY
onready var pivot_x : Spatial = $PivotY/PivotX

var game_pad_force : Vector2
var smooth_pad : Vector2

#defaults
var def_fov : float = 80.0
var def_distance : float = 45.959


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	connect_signals()
	apply_settings()
	
	
func connect_signals() -> void:
	SignalBus.connect("change_camera_target", self, "on_change_camera_target")
	SignalBus.connect("revert_camera_target", self, "on_revert_camera_target")
	SignalBus.connect("set_camera_fov", self, "on_set_camera_fov")
	SignalBus.connect("add_camera_collision_exception", self, "on_add_camera_collision_exception")
	SignalBus.connect("clear_camera_collision_excpetions", self, "on_clear_camera_collision_excpetions")
	SignalBus.connect("change_mouse_sensitivity", self, "on_change_mouse_sensitivity")
	SignalBus.connect("settings_changed", self, "on_settings_changed")
	
	
func apply_settings() -> void:
	# fov
	$PivotY/PivotX/ClippedCamera.fov = GameManager.game_settings.fov
	def_fov = GameManager.game_save.fov
	# mouse sensitvity
	mouse_sensitivity = GameManager.game_save.mouse_sensitivity
	# mouse smooth
	mouse_smooth_amount = MAX_SMOOTH - ((GameManager.game_save.mouse_smooth - 0.05) * MAX_SMOOTH)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_speed = event.relative
		
		
func _process(delta: float) -> void:
	get_gamepad_force()
	interpolate_inputs(delta)
	rotate_cam(delta)
	
	GameManager.camera_transform = camera.global_transform
	GameManager.camera_x_rot = pivot_y.rotation.y
	GameManager.camera_y_rot = pivot_x.rotation.x
	
	
func _physics_process(delta: float) -> void:
	follow_target(delta)
	
	
func follow_target(delta : float) -> void:
	if target == null: return
	translation = translation.linear_interpolate(target.global_transform.origin, lerp_speed * delta)


func get_gamepad_force() -> void:
	game_pad_force.x = -Input.get_action_strength("gp_cam_x_left") + Input.get_action_strength("gp_cam_x_right")
	game_pad_force.y = -Input.get_action_strength("gp_cam_y_down") + Input.get_action_strength("gp_cam_y_up")


func interpolate_inputs(delta : float) -> void:
	smooth_pad = smooth_pad.linear_interpolate(game_pad_force, 4.0 * delta)
	smooth_mouse = smooth_mouse.linear_interpolate(mouse_speed, mouse_smooth_amount * delta)

	
func rotate_cam(delta) -> void:
	# mouse
	pivot_y.rotate_y(-smooth_mouse.x * mouse_sensitivity * delta)
	pivot_x.rotate_x(-smooth_mouse.y * mouse_sensitivity * delta)
#	#gamepad
	pivot_y.rotate_y(-smooth_pad.x * game_pad_sensitivity * delta)
	pivot_x.rotate_x(smooth_pad.y * game_pad_sensitivity * delta)
	#clamp
	pivot_x.rotation.x = clamp(pivot_x.rotation.x, deg2rad(ROT_LIMIT_MIN), deg2rad(ROT_LIMIT_MAX))
	
	mouse_speed = Vector2()


func tween_settings(_distance : float = 46.0, fov : float = 80.0) -> void:
	$SettingsTween.interpolate_property($PivotY/PivotX/ClippedCamera, "fov", $PivotY/PivotX/ClippedCamera.fov, fov, 1.0, Tween.TRANS_EXPO, Tween.EASE_OUT, 0.0)
	$SettingsTween.interpolate_property($PivotY/PivotX/ClippedCamera, "translation:z", $PivotY/PivotX/ClippedCamera.translation.z, _distance, 1.0, Tween.TRANS_EXPO, Tween.EASE_OUT, 0.0)
	$SettingsTween.start()
	

# Signals
func on_change_camera_target(_new, _distance, _fov) -> void:
	previous_target = target
	target = _new
	if _distance == 0.0 or _fov == 0.0: return
	tween_settings(_distance, _fov)


func on_revert_camera_target() -> void:
	if previous_target:
		target = previous_target
	tween_settings(def_distance, def_fov)


func on_change_mouse_sensitivity(new : float) -> void:
	mouse_sensitivity = new


func on_set_camera_fov(_fov : float) -> void:
	camera.fov = _fov


func on_add_camera_collision_exception(_n : Node) -> void:
	camera.add_exception(_n)


func on_clear_camera_collision_excpetions() -> void:
	camera.clear_exceptions()


func on_settings_changed() -> void:
	apply_settings()
