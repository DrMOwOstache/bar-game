class_name Drink
extends Area2D

@export var drinks_data: Array[DrinkData]

@export var drink_visual: TextureRect
@export var fluid_visual: TextureRect
@export var text_control: Control
@export var current_drink: int = 0

@export var pour_position: Node2D
@export var npc_node: Node2D
@export var shaker: Sprite2D

var tween: Tween
var mouse_in = false
var pouring = false

func _enter_tree() -> void:
	drink_visual.texture = drinks_data[current_drink].drink_texture
	text_control.hide()
	text_control.set_text(
		drinks_data[current_drink].drink_name,
		drinks_data[current_drink].drink_description
	)
	fluid_visual.material.set("shader", drinks_data[current_drink])
	

func _mouse_enter() -> void:
	if !pouring:
		text_control.show()
		mouse_in = true
	
func _mouse_exit() -> void:
	if !pouring:
		text_control.hide()
		mouse_in = false
	
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !pouring:
		filldrink(position,pour_position.position)
	
func filldrink(start_point: Vector2, end_point: Vector2) -> void:
	pouring = true
	text_control.hide()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"position",end_point,0.2)
	tween.tween_property(self,"rotation",-1.5,2.0)
	tween.tween_property(self,"rotation",0.0,0.2)
	tween.tween_property(self,"position",start_point,0.2)
	await tween.finished
	pouring = false
	npc_node.call("drink_the_fluid")
	tween.stop()
	make_him_drink()
	

func make_him_drink() -> void:
	var original_shaker_position = shaker.position
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(shaker,"visible",false,1.0)
	tween.parallel().tween_property(shaker,"position", shaker.position + Vector2(70.0,170.0), 1.0)
	
	tween.tween_property(shaker,"visible",false,0.9)
	tween.parallel().tween_property(shaker,"position", shaker.position + Vector2(-50.0,-60.0), 0.9)

	tween.tween_property(shaker,"visible",true,0.1)
	tween.tween_property(shaker,"position", original_shaker_position, 0.1)
	await tween.finished
	
	
