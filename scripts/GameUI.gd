extends CanvasLayer
class_name GameUI

signal start_requested
signal restart_requested

var health_label: Label
var health_bar: TextureProgressBar
var enemy_label: Label
var overlay: Control
var title_label: Label
var message_label: Label
var action_button: Button

const BAR_BASE_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/BigBar_Base.png"
const BAR_FILL_PATH := "res://assets/tiny_swords/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/BigBar_Fill.png"

func _ready() -> void:
	_build_hud()
	_build_overlay()

func show_start() -> void:
	health_bar.visible = false
	health_label.visible = false
	enemy_label.visible = false
	overlay.visible = true
	title_label.text = "Tiny Swords Adventure"
	message_label.text = "Clear the meadow before the raiders surround the village."
	action_button.text = "Start"

func show_hud() -> void:
	health_bar.visible = true
	health_label.visible = true
	enemy_label.visible = true
	overlay.visible = false

func show_result(title: String, message: String) -> void:
	overlay.visible = true
	title_label.text = title
	message_label.text = "%s\nPress R or use the button to try again." % message
	action_button.text = "Restart"

func set_health(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "HP  %d / %d" % [current, maximum]

func set_enemies(count: int) -> void:
	enemy_label.text = "Enemies  %d" % count

func _build_hud() -> void:
	health_bar = TextureProgressBar.new()
	health_bar.position = Vector2(24, 18)
	health_bar.scale = Vector2(2.0, 2.0)
	health_bar.min_value = 0.0
	health_bar.max_value = 1.0
	health_bar.value = 1.0
	health_bar.texture_under = load(BAR_BASE_PATH) as Texture2D
	health_bar.texture_progress = load(BAR_FILL_PATH) as Texture2D
	health_bar.tint_progress = Color("#57d47a")
	health_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(health_bar)

	health_label = Label.new()
	health_label.position = Vector2(42, 22)
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

func _build_overlay() -> void:
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.07, 0.1, 0.76)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 250)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -240
	panel.offset_top = -125
	panel.offset_right = 240
	panel.offset_bottom = 125
	overlay.add_child(panel)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
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

	action_button = Button.new()
	action_button.custom_minimum_size = Vector2(180, 44)
	action_button.pressed.connect(_on_action_pressed)
	box.add_child(action_button)

func _on_action_pressed() -> void:
	if action_button.text == "Start":
		start_requested.emit()
	else:
		restart_requested.emit()
