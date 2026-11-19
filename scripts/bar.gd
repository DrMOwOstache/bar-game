class_name Bar
extends Control

@export var npcs: Array[NPCDialogueData] = []
var _next: int = 0

@onready var npc_control: NPC = %NPC

func _ready() -> void:
	npc_control.exited_bar.connect(next_visitor)
	
	next_visitor()

func next_visitor() -> void:
	if _next >= npcs.size():
		get_tree().free()
	
	npc_control.new_visitor(npcs[_next])
	_next += 1
