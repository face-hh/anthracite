extends CharacterBody3D
class_name Character

# VARS
@export var model : Node3D
@export var weapons: Node3D
@export var internal_anim : AnimationPlayer
@export var inventory_data: InventoryData

@onready var anim : AnimationPlayer = model.get_node("AnimationPlayer")
@onready var working_material: Resource = load("res://Models/Material.001 Base Color.001.png");
@onready var idle_material: Resource = load("res://Models/survivor_Material.png");
@onready var camera_3d: Camera3D = $survivor/Camera3D
@onready var main: Main = $".."
@onready var ray_cast_3d: RayCast3D = $survivor/RayCast3D

signal hit_anim
signal toggle_inventory
# MOVEMENT
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var target_angle: float = 0.0
var rotation_speed: float = 10.0

# MISC
var cooldown: float = 0
var health: int = 5

var close_items: Array[Node3D] = []
var blocked_dir: Variant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player = self

	#anim.play("idle")

	await get_tree().create_timer(1).timeout
	Global.give_money(300)

func _physics_process(delta: float) -> void:
	handle_input()
	cooldown -= delta

	if not is_on_floor():
		velocity.y -= gravity * delta

	if !Global.allow_actions: return

	var input_dir := Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")

	if input_dir == Vector2(0, 0):
		anim.play("idle")
	else:
		anim.play("walk")

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		target_angle = atan2(-direction.x, -direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# ROTATION
	var current_angle: float = atan2(model.transform.basis.z.x, model.transform.basis.z.z)
	var new_angle: float = lerp_angle(current_angle, target_angle, rotation_speed * delta)

	model.rotation.y = new_angle

	weapons.rotation.y = new_angle
	weapons.global_position = model.global_position

	if !ray_cast_3d.is_colliding():
		velocity.z = 0
		velocity.x = 0

	move_and_slide()

func handle_input() -> void:
	if Input.is_action_just_pressed("ui_click") and Global.allow_actions:
		handle_click()
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()

func play_anim(anim_name: String) -> void:
	internal_anim.play(anim_name)

	if anim_name == "axe_attack" or anim_name == "pickaxe_attack":
		var skeleton_children: Array[Node] = $survivor.get_node("Armature").get_node("Skeleton3D").get_children()
		var changed: Array[Array] = []

		for child: MeshInstance3D in skeleton_children:
			var material_one: StandardMaterial3D = child.mesh.surface_get_material(0)

			material_one.albedo_texture = working_material

			child.mesh.surface_set_material(0, material_one)

			changed.append([child.mesh, material_one])

		await internal_anim.animation_finished

		for child in changed:
			var mesh: ArrayMesh = child[0]
			var material_one: StandardMaterial3D = child[1]

			material_one.albedo_texture = idle_material

			mesh.surface_set_material(0, material_one)

			hit_anim.emit()

func handle_click() -> void:
	var closest: Node3D = find_closest()

	if cooldown > 0 or !closest: return

	var tool: String

	if "rock" in closest.name: tool = "pickaxe"
	elif "tree" in closest.name: tool = "axe"
	elif "box" in closest.name: tool = "axe"
	elif "furnace" in closest.name: tool = "pickaxe"
	else: return

	var tool_info: Item = Global.get_info(tool)

	cooldown = tool_info.hitspeed

	var entity_model: Node3D = closest.get_node("model")
	var entity: Model = closest as Model

	if entity.infected_rate == 1.0:
		return

	play_anim(tool + "_attack")
	squish(entity_model)
	Global.sfx.play_sound("hit", true)
	await hit_anim

	entity.take_damage(tool_info.damage)

	var binded: Callable = Global.give_resources.bind(entity.resources, entity)

	if !entity.death.is_connected(binded):
		entity.death.connect(binded)


func interact() -> void:
	var _interactable: Node3D = find_closest(func(body: Node3D) -> bool:
		return "box" in body.name || "furnace" in body.name
	)

	if(!_interactable): return

	if _interactable is Box:
		var interactable: Box = _interactable
		interactable.player_interact()
	elif _interactable is Furnace:
		var interactable: Furnace = _interactable
		interactable.player_interact()


func squish(node: Node3D) -> void:
	var tween: Tween = create_tween();
	var first_val: Vector3 = node.scale
	var final_val: Vector3 = node.scale

	first_val.y -= final_val.y * .15

	tween.tween_property(node, "scale", first_val, 0.1)
	tween.tween_property(node, "scale", final_val, 0.1)

func find_closest(skip_check: Callable = func(_body: Node3D) -> bool: return true) -> Node3D:
	var closest: Node3D

	for body: Node3D in close_items:
		if !skip_check.bind(body).call():
			continue

		if !closest:
			closest = body
			continue

		var is_closer: bool = global_position.distance_to(closest.global_position) > global_position.distance_to(body.global_position)

		if is_closer:
			closest = body

	return closest


func get_drop_position() -> Vector3:
	var direction: Vector3 = -camera_3d.global_transform.basis.z * 5 # 1.81 after u fix magnet

	return camera_3d.global_position + direction


# JUNK
func _on_attack_hitbox_area_body_entered(body: Node3D) -> void:
	if body == self:
		return

	close_items.append(body)

func _on_attack_hitbox_area_body_exited(body: Node3D) -> void:
	if body == self:
		return
	close_items.remove_at(close_items.find(body))

func heal(heal_value: int) -> void:
	health += heal_value
