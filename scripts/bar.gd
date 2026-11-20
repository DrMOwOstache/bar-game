class_name Bar
extends Control

@export var npcs: Array[NPCDialogueData] = []
var _next: int = 0

@onready var npc_control: NPC = %NPC
@onready var ui: MainUI = %MainUIControl

func _ready() -> void:
	npc_control.exited_bar.connect(next_visitor)
	npc_control.finished_dialogue_start_visit.connect(ui.serve_button.show)
	ui.next_customer_button.pressed.connect(next_visitor)
	ui.serve_button.pressed.connect(_on_serve_button_pressed)

func next_visitor() -> void:
	if _next >= npcs.size():
		get_tree().free()
	
	npc_control.new_visitor(npcs[_next])
	_next += 1

func _on_serve_button_pressed() -> void:
	npc_control.play_anim(NPC.AnimType.DrinkAnim)