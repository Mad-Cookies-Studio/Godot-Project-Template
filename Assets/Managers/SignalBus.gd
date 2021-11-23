extends Node

# Put signals here

# camera signals
signal change_camera_target(target, distance, fov)
signal revert_camera_target
signal change_mouse_sensitivity(new) # float
signal set_camera_fov(new) # float
signal add_camera_collision_exception(n) # n is node
signal clear_camera_collision_excpetions

# settings
signal settings_changed
signal settings_saved
signal settings_save_problem


# save game
signal game_saved
signal game_save_problem
