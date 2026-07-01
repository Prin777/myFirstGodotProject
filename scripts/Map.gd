extends Node2D
class_name AdventureMap

const WORLD_RECT := Rect2(40, 80, 1160, 580)
const OBSTACLES := [
	Rect2(320, 180, 95, 110),
	Rect2(470, 460, 120, 72),
	Rect2(785, 155, 120, 88),
	Rect2(900, 470, 135, 90),
	Rect2(555, 285, 80, 70),
]

var tile_texture: Texture2D

func _ready() -> void:
	z_index = -20
	tile_texture = load("res://assets/tiny_swords/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png") as Texture2D
	_build_collisions()
	_add_decorations()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-400, -240, 2100, 1200), Color("#22324a"))
	draw_rect(WORLD_RECT, Color("#6eab57"))
	_draw_grass()
	_draw_water()
	_draw_paths()
	_draw_obstacles()
	_draw_border()

func _build_collisions() -> void:
	var bounds := [
		Rect2(WORLD_RECT.position.x - 80, WORLD_RECT.position.y - 80, WORLD_RECT.size.x + 160, 80),
		Rect2(WORLD_RECT.position.x - 80, WORLD_RECT.end.y, WORLD_RECT.size.x + 160, 80),
		Rect2(WORLD_RECT.position.x - 80, WORLD_RECT.position.y, 80, WORLD_RECT.size.y),
		Rect2(WORLD_RECT.end.x, WORLD_RECT.position.y, 80, WORLD_RECT.size.y),
	]
	for rect in bounds:
		_add_static_rect(rect)
	for rect in OBSTACLES:
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

func _draw_grass() -> void:
	if tile_texture != null:
		var source := Rect2(0, 0, 64, 64)
		for x in range(int(WORLD_RECT.position.x), int(WORLD_RECT.end.x), 64):
			for y in range(int(WORLD_RECT.position.y), int(WORLD_RECT.end.y), 64):
				draw_texture_rect_region(tile_texture, Rect2(x, y, 64, 64), source)
		return
	for x in range(int(WORLD_RECT.position.x) + 20, int(WORLD_RECT.end.x), 64):
		for y in range(int(WORLD_RECT.position.y) + 20, int(WORLD_RECT.end.y), 64):
			var shade := Color("#79b960") if int((x + y) / 64) % 2 == 0 else Color("#669f50")
			draw_rect(Rect2(x, y, 18, 6), shade)

func _draw_water() -> void:
	var water := Rect2(72, 112, 136, 516)
	draw_rect(water, Color("#4287c7"))
	for y in range(int(water.position.y) + 18, int(water.end.y), 38):
		draw_line(Vector2(water.position.x + 18, y), Vector2(water.end.x - 20, y + 10), Color("#9bd4f0"), 3.0)

func _draw_paths() -> void:
	draw_rect(Rect2(180, 332, 760, 74), Color("#c9a56a"))
	draw_rect(Rect2(706, 220, 76, 280), Color("#c9a56a"))
	draw_rect(Rect2(180, 332, 760, 74), Color("#aa8754"), false, 3.0)
	draw_rect(Rect2(706, 220, 76, 280), Color("#aa8754"), false, 3.0)

func _draw_obstacles() -> void:
	for rect in OBSTACLES:
		draw_rect(rect, Color("#6a4f37"))
		draw_rect(rect.grow(-10), Color("#2f7d4a"))
		draw_rect(Rect2(rect.position.x + 15, rect.position.y - 18, rect.size.x - 30, 28), Color("#7a5638"))
	for point in [Vector2(245, 205), Vector2(265, 545), Vector2(1110, 170), Vector2(1125, 610)]:
		draw_circle(point, 30, Color("#3f8452"))
		draw_circle(point + Vector2(0, 22), 13, Color("#74533a"))

func _draw_border() -> void:
	draw_rect(WORLD_RECT, Color("#395238"), false, 6.0)

func _add_decorations() -> void:
	_add_decoration("res://assets/tiny_swords/Tiny Swords (Free Pack)/Terrain/Decorations/Bushes/Bushe1.png", Vector2(360, 206), 0.85)
	_add_decoration("res://assets/tiny_swords/Tiny Swords (Free Pack)/Terrain/Decorations/Bushes/Bushe3.png", Vector2(525, 488), 0.85)
	_add_decoration("res://assets/tiny_swords/Tiny Swords (Free Pack)/Terrain/Decorations/Rocks/Rock1.png", Vector2(840, 178), 0.78)
	_add_decoration("res://assets/tiny_swords/Tiny Swords (Free Pack)/Terrain/Decorations/Rocks/Rock3.png", Vector2(956, 502), 0.78)

func _add_decoration(path: String, decoration_position: Vector2, scale_amount: float) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = decoration_position
	sprite.scale = Vector2(scale_amount, scale_amount)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
