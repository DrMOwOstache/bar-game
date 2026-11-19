extends CanvasLayer
@onready var toggle_button: Button = $ToggleButton

#func _ready() -> void:
	#toggle_button.pressed.connect(_on_toggle_button_pressed)
#
#func _on_toggle_button_pressed() -> void:
	#overlay.visible = not overlay.visible


func _on_button_toggled(toggled_on: bool) -> void:
	pass
