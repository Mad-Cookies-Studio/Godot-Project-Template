extends Node

# Global audio manager

const VO_PATH : = "res://Assets/VO/"
const VO_EXT : = ".wav"


enum SFX {}


func play_bgm(which : int) -> void:
	$BGM.get_child(which).play()


# Use the values from SFX enum
func play_sfx(which : int) -> void:
	$SFX.get_child(which).play()


func play_voiceover(tag : String, really : bool) -> void:
	var audio_name : String = tag.lstrip("audio_")
	print(VO_PATH + audio_name + VO_EXT)
	$Voiceovers/VoiceoverPlayer.stream = load(VO_PATH + audio_name + VO_EXT)
	$Voiceovers/VoiceoverPlayer.play()
