extends Area2D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

@export var _item_sprite: Texture
#@export var collision : Shape2D :
	#set(v):
		#collision = v
		#if has_node("CollisionShape2D"):
			#$CollisionShape2D.shape = v

@export_enum("mate", "medialuna", "empanada")

var _name_item: String

func _ready() -> void:
	_changue_item()

func _changue_item() -> void:
	$Sprite2D.texture = _item_sprite

func _verify_collection(name_item: String) -> void:
	match name_item:
		"mate":
			GameManager.medialuna_count += 1
			if GameManager.medialuna_count == 5:
				print("Cantidad de mates completados")
			print("Mate:", GameManager.medialuna_count)
		"shoe":
			GameManager.medialuna_count += 1
			if GameManager.medialuna_count == 5:
				print("Cantidad de medialunas completadas")
			print("Medialuna:", GameManager.medialuna_count)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.get_parent() is Player:
		_verify_collection(_name_item)
		_animation_player.play("fade_out")
