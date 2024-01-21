extends RigidBody3D
class_name PickUpType

@export var item_data: ItemData

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var character: Character


var speed: float = 5.0
var reachedPlayer: bool = false
var player_in_radius: bool = false

func _ready() -> void:
	sprite_3d.texture = item_data.texture
	set_process(true)

func play_intro() -> void:
	var tween: Tween = create_tween()
	var old_scale: Vector3 = sprite_3d.scale

	sprite_3d.scale = Vector3(0,0,0)

	tween.tween_property(sprite_3d, "scale", old_scale, 0.2)

func _physics_process(delta: float) -> void:
	sprite_3d.rotate_y(delta)

func _process(delta: float) -> void:
	if !ray_cast_3d.is_colliding():
		get_tree().create_timer(20).connect("timeout", queue_free)

	if !player_in_radius: return

	if !reachedPlayer:
		var direction: Vector3 = (character.global_transform.origin - global_transform.origin).normalized()

		global_transform.origin += direction * speed * delta

		if global_transform.origin.distance_to(character.global_transform.origin) < 2.0:
			reachedPlayer = true

			var slot_data: SlotData = character.inventory_data.find_by_item_data(item_data)
			if character.inventory_data.pick_up_slot_data(slot_data):
				Global.sfx.play_sound("pickup", true)
				queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		player_in_radius = true
