extends PanelContainer

@onready var item_name: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control2/HBoxContainer/ItemName
@onready var cost: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control2/HBoxContainer/Cost
@onready var owned: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control3/Owned
@onready var texture: TextureRect = $MarginContainer/HBoxContainer2/VBoxContainer/Control2/Control/TextureRect

@onready var texture_rect_1: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect
@onready var texture_rect_2: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect2
@onready var texture_rect_3: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect3
@onready var texture_rect_4: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect4

func _ready() -> void:
	Global.find_item_by_name("Coal").texture = texture_rect_1.texture

func manage_item_selection(_event: InputEvent, item: FurnaceItem) -> void:
	if !(_event is InputEventMouseButton): return

	var event: InputEventMouseButton = _event

	if !(event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true): return

	print(item.item_name)

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_1)

func _on_texture_rect_2_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_2)

func _on_texture_rect_3_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_3)

func _on_texture_rect_4_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_4)
