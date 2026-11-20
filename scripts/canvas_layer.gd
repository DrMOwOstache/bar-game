extends Control

@onready var text_page: Panel = $Panel
@onready var toggle_button: Button = $Button


func _ready() -> void:
	text_page.visible = false
	if not toggle_button.toggled.is_connected(_on_button_toggled):
		toggle_button.toggled.connect(_on_button_toggled)


func _on_button_toggled(toggled_on: bool) -> void:
	text_page.visible = toggled_on
