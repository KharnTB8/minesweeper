extends Node2D

signal uncover_signal(tile_id)
signal lose_signal
signal increment_uncovered_signal

onready var tileBombNode	= $TileBomb
onready var tileBackNode	= $TileBack
onready var clueNode		= $Clue
onready var clueSpriteNode	= $Clue/ClueSprite
onready var flagNode		= $Flag
onready var tileCoverNode	= $TileCover

#default states of the tile
var bomb: bool		= false
var clue: int		= 0
var covered: bool	= true
var flagged: bool	= false

func _ready():
	spriteinitialization() 

#just to make sure that the correct sprites are showing up initially
func spriteinitialization():
	tileBombNode.visible	 = false
	tileBackNode.visible	 = true
	clueNode.visible		 = false 
	flagNode.visible		 = false
	tileCoverNode.visible	 = true

#handles the uncovering of self and starts chunk uncovering if emit is true
func uncover(emit: bool):
	if not flagged and covered: #prevents uncovering flagged tiles, and the tile has to be covered
		covered = false
		tileCoverNode.visible = false
		if bomb: #clicked on a bomb, game is lost. parent handles this
			emit_signal("lose_signal")
		elif emit and clue == 0:
			emit_signal("uncover_signal", self.get_instance_id())
		else:
			emit_signal("increment_uncovered_signal")
		
		

func toggleflag():
	if covered:
		flagged = not flagged
		flagNode.visible = flagged

func setbomb():
	bomb = true
	tileBombNode.visible = true
	clueSpriteNode.set_frame(0)
	clueNode.visible = false
	clue = 0

func incrementClue():
	if clue < 8 and not bomb:
		clue +=1
		clueSpriteNode.set_frame(clue)
		clueNode.visible = true

func _on_Control_gui_input(event):
	if event is InputEventMouseButton and not get_parent().get_parent().game_is_over:
		if event.is_action_pressed("left_click"):
			uncover(true)
		if event.is_action_pressed("right_click"):
			toggleflag()
