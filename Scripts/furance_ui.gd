extends PanelContainer
class_name FurnaceUI

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

@onready var button: Button = $MarginContainer/HBoxContainer2/VBoxContainer/Control/Craft
@onready var amount: Label = $MarginContainer/HBoxContainer2/VBoxContainer/Control/Amount


var substract := {}
var craft_times := 1

var current_item: Variant = null

func _ready() -> void:
	current_item = texture_rect_1

	replace_item(texture_rect_1, "Coal")
	replace_item(texture_rect_2, "Steel")
	replace_item(texture_rect_3, "Gold")

func _reload(_texture: Variant) -> void:
	if !_texture:
		_texture = texture_rect_1
		current_item = _texture

	select_item(_texture)

func replace_item(texture_rect: FurnaceItem, _item: String) -> void:
	var item: ItemData = Global.find_item_by_name(_item)

	texture_rect.texture = item.texture
	texture_rect.item_name = item.name

func manage_item_selection(_event: InputEvent, item: FurnaceItem) -> void:
	if !(_event is InputEventMouseButton): return

	var event: InputEventMouseButton = _event

	if !(event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true): return

	Global.sfx.play_sound("select", true)

	current_item = item

	select_item(item)

func select_item(__item: Variant) -> void:
	var _item: FurnaceItem = __item

	for requirement in requirements:
		requirement.visible = false

	var item: ItemData = Global.find_item_by_name(_item.item_name)
	var inventory: InventoryData = character.inventory_data

	resource_name.text = "⎯ %s ⎯" % item.name.to_upper()
	texture.texture = item.texture

	var i := 0
	var craftable := true

	substract = item.craft_resources

	for key: String in item.craft_resources:
		var value: int = item.craft_resources[key]

		value = value * craft_times

		requirements[i].visible = true

		var required_texture: TextureRect = required_items[i][0]
		var required_name: Label = required_items[i][1]
		var required_cost: Label = required_items[i][2]
		var current: int = get_quantity_in_inventory(inventory, key)

		required_texture.texture = Global.find_item_by_name(key).texture
		required_name.text = key.to_upper()
		required_cost.text = "%s/%s" % [current, value]
		i += 1

		if current < value:
			craftable = false

	owned.text = "OWNED: %s" % str(get_quantity_in_inventory(inventory, _item.item_name))
	amount.text = "x%s" % craft_times

	button.disabled = !craftable

	if !craftable: button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else: button.mouse_filter = Control.MOUSE_FILTER_STOP

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


func _on_button_pressed() -> void:
	var furnace: Furnace = character.find_closest(func(body: Node3D) -> bool:
		return "furnace" in body.name
	)

	for key: String in substract:
		var value: int = substract[key]
		var inventory: InventoryData = character.inventory_data

		inventory.use_slot_data(key, value * craft_times, false)
	_reload(current_item)

	furnace.busy = true
	Global.sfx.play_sound("confirm", true)

	furnace.player_interact()
	Global.register_furance_task(furnace, (current_item as FurnaceItem).item_name, craft_times) # CHANGE THIS LATER


func _on_min() -> void:
	Global.sfx.play_sound("click", true)

	craft_times = 1
	_reload(current_item)

func _on_max() -> void:
	Global.sfx.play_sound("click", true)

	var max_craft_times: int = 3  # Set a default value, adjust as needed

	for key: String in substract:
		var value: int = substract[key]
		var inventory: InventoryData = character.inventory_data
		var item: SlotData = inventory.find_item_by_name(key)

		if item and value > 0:
			var available_craft_times: int = item.quantity / value
			max_craft_times = min(max_craft_times, available_craft_times)

	if max_craft_times == 0:
		# my son will do item duplicating glitch in Anthracite
		# my honest reaction:
		craft_times = 1
	else:
		craft_times = max_craft_times

	_reload(current_item)

func _on_plus() -> void:
	Global.sfx.play_sound("click", true)

	craft_times += 1
	_reload(current_item)
