extends CharacterBody2D

const MIN_JUMP_VERTICAL_VELOCITY = -1100.0 # 점프 시 최소 수직 속도
const MAX_JUMP_VERTICAL_VELOCITY = -500.0 # 점프 시 최대 수직 속도
const JUMP_HORIZONTAL_VELOCITY = 400.0 # 점프 시 수평 속도

var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var jump_timer = Timer.new()

func _ready():
	randomize() # Initialize random number generator

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("SlimeKing: Player not found in group 'player'. Make sure your player node is in this group.")

	add_child(jump_timer)
	jump_timer.wait_time = 3.0
	jump_timer.autostart = true
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	jump_timer.start() # Explicitly start the timer
	print("SlimeKing: Timer setup complete.")

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

	var collided_with_side_wall = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		# Check if the collision normal is primarily horizontal
		if abs(collision.get_normal().x) > 0.1: 
			collided_with_side_wall = true
			break

	if collided_with_side_wall:
		velocity.x *= -1 # Reverse horizontal velocity
		print("SlimeKing: Hit side wall, reversing velocity.x.")

	# If on floor and not currently jumping and no side wall collision occurred in this frame
	if is_on_floor() and abs(velocity.y) < 10 and not collided_with_side_wall:
		velocity.x = 0.0
		print("SlimeKing: On floor, not jumping, no wall hit, resetting velocity.x to 0.")

func _on_jump_timer_timeout():
	print("SlimeKing: Jump timer timed out!")
	if is_on_floor() and player:
		print("SlimeKing: Initiating jump!")
		var direction_to_player_x = sign(player.global_position.x - global_position.x)
		print("SlimeKing: Direction to player X:", direction_to_player_x) # New debug print

		velocity.x = direction_to_player_x * JUMP_HORIZONTAL_VELOCITY
		
		# Set random vertical jump velocity
		velocity.y = randf_range(MIN_JUMP_VERTICAL_VELOCITY, MAX_JUMP_VERTICAL_VELOCITY)
		
		print("SlimeKing: Setting velocity to X:", velocity.x, " Y:", velocity.y) # New debug print
	else:
		print("SlimeKing: Cannot jump (not on floor or player not found). is_on_floor(): ", is_on_floor(), ", player: ", player)