class_name MainUI
extends Control

@onready var text_page: Panel = %RecipiesPanel
@onready var toggle_button: Button = %ShowRecipiesButton
@onready var next_customer_button: Button = %NextCustomerButton
@onready var serve_button: Button = %ServeButton


func _ready() -> void:
	text_page.visible = false
	toggle_button.toggled.connect(_on_button_toggled)
	serve_button.hide()
	serve_button.pressed.connect(_on_serve_button_pressed)


func _on_button_toggled(toggled_on: bool) -> void:
	text_page.visible = toggled_on

func _on_serve_button_pressed() -> void:
	serve_button.hide()
