extends CharacterBody2D
class_name Enemy

signal died

@export var speed := 112.0
@export var max_health := 4
@export var damage := 1
@export var detection_range := 300.0
@export var attack_range := 42.0
@export var personal_space := 54.0
@export var attack_windup_time := 0.28
@export var attack_recovery_time := 1.15

var player_path: NodePath
var player: Node2D
var health := max_health
var state := "idle"
var attack_cooldown := 0.0
var attack_windup := 0.0
var attack_has_hit := false
var current_attack_animation := "attack1"
var next_attack_index := 1
var hurt_time := 0.0
var wander_target := Vector2.ZERO
var sprite: AnimatedSprite2D
var sprite_frame_height := 192.0

@onready var body: Node2D = $Body

func _ready() -> void:
	z_as_relative = false
	health = max_health
	wander_target = global_position
	_setup_sprite()
	call_deferred("_resolve_player")

func _physics_process(delta: float) -> void:
	if state == "dead":
		return
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	attack_windup = maxf(0.0, attack_windup - delta)
	hurt_time = maxf(0.0, hurt_time - delta)
	if not is_instance_valid(player):
		_resolve_player()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player := player.global_position - global_position
	var distance := to_player.length()
	if state == "attack" and not attack_has_hit and attack_windup <= 0.0:
		_apply_attack_hit(distance)

	if distance <= attack_range or distance <= personal_space:
		velocity = Vector2.ZERO
		if attack_cooldown <= 0.0 and attack_windup <= 0.0:
			_start_attack()
		elif attack_windup > 0.0:
			state = "attack"
		else:
			state = "idle"
	elif distance <= detection_range:
		state = "chase"
		velocity = to_player.normalized() * speed
	else:
		state = "idle"
		if global_position.distance_to(wander_target) < 12.0:
			wander_target = global_position + Vector2(randf_range(-90, 90), randf_range(-70, 70))
		velocity = (wander_target - global_position).normalized() * speed * 0.35

	move_and_slide()
	z_index = int(global_position.y)
	_update_visuals(to_player)

func take_damage(amount: int) -> void:
	if state == "dead":
		return
	health = maxi(0, health - amount)
	hurt_time = 0.18
	if health == 0:
		state = "dead"
		died.emit()
		queue_free()

func _start_attack() -> void:
	state = "attack"
	attack_cooldown = attack_windup_time + attack_recovery_time
	attack_windup = attack_windup_time
	attack_has_hit = false
	current_attack_animation = "attack%d" % next_attack_index
	next_attack_index = 2 if next_attack_index == 1 else 1
	if is_instance_valid(sprite):
		sprite.play(current_attack_animation)

func _apply_attack_hit(distance: float) -> void:
	attack_has_hit = true
	if distance > attack_range + 8.0:
		return
	if player.has_method("take_damage"):
		player.take_damage(damage)

func _resolve_player() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path)
	if not is_instance_valid(player):
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]

func _draw_body() -> void:
	for child in body.get_children():
		child.queue_free()
	var torso := Polygon2D.new()
	torso.polygon = PackedVector2Array([Vector2(-13, -13), Vector2(13, -13), Vector2(16, 10), Vector2(0, 19), Vector2(-16, 10)])
	torso.color = Color("#b83b42")
	body.add_child(torso)

	var head := Polygon2D.new()
	head.polygon = PackedVector2Array([Vector2(-10, -25), Vector2(10, -25), Vector2(12, -14), Vector2(0, -7), Vector2(-12, -14)])
	head.color = Color("#d28b55")
	body.add_child(head)

	var axe := Polygon2D.new()
	axe.name = "Axe"
	axe.polygon = PackedVector2Array([Vector2(8, -6), Vector2(26, -3), Vector2(25, 4), Vector2(8, 5)])
	axe.color = Color("#d8d3c8")
	body.add_child(axe)

	var shadow := Polygon2D.new()
	shadow.z_index = -1
	shadow.polygon = PackedVector2Array([Vector2(-17, 17), Vector2(17, 17), Vector2(23, 23), Vector2(-23, 23)])
	shadow.color = Color(0, 0, 0, 0.22)
	body.add_child(shadow)

func _setup_sprite() -> void:
	sprite = AnimatedSprite2D.new()
	var frames := _build_warrior_frames("Red Units")
	if frames:
		sprite.sprite_frames = frames
		sprite.animation = "idle"
		sprite.play()
		sprite.scale = Vector2.ONE * _sprite_scale_for_height(sprite_frame_height)
		sprite.position = Vector2(0, -18)
		body.add_child(sprite)
	else:
		_draw_body()

func _build_warrior_frames(faction: String) -> SpriteFrames:
	var base := "res://assets/tiny_swords/Tiny Swords (Free Pack)/Units/%s/Warrior/" % faction
	var idle_path := base + "Warrior_Idle.png"
	if not ResourceLoader.exists(idle_path):
		return null
	var idle_texture := load(idle_path) as Texture2D
	if idle_texture != null:
		sprite_frame_height = float(idle_texture.get_height())

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

func _sprite_scale_for_height(frame_height: float) -> float:
	return 106.0 / frame_height

func _update_visuals(to_player: Vector2) -> void:
	if abs(to_player.x) > 4.0:
		body.scale.x = -1.0 if to_player.x < 0.0 else 1.0
	body.modulate = Color(1.0, 0.45, 0.45) if hurt_time > 0.0 else Color.WHITE
	body.rotation = sin(Time.get_ticks_msec() * 0.018 + global_position.x) * 0.04 if state == "chase" else 0.0
	if is_instance_valid(sprite):
		var desired := current_attack_animation if state == "attack" else ("move" if state == "chase" else "idle")
		if sprite.animation != desired:
			sprite.play(desired)
