extends Node

signal participant_joined(participant)
var participants = []

var participant_count = 0

func participant_join(participant):
	participant_count += 1
	emit_signal("participant_joined", participant)


