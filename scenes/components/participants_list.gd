extends Control

var participant_row = preload("res://scenes/components/participant_row.tscn")
@export var participant_container : VBoxContainer

func _ready():
	# ask for a class list
	NetworkManager.get_event(PlayerManager.player.event_code)
	# connect to our data parser to get participant lists
	DataParser.connect("class_recieved", _on_class_list_recieved)
	DataParser.connect("participant_joined", _on_participant_joined)
	

func _on_class_list_recieved(data):
	
	# clear our current list
	for child in participant_container.get_children():
		child.queue_free()

	for participant in data.participants:
		print(data.participants[participant])
		var p = participant_row.instantiate()
		participant_container.add_child(p)
		p.participant_name.text = data.participants[participant]["name"]
		p.participant_address.text = data.participants[participant]["eth_address"]
		p.treasure_label.text = str(data.participants[participant]["treasure"])

func _on_participant_joined():
	print('new participant!')
	NetworkManager.get_event(PlayerManager.player.event_code)
