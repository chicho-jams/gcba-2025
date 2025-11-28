extends CharacterBody2D
class_name Player


@export var SPEED = 300.0
@export var RAYCAST_SCALE = 0.5

@onready var _viewport = get_viewport()

var _last_direction := Vector2.RIGHT
var _last_focused_object
var locked := false


func _physics_process(_delta: float) -> void:
	if locked: return

	# Get the input direction and handle the movement
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

	# update last input direction
	if direction.length() > 0.1:
		_last_direction = direction


func _process(_delta: float) -> void:
	# update animation tree
	$AnimationTree.set("parameters/Idle/blend_position", _last_direction)
	$AnimationTree.set("parameters/Moving/blend_position", _last_direction)

	# align raycast
	$RayCast2D.target_position = _last_direction * RAYCAST_SCALE

	# check for interactable collisions
	if $RayCast2D.is_colliding():
		var collider : Object = $RayCast2D.get_collider().get_parent()
		if collider.has_method("focus"):
			update_focus(collider)
		else:
			update_focus(null)
	else:
		update_focus(null)


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
