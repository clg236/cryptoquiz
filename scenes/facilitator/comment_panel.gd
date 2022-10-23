extends Panel

@export var comment_container : VBoxContainer
var comment_scene = preload("res://scenes/components/comment.tscn")

func _ready():
	DataParser.connect('comment_recieved', _on_comment_recieved)
	
func _on_comment_recieved(comment, comment_name):
	var c = comment_scene.instantiate()
	comment_container.add_child(c)
	c.participant_name.text = comment_name + ": "
	c.comment_text.text = comment
