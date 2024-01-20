extends PanelContainer

@export var texture: Texture
@export var label: String

@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var quantity_label: Label = $HBoxContainer/QuantityLabel

signal button_called(label: String)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	texture_rect.texture = texture
	quantity_label.text = label


func _on_texture_button_pressed() -> void:
	button_called.emit(label)
