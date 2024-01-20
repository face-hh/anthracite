extends Model
class_name Furnace

@onready var ui: PanelContainer = $"../../../../UI/FurnaceUI"

func player_interact() -> void:
	ui.visible = !ui.visible
