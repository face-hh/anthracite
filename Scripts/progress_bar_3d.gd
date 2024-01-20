extends Sprite3D

func _ready() -> void:
	texture = ($SubViewport as SubViewport).get_texture()
