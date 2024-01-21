# Put this script on something you want to play sound effects
extends Node
class_name SFX

# Set this in the inspector
@export var sounds: Array[AudioStream]

@onready var sounds_map: Dictionary = {
	"select": [sounds[0]],
	"confirm": [sounds[1]],
	"hit": sounds.slice(2,4),
	"pickup": [sounds[4]],
	"chest_open": [sounds[5]],
	"chest_close": [sounds[6]],
	"inventory_open": [sounds[7]],
	"inventory_close": [sounds[8]],
	"popup_open": [sounds[9]],
	"popup_close": [sounds[10]],
	"zoom_out": [sounds[11]],
	"zoom_in": [sounds[12]],
	"click": [sounds[13]],
	"tick": [sounds[14]],
	"fire": [sounds[15]],
}

var last_sound: Variant

# TODO: lower volume if play_sound is called multiple times with the same sound

func play_sound(sound: String, allow_stack: bool) -> void:
	if last_sound == sound:
		return

	var item: Array[Variant] = sounds_map.get(sound)
	var rand_item: AudioStream = item.pick_random()

	var player: AudioStreamPlayer = SoundManager.play_sound(rand_item)

	if allow_stack:
		await get_tree().create_timer(1).timeout
		return

	last_sound = sound

	player.finished.connect(func() -> void:
		last_sound = null
	)

func play_with_stop(sound: String) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = SoundManager.play_sound(sounds_map.get(sound)[0])

	return player

func stop_audio_stream_player(stream: AudioStreamPlayer) -> void:
	fade_out(stream)

func fade_out(stream_player: AudioStreamPlayer):
	# tween music volume down to 0
	var tween_out: Tween = create_tween()

	tween_out.tween_property(stream_player, "volume_db", -80, 0.5)
	tween_out.tween_callback(func() -> void:
		stream_player.stop()
	)
