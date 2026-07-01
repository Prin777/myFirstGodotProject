extends CharacterBody2D
class_name Player

signal health_changed(current: int, maximum: int)
signal died

@export var speed := 185.0
@export var max_health := 6
@export var attack_damage := 2

var health := max_health
var facing := Vector2.RIGHT
var state := "idle"
var attack_time := 0.0
var attack_cooldown := 0.0
var current_attack_animation := "attack1"
var next_attack_index := 1
var invulnerable_time := 0.0
var hit_targets: Array[Node] = []
var sprite: AnimatedSprite2D

@onready var body: Node2D = $Body
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)
	attack_area.body_entered.connect(_on_attack_body_entered)
	_setup_sprite()

func _physics_process(delta: float) -> void:
	if state == "dead":
		return

	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	invulnerable_time = maxf(0.0, invulnerable_time - delta)

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length() > 0.0:
		facing = input_vector.normalized()

	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		_start_attack()

	if attack_time > 0.0:
		attack_time -= delta
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 7.0)
		if attack_time <= 0.0:
			attack_area.monitoring = false
			attack_area.visible = false
			state = "idle"
	else:
		velocity = input_vector * speed
		state = "move" if input_vector.length() > 0.0 else "idle"

	move_and_slide()
	_update_visuals()

func take_damage(amount: int) -> void:
	if state == "dead" or invulnerable_time > 0.0:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	invulnerable_time = 0.65
	if health == 0:
		state = "dead"
		velocity = Vector2.ZERO
		attack_area.monitoring = false
		attack_area.visible = false
		died.emit()

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
	var frames := _build_warrior_frames("Blue Units")
	if frames:
		sprite.sprite_frames = frames
		sprite.animation = "idle"
		sprite.play()
		sprite.scale = Vector2(0.55, 0.55)
		sprite.position = Vector2(0, -16)
		body.add_child(sprite)
	else:
		_draw_body()

func _build_warrior_frames(faction: String) -> SpriteFrames:
	var base := "res://assets/tiny_swords/Tiny Swords (Free Pack)/Units/%s/Warrior/" % faction
	var idle_path := base + "Warrior_Idle.png"
	if not ResourceLoader.exists(idle_path):
		return null

	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	_add_animation_frames(frames, "idle", idle_path, 8, true)
	_add_animation_frames(frames, "move", base + "Warrior_Run.png", 6, true)
	_add_animation_frames(frames, "attack1", base + "Warrior_Attack1.png", 4, false)
	_add_animation_frames(frames, "attack2", base + "Warrior_Attack2.png", 4, false)
	_add_animation_frames(frames, "guard", base + "Warrior_Guard.png", 4, false)
	return frames

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
	body.modulate = Color(1.0, 0.55, 0.55) if invulnerable_time > 0.0 else Color.WHITE
	if state == "attack":
		body.rotation = sin(Time.get_ticks_msec() * 0.04) * 0.12
	else:
		body.rotation = 0.0
	if is_instance_valid(sprite):
		var desired := current_attack_animation if state == "attack" else ("move" if state == "move" else "idle")
		if sprite.animation != desired:
			sprite.play(desired)
