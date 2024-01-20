extends Resource

class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var craft_resources: Dictionary = {}
@export var texture: AtlasTexture
@export var craft_time: float

func use(_target: Character) -> void:
	pass
