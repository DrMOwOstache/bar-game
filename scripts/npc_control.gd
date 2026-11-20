class_name NPC
extends Node2D

@export var shaker: Sprite2D

@onready var character_sprite: AnimatedSprite2D = %character_sprite
@onready var anim_player: AnimationPlayer = %AnimationPlayer

@onready var dialogue_manager: DialogueManager = Engine.get_singleton("DialogueManager")

signal entered_bar
signal finished_dialogue_start_visit
signal drank
signal finished_dialogue_after_drink
signal exited_bar

var _npc_data: NPCDialogueData = null
var _balloon: Node = null
var tween: Tween

func drink_the_fluid() -> void:
	anim_player.play("drink", -1, 1.0, false)

func _ready() -> void:
	self.hide()

func new_visitor(d: NPCDialogueData) -> void:
	_npc_data = d
	character_sprite.sprite_frames = _npc_data.sprite_frames
	play_anim.call_deferred(AnimType.EnterAnim)

enum AnimType {EnterAnim, DrinkAnim, ExitAnim}
enum DialogueType {StartVisit, AfterDrink}

func play_anim(t: AnimType) -> void:
	match t:
		AnimType.EnterAnim:
			self.show()
			anim_player.animation_finished.connect(
				_on_enter_anim_finished
			)
			anim_player.play("move_to_bar")
		AnimType.DrinkAnim:
			anim_player.animation_finished.connect(
				_on_drink_anim_finished
			)
			anim_player.play("drink")
			make_him_drink()
		AnimType.ExitAnim:
			anim_player.animation_finished.connect(
				_on_exit_anim_finished
			)
			anim_player.play("Move_Out_Of_Bar")

func _on_enter_anim_finished(_name: String) -> void:
	entered_bar.emit()
	start_dialogue(DialogueType.StartVisit)
	anim_player.animation_finished.disconnect(_on_enter_anim_finished)

func _on_drink_anim_finished(_name: String) -> void:
	drank.emit()
	start_dialogue(DialogueType.AfterDrink)
	anim_player.animation_finished.disconnect(_on_drink_anim_finished)

func _on_exit_anim_finished(_name: String) -> void:
	exited_bar.emit()
	self.hide()
	anim_player.animation_finished.disconnect(_on_exit_anim_finished)

func start_dialogue(t: DialogueType) -> void:
	match t:
		DialogueType.StartVisit:
			dialogue_manager.dialogue_ended.connect(
				_on_dialogue_start_visit_finished
			)
			_balloon = dialogue_manager.show_dialogue_balloon(_npc_data.dialogue_res, _npc_data.start_visit_cue)
		DialogueType.AfterDrink:
			dialogue_manager.dialogue_ended.connect(
				_on_dialogue_after_drink_finished
			)
			_balloon = dialogue_manager.show_dialogue_balloon(_npc_data.dialogue_res, _npc_data.after_drink_cue)

func _on_dialogue_start_visit_finished(_res: DialogueResource) -> void:
	_balloon.queue_free()
	_balloon = null
	finished_dialogue_start_visit.emit()
	dialogue_manager.dialogue_ended.disconnect(_on_dialogue_start_visit_finished)

func _on_dialogue_after_drink_finished(_res: DialogueResource) -> void:
	_balloon.queue_free()
	_balloon = null
	finished_dialogue_after_drink.emit()
	play_anim(AnimType.ExitAnim)
	dialogue_manager.dialogue_ended.disconnect(_on_dialogue_after_drink_finished)
	
func make_him_drink() -> void:
	var original_shaker_position = shaker.position
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(shaker, "visible", false, 1.0)
	tween.parallel().tween_property(shaker, "position", shaker.position + Vector2(70.0, 170.0), 1.0)
	
	tween.tween_property(shaker, "visible", false, 0.9)
	tween.parallel().tween_property(shaker, "position", shaker.position + Vector2(-50.0, -60.0), 0.9)

	tween.tween_property(shaker, "visible", true, 0.1)
	tween.tween_property(shaker, "position", original_shaker_position, 0.1)
	await tween.finished
