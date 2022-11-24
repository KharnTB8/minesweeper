extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var bomb = false
var clue = 0
var covered = true
var flagged = false
signal uncover_signal(tile_id)
signal lose_signal
signal win_signal
func _ready():
	spriteinitialization() 
	pass # Replace with function body.
func spriteinitialization():
	$TileBomb.visible = false
	$TileBack.visible = true
	$Clue.visible = false 
	$Flag.visible = false
	$TileCover.visible = true
func uncover(emit:bool):
	if not flagged and covered:
		covered = false
		$TileCover.visible = false
		if not bomb:
			get_parent().win_counter += 1
			if get_parent().win_counter == get_parent().win_goal:
				emit_signal("win_signal")
		if bomb:
			emit_signal("lose_signal")
		elif emit and clue == 0:
			emit_signal("uncover_signal", self.get_instance_id())
func toggleflag():
	if covered:
		flagged = not flagged
		$Flag.visible = flagged
func setbomb():
	bomb = true
	$TileBomb.visible = true
	$Clue/ClueSprite.set_frame(0)
	$Clue.visible = false
	clue = 0
func incrementClue():
	if clue < 8 and not bomb:
		clue +=1
		$Clue/ClueSprite.set_frame(clue)
		$Clue.visible = true
func _on_Control_gui_input(event):
	if event is InputEventMouseButton and not get_parent().game_is_over:
		if event.is_action_pressed("left_click"):
			uncover(true)
		if event.is_action_pressed("right_click"):
			toggleflag()
