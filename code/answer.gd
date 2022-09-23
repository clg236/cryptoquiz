extends RichTextLabel

signal answer_chosen(index)
@export var button : Button

func _ready():
	button.connect("pressed", _on_choice_selected)

func _on_choice_selected():
	emit_signal("answer_chosen", get_index())
