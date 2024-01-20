extends Node

var Axe: Item = Item.new()
var Pickaxe: Item = Item.new()

var items: Array[Item] = [Axe, Pickaxe]

var player: Character

var money: int = 0

@onready var money_label: Label = $/root/main/UI/Money

@onready var esc: PanelContainer = $/root/main/UI/Esc
@onready var camera: Camera = $/root/main/Camera3D
@onready var holograms: Node3D = $/root/main/holograms

@onready var islands_parent: Node3D = $/root/main/islands

@onready var island_1: Node3D = $/root/main/holograms/island1
@onready var island_2: Node3D = $/root/main/holograms/island2
@onready var island_3: Node3D = $/root/main/holograms/island3
@onready var island_4: Node3D = $/root/main/holograms/island4

const ISLAND_1 = "res://Scenes/islands/island1.tscn"

var purchaseable_islands: Array[String] = [ISLAND_1]
var island_price: int = 50

var old_scale: Vector2 = Vector2(0.26, 0.26)

var island_buy: bool = false

const COAL = preload("res://ItemIcons/Items/coal.tres")
const COIN = preload("res://ItemIcons/Items/coin.tres")
const GOLD = preload("res://ItemIcons/Items/gold.tres")
const GOLD_ORE = preload("res://ItemIcons/Items/gold_ore.tres")
const STEEL = preload("res://ItemIcons/Items/steel.tres")
const STEEL_ORE = preload("res://ItemIcons/Items/steel_ore.tres")
const STONE = preload("res://ItemIcons/Items/stone.tres")
const WOOD = preload("res://ItemIcons/Items/wood.tres")

var inventory_items: Array[ItemData] = [COAL, COIN, GOLD, GOLD_ORE, STEEL, STEEL_ORE, STONE, WOOD]

func _ready() -> void:
	island_1.connect("clicked", handle_hologram_input.bind(island_1))
	island_2.connect("clicked", handle_hologram_input.bind(island_2))
	island_3.connect("clicked", handle_hologram_input.bind(island_3))
	island_4.connect("clicked", handle_hologram_input.bind(island_4))

	process_mode = Node.PROCESS_MODE_ALWAYS

	Axe.tool_name = "axe"
	Axe.damage = 15
	Axe.hitspeed = 1.0

	Pickaxe.tool_name = "pickaxe"
	Pickaxe.damage = 15
	Pickaxe.hitspeed = 1.0

func get_info(item: String) -> Item:
	var index: Item = items.filter(func(el: Item) -> bool:
		return el.tool_name == item
	)[0]

	if index:
		return index
	else:
		print("ERROR: could not find item \"", item, "\"")
		return Axe

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		if island_buy:
			return exit_island_buy()

		update_menu()

func update_menu() -> void:
	get_tree().paused = !get_tree().paused
	var tween: Tween = get_tree().create_tween()

	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	if !esc.visible:
		esc.scale = Vector2(0.01, 0.01)
		esc.visible = true
		return tween.tween_property(esc, "scale", old_scale, 0.2)

	tween.tween_property(esc, "scale", Vector2(0.01, 0.01), 0.2)
	tween.tween_callback(func() -> void:
		esc.visible = false
	)

func enter_island_buy() -> void:
	island_buy = true
	camera.handle_manual_zoom(90)

	update_island_availability()

	scale_node(holograms, Vector3(1, 1, 1))

func exit_island_buy() -> void:
	island_buy = false
	camera.handle_manual_zoom(60)

	scale_node(holograms, Vector3(0.01, 0.01, 0.01))


func scale_node(node: Node, scale: Vector3, callback: Callable = func() -> void: pass) -> void:
	var tween: Tween = get_tree().create_tween()

	tween.tween_property(node, "scale", scale, 0.2)
	tween.tween_callback(callback)

func handle_hologram_input(node: Hologram) -> void:
	# how the heck did you click something invisible, sussy baka..
	if !island_buy: return

	scale_node(node, Vector3(0.01, 0.01, 0.01), func() -> void:
		node.queue_free()

		# remove_at() the random island (when implementing more than 4)
		var random_island_path: String = purchaseable_islands.pick_random()
		var random_island: PackedScene = load(random_island_path)
		var island: Node3D = random_island.instantiate()

		island.scale = Vector3(0.01, 0.01, 0.01)

		islands_parent.add_child(island)

		island.global_position = node.global_position

		substract_money(node.price)

		scale_node(island, Vector3(1,1,1))
	)

func update_island_availability() -> void:
	for hologram: Hologram in holograms.get_children():
		if hologram.price > money:
			hologram.update_colors(Color.from_string("ff1622", "ff1622"), 0.25)
			hologram.buyable = false
		else:
			hologram.update_colors(Color.from_string("00ff00", "00ff00"), 0.05)

### MONEY

func give_money(amount: int) -> void:
	money += amount
	update_money()

func substract_money(amount: int) -> void:
	money -= amount
	update_money()

func update_money() -> void:
	money_label.text = "$" + str(money)
	update_island_availability()

### FURNACE UI

func find_item_by_name(_name: String) -> ItemData:
	for item: ItemData in inventory_items:
		if item.name == _name:
			return item

	return null
