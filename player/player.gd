extends Node2D


@export var SPEED = 300.0


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		$CharacterBody2D.velocity = direction * SPEED
	else:
		$CharacterBody2D.velocity = $CharacterBody2D.velocity.move_toward(Vector2.ZERO, SPEED)

	$CharacterBody2D.move_and_slide()

	$AnimationTree.set("parameters/blend_position", $CharacterBody2D.velocity)
	$AnimationTree.active = not $CharacterBody2D.velocity.is_equal_approx(Vector2.ZERO)
