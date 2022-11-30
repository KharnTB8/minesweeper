extends Node2D

# basic attributes of the game
export var height: int	 		= 10
export var width: int	 		= 10
export var bomb_percent: float 	= 0.10
var bomb: int
# arrays of coords for bombs and clues
var bomb_coords: Array = []
var clue_coords: Array = []
var chunk_queue: Array = []
# dictionaries that keeps track of the coordinates linked to an instance id
var dict_instances: Dictionary = {}
var reversed_dict_instances: Dictionary = {} 

var game_is_over: bool = false
var win_goal: int #generated from the basic attributes of the game
var win_counter: int = 0

#nodes used by the scene script
onready var playfield		 = $Playfield
onready var tileGrid		 = $_TileGridContainer
onready var gameOverLabel	 = $TextLayer/GameOver
onready var youWinLabel		 = $TextLayer/YouWin

#scene to be used by the script
const tiles = preload("res://Tiles.tscn")


func _ready():
	new_game_gen()

func new_game_gen():
	initialize()
	bombcoordgeneration()
	win_condition_generation()
	for h in height:
		for w in width:
			var tempvector = Vector2(w,h) #significant info that will be used at several places
			
			#setup for the single tile 
			var single_tile = tiles.instance()
			single_tile.connect("uncover_signal", self, "chunk_uncover_gen")
			single_tile.connect("lose_signal", self, "game_lost")
			single_tile.connect("increment_uncovered_signal", self, "check_game_won")
			
			#saving the relation of instance id to coordinate in dictionaries
			dict_instances[tempvector] = single_tile.get_instance_id()
			reversed_dict_instances[single_tile.get_instance_id()] = tempvector
			
			#fills the tilemap at the given coordinate with a dummy tile 
			playfield.set_cellv(tempvector,0)
			#uses the position of that dummy tile to set the position of our actual tile
			single_tile.position = playfield.map_to_world(tempvector) * playfield.scale
			#removes the dummy tile
			playfield.set_cellv(tempvector,-1)
			
			tileGrid.add_child(single_tile) #instanciates the node to the scene and calls its _ready()
			
			#sets the bomb at the coordinate if it was determined to be a bomb by the bomb list
			if tempvector in bomb_coords:
				single_tile.setbomb()
				cluecoordgen(tempvector)
		
	cluepopulation()

func initialize():
	clear_tiles()
	game_is_over = false
	gameOverLabel.visible = false
	youWinLabel.visible = false
	bomb_coords = []
	clue_coords = []
	chunk_queue = []
	dict_instances = {}
	reversed_dict_instances = {}

func clear_tiles():
	for n in tileGrid.get_children():
		tileGrid.remove_child(n)
		n.queue_free()

# will queue up all the tiles to uncover around a clicked tile(tile_id) and uncover them
# recursively called
func chunk_uncover_gen(tile_id, recursive: bool):
	
	var clickedcoords = reversed_dict_instances[tile_id]
	#populate the chunk queue
	#since surrounding tiles are layed out like a 3x3 square with an offset
	#we can iterate through that 3x3 square like usual with nested fors
	for x in 3: # x values range from 0 to 2
		for y in 3:
			#the -1 is that offset to move the starting coordinate to be on the top left tile
			#we add the coords of the clicked tile to center it around that tile
			var offsetx = -1 + clickedcoords.x + x
			var offsety = -1 + clickedcoords.y + y
			var tempvector = Vector2(offsetx, offsety)
			var surrounding_tile_id = dict_instances.get(tempvector)
			#set of boolean checks to see if the coordinate is a valid tile
			#just to make the next if more readable
			var isInXRange: bool = offsetx >= 0 and offsetx <= width-1
			var isInYRange: bool = offsety >= 0 and offsety <= height-1 #checks if it is within the boundaries of the playfield
			var isSelfCoords: bool = offsetx == clickedcoords.x and offsety == clickedcoords.y #checks if it is its own coordinate
			var isAlreadyAdded: bool = surrounding_tile_id in chunk_queue #prevents the addition of duplicates
			if isInXRange and isInYRange and !(isSelfCoords) and not isAlreadyAdded:
				#only get the tile to check its clue when the tile is valid
				var surrounding_tile_instance = instance_from_id(surrounding_tile_id)
				chunk_queue.push_back(surrounding_tile_id)
				#it is only when a tile has no clue that we need to check its own 8 surrounding tiles
				if surrounding_tile_instance.clue == 0:
					chunk_uncover_gen(surrounding_tile_id, true)
	#since the recursive call are still building the queue we need to only actually call
	#the uncovering until tue queue is complete
	if not recursive:
		chunk_uncover()

#actual iterating of the chunk queue to uncover the tiles
func chunk_uncover():
	for next_tile_id in chunk_queue:
		var next_tile_instance = instance_from_id(next_tile_id)
		if next_tile_instance.covered: #make sure to only treat tiles that are still covered
			next_tile_instance.uncover(false)

#fills the array that keeps track of where the bombs are on the grid
func bombcoordgeneration():
	#rng setup
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var tempx = 0
	var tempy = 0
	var tempcoord
	bomb = int(height * width * bomb_percent)
	if bomb < 1:
		bomb = 1
	#while is used to make sure that there are the correct amount of bombs
	#due to the randomness of the generation it could generate the same coord multiple times
	while bomb_coords.size()<bomb:
		tempx = rng.randi_range(0,width-1)
		tempy = rng.randi_range(0,height-1)
		tempcoord = Vector2(tempx,tempy)
		if not tempcoord in bomb_coords: #only add coords that arent already in the array
			bomb_coords.push_back(tempcoord)

#takes a coordinate of a bomb and saves the coordinates the valid surrounding tiles
func cluecoordgen(bombcoord : Vector2):
	for x in 3:
		for y in 3:
			var offsetx = -1+bombcoord.x + x
			var offsety = -1+bombcoord.y + y
			var xrange = offsetx >= 0 and offsetx <= width-1
			var yrange = offsety >= 0 and offsety <= height-1
			var selfcoords = offsetx== bombcoord.x and offsety== bombcoord.y
			if xrange and yrange and !(selfcoords):
				var tempvector = Vector2(offsetx, offsety)
				clue_coords.push_back(tempvector)

#from the list of clue coordinates (which can have duplicates in the list)
#increments the clue for the tile
func cluepopulation():
	for cluecoord in clue_coords :
		var tempTile = instance_from_id(dict_instances[cluecoord])
		tempTile.incrementClue()

func game_lost():
	var bomb_tile
	for revealed_bomb in bomb_coords: #just to uncover remaining bombs
		bomb_tile = instance_from_id(dict_instances[revealed_bomb])
		if bomb_tile.covered:
			bomb_tile.uncover(false)
	gameOverLabel.visible = true
	game_is_over = true #prevents any more clicking on the playing field

func check_game_won():
	win_counter +=1
	if win_counter == win_goal:
		game_is_over = true
		youWinLabel.visible = true

#if we take the amount of uncovered tiles as the sensor for a win
#the maximum amount of tiles to uncover would be equal to
#the area of the playfield minus the amount of bombs
func win_condition_generation():
	win_counter = 0
	win_goal = height * width - bomb
