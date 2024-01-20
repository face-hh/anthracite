extends Node3D
class_name Main

const PickUp = preload("res://Scenes/pick_up.tscn")

@onready var character: Character = $Character
@onready var inventory_interface: InventoryInterface = $UI/InventoryInterface
@onready var hot_bar_inventory: HotBar = $UI/HotBarInventory
@onready var islands: Node3D = $islands
@onready var esc: PanelContainer = $UI/Esc

var colors: Array[Color] = [
	Color.from_string("c6c5d1", "78ce5e"),
	Color.from_string("b4b1cd", "78ce5e"),
	Color.from_string("bda7ec", "78ce5e"),
	Color.from_string("ca9cff", "78ce5e")
]

func _ready() -> void:
	character.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(character.inventory_data)
	hot_bar_inventory.set_inventory_data(character.inventory_data)

	for node: Box in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

################
# MISC
################
func update_colors(node: Node, past_color: Variant, color: Color) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child as MeshInstance3D
			var material_one: StandardMaterial3D = mesh_instance.mesh.surface_get_material(0).duplicate()

			var tween: Tween = create_tween()

			if past_color:
				material_one.albedo_color = past_color

			mesh_instance.set_surface_override_material(0, material_one)

			tween.tween_property(material_one, "albedo_color", color, 1)

func _on_spreading_timeout(random: bool = true) -> void:
	var chance: float = randf()

	if chance < 0.1 or !random: return

	var rand: float = randf()
	var children: Array[Node] = []

	for island: Node3D in islands.get_children():
		for child: Node in island.get_node("Infectables").get_children():
			children.append(child)

	if children.size() == 0: return

	var index: int = int(rand * children.size())
	var infectable: Model = children[index]
	var rate: float = infectable.infected_rate

	if rate == 1.0:
		return _on_spreading_timeout(false)

	infectable.infected_rate += .25
	rate += .25

	var color_index: int = ((int(rate / .25) - 1) % 4)

	var color: Color = colors[color_index]

	var past_color: Variant = colors[color_index - 1]

	if color_index == 1:
		past_color = null

	update_colors(infectable.get_node("model"), past_color, color)

################
# INVENTORY
################
func toggle_inventory_interface(external_inventory_owner: Box = null) -> void:
	inventory_interface.visible = !inventory_interface.visible

	if inventory_interface.visible:
		Global.allow_actions = false
		hot_bar_inventory.hide()
	else:
		Global.allow_actions = true
		hot_bar_inventory.show()

	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func drop_item(item_data: Variant, pos: Vector3 = character.get_drop_position()) -> void:
	var pick_up: PickUpType = PickUp.instantiate()

	if item_data is ItemData:
		pick_up.item_data = item_data
	elif item_data is SlotData:
		var slot_data: SlotData = item_data
		for i in slot_data.quantity:
			drop_item(slot_data.item_data)
		return

	pick_up.position = pos
	pick_up.character = character

	add_child(pick_up)

	pick_up.play_intro()
