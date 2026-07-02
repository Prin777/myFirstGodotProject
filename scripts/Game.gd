extends Node2D

const PlayerScene: PackedScene = preload("res://scenes/Player.tscn")
const EnemyScene: PackedScene = preload("res://scenes/Enemy.tscn")
const MapScene: PackedScene = preload("res://scenes/Map.tscn")
const UIScene: PackedScene = preload("res://scenes/GameUI.tscn")

var player: Player
var ui: GameUI
var map: AdventureMap
var enemies_alive := 0
var is_running := false
var selected_character: Dictionary = {}

func _ready() -> void:
	randomize()
	map = MapScene.instantiate() as AdventureMap
	add_child(map)

	ui = UIScene.instantiate() as GameUI
	add_child(ui)
	ui.start_requested.connect(_start_game)
	ui.restart_requested.connect(_restart_game)
	ui.show_start()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not is_running:
		_restart_game()

func _start_game(character_config: Dictionary = {}) -> void:
	_clear_run()
	if not character_config.is_empty():
		selected_character = character_config.duplicate()
	elif selected_character.is_empty():
		selected_character = ui.get_selected_character()
	is_running = true
	ui.show_hud()

	player = PlayerScene.instantiate() as Player
	player.set_character(selected_character)
	player.global_position = Vector2(180, 370)
	player.health_changed.connect(ui.set_health)
	player.died.connect(_on_player_died)
	add_child(player)
	ui.set_health(player.health, player.max_health)

	var spawn_points := [
		Vector2(650, 210),
		Vector2(850, 360),
		Vector2(650, 530),
		Vector2(1030, 270),
		Vector2(1060, 500),
	]
	for point in spawn_points:
		var enemy := EnemyScene.instantiate() as Enemy
		enemy.global_position = point
		enemy.player_path = player.get_path()
		enemy.died.connect(_on_enemy_died)
		add_child(enemy)
		enemies_alive += 1
	ui.set_enemies(enemies_alive)

func _restart_game() -> void:
	_start_game()

func _on_enemy_died() -> void:
	enemies_alive = maxi(0, enemies_alive - 1)
	ui.set_enemies(enemies_alive)
	if enemies_alive == 0 and is_running:
		is_running = false
		ui.show_result("VICTORY", "The last raider has fallen.")

func _on_player_died() -> void:
	if not is_running:
		return
	is_running = false
	ui.show_result("DEFEAT", "Your banner drops in the grass.")

func _clear_run() -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		node.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	enemies_alive = 0
	ui.set_enemies(enemies_alive)
