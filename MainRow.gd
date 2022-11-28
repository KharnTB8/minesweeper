extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var game = get_node("CenterContainer/Main")
onready var diff = get_node("Difficulty_Menu")
onready var easy_button = get_node("Difficulty_Menu/MarginContainer/VBoxContainer/Bomb_Options/Easy")
onready var norm_button = get_node("Difficulty_Menu/MarginContainer/VBoxContainer/Bomb_Options/Normal")
onready var hard_button = get_node("Difficulty_Menu/MarginContainer/VBoxContainer/Bomb_Options/Hard")
onready var small_size_button = get_node("Difficulty_Menu/MarginContainer/VBoxContainer/Size_Options/Small")
onready var med_size_button = get_node("Difficulty_Menu/MarginContainer/VBoxContainer/Size_Options/Medium")
onready var large_size_button = get_node("Difficulty_Menu/MarginContainer/VBoxContainer/Size_Options/Large")

func _ready():
	easy_button.connect("pressed", self,"easy_pressed")
	norm_button.connect("pressed", self,"norm_pressed")
	hard_button.connect("pressed", self,"hard_pressed")
	small_size_button.connect("pressed", self,"small_pressed")
	med_size_button.connect("pressed", self,"med_pressed")
	large_size_button.connect("pressed", self,"large_pressed")
func small_pressed():
	game.height = 10
	game.width = 10
func med_pressed():
	game.height = 15
	game.width = 15
func large_pressed():
	game.height = 20
	game.width = 20
func hard_pressed():
	game.bomb_percent = 0.25
func norm_pressed():
	game.bomb_percent = 0.15
func easy_pressed():
	game.bomb_percent = 0.10
func _on_NewGameButton_pressed():
	game.new_game_gen()
	game.visible = true
	diff.visible = false

func _on_Change_Difficulty_pressed():
	game.visible = false
	diff.visible = true
