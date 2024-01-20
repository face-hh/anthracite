extends PanelContainer
class_name HotBar

signal hot_bar_use(index: int)

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
const SlotScene = preload("res://Scenes/slot.tscn")

func _unhandled_input(_event: InputEvent) -> void:
	if not visible or not _event.is_pressed() or not _event is InputEventKey:
		return

	var event: InputEventKey = _event

	if range(KEY_1, KEY_7).has(event.keycode):
		hot_bar_use.emit(event.keycode - KEY_1)

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hotbar)

	populate_hotbar(inventory_data)
	hot_bar_use.connect(inventory_data.use_slot_data)

func populate_hotbar(inventory_data: InventoryData) -> void:
	for child in h_box_container.get_children():
		child.queue_free()

	for slot_data: SlotData in inventory_data.slot_datas.slice(0, 6):
		var slot: Slot = SlotScene.instantiate()

		h_box_container.add_child(slot)

		if slot_data:
			slot.set_slot_data(slot_data)
