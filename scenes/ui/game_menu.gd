extends Control

signal _return_to_game()
signal _main_menu()

@onready var master_bus_id: int = AudioServer.get_bus_index("Master")
@onready var sfx_bus_id: int = AudioServer.get_bus_index("SFX")
@onready var music_bus_id: int = AudioServer.get_bus_index("BGM")

@onready var buttons_v_box: VBoxContainer = %ButtonsVBox

func _focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_id, value < 0.05)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_id, value < 0.05)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_id, value < 0.05)

func _on_visibility_changed() -> void:
	if visible:
		_focus_button()

func _on_return_to_game_button_pressed() -> void:
	_return_to_game.emit()

func _on_main_menu_pressed() -> void:
	_main_menu.emit()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
