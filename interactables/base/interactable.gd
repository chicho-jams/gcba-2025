class_name InteractableZone
extends Node2D


signal focused
signal unfocused
signal player_entered
signal player_exited
signal became_interactable
signal pressed
signal holded
signal released

@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var press_action: StringName
@export var hold_timeout := 0.0

## Enable or disable interactable zone
@export var enabled : bool = true :
	set(v):
		enabled = v
		if is_inside_tree():
			$FocusArea/CollisionShape3D.disabled = !v
			$PlayerArea/CollisionShape3D.disabled = !v

@onready var player := get_tree().get_nodes_in_group("player")[0]

var is_focused := false
var is_player_inside := false
var is_holding := false
var has_interacted := false
var has_released := false

var _holded_time := 0.0
var hold_progress : float :
	get():
		return clampf(_holded_time / hold_timeout, 0.0, 1.0)

var cooldown_timeout : float :
	get():
		return $CooldownTimeout.wait_time


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayerArea.body_entered.connect(_on_player_area_body_entered)
	$PlayerArea.body_exited.connect(_on_player_area_body_exited)
	$HoldTimeout.timeout.connect(_on_hold_timeout)
	$CooldownTimeout.timeout.connect(_on_cooldown_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return

	if is_interactable() and not press_action.is_empty() and InputMap.has_action(press_action) and not player.locked:
		if not has_released:
			if event.is_action_pressed(press_action, false, true):
				if hold_timeout > 0.0:
					is_holding = true
					$HoldTimeout.wait_time = hold_timeout
					$HoldTimeout.start()
				else:
					has_interacted = true

				pressed.emit()
				get_viewport().set_input_as_handled()

			if event.is_action_released(press_action, true):
				has_interacted = false
				is_holding = false
				has_released = true
				$CooldownTimeout.start()
				$HoldTimeout.stop()
				_holded_time = 0.0

				released.emit()
				get_viewport().set_input_as_handled()


func is_interactable():
	return enabled and is_focused and is_player_inside


func _on_player_area_body_entered(_body) -> void:
	if not is_player_inside:
		is_player_inside = true
		if is_interactable():
			became_interactable.emit()

		player_entered.emit()


func _on_player_area_body_exited(_body) -> void:
	if is_player_inside:
		is_player_inside = false
		player_exited.emit()



func _on_hold_timeout() -> void:
	if not has_interacted:
		has_interacted = true
		holded.emit()


func _on_cooldown_timeout() -> void:
	has_released = false
	# dont released.emit() here, this is just a temporary state


# Called by the player
func focus():
	if not is_focused:
		is_focused = true
		if is_interactable():
			became_interactable.emit()

		focused.emit()

func unfocus():
	if is_focused:
		is_focused = false
		unfocused.emit()
