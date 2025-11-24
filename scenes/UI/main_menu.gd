extends Control

signal start_game()
@onready var button_v_box: VBoxContainer = %ButtonVBox

func _ready() -> void:
	focus_button()

func _on_start_button_pressed() -> void:
	start_game.emit()
	hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_visibility_changed() -> void:
	if visible:
		focus_button()

func focus_button() -> void:
	if button_v_box:
		var button: Button = button_v_box.get_child(0)
		if button is Button:
			button.grab_focus()
