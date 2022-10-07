extends CanvasLayer

@export var logout_button : Button
@export var page_heading : Label
@export var menu : PopupMenu
@export var home_icon : Texture2D
@export var classes_icon : Texture2D
@export var quizzes_icon : Texture2D
@export var financials_icon : Texture2D
@export var students_icon : Texture2D

signal menu_changed(item)
var menu_created : bool = false

func _ready():
	menu.connect("id_pressed", _on_menu_selected)
	logout_button.connect("pressed", _on_logout_button_pressed)

func create_menu():
	if !menu_created:
		menu_created = true
		if PlayerManager.player.role == 'facilitator':
			page_heading.text = 'HOME'
			menu.add_icon_item(home_icon, 'HOME')
			menu.add_icon_item(classes_icon, 'CLASSES')
			menu.add_icon_item(quizzes_icon, 'QUIZZES')
			menu.add_icon_item(students_icon, 'PARTICIPANTS')
			menu.add_icon_item(financials_icon, 'FINANCIALS')
		else:
			page_heading.text = 'HOME'
			menu.add_icon_item(home_icon, 'HOME')
			menu.add_icon_item(classes_icon, 'CLASSES')
			menu.add_icon_item(financials_icon, 'WALLET')
	
func _on_menu_selected(index):
	page_heading.text = menu.get_item_text(index)
	emit_signal("menu_changed", menu.get_item_text(index))
	
func _on_logout_button_pressed():
	UIManager.change_scene(UIManager.start_page)
	NetworkManager.disconnect_from_server()

func remove_items():
	menu.clear()
	
func show_header(header):
	if header:
		visible = true
	else:
		visible = false
