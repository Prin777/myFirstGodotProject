extends CanvasLayer
class_name GameUI

signal start_requested(character: Dictionary)
signal restart_requested

var health_label: Label
var health_container: Control
var health_fill_clip: Control
var enemy_label: Label
var overlay: Control
var panel_slices: Array[TextureRect] = []
var title_label: Label
var message_label: Label
var selection_grid: GridContainer
var character_buttons: Array[Button] = []
var character_button_slices: Array = []
var action_button: Button
var action_button_slices: Array[TextureRect] = []
var action_label: Label
var showing_start := true
var selected_character_index := 0

const CHARACTER_OPTIONS := [
	{
		"name": "Warrior",
		"faction": "Blue Units",
		"unit_type": "Warrior",
		"idle_path": "res://assets/tiny_swords/Tiny Swords (Free Pack)/Units/Blue Units/Warrior/Warrior_Idle.png",
		"idle_frames": 8,
		"max_health": 6,
		"attack_damage": 2,
		"speed": 185.0,
	},
	{
		"name": "Archer",
		"faction": "Blue Units",
		"unit_type": "Archer",
		"idle_path": "res://assets/tiny_swords/Tiny Swords (Free Pack)/Units/Blue Units/Archer/Archer_Idle.png",
		"idle_frames": 6,
		"max_health": 4,
		"attack_damage": 2,
		"speed": 205.0,
	},
	{
		"name": "Lancer",
		"faction": "Blue Units",
		"unit_type": "Lancer",
		"idle_path": "res://assets/tiny_swords/Tiny Swords (Free Pack)/Units/Blue Units/Lancer/Lancer_Idle.png",
		"idle_frames": 12,
		"max_health": 7,
		"attack_damage": 2,
		"speed": 170.0,
	},
	{
		"name": "Pawn",
		"faction": "Blue Units",
		"unit_type": "Pawn",
		"idle_path": "res://assets/tiny_swords/Tiny Swords (Free Pack)/Units/Blue Units/Pawn/Pawn_Idle.png",
		"idle_frames": 8,
		"max_health": 5,
		"attack_damage": 1,
		"speed": 195.0,
	},
]

const BAR_BASE_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/BigBar_Base.png"
const BAR_FILL_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/BigBar_Fill.png"
const PAPER_REGULAR_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Papers/RegularPaper.png"
const PAPER_SPECIAL_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Papers/SpecialPaper.png"
const BUTTON_BLUE_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const BUTTON_BLUE_PRESSED_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"
const BUTTON_RED_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png"
const BUTTON_RED_PRESSED_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Pressed.png"

const HEALTH_BAR_SIZE := Vector2(240, 48)
const HEALTH_CAP_WIDTH := 24.0
const HEALTH_FILL_INSET := Vector2(24, 16)
const HEALTH_FILL_SIZE := Vector2(192, 16)
const ATLAS_SLICE_SIZE := 64.0
const PANEL_CORNER_SIZE := 80.0
const BUTTON_CORNER_SIZE := 22.0

func _ready() -> void:
	_build_hud()
	_build_overlay()

func show_start() -> void:
	health_container.visible = false
	health_label.visible = false
	enemy_label.visible = false
	overlay.visible = true
	showing_start = true
	selection_grid.visible = true
	_set_sliced_box_texture(panel_slices, PAPER_REGULAR_PATH)
	title_label.text = "Tiny Swords Adventure"
	message_label.text = "Choose a unit, then clear the meadow before the raiders surround the village."
	_set_sliced_box_texture(action_button_slices, BUTTON_BLUE_PATH)
	action_label.text = "Start"
	_refresh_character_buttons()

func show_hud() -> void:
	health_container.visible = true
	health_label.visible = true
	enemy_label.visible = true
	overlay.visible = false

func show_result(title: String, message: String) -> void:
	overlay.visible = true
	showing_start = false
	selection_grid.visible = false
	_set_sliced_box_texture(panel_slices, PAPER_SPECIAL_PATH)
	title_label.text = title
	message_label.text = "%s\nPress R or use the button to try again." % message
	_set_sliced_box_texture(action_button_slices, BUTTON_RED_PATH)
	action_label.text = "Restart"

func set_health(current: int, maximum: int) -> void:
	var ratio := 0.0
	if maximum > 0:
		ratio = clampf(float(current) / float(maximum), 0.0, 1.0)
	health_fill_clip.size.x = HEALTH_FILL_SIZE.x * ratio
	health_label.text = "HP  %d / %d" % [current, maximum]

func set_enemies(count: int) -> void:
	enemy_label.text = "Enemies  %d" % count

func get_selected_character() -> Dictionary:
	return CHARACTER_OPTIONS[selected_character_index].duplicate()

func _build_hud() -> void:
	health_container = Control.new()
	health_container.position = Vector2(24, 18)
	health_container.size = HEALTH_BAR_SIZE
	health_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(health_container)

	_add_health_bar_slice(Vector2.ZERO, Vector2(HEALTH_CAP_WIDTH, HEALTH_BAR_SIZE.y), Rect2(40, 0, 24, 64))
	_add_health_bar_slice(Vector2(HEALTH_CAP_WIDTH, 0), Vector2(HEALTH_FILL_SIZE.x, HEALTH_BAR_SIZE.y), Rect2(128, 0, 64, 64))
	_add_health_bar_slice(Vector2(HEALTH_CAP_WIDTH + HEALTH_FILL_SIZE.x, 0), Vector2(HEALTH_CAP_WIDTH, HEALTH_BAR_SIZE.y), Rect2(256, 0, 24, 64))

	health_fill_clip = Control.new()
	health_fill_clip.position = HEALTH_FILL_INSET
	health_fill_clip.size = HEALTH_FILL_SIZE
	health_fill_clip.clip_contents = true
	health_container.add_child(health_fill_clip)

	var fill_atlas := AtlasTexture.new()
	fill_atlas.atlas = load(BAR_FILL_PATH) as Texture2D
	fill_atlas.region = Rect2(0, 20, 64, 24)

	var health_fill := TextureRect.new()
	health_fill.texture = fill_atlas
	health_fill.size = HEALTH_FILL_SIZE
	health_fill.stretch_mode = TextureRect.STRETCH_TILE
	health_fill.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	health_fill_clip.add_child(health_fill)

	health_label = Label.new()
	health_label.position = Vector2(64, 28)
	health_label.add_theme_font_size_override("font_size", 16)
	health_label.add_theme_color_override("font_color", Color("#fff7d8"))
	health_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	health_label.add_theme_constant_override("shadow_offset_x", 1)
	health_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(health_label)

	enemy_label = Label.new()
	enemy_label.position = Vector2(24, 58)
	enemy_label.add_theme_font_size_override("font_size", 22)
	enemy_label.add_theme_color_override("font_color", Color("#f7f1dc"))
	add_child(enemy_label)

func _add_health_bar_slice(position: Vector2, size: Vector2, region: Rect2) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(BAR_BASE_PATH) as Texture2D
	atlas.region = region

	var slice := TextureRect.new()
	slice.texture = atlas
	slice.position = position
	slice.size = size
	slice.stretch_mode = TextureRect.STRETCH_SCALE
	slice.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	health_container.add_child(slice)

func _build_overlay() -> void:
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.07, 0.1, 0.76)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)

	var panel := Control.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -300
	panel.offset_top = -220
	panel.offset_right = 300
	panel.offset_bottom = 220
	overlay.add_child(panel)

	_build_sliced_box(panel, panel_slices, PAPER_REGULAR_PATH, PANEL_CORNER_SIZE)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 86
	box.offset_top = 76
	box.offset_right = -86
	box.offset_bottom = -70
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 34)
	box.add_child(title_label)

	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(400, 84)
	message_label.add_theme_font_size_override("font_size", 18)
	box.add_child(message_label)

	selection_grid = GridContainer.new()
	selection_grid.columns = 4
	selection_grid.add_theme_constant_override("h_separation", 12)
	selection_grid.custom_minimum_size = Vector2(408, 116)
	box.add_child(selection_grid)
	_build_character_selection()

	action_button = Button.new()
	action_button.custom_minimum_size = Vector2(180, 58)
	action_button.text = ""
	action_button.flat = true
	action_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	action_button.button_down.connect(_on_action_button_down)
	action_button.button_up.connect(_on_action_button_up)
	action_button.mouse_exited.connect(_on_action_button_up)
	action_button.pressed.connect(_on_action_pressed)
	box.add_child(action_button)
	_build_sliced_box(action_button, action_button_slices, BUTTON_BLUE_PATH, BUTTON_CORNER_SIZE)

	action_label = Label.new()
	action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	action_label.add_theme_font_size_override("font_size", 20)
	action_label.add_theme_color_override("font_color", Color("#fff7d8"))
	action_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	action_label.add_theme_constant_override("shadow_offset_x", 1)
	action_label.add_theme_constant_override("shadow_offset_y", 1)
	action_button.add_child(action_label)

func _on_action_pressed() -> void:
	if showing_start:
		start_requested.emit(get_selected_character())
	else:
		restart_requested.emit()

func _on_character_pressed(index: int) -> void:
	selected_character_index = index
	_refresh_character_buttons()

func _refresh_character_buttons() -> void:
	for index in range(character_buttons.size()):
		var slices: Array = character_button_slices[index]
		_set_sliced_box_texture(slices, BUTTON_BLUE_PATH if index == selected_character_index else BUTTON_RED_PATH)

func _on_action_button_down() -> void:
	if showing_start:
		_set_sliced_box_texture(action_button_slices, BUTTON_BLUE_PRESSED_PATH)
	else:
		_set_sliced_box_texture(action_button_slices, BUTTON_RED_PRESSED_PATH)

func _on_action_button_up() -> void:
	if showing_start:
		_set_sliced_box_texture(action_button_slices, BUTTON_BLUE_PATH)
	else:
		_set_sliced_box_texture(action_button_slices, BUTTON_RED_PATH)

func _build_character_selection() -> void:
	for index in range(CHARACTER_OPTIONS.size()):
		var config: Dictionary = CHARACTER_OPTIONS[index]
		var button := Button.new()
		button.custom_minimum_size = Vector2(93, 116)
		button.text = ""
		button.flat = true
		button.clip_contents = true
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.pressed.connect(_on_character_pressed.bind(index))
		selection_grid.add_child(button)
		character_buttons.append(button)

		var slices: Array[TextureRect] = []
		_build_sliced_box(button, slices, BUTTON_RED_PATH, BUTTON_CORNER_SIZE)
		character_button_slices.append(slices)

		var preview := Sprite2D.new()
		preview.texture = _make_unit_preview_texture(config)
		preview.centered = true
		preview.position = Vector2(46, 42)
		preview.scale = Vector2.ONE * _preview_scale(config)
		preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.add_child(preview)

		var label_backing := ColorRect.new()
		label_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label_backing.position = Vector2(8, 80)
		label_backing.size = Vector2(77, 26)
		label_backing.color = Color(0.04, 0.08, 0.12, 0.82)
		button.add_child(label_backing)

		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.position = Vector2(8, 81)
		label.size = Vector2(77, 24)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.text = String(config["name"])
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color("#fff6c7"))
		label.add_theme_color_override("font_outline_color", Color("#111827"))
		label.add_theme_constant_override("outline_size", 4)
		button.add_child(label)

func _make_unit_preview_texture(config: Dictionary) -> Texture2D:
	var texture := load(String(config["idle_path"])) as Texture2D
	if texture == null:
		return null
	var frame_count := int(config["idle_frames"])
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2.ZERO, Vector2(float(texture.get_width()) / float(frame_count), float(texture.get_height())))
	return atlas

func _preview_scale(config: Dictionary) -> float:
	var texture := load(String(config["idle_path"])) as Texture2D
	if texture == null:
		return 1.0
	return 56.0 / float(texture.get_height())

func _build_sliced_box(parent: Control, slices: Array, texture_path: String, corner_size: float) -> void:
	for index in range(9):
		var piece := TextureRect.new()
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		piece.stretch_mode = TextureRect.STRETCH_SCALE
		parent.add_child(piece)
		slices.append(piece)
	_set_sliced_box_texture(slices, texture_path)
	parent.resized.connect(_layout_sliced_box.bind(parent, slices, corner_size))
	_layout_sliced_box(parent, slices, corner_size)

func _set_sliced_box_texture(slices: Array, texture_path: String) -> void:
	var atlas_texture := load(texture_path) as Texture2D
	for index in range(slices.size()):
		var column := index % 3
		var row := int(index / 3)
		var atlas := AtlasTexture.new()
		atlas.atlas = atlas_texture
		atlas.region = Rect2(
			Vector2(column * ATLAS_SLICE_SIZE * 2.0, row * ATLAS_SLICE_SIZE * 2.0),
			Vector2(ATLAS_SLICE_SIZE, ATLAS_SLICE_SIZE)
		)
		var piece: TextureRect = slices[index] as TextureRect
		piece.texture = atlas

func _layout_sliced_box(target: Control, slices: Array, corner_size: float) -> void:
	if slices.size() != 9:
		return
	var size := target.size
	var middle_size := Vector2(
		maxf(0.0, size.x - corner_size * 2.0),
		maxf(0.0, size.y - corner_size * 2.0)
	)
	var widths := [corner_size, middle_size.x, corner_size]
	var heights := [corner_size, middle_size.y, corner_size]
	var lefts := [0.0, corner_size, size.x - corner_size]
	var tops := [0.0, corner_size, size.y - corner_size]
	for row in range(3):
		for column in range(3):
			var piece: TextureRect = slices[row * 3 + column] as TextureRect
			piece.position = Vector2(lefts[column], tops[row])
			piece.size = Vector2(widths[column], heights[row])
