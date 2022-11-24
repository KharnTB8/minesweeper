extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var height = 10
var width = 10
var bomb = 10
var bomb_coords = []
onready var playfield = $Playfield
const tiles = preload("res://Tiles.tscn")
var clue_coords = []
var dict_instances = {}
var reversed_dict_instances = {}
var dict_chunk_queue = {}
var game_is_over = false
var win_goal
var win_counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	win_condition_generation()
	bombcoordgeneration()
	for h in height:
		for w in width:
			var tempvector = Vector2(w,h)
			playfield.set_cellv(tempvector,0) 
			var object = tiles.instance()
			object.connect("uncover_signal", self, "chunk_uncover")
			object.connect("lose_signal", self, "game_lost")
			object.connect("win_signal", self, "game_won")
			dict_instances[tempvector] = object.get_instance_id()
			reversed_dict_instances[object.get_instance_id()] = tempvector
			object.position = playfield.map_to_world(tempvector) * playfield.scale
			add_child(object)
			if bomb_coords.find(tempvector) >= 0:
				object.setbomb()
				cluecoordgen(tempvector)
			playfield.set_cellv(tempvector,-1)
	cluepopulation()
func chunk_uncover(tile_id):
	var clicked_tile = instance_from_id(tile_id)
	if not clicked_tile.bomb:
		var clickedcoords = reversed_dict_instances[tile_id]
		for x in 3:
			for y in 3:
				var offsetx = -1+clickedcoords.x + x
				var offsety = -1+clickedcoords.y + y
				var xrange = offsetx >= 0 and offsetx <= width-1
				var yrange = offsety >= 0 and offsety <= height-1
				var selfcoords = offsetx== clickedcoords.x and offsety== clickedcoords.y
				if xrange and yrange and !(selfcoords):
					var tempvector = Vector2(offsetx, offsety)
					dict_chunk_queue[dict_instances[tempvector]] = tempvector
		for next_tile in dict_chunk_queue:
			var next_tile_instance = instance_from_id(next_tile)
			if not next_tile_instance.bomb and  next_tile_instance.covered:
				next_tile_instance.uncover(false)
				if next_tile_instance.clue == 0:
					chunk_uncover(next_tile)
func bombcoordgeneration():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var tempx = 0
	var tempy = 0
	var tempcoord = []
	while bomb_coords.size()<bomb:
		tempx = rng.randi_range(0,width-1)
		tempy = rng.randi_range(0,height-1)
		tempcoord = Vector2(tempx,tempy)
		if bomb_coords.find(tempcoord) < 0:
			bomb_coords.push_back(tempcoord)
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
func cluepopulation():
	for cluecoord in clue_coords :
		var tempTile = instance_from_id(dict_instances[cluecoord])
		tempTile.incrementClue()
func game_lost():
	var bomb_tile
	for bomb in bomb_coords:
		bomb_tile = instance_from_id(dict_instances[bomb])
		bomb_tile.uncover(false)
	$"Text Layer/Game over".visible = true
	
	game_is_over = true
func game_won():
	game_is_over = true
	$"Text Layer/You win!".visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func win_condition_generation():
	win_goal = height * width - bomb
