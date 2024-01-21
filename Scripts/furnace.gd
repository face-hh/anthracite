extends Model
class_name Furnace

@onready var ui: FurnaceUI = $"../../../../UI/FurnaceUI"
@onready var progress_bar: TextureProgressBar = $Sprite3D/SubViewport/TextureProgressBar
@onready var amount: Label = $Sprite3D/SubViewport/Amount
@onready var texture_rect: TextureRect = $Sprite3D/SubViewport/TextureRect
@onready var timer: Timer = $Timer
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var spawn_area: Area3D = $Area3D
@onready var vfx: Node3D = $VFX

var busy := false
var runs := 0
func update_ui(_amount: int, _texture: Texture) -> void:
	amount.text = str(_amount)
	texture_rect.texture = _texture

func player_interact() -> void:
	if ui.visible:
		Global.sfx.play_sound("popup_close", true)
		Global.allow_actions = true

		ui.scale = Vector2(1, 1)

		Global.allow_zoom = true
		Global.scale_node(ui, Vector2(0.01, 0.01), func() -> void: ui.visible = !ui.visible)
	else:
		Global.sfx.play_sound("popup_open", true)
		Global.allow_actions = false

		ui.visible = !ui.visible
		ui.scale = Vector2(0.01, 0.01)
		ui._reload(null)

		Global.allow_zoom = false
		Global.scale_node(ui, Vector2(1, 1))

func tint_color_on_value(value: float) -> Color:
	var clamped_value: float = clamp(value, 0, 100)

	var start_color: Color = Color.from_string("40c178", "40c178")
	var end_color: Color = Color.from_string("f47d6f", "f47d6f")

	var interpolated_color: Color = start_color.lerp(end_color, clamped_value / 100.0)

	return interpolated_color

func _process(_delta: float) -> void:
	if busy: update_progress((timer.time_left / timer.wait_time) * 100)
	else:
		sprite_3d.hide()
		turn_vfx(false)

func update_progress(value: float) -> void:
	if !sprite_3d.visible: sprite_3d.show()

	if value >= 99.05: # self-induced malfunction in tweening that im lazy to fix :^) why am i even writing in this comment instead of doing actual work bruh
		progress_bar.value = value
		return
	if value >= 0.05:
		progress_bar.value = value
		return

	var tween: Tween = get_tree().create_tween()

	tween.tween_property(progress_bar, "value", value, 0.2)
	tween.tween_property(progress_bar, "tint_progress", tint_color_on_value(progress_bar.value), 0.2)

func turn_vfx(what: bool) -> void:
	for child: GPUParticles3D in vfx.get_children():
			child.emitting = what
