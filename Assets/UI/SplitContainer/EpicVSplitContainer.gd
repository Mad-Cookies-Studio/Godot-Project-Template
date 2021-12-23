tool
extends Control

export var grabber_col : Color = Color() setget set_grabber_col
export var grabber_col_highlight : Color = Color()
export var initial_size : int = 50 setget set_init_size
export var grabber_size : int = 1 setget set_grabber_size
export var grabber_area_size : int = 1 setget set_grabber_area_size

onready var sorting_container : Node = $SortingContainer

var starting_pos : Vector2


func set_grabber_col(new : Color) -> void:
	grabber_col = new
	if !Engine.is_editor_hint(): return
	$SortingContainer/Grabber.color = new


func set_init_size(new : int) -> void:
	if !Engine.is_editor_hint(): return
	initial_size = new
	$SortingContainer/Section1.rect_min_size.y = new 
	$SortingContainer/Section1.minimum_size_changed()


func set_grabber_size(new : int) -> void:
	if !Engine.is_editor_hint(): return
	grabber_size = new
	$SortingContainer/Grabber.rect_min_size.y = new
	$SortingContainer/Grabber.minimum_size_changed()


func set_grabber_area_size(new : int) -> void:
	if !Engine.is_editor_hint(): return
	grabber_area_size = new
	$SortingContainer/Grabber.get_child(0).rect_min_size.y = new
	$SortingContainer/Grabber.get_child(0).minimum_size_changed()


func _ready() -> void:
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$SortingContainer/Section1.rect_min_size.y = get_local_mouse_position().y


func _on_Control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		starting_pos = get_global_mouse_position()
		set_process_input(true)
	if event is InputEventMouseButton and event.button_index == 1 and !event.pressed:
		set_process_input(false)


func _on_GrabberArea_mouse_entered() -> void:
	$SortingContainer/Grabber.color = grabber_col_highlight


func _on_GrabberArea_mouse_exited() -> void:
	$SortingContainer/Grabber.color = grabber_col
