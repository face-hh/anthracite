extends PanelContainer

@onready var camera: Camera = $"../../Camera3D"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _manage_button(label: String) -> void:
	if label == "Quit":
		get_tree().quit()
	if label == "Buy Island":
		Global.update_menu()
		Global.enter_island_buy()

func _on_settings_cell_button_called(label: String) -> void:
	_manage_button(label)

func _on_settings_cell_2_button_called(label: String) -> void:
	_manage_button(label)

func _on_settings_cell_3_button_called(label: String) -> void:
	_manage_button(label)
