extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite_2d = $Sprite2D

@export var idle_texture: Texture2D
@export var walk_texture_a: Texture2D
@export var walk_texture_b: Texture2D
@export var jump_texture: Texture2D

func _ready():
	# Load textures if not set in editor (for testing purposes)
	if idle_texture == null: idle_texture = load("res://Sprites/Character/character_purple_idle.png")
	if walk_texture_a == null: walk_texture_a = load("res://Sprites/Character/character_purple_walk_a.png")
	if walk_texture_b == null: walk_texture_b = load("res://Sprites/Character/character_purple_walk_b.png")
	if jump_texture == null: jump_texture = load("res://Sprites/Character/character_purple_jump.png")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
