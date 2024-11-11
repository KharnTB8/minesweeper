extends HBoxContainer

@onready var gameContainer = get_node("CenterContainer")
@onready var game = gameContainer.get_node("Main")
@onready var diff = get_node("Difficulty_Menu")
@onready var custom = get_node("Custom_Difficulty")
@onready var bomb_option = diff.get_node("MarginContainer/VBoxContainer/Bomb_Options")
@onready var easy_button = bomb_option.get_node("Easy")
@onready var norm_button = bomb_option.get_node("Normal")
@onready var hard_button = bomb_option.get_node("Hard")
@onready var size_option = diff.get_node("MarginContainer/VBoxContainer/Size_Options")
@onready var small_size_button = size_option.get_node("Small")
@onready var med_size_button = size_option.get_node("Medium")
@onready var large_size_button = size_option.get_node("Large")
@onready var new_game_button = get_node("Buttons/NewGameButton")
@onready var change_diff_button = get_node("Buttons/ChangeDifficultyButton")
@onready var custom_diff_button = get_node("Buttons/CustomDifficultyButton")

@onready var custom_option = get_node("Custom_Difficulty/MarginContainer/OptionsContainer")
@onready var custom_bomb_slider = custom_option.get_node("BombOptions/BombSlider")
@onready var custom_height_slider = custom_option.get_node("HeightOptions/HeightSlider")
@onready var custom_width_slider = custom_option.get_node("WidthOptions/WidthSlider")

func _ready():
	neighbor_setup()
	easy_button.pressed.connect(easy_pressed)
	norm_button.pressed.connect(norm_pressed)
	hard_button.pressed.connect(hard_pressed)
	
	small_size_button.pressed.connect(small_pressed)
	med_size_button.pressed.connect(med_pressed)
	large_size_button.pressed.connect(large_pressed)
	
	custom_bomb_slider.drag_ended.connect(bomb_drag_ended)
	custom_height_slider.drag_ended.connect(height_drag_ended)
	custom_width_slider.drag_ended.connect(width_drag_ended)

func neighbor_setup():
	new_game_button.grab_focus()

func bomb_drag_ended(value_changed):
	if value_changed:
		game.bomb_percent = custom_bomb_slider.value

func height_drag_ended(value_changed):
	if value_changed:
		game.height = custom_height_slider.value

func width_drag_ended(value_changed):
	if value_changed:
		game.width = custom_width_slider.value

#@todo make all these just one function from the signal with a size param
func small_pressed():
	change_size(10,10)

func med_pressed():
	change_size(15,15)

func large_pressed():
	change_size(20,20)
	
func change_size(xvalue, yvalue):
	game.height = xvalue
	game.width = yvalue
	custom_height_slider.value = xvalue
	custom_width_slider.value = yvalue

func hard_pressed():
	change_bombs(0.25)

func norm_pressed():
	change_bombs(0.15)

func easy_pressed():
	change_bombs(0.10) 

func change_bombs(value):
	game.bomb_percent = value
	custom_bomb_slider.value = value

func _on_NewGameButton_pressed():
	game.new_game_gen()
	gameContainer.visible = true
	diff.visible = false
	custom.visible = false
	

func _on_Change_Difficulty_pressed():
	gameContainer.visible = false
	diff.visible = true
	custom.visible = false

func _on_Custom_Game_pressed():
	gameContainer.visible = false
	diff.visible = false
	custom.visible = true
