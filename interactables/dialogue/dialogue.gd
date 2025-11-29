class_name InteractableDialogue
extends Node2D


signal dialogue_started
signal dialogue_ended
signal dialogue_line_started(line: DialogueLine)


@export var dialogue: DialogueResource
@export var dialogue_id := ""
@export var context := {}
@export var type_blip : AudioStream :
	set(v):
		type_blip = v

		if has_node("TypeBlip"):
			$TypeBlip.set_stream(v)

@onready var player := get_tree().get_nodes_in_group("player")[0]

var _interactable_zone
var is_open := false
var balloon : CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_interactable_zone = get_parent()
	_interactable_zone.focused.connect(interact_with_dialogue.bind("focused"))
	_interactable_zone.unfocused.connect(interact_with_dialogue.bind("unfocused"))
	_interactable_zone.player_entered.connect(interact_with_dialogue.bind("player_entered"))
	_interactable_zone.player_exited.connect(interact_with_dialogue.bind("player_exited"))
	_interactable_zone.pressed.connect(interact_with_dialogue.bind("pressed"))
	_interactable_zone.holded.connect(interact_with_dialogue.bind("holded"))
	_interactable_zone.released.connect(interact_with_dialogue.bind("released"))

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.got_dialogue.connect(_on_dialogue_line_started)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_dialogue_started(d: DialogueResource):
	if d == dialogue:
		dialogue_started.emit()


func _on_dialogue_ended(d: DialogueResource):
	if d == dialogue:
		dialogue_ended.emit()


func _on_dialogue_line_started(line: DialogueLine):
	if is_open:
		player.set_locked(!line.tags.has("unlocked"))

		dialogue_line_started.emit(line)


func _on_dialogue_label_spoke(_letter: String, _letter_index: int, _speed: float):
	$TypeBlip.play()


func interact_with_dialogue(state: String):
	if is_instance_valid(dialogue) and not dialogue_id.is_empty():

		# Thread safety
		if not is_open:
			var key = "%s/%s" % [dialogue_id, state]
			if key in dialogue.titles.keys():
				is_open = true

				# simulate action key release
				_interactable_zone.call_deferred("_unhandled_input", simulated_action(_interactable_zone.press_action, false))

				balloon = DialogueManager.show_dialogue_balloon(
					dialogue,
					key,
					[
						self,
						prepare_context(context),
						{
							"player": player,
						},
						_interactable_zone,
					]
				)

				# await the balloon to initialize before connecting
				await get_tree().create_timer(0.1).timeout
				balloon.dialogue_label.spoke.connect(_on_dialogue_label_spoke)

				await DialogueManager.dialogue_ended
				is_open = false

				# unlock player when conversation is finished
				player.set_locked(false)


func prepare_context(c):
	var dict = c.duplicate(true)
	for k in c.keys():
		if c[k] is NodePath and not c[k].is_empty():
			if str(c[k]).contains(":"):
				var node_path = str(c[k]).split(":", false, 1)
				dict[k] = get_node(node_path[0]).get_indexed(node_path[1])
			else:
				dict[k] = get_node(c[k])
	return dict


func simulated_action(action_name, pressed) -> InputEventAction:
	var e = InputEventAction.new()
	e.action = action_name
	e.pressed = pressed
	return e
