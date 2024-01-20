extends Node3D
class_name Hologram

@onready var blocks: Node3D = $blocks
@onready var label_3d: Label3D = $Label3D

@export var price: int

var buyable: bool = true

signal clicked

func _ready() -> void:
	label_3d.text = "$" + str(price)
	update_colors()
	disable_collision()

func update_colors(color: Variant = null, transparency: float = 0.05) -> void:
	for block: Node3D in blocks.get_children():
		for child in block.get_children():
			if child is MeshInstance3D:
				var mesh_instance: MeshInstance3D = child as MeshInstance3D
				var material_one: StandardMaterial3D = mesh_instance.mesh.surface_get_material(0).duplicate()

				material_one.set_transparency(StandardMaterial3D.TRANSPARENCY_ALPHA)

				if color:
					material_one.albedo_color = color

				material_one.albedo_color.a = transparency

				mesh_instance.set_surface_override_material(0, material_one)

func disable_collision() -> void:
	for block: Node3D in blocks.get_children():
		for child in block.get_children():
			if child is MeshInstance3D:
				for child2 in child.get_children():
					if child2.has_node("CollisionShape3D"):
						var col: CollisionShape3D = child2.get_node("CollisionShape3D");

						col.disabled = true

func _on_area_3d_input_event(_camera: Node, _event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not _event is InputEventMouseButton: return

	var event: InputEventMouseButton = _event

	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true and buyable:
		clicked.emit()
