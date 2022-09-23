extends Control

@export var create_class_button : Button
@export var class_code_field : TextEdit
@export var class_name_field : TextEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	create_class_button.connect('pressed', _on_create_class_button_pressed)
	DataParser.connect("class_recieved", _on_class_list_recieved)
	DataParser.connect("class_created", _on_class_created)

func _on_class_list_recieved(clazz):
	print('got a class list: ', clazz)
	
func _on_class_created(clazz):
	print('class created successfully: ', clazz)
	# update our class list
	

func _on_create_class_button_pressed():
	if class_name_field.text != '' and class_code_field.text != '':
		NetworkManager.create_class(class_code_field.text, class_name_field.text)
	else:
		print('need a code and name!')
