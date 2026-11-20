extends Control

@export var title: Label
@export var description: RichTextLabel

func set_text(title_text: String, description_text: String) -> void:
	title.text = title_text
	description.text = description_text
	
