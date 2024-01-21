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
	"chest_close": [sounds[6]]
}

var last_sound: Variant

func play_sound(sound, allow_stack: bool) -> void:
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
