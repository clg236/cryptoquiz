extends Node

var player = {
	'id' : 'clg236',
	'role' : 'faculty',
	'name' : 'Christian Grewell',
	'total_eth' : 10,
	'session_eth' : 0,
	'eth_address' : '0x556E1fE6491036be98023B714390f1d4940Aaf45',
	'signature' : '0x570d969a1eb503832097df966b55c7c62ca6db8b61056394489df284f8455b927f569807103c1a2fc30d2e47fa0196b5b411b433306b455bab5035001807541e1b',
	'secret' : 'hello!',
	'avatar' : {
		'color' : '#FE00E7',
	}
}

func get_address():
	return player.eth_address
	
func _test():
	print('test')
