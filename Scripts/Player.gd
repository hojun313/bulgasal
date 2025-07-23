extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 체력 시스템
@export var max_health = 100
var current_health = 100

# 총알 관련 변수들
@export var bullet_scene: PackedScene
var bullet_speed = 500.0
var z_key_pressed_last_frame = false

@onready var sprite_2d = $Sprite2D

@export var idle_texture: Texture2D
@export var walk_texture_a: Texture2D
@export var walk_texture_b: Texture2D
@export var jump_texture: Texture2D

func _ready():
	# 플레이어를 "player" 그룹에 추가
	add_to_group("player")
	current_health = max_health
	
	# UI 직접 생성 (테스트)
	create_debug_ui()
	
	# Load textures if not set in editor (for testing purposes)
	if idle_texture == null: idle_texture = load("res://Sprites/Character/character_purple_idle.png")
	if walk_texture_a == null: walk_texture_a = load("res://Sprites/Character/character_purple_walk_a.png")
	if walk_texture_b == null: walk_texture_b = load("res://Sprites/Character/character_purple_walk_b.png")
	if jump_texture == null: jump_texture = load("res://Sprites/Character/character_purple_jump.png")
	
	# 총알 씬 로드
	if bullet_scene == null: bullet_scene = preload("res://Scenes/Bullet.tscn")

func _physics_process(delta):
	# UI 업데이트
	update_debug_ui()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Attack (공격키)
	var z_key_pressed = Input.is_physical_key_pressed(KEY_Z)
	if z_key_pressed and not z_key_pressed_last_frame:  # Z key just pressed
		shoot()
	z_key_pressed_last_frame = z_key_pressed

	# Get the input direction and handle the movement.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0 # Flip sprite based on direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Update sprite texture based on state
	if not is_on_floor():
		sprite_2d.texture = jump_texture
	elif direction != 0:
		# Simple walk animation (alternating between walk_a and walk_b)
		if int(Engine.get_frames_drawn() / 10) % 2 == 0:
			sprite_2d.texture = walk_texture_a
		else:
			sprite_2d.texture = walk_texture_b
	else:
		sprite_2d.texture = idle_texture

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		
		# 총알 시작 위치 설정 (플레이어 앞쪽)
		bullet.position = global_position + Vector2(30 * (1 if not sprite_2d.flip_h else -1), 0)
		
		# 총알 방향 설정 (플레이어가 보고 있는 방향)
		var bullet_direction = Vector2(1 if not sprite_2d.flip_h else -1, 0)
		bullet.set_direction(bullet_direction)

func take_damage(damage_amount: int):
	current_health -= damage_amount
	print("Player took ", damage_amount, " damage! Current health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	print("Player has died!")
	# 게임 오버 처리나 리스폰 로직

func get_health_info():
	return {"current": current_health, "max": max_health}

var debug_label: Label
var player_health_bar: ProgressBar
var boss_health_bar: ProgressBar

func create_debug_ui():
	print("Creating debug UI...")
	
	# CanvasLayer 생성
	var canvas_layer = CanvasLayer.new()
	get_tree().root.add_child(canvas_layer)
	
	# 배경 패널 생성
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.size = Vector2(400, 120)
	bg.position = Vector2(30, 30)
	canvas_layer.add_child(bg)
	
	# 플레이어 체력 라벨
	var player_label = Label.new()
	player_label.text = "PLAYER"
	player_label.position = Vector2(50, 40)
	player_label.add_theme_font_size_override("font_size", 18)
	player_label.add_theme_color_override("font_color", Color.WHITE)
	canvas_layer.add_child(player_label)
	
	# 플레이어 체력바
	player_health_bar = ProgressBar.new()
	player_health_bar.position = Vector2(50, 65)
	player_health_bar.size = Vector2(300, 20)
	player_health_bar.min_value = 0
	player_health_bar.max_value = 100
	player_health_bar.value = 100
	player_health_bar.show_percentage = false
	canvas_layer.add_child(player_health_bar)
	
	# 보스 체력 라벨
	var boss_label = Label.new()
	boss_label.text = "BOSS"
	boss_label.position = Vector2(50, 95)
	boss_label.add_theme_font_size_override("font_size", 18)
	boss_label.add_theme_color_override("font_color", Color.RED)
	canvas_layer.add_child(boss_label)
	
	# 보스 체력바
	boss_health_bar = ProgressBar.new()
	boss_health_bar.position = Vector2(50, 120)
	boss_health_bar.size = Vector2(300, 20)
	boss_health_bar.min_value = 0
	boss_health_bar.max_value = 100
	boss_health_bar.value = 100
	boss_health_bar.show_percentage = false
	canvas_layer.add_child(boss_health_bar)
	
	# 체력 텍스트 라벨 (수치 표시용)
	debug_label = Label.new()
	debug_label.text = "100/100"
	debug_label.position = Vector2(360, 65)
	debug_label.add_theme_font_size_override("font_size", 14)
	debug_label.add_theme_color_override("font_color", Color.WHITE)
	canvas_layer.add_child(debug_label)
	
	print("Debug UI created!")

func update_debug_ui():
	if player_health_bar and boss_health_bar and debug_label:
		# 플레이어 체력바 업데이트
		var player_percentage = (float(current_health) / float(max_health)) * 100
		player_health_bar.value = player_percentage
		
		# 보스 체력바 업데이트
		var bosses = get_tree().get_nodes_in_group("boss")
		if bosses.size() > 0:
			var boss = bosses[0]
			var boss_percentage = (float(boss.current_health) / float(boss.max_health)) * 100
			boss_health_bar.value = boss_percentage
			boss_health_bar.visible = true
			
			# 체력 수치 텍스트 업데이트
			debug_label.text = str(current_health) + "/" + str(max_health) + "\n" + str(boss.current_health) + "/" + str(boss.max_health)
			debug_label.position = Vector2(360, 65)
		else:
			boss_health_bar.visible = false
			debug_label.text = str(current_health) + "/" + str(max_health) + "\nNo Boss"
