extends Node2D
class_name AdventureMap

const CELL_SIZE := 64
const MAP_ORIGIN := Vector2(64, 96)
const MAP_COLUMNS := 18
const MAP_ROWS := 9
const WORLD_RECT := Rect2(40, 80, 1160, 580)

const TERRAIN_BASE := "res://assets/tiny_swords/Tiny Swords (Free Pack)/Terrain/"
const BUILDING_BASE := "res://assets/tiny_swords/Tiny Swords (Free Pack)/Buildings/"
const BLUE_BUILDINGS := BUILDING_BASE + "Blue Buildings/"
const RED_BUILDINGS := BUILDING_BASE + "Red Buildings/"
const YELLOW_BUILDINGS := BUILDING_BASE + "Yellow Buildings/"

const LEVEL_MASK := [
	"LLLLLLWWWWWWWWWWWW",
	"LLLLLLLLLLWWLLLLLW",
	"LLLLLLLLLLLLLLLLLL",
	"LLLLLLLLWWWLLLLLLL",
	"LLLLLLLWWLLLLLLLLL",
	"LLLLLLWWLLLLLLLLLL",
	"LLLLWWWWLLLLLLLLLL",
	"WWLLWWLWWLLLLLLLLW",
	"LWWWWLWWWWWWLLLLLW",
]

const CLIFF_COLOR := Color("#6f8f88")
const CLIFF_DARK := Color("#435f62")
const FOAM_COLOR := Color("#d6fff0")
const WATER_COLOR := Color("#69aaa8")
const DEEP_WATER_COLOR := Color("#5f9d9e")

var tile_texture: Texture2D
var water_texture: Texture2D
var foam_texture: Texture2D
var generated_sprites: Node2D

func _ready() -> void:
	z_index = -20
	tile_texture = load(TERRAIN_BASE + "Tileset/Tilemap_color1.png") as Texture2D
	water_texture = load(TERRAIN_BASE + "Tileset/Water Background color.png") as Texture2D
	foam_texture = load(TERRAIN_BASE + "Tileset/Water Foam.png") as Texture2D
	_build_level()

func _draw() -> void:
	_draw_water_background()
	_draw_land_tiles()
	_draw_shore_foam()
	_draw_cliff_edges()

func _build_level() -> void:
	generated_sprites = Node2D.new()
	generated_sprites.name = "GeneratedDecorations"
	add_child(generated_sprites)

	_build_collisions()
	_add_landmarks()
	_add_forests()
	_add_ground_details()
	queue_redraw()

func _build_collisions() -> void:
	var bounds: Array[Rect2] = [
		Rect2(WORLD_RECT.position.x - 160, WORLD_RECT.position.y - 160, WORLD_RECT.size.x + 320, 160),
		Rect2(WORLD_RECT.position.x - 160, WORLD_RECT.end.y, WORLD_RECT.size.x + 320, 160),
		Rect2(WORLD_RECT.position.x - 160, WORLD_RECT.position.y, 160, WORLD_RECT.size.y),
		Rect2(WORLD_RECT.end.x, WORLD_RECT.position.y, 160, WORLD_RECT.size.y),
	]
	for rect: Rect2 in bounds:
		_add_static_rect(rect)

	for row: int in range(MAP_ROWS):
		for column: int in range(MAP_COLUMNS):
			if not _is_land_cell(column, row):
				_add_static_rect(_cell_rect(column, row).grow(-3.0))

	var blockers: Array[Rect2] = [
		Rect2(104, 118, 240, 118),
		Rect2(76, 408, 100, 98),
		Rect2(850, 268, 250, 130),
		Rect2(524, 562, 92, 88),
		Rect2(944, 548, 160, 80),
	]
	for rect: Rect2 in blockers:
		_add_static_rect(rect)

func _add_static_rect(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = rect.position + rect.size * 0.5
	add_child(body)

	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect.size
	shape.shape = rectangle
	body.add_child(shape)

func _draw_water_background() -> void:
	draw_rect(Rect2(-320, -220, 1920, 1200), WATER_COLOR)
	for x: int in range(-320, 1600, 128):
		for y: int in range(-220, 980, 128):
			var offset := Vector2(32 if int(y / 128) % 2 == 0 else 0, 0)
			var rect := Rect2(Vector2(x, y) + offset, Vector2(90, 58))
			draw_rect(rect, DEEP_WATER_COLOR, false, 2.0)
	if water_texture != null:
		for x: int in range(-64, 1408, 128):
			for y: int in range(0, 768, 128):
				draw_texture_rect(water_texture, Rect2(x, y, 128, 128), false)

func _draw_land_tiles() -> void:
	for row: int in range(MAP_ROWS):
		for column: int in range(MAP_COLUMNS):
			if not _is_land_cell(column, row):
				continue
			var rect: Rect2 = _cell_rect(column, row)
			if tile_texture != null:
				var tile_index: int = int((column * 3 + row * 5) % 6)
				var source := Rect2(Vector2((tile_index % 3) * CELL_SIZE, int(tile_index / 3) * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
				draw_texture_rect_region(tile_texture, rect, source)
			else:
				var grass := Color("#8abd4d") if int((column + row) % 2) == 0 else Color("#78ad46")
				draw_rect(rect, grass)

func _draw_shore_foam() -> void:
	for row: int in range(MAP_ROWS):
		for column: int in range(MAP_COLUMNS):
			if not _is_land_cell(column, row):
				continue
			var rect: Rect2 = _cell_rect(column, row)
			if not _is_land_cell(column, row - 1):
				_draw_foam_segment(Vector2(rect.position.x, rect.position.y), Vector2(CELL_SIZE, 0))
			if not _is_land_cell(column, row + 1):
				_draw_foam_segment(Vector2(rect.position.x, rect.end.y), Vector2(CELL_SIZE, 0))
			if not _is_land_cell(column - 1, row):
				_draw_foam_segment(Vector2(rect.position.x, rect.position.y), Vector2(0, CELL_SIZE))
			if not _is_land_cell(column + 1, row):
				_draw_foam_segment(Vector2(rect.end.x, rect.position.y), Vector2(0, CELL_SIZE))

func _draw_foam_segment(start: Vector2, span: Vector2) -> void:
	if foam_texture != null and span.x != 0.0:
		draw_texture_rect_region(foam_texture, Rect2(start - Vector2(0, 8), Vector2(CELL_SIZE, 16)), Rect2(0, 0, 64, 16))
		return
	draw_line(start, start + span, FOAM_COLOR, 3.0)

func _draw_cliff_edges() -> void:
	for row: int in range(MAP_ROWS):
		for column: int in range(MAP_COLUMNS):
			if not _is_land_cell(column, row):
				continue
			var rect: Rect2 = _cell_rect(column, row)
			if not _is_land_cell(column, row + 1):
				_draw_cliff(Rect2(rect.position.x, rect.end.y - 10.0, CELL_SIZE, 28.0))
			if not _is_land_cell(column + 1, row):
				_draw_side_cliff(Rect2(rect.end.x - 8.0, rect.position.y + 4.0, 22.0, CELL_SIZE - 8.0))
			if not _is_land_cell(column - 1, row):
				_draw_side_cliff(Rect2(rect.position.x - 14.0, rect.position.y + 4.0, 22.0, CELL_SIZE - 8.0))

func _draw_cliff(rect: Rect2) -> void:
	draw_rect(rect, CLIFF_COLOR)
	for x: int in range(int(rect.position.x), int(rect.end.x), 16):
		draw_line(Vector2(x, rect.position.y + 3.0), Vector2(x + 7.0, rect.end.y - 3.0), CLIFF_DARK, 2.0)
	draw_line(rect.position, Vector2(rect.end.x, rect.position.y), Color("#a5c798"), 3.0)

func _draw_side_cliff(rect: Rect2) -> void:
	draw_rect(rect, CLIFF_COLOR)
	for y: int in range(int(rect.position.y), int(rect.end.y), 18):
		draw_line(Vector2(rect.position.x + 3.0, y), Vector2(rect.end.x - 3.0, y + 8.0), CLIFF_DARK, 2.0)

func _add_landmarks() -> void:
	_add_decoration(BLUE_BUILDINGS + "Castle.png", Vector2(220, 162), 0.78)
	_add_decoration(BLUE_BUILDINGS + "Tower.png", Vector2(128, 456), 0.68)
	_add_decoration(BLUE_BUILDINGS + "Tower.png", Vector2(566, 604), 0.62)

	_add_decoration(YELLOW_BUILDINGS + "House1.png", Vector2(888, 330), 0.66)
	_add_decoration(YELLOW_BUILDINGS + "House2.png", Vector2(986, 350), 0.66)
	_add_decoration(YELLOW_BUILDINGS + "House3.png", Vector2(1068, 318), 0.68)
	_add_decoration(YELLOW_BUILDINGS + "House2.png", Vector2(852, 508), 0.62, true)

	_add_decoration(RED_BUILDINGS + "Barracks.png", Vector2(1012, 594), 0.58, true)

func _add_forests() -> void:
	var tree_base := TERRAIN_BASE + "Resources/Wood/Trees/"
	for position: Vector2 in [
		Vector2(86, 180), Vector2(110, 246), Vector2(174, 268), Vector2(314, 122),
		Vector2(730, 112), Vector2(790, 92), Vector2(840, 128), Vector2(1128, 126),
		Vector2(1086, 526), Vector2(1138, 556), Vector2(1192, 528), Vector2(1168, 620),
	]:
		var index: int = int(abs(position.x + position.y)) % 4 + 1
		_add_decoration(tree_base + "Tree%d.png" % index, position, 0.72)

func _add_ground_details() -> void:
	var decor_base := TERRAIN_BASE + "Decorations/"
	var gold_base := TERRAIN_BASE + "Resources/Gold/Gold Stones/"
	var sheep_base := TERRAIN_BASE + "Resources/Meat/Sheep/"

	for data: Array in [
		[decor_base + "Bushes/Bushe1.png", Vector2(210, 432), 0.78, false],
		[decor_base + "Bushes/Bushe2.png", Vector2(362, 548), 0.72, true],
		[decor_base + "Bushes/Bushe3.png", Vector2(816, 438), 0.76, false],
		[decor_base + "Bushes/Bushe4.png", Vector2(1100, 456), 0.74, true],
		[decor_base + "Rocks/Rock1.png", Vector2(450, 406), 0.72, false],
		[decor_base + "Rocks/Rock2.png", Vector2(690, 288), 0.70, false],
		[decor_base + "Rocks/Rock3.png", Vector2(340, 656), 0.72, true],
		[decor_base + "Rocks/Rock4.png", Vector2(1190, 646), 0.70, false],
		[gold_base + "Gold Stone 2.png", Vector2(598, 292), 0.62, false],
		[sheep_base + "Sheep_Idle.png", Vector2(914, 416), 0.62, false],
		[sheep_base + "Sheep_Grass.png", Vector2(1054, 442), 0.62, true],
		[decor_base + "Rubber Duck/Rubber duck.png", Vector2(664, 612), 0.56, false],
		[decor_base + "Rocks in the Water/Water Rocks_01.png", Vector2(56, 366), 0.70, false],
		[decor_base + "Rocks in the Water/Water Rocks_02.png", Vector2(474, 570), 0.68, true],
		[decor_base + "Rocks in the Water/Water Rocks_03.png", Vector2(1228, 430), 0.68, false],
		[decor_base + "Clouds/Clouds_03.png", Vector2(678, 172), 0.50, false],
	]:
		var path: String = data[0]
		var position: Vector2 = data[1]
		var scale_amount: float = data[2]
		var flip_h: bool = data[3]
		_add_decoration(path, position, scale_amount, flip_h)

func _add_decoration(path: String, decoration_position: Vector2, scale_amount: float, flip_h := false) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = decoration_position
	sprite.scale = Vector2(scale_amount, scale_amount)
	sprite.flip_h = flip_h
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	generated_sprites.add_child(sprite)

func _is_land_cell(column: int, row: int) -> bool:
	if row < 0 or row >= MAP_ROWS or column < 0 or column >= MAP_COLUMNS:
		return false
	return LEVEL_MASK[row].substr(column, 1) == "L"

func _cell_rect(column: int, row: int) -> Rect2:
	return Rect2(MAP_ORIGIN + Vector2(column * CELL_SIZE, row * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
