extends Camera3D
class_name Camera

@onready var player: CharacterBody3D = $"../Character"

var last_position: Vector3 = Vector3()
var speed: float = 0.75


var desiredFov:float = 75
var fovStep := 3
var maxFov := 90
var minFov := 45
var fovSmooth := 0.95

func handle_zoom() -> void:
	if Input.is_action_just_pressed("zoom_in"):
		desiredFov = desiredFov - fovStep
	elif Input.is_action_just_pressed("zoom_out"):
		desiredFov = desiredFov + fovStep

	handle_manual_zoom(desiredFov)

func handle_manual_zoom(desiredFov2: float) -> void:
	desiredFov = clamp(desiredFov2, minFov, maxFov)

	fovSmooth = lerp(fovSmooth, desiredFov, 0.1)

	self.set_fov(fovSmooth)

func _process(_delta: float) -> void:
	handle_zoom()
	var movement: Vector3 = player.global_position

	if last_position == movement:
		return

	var direction: Vector3 = movement - last_position
	var new_position: Vector3 = Vector3()
	new_position.x = lerp(position.x, position.x + direction.x, speed)
	new_position.z = lerp(position.z, position.z + direction.z, speed)
	new_position.y = position.y

	position = new_position
	last_position = movement
