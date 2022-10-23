extends CenterContainer

var participant_scene = preload("res://scenes/components/hand_raised_participant.tscn")
@export var participant_container : GridContainer

var participants = []

func _ready():
	DataParser.connect('hand_raised', _on_hand_raised)

func _on_hand_raised(raised, participant):
	if raised:
		if participant_container.get_child_count() != 0:
			for child in participant_container.get_children():
				if child.participant.name == participant.name:
					return
				else:
					var p = participant_scene.instantiate()
					participant_container.add_child(p)
					p.participant = participant
					p.name_label.text = participant.name
		else:
			var p = participant_scene.instantiate()
			participant_container.add_child(p)
			p.participant = participant
			p.name_label.text = participant.name
	else:
		for child in participant_container.get_children():
			if child.participant.name == participant.name:
				child.queue_free()
