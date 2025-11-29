extends Control

@onready var button_v_box: VBoxContainer = %ButtonVBox
@onready var _main_menu_animation_player: AnimationPlayer = $MainMenuAnimationPlayer

var _new_scene = preload("res://scenes/levels/level.tscn")

func _ready() -> void:
	focus_button()

func _on_start_button_pressed() -> void:
	_main_menu_animation_player.play("fade_in")

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

func _on_main_menu_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_packed(_new_scene)
