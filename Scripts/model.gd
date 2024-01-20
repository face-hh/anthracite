extends StaticBody3D
class_name Model

var health: int
var total_health: int
var resources: Array[Dictionary] = []
var infected_rate: float #0.0 - 1.0

signal death

func _ready() -> void:
	var wood: ItemData = Global.find_item_by_name("Wood")
	var stone: ItemData = Global.find_item_by_name("Stone")

	if "tree" in name:
		health = 45
		resources.append({ "resource": wood, "amount": 3 })
	if "rock" in name:
		health = 60
		resources.append({ "resource": stone, "amount": 3 })
	if "box" in name:
		health = 200
	if "furnace" in name:
		health = 200

	total_health = health

func take_damage(damage: int) -> void:
	health -= damage

	if health <= 0:
		die()

func die() -> void:
	death.emit()

	var tween: Tween = create_tween()

	tween.tween_property(self, "scale", Vector3(0.01,0.01,0.01), 0.1)
	tween.tween_callback(queue_free)
