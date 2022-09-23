extends CanvasLayer

### LABELS ###
@export var status_label : Control
@export var participants_label : Control


var participant_count = 0

var dot_tween

func _ready():
	# signal connectsion
	StateManager.connect("network_state_changed", _on_network_state_changed)
	ParticipantManager.connect("participant_joined", _on_participant_joined)

	# dot tween
	dot_tween = create_tween().set_loops()
	dot_tween.tween_property(status_label, "text", "CONNECTING ", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING .", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING ..", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING ...", .1)

# state handlers
func _on_network_state_changed(new_state):
	# stop the dot tween if we are not connecting
	if new_state != StateManager.NETWORK_STATE.CONNECTING:
		dot_tween.stop()
	status_label.text = 'CONNECTION STATUS: ' + StateManager.NETWORK_STATE.keys()[new_state]

func _on_participant_joined(participant):
	participants_label.text = 'PARTICIPANTS: ' + str(ParticipantManager.participant_count)

func show_status(status):
	if status:
		visible = true
	else:
		visible = false
	
