class_name InteractableUI
extends CanvasLayer

var _interactable_zone : InteractableZone
var _current_device : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_device = InputHelper.guess_device_name()
	InputHelper.device_changed.connect(_on_device_changed)

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	_interactable_zone = get_parent()
	_interactable_zone.focused.connect(_update_visibility)
	_interactable_zone.unfocused.connect(_update_visibility)
	_interactable_zone.player_entered.connect(_update_visibility)
	_interactable_zone.player_exited.connect(_update_visibility)
	_interactable_zone.holded.connect(_update_visibility)

	_interactable_zone.pressed.connect(_on_interactable_zone_pressed)
	_interactable_zone.released.connect(_on_interactable_zone_released)

	%HoldProgress.material.set_shader_parameter("progress", 0.0)
	_update_ui_key()
	hide()


func _process(_delta: float) -> void:
	if _interactable_zone.is_holding and _interactable_zone.hold_timeout > 0.0:
		%HoldProgress.material.set_shader_parameter("progress", _interactable_zone.hold_progress)

func _update_ui_key():
	var press_action = _interactable_zone.press_action
	%InteractionLabel.text = press_action
	if press_action.is_empty():
		%InteractionKey.text = ""
	elif InputMap.has_action(press_action):
		var action_text := ""
		if _current_device == InputHelper.DEVICE_KEYBOARD:
			action_text = InputHelper.get_keyboard_input_for_action(press_action).as_text().trim_suffix(" (Physical)")
		else:
			var regex := RegEx.new()
			regex.compile("Nintendo\\s+(A|B|X|Y)")
			var found = regex.search(InputHelper.get_joypad_input_for_action(press_action).as_text())
			if found != null:
				action_text = found.get_string(1)

		%InteractionKey.text = action_text
	else:
		%InteractionKey.text = "??"


func _update_visibility():
	visible = _interactable_zone.is_interactable()


func _on_dialogue_started(_resource: DialogueResource):
	hide()


func _on_dialogue_ended(_resource: DialogueResource):
	_update_visibility()


func _on_interactable_zone_pressed():
	%InteractionKey.button_pressed = true
	_update_visibility()


func _on_interactable_zone_released():
	# tween back the progress to 0
	if _interactable_zone.hold_timeout > 0.0:
		var t = get_tree().create_tween()
		t.tween_property(
			%HoldProgress.material,
			"shader_parameter/progress",
			0.0,
			_interactable_zone.cooldown_timeout
		) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)

	%InteractionKey.button_pressed = false
	_update_visibility()


func _on_device_changed(next_device, _index):
	_current_device = next_device
	_update_ui_key()
