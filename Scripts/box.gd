extends Model
class_name Box

signal toggle_inventory(external_inventory_owner: StaticBody3D)

@export var inventory_data: InventoryData

func _ready() -> void:
	update_parent()

func player_interact() -> void:
	toggle_inventory.emit(self)
	update_parent()

func update_parent() -> void:
	for slot_data: SlotData in inventory_data.slot_datas:
		if !slot_data: return

		resources.append({ "resource": slot_data.item_data, "amount": slot_data.quantity })
