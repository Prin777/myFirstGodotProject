extends CharacterBody2D
class_name Player

signal health_changed(current: int, maximum: int)
signal died

@export var speed := 185.0
@export var max_health := 6
@export var attack_damage := 2
@export var unit_faction := "Blue Units"
@export var unit_type := "Warrior"

var health := max_health
var facing := Vector2.RIGHT
var state := "idle"
var attack_time := 0.0
var attack_cooldown := 0.0
var current_attack_animation := "attack1"
var next_attack_index := 1
var invulnerable_time := 0.0
var hurt_flash_time := 0.0
var hit_targets: Array[Node] = []
var sprite: AnimatedSprite2D
var sprite_frame_height := 192.0

@onready var body: Node2D = $Body
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	z_as_relative = false
	health = max_health
	health_changed.emit(health, max_health)
	attack_area.body_entered.connect(_on_attack_body_entered)
	_setup_sprite()

func _physics_process(delta: float) -> void:
	if state == "dead":
		return

	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	invulnerable_time = maxf(0.0, invulnerable_time - delta)
	hurt_flash_time = maxf(0.0, hurt_flash_time - delta)

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length() > 0.0:
		facing = input_vector.normalized()

	var wants_defend := Input.is_action_pressed("defend")
	if wants_defend and attack_time <= 0.0:
		state = "defend"
		attack_area.monitoring = false
		attack_area.visible = false
		velocity = Vector2.ZERO
	elif Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		_start_attack()

	if attack_time > 0.0:
		attack_time -= delta
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 7.0)
		if attack_time <= 0.0:
			attack_area.monitoring = false
			attack_area.visible = false
			state = "idle"
	else:
		if not wants_defend:
			velocity = input_vector * speed
			state = "move" if input_vector.length() > 0.0 else "idle"

	move_and_slide()
	z_index = int(global_position.y)
	_update_visuals()

func take_damage(amount: int) -> void:
	if state == "dead" or invulnerable_time > 0.0:
		return
	if state == "defend" or Input.is_action_pressed("defend"):
		invulnerable_time = 0.12
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	invulnerable_time = 0.65
	hurt_flash_time = 0.18
	if health == 0:
		state = "dead"
		velocity = Vector2.ZERO
		attack_area.monitoring = false
		attack_area.visible = false
		died.emit()

func set_character(config: Dictionary) -> void:
	unit_faction = config.get("faction", unit_faction)
	unit_type = config.get("unit_type", unit_type)
	max_health = int(config.get("max_health", max_health))
	attack_damage = int(config.get("attack_damage", attack_damage))
	speed = float(config.get("speed", speed))

func _start_attack() -> void:
	state = "attack"
	current_attack_animation = "attack%d" % next_attack_index
	next_attack_index = 2 if next_attack_index == 1 else 1
	attack_time = 0.34
	attack_cooldown = 0.48
	hit_targets.clear()

	var aim := get_global_mouse_position() - global_position
	if aim.length() > 16.0:
		facing = aim.normalized()

	attack_area.position = facing * 28.0
	attack_area.rotation = facing.angle()
	attack_area.monitoring = true
	attack_area.visible = true
	for body_node in attack_area.get_overlapping_bodies():
		_hit_body(body_node)

func _on_attack_body_entered(body_node: Node) -> void:
	_hit_body(body_node)

func _hit_body(body_node: Node) -> void:
	if not body_node.is_in_group("enemies") or hit_targets.has(body_node):
		return
	hit_targets.append(body_node)
	if body_node.has_method("take_damage"):
		body_node.take_damage(attack_damage)

func _draw_body() -> void:
	for child in body.get_children():
		child.queue_free()
	var torso := Polygon2D.new()
	torso.polygon = PackedVector2Array([Vector2(-12, -14), Vector2(12, -14), Vector2(15, 10), Vector2(0, 20), Vector2(-15, 10)])
	torso.color = Color("#3f6ed3")
	body.add_child(torso)

	var head := Polygon2D.new()
	head.polygon = PackedVector2Array([Vector2(-9, -25), Vector2(9, -25), Vector2(11, -15), Vector2(0, -8), Vector2(-11, -15)])
	head.color = Color("#f1c27d")
	body.add_child(head)

	var sword := Polygon2D.new()
	sword.name = "Sword"
	sword.polygon = PackedVector2Array([Vector2(10, -6), Vector2(31, -3), Vector2(33, 2), Vector2(10, 5)])
	sword.color = Color("#e9edf4")
	body.add_child(sword)

	var shadow := Polygon2D.new()
	shadow.z_index = -1
	shadow.polygon = PackedVector2Array([Vector2(-17, 17), Vector2(17, 17), Vector2(23, 23), Vector2(-23, 23)])
	shadow.color = Color(0, 0, 0, 0.22)
	body.add_child(shadow)

func _setup_sprite() -> void:
	sprite = AnimatedSprite2D.new()
	var frames := _build_unit_frames(unit_faction, unit_type)
	if frames:
		sprite.sprite_frames = frames
		sprite.animation = "idle"
		sprite.play()
		sprite.scale = Vector2.ONE * _sprite_scale_for_height(sprite_frame_height)
		sprite.position = Vector2(0, -18)
		body.add_child(sprite)
	else:
		_draw_body()

func _build_unit_frames(faction: String, type: String) -> SpriteFrames:
	var base := "res://assets/tiny_swords/Tiny Swords (Free Pack)/Units/%s/%s/" % [faction, type]
	var idle_path := base + _animation_file(type, "idle")
	if not ResourceLoader.exists(idle_path):
		return null
	var idle_texture := load(idle_path) as Texture2D
	if idle_texture != null:
		sprite_frame_height = float(idle_texture.get_height())

	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	_add_animation_frames(frames, "idle", idle_path, _animation_frames(type, "idle"), true)
	_add_optional_animation(frames, "move", base + _animation_file(type, "move"), _animation_frames(type, "move"), true, "idle")
	_add_optional_animation(frames, "attack1", base + _animation_file(type, "attack1"), _animation_frames(type, "attack1"), false, "idle")
	_add_optional_animation(frames, "attack2", base + _animation_file(type, "attack2"), _animation_frames(type, "attack2"), false, "attack1")
	_add_optional_single_frame_animation(frames, "guard", base + _animation_file(type, "guard"), _animation_frames(type, "guard"), "idle")
	return frames

func _animation_file(type: String, animation: String) -> String:
	if type == "Archer":
		if animation == "move":
			return "Archer_Run.png"
		if animation == "attack1" or animation == "attack2":
			return "Archer_Shoot.png"
		return "Archer_Idle.png"
	if type == "Lancer":
		if animation == "move":
			return "Lancer_Run.png"
		if animation == "attack1" or animation == "attack2":
			return "Lancer_Right_Attack.png"
		if animation == "guard":
			return "Lancer_Right_Defence.png"
		return "Lancer_Idle.png"
	if type == "Pawn":
		if animation == "move":
			return "Pawn_Run.png"
		if animation == "attack1" or animation == "attack2":
			return "Pawn_Interact Knife.png"
		return "Pawn_Idle.png"
	if animation == "move":
		return "Warrior_Run.png"
	if animation == "attack1":
		return "Warrior_Attack1.png"
	if animation == "attack2":
		return "Warrior_Attack2.png"
	if animation == "guard":
		return "Warrior_Guard.png"
	return "Warrior_Idle.png"

func _animation_frames(type: String, animation: String) -> int:
	if type == "Lancer":
		if animation == "idle":
			return 12
		if animation == "attack1" or animation == "attack2":
			return 3
		return 6
	if type == "Archer":
		if animation == "move":
			return 4
		if animation == "attack1" or animation == "attack2":
			return 8
		return 6
	if type == "Pawn":
		if animation == "idle" or animation == "guard":
			return 8
		if animation == "attack1" or animation == "attack2":
			return 4
		return 6
	if animation == "idle":
		return 8
	if animation == "move":
		return 6
	if animation == "guard":
		return 6
	return 4

func _sprite_scale_for_height(frame_height: float) -> float:
	return 106.0 / frame_height

func _add_optional_animation(frames: SpriteFrames, animation: StringName, path: String, frame_count: int, loop: bool, fallback: StringName) -> void:
	if ResourceLoader.exists(path):
		_add_animation_frames(frames, animation, path, frame_count, loop)
	else:
		frames.add_animation(animation)
		frames.set_animation_speed(animation, frames.get_animation_speed(fallback))
		frames.set_animation_loop(animation, frames.get_animation_loop(fallback))
		for frame_index in range(frames.get_frame_count(fallback)):
			frames.add_frame(animation, frames.get_frame_texture(fallback, frame_index))

func _add_optional_single_frame_animation(frames: SpriteFrames, animation: StringName, path: String, sheet_frame_count: int, fallback: StringName) -> void:
	frames.add_animation(animation)
	frames.set_animation_speed(animation, 1.0)
	frames.set_animation_loop(animation, false)
	if ResourceLoader.exists(path):
		var texture := load(path) as Texture2D
		if texture != null:
			var frame_size := Vector2(float(texture.get_width()) / float(sheet_frame_count), float(texture.get_height()))
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(Vector2.ZERO, frame_size)
			frames.add_frame(animation, atlas)
			return
	frames.add_frame(animation, frames.get_frame_texture(fallback, 0))

func _add_animation_frames(frames: SpriteFrames, animation: StringName, path: String, frame_count: int, loop: bool) -> void:
	frames.add_animation(animation)
	frames.set_animation_speed(animation, 10.0)
	frames.set_animation_loop(animation, loop)
	var texture := load(path) as Texture2D
	if texture == null:
		return
	var frame_size := Vector2(float(texture.get_width()) / float(frame_count), float(texture.get_height()))
	for index in range(frame_count):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(Vector2(frame_size.x * index, 0), frame_size)
		frames.add_frame(animation, atlas)

func _update_visuals() -> void:
	body.scale.x = -1.0 if facing.x < -0.05 else 1.0
	body.modulate = Color(1.0, 0.55, 0.55) if hurt_flash_time > 0.0 else Color.WHITE
	if state == "attack":
		body.rotation = sin(Time.get_ticks_msec() * 0.04) * 0.12
	else:
		body.rotation = 0.0
	if is_instance_valid(sprite):
		var desired := "guard" if state == "defend" else (current_attack_animation if state == "attack" else ("move" if state == "move" else "idle"))
		if sprite.animation != desired:
			sprite.play(desired)
