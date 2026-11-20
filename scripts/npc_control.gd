class_name NPC
extends Node2D

@export var character_sprite: AnimatedSprite2D
@export var animation_player: AnimationPlayer


func drink_the_fluid() -> void:
	animation_player.play("drink", -1, 1.0, false)
