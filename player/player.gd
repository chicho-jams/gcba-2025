extends Node2D


@export var SPEED = 300.0
@export var RAYCAST_SCALE = 0.5

@onready var _viewport = get_viewport()

var _last_focused_object
var locked := false


func _physics_process(_delta: float) -> void:
	if locked: return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		$CharacterBody2D.velocity = direction * SPEED
	else:
		$CharacterBody2D.velocity = $CharacterBody2D.velocity.move_toward(Vector2.ZERO, SPEED)

	$CharacterBody2D.move_and_slide()

	# align raycast
	if $CharacterBody2D.velocity.length() > 0.1:
		$RayCast2D.global_position = $CharacterBody2D.global_position
		$RayCast2D.target_position = $CharacterBody2D.velocity * RAYCAST_SCALE

	if $RayCast2D.is_colliding():
		var collider : Object = $RayCast2D.get_collider().get_parent()
		if collider.has_method("focus"):
			update_focus(collider)
		else:
			update_focus(null)
	else:
		update_focus(null)

	$AnimationTree.set("parameters/blend_position", $CharacterBody2D.velocity)
	$AnimationTree.active = not $CharacterBody2D.velocity.is_equal_approx(Vector2.ZERO)


func update_focus(new_focus):
	if _last_focused_object != new_focus:
		if _last_focused_object != null:
			_last_focused_object.unfocus()

		_last_focused_object = new_focus

		if new_focus != null:
			new_focus.focus()


func set_locked(_locked: bool):
	locked = _locked

	# remove ui focus if capturing mouse
	if not locked and is_inside_tree():
		var current_focus_control = _viewport.gui_get_focus_owner()
		if current_focus_control:
			current_focus_control.release_focus()
