extends Node

var mate_count: int = 0
var medialuna_count: int = 0
var empanada_count: int = 0



func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)


func _on_scene_changed():
	if get_tree().has_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0]
		player.set_locked(true)
		var balloon = DialogueManager.show_dialogue_balloon(
			preload("res://interactables/dialogue/intro.dialogue"),
			"intro"
		)
		await DialogueManager.dialogue_ended
		balloon.queue_free() # avoid double showing this balloon bug
		player.set_locked(false)

func taks_completd() -> void:
	if get_tree().has_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0]
		player.set_locked(true)
		var balloon = DialogueManager.show_dialogue_balloon(
		preload("res://interactables/dialogue/tasks_completed.dialogue"),
		"mate_completed"
		)
		await DialogueManager.dialogue_ended
		balloon.queue_free()
		player.set_locked(false)
