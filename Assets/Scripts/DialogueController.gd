extends Control

const SIGNAL_DELIMITER : String = "|"

var pause_game := false

var _dialogue
var options_showing : bool = false
var option_range : int = 0

var active_speaker_sprite : TextureRect setget set_active_speaker_sprite


func _ready():
	hide()
	_dialogue = ClydeDialogue.new()
#	_dialogue.load_dialogue('pulp_with_blocks')

	_dialogue.connect("event_triggered", self, '_on_event_triggered')
	_dialogue.connect("variable_changed", self, '_on_variable_changed')
	SignalBus.connect("start_dialogue", self, "on_start_dialogue")
	
	set_process_input(false)
	
	for c in $Options/Items.get_children():
		c.queue_free()
	
#	SignalBus.emit_signal("start_dialogue", "intro")


func set_variable(_name, _value) -> void:
	_dialogue.setVariable(_name, _value);


func set_active_speaker_sprite(new : TextureRect) -> void:
	if new == active_speaker_sprite : return
	if active_speaker_sprite:
		active_speaker_sprite.modulate.a = 0.25
	new.show()
	new.modulate.a = 1.0
	active_speaker_sprite = new


#func hide_profile_pictures() -> void:
#	for i in $ProfilePictures.get_children():
#		i.hide()

func start_dialogue(which : String) -> void:
	# set up the new dialogue
	_dialogue.load_dialogue(which)
	# pause the game
	if pause_game:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		GameManager.active_game_state = Types.GAME_STATES.DIALOGUE_PAUSED
	# start listening to input
	set_process_input(true)
	# load the first line of dialogue
	_get_next_dialogue_line()
	# show the dialogue
	show()
	


func _get_next_dialogue_line():
	var content = _dialogue.get_content()
	if not content:
		hide()
		get_tree().paused = false
		Input.set_mouse_mode(2)
		set_process_input(false)
		$Timer.stop()
		if GameManager.active_game_state == Types.GAME_STATES.DIALOGUE_PAUSED:
			GameManager.active_game_state = Types.GAME_STATES.IN_GAME
#		hide_profile_pictures()
		return

	if content.type == 'line':
#		$Timer.start()
		_set_up_line(content)
#		$Panel.show()
#		$Options.hide()
		options_showing = false
	else:
		_set_up_options(content)
		$Options.show()
		options_showing = true
#		$Panel.hide()


func _set_up_line(content):
	var speaker : String = content.get('speaker') if content.get('speaker') != null else ''
	$Panel/SpeakerPanel/Label.text = speaker
	_check_speaker(speaker)
	
	$Panel/Text.text = content.text
	if content.tags:
		check_tags(content.tags)


func _set_up_options(options):
	for c in $Options/Items.get_children():
		c.queue_free()

	$Panel/Text.text = options.get('name') if options.get('name') != null else ''
	if options.tags:
		check_tags(options.tags)
	
	var speaker : String = options.get('speaker') if options.get('speaker') != null else ''
	$Panel/SpeakerPanel/Label.text = speaker
	_check_speaker(speaker)

	var index = 0
	for option in options.options:
		var btn = Button.new()
		btn.text = "[" + str(index +1) + "]   " + option.label
		btn.connect("button_down", self, "_on_option_selected", [index])
		$Options/Items.add_child(btn)
		index += 1
		
	$Options.show()
	$Options/Items.get_child(0).grab_focus()
	
	# save the option range so that we can work with it afterwards in input
	option_range = index


func _check_speaker(_n : String) -> void:
	match _n:
		"DEATH":
			set_active_speaker_sprite($ProfilePictures/DEATH)
		"DICINJO":
			set_active_speaker_sprite($ProfilePictures/DICINJO)


func _on_option_selected(index):
	# make sure we're within the length of the options first
	if index > option_range: return
	# continue if so
	_dialogue.choose(index)
	_get_next_dialogue_line()
	$Options.hide()

#
#func _gui_input(event):
#	if event is InputEventMouseButton and event.is_pressed():
#		_get_next_dialogue_line()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DialogueProgress", false):
		_get_next_dialogue_line()
	if options_showing:
		if event.is_action_pressed("1"):
			_on_option_selected(0)
		elif event.is_action_pressed("2"):
			_on_option_selected(1)
		elif event.is_action_pressed("3"):
			_on_option_selected(2)
		elif event.is_action_pressed("4"):
			_on_option_selected(3)


func _on_event_triggered(event_name : String):
	print("Event received: %s" % event_name)
	
	if event_name.begins_with("signal"):
		var signal_parts : PoolStringArray = event_name.split(SIGNAL_DELIMITER, false)
		if signal_parts.size() > 2:
			# emits a signal from the signal bus
			# first part is the signal name
			# secon part is argument
			# "{trigger signal|signal_name|signal_param}" --- use | (long pipe to seperate calls)
			SignalBus.emit_signal(signal_parts[1], signal_parts[2])
		else:
			SignalBus.emit_signal(signal_parts[1])
			
		print("Signal event parsed: %s" % signal_parts)
		print("Signal string array size: %s" % signal_parts.size())
		
		
func _on_variable_changed(variable_name, new_value, previous_value):
	print("variable changed: %s old %s new %s" % [variable_name, previous_value, new_value])


func check_tags(tags : Array) -> void:
	if tags.size() == 0 : return
	for tag in tags:
		if tag.begins_with("audio_"):
			AudioManager.play_voiceover(tag, true)
		if tag.begins_with("length_"):
			$Timer.wait_time = int(tag.lstrip("length_"))
			$Timer.start()
		


func _on_restart_pressed():
	$dialogue_ended.hide()
	_dialogue.start()
	_get_next_dialogue_line()


# which is a string of the file *.clyde within the dialogue folder
func on_start_dialogue(which : String, pause : bool) -> void:
	pause_game = pause
	start_dialogue(which)


func _on_Timer_timeout() -> void:
	_get_next_dialogue_line()
