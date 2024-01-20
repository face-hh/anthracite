extends PanelContainer

@export var character: Character

@onready var owned: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control3/Owned
@onready var resource_name: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control4/ResourceName
@onready var texture: TextureRect = $MarginContainer/HBoxContainer2/VBoxContainer/Control2/Control/TextureRect

@onready var required_item_icon_1: TextureRect = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement1/Control/RequiredItemIcon1
@onready var required_item_name_1: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement1/RequiredItemName1
@onready var required_item_cost_1: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement1/Control2/RequiredItemCost1
@onready var required_item_icon_2: TextureRect = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement2/Control/RequiredItemIcon2
@onready var required_item_name_2: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement2/RequiredItemName2
@onready var required_item_cost_2: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement2/Control2/RequiredItemCost2
@onready var required_item_icon_3: TextureRect = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement3/Control/RequiredItemIcon3
@onready var required_item_name_3: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement3/RequiredItemName3
@onready var required_item_cost_3: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement3/Control2/RequiredItemCost3

@onready var requirement_1: HBoxContainer = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement1
@onready var requirement_2: HBoxContainer = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement2
@onready var requirement_3: HBoxContainer = $MarginContainer/HBoxContainer2/VBoxContainer/Control5/VBoxContainer/Requirement3

###
@onready var requirements: Array[HBoxContainer] = [requirement_1, requirement_2, requirement_3]

@onready var required_items : Array[Array] = [
	[required_item_icon_1, required_item_name_1, required_item_cost_1],
	[required_item_icon_2, required_item_name_2, required_item_cost_2],
	[required_item_icon_3, required_item_name_3, required_item_cost_3]
]
###

@onready var texture_rect_1: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect
@onready var texture_rect_2: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect2
@onready var texture_rect_3: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect3
@onready var texture_rect_4: FurnaceItem = $MarginContainer/HBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/TextureRect4

func _ready() -> void:
	replace_item(texture_rect_1, "Coal")
	replace_item(texture_rect_2, "Steel")
	replace_item(texture_rect_3, "Gold")

	select_item(texture_rect_1)

func replace_item(texture_rect: FurnaceItem, _item: String) -> void:
	var item: ItemData = Global.find_item_by_name(_item)

	texture_rect.texture = item.texture
	texture_rect.item_name = item.name

func manage_item_selection(_event: InputEvent, item: FurnaceItem) -> void:
	if !(_event is InputEventMouseButton): return

	var event: InputEventMouseButton = _event

	if !(event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true): return

	select_item(item)

func select_item(_item: FurnaceItem) -> void:
	for requirement in requirements:
		requirement.visible = false

	var item: ItemData = Global.find_item_by_name(_item.item_name)
	var inventory: InventoryData = character.inventory_data

	resource_name.text = "⎯ %s ⎯" % item.name.to_upper()
	texture.texture = item.texture

	var i := 0
	for key: String in item.craft_resources:
		var value: int = item.craft_resources[key]

		requirements[i].visible = true

		var required_texture: TextureRect = required_items[i][0]
		var required_name: Label = required_items[i][1]
		var required_cost: Label = required_items[i][2]

		required_texture.texture = Global.find_item_by_name(key).texture
		required_name.text = key.to_upper()
		required_cost.text = "%s/%s" % [get_quantity_in_inventory(inventory, key), value]
		i += 1

	owned.text = "OWNED: %s" % str(get_quantity_in_inventory(inventory, _item.item_name))

func get_quantity_in_inventory(inventory: InventoryData, _item: String) -> int:
	var slot_in_inv: SlotData = inventory.find_item_by_name(_item)

	if !slot_in_inv: return 0

	return slot_in_inv.quantity

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_1)

func _on_texture_rect_2_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_2)

func _on_texture_rect_3_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_3)

func _on_texture_rect_4_gui_input(event: InputEvent) -> void:
	manage_item_selection(event, texture_rect_4)
