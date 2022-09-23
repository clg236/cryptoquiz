extends Control

@export var high_scores_list : Control

var score_list_item = preload("res://scenes/score_list_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	DataParser.connect('quiz_participant_recieved', _on_participant_recieved)

func _on_participant_recieved(participant):
	var participant_exists
	# check if they are already on our list
	for high_score in high_scores_list.get_children():
		if high_score.player_name.text == participant.name:
			participant_exists = true
			high_score.session_eth.text = str(participant.session_eth)
			high_score.total_eth.text = str(participant.total_eth)
		else:
			participant_exists = false
	
	if !participant_exists:
		# add them to our high scores list
		var p = score_list_item.instantiate()
		high_scores_list.add_child(p)
		p.player_name.text = participant.name
		p.session_eth.text = str(participant.session_eth)
		p.total_eth.text = str(participant.total_eth)
	
	
	
	
