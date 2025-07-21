extends CharacterBody2D

const JUMP_VERTICAL_VELOCITY = -800.0 # 점프 시 수직 속도 (위로 향함)
const JUMP_HORIZONTAL_VELOCITY = 400.0 # 점프 시 수평 속도

var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var jump_timer = Timer.new()

func _ready():
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
	
	# Reset horizontal velocity only if not currently jumping and on floor
	# This ensures horizontal velocity from jump is not immediately reset
	if is_on_floor() and velocity.y == 0: # Only reset if not moving vertically (i.e., not jumping)
		velocity.x = 0.0 

	move_and_slide()

func _on_jump_timer_timeout():
	print("SlimeKing: Jump timer timed out!")
	if is_on_floor() and player:
		print("SlimeKing: Initiating jump!")
		var direction_to_player_x = sign(player.global_position.x - global_position.x)
		print("SlimeKing: Direction to player X:", direction_to_player_x) # New debug print

		velocity.x = direction_to_player_x * JUMP_HORIZONTAL_VELOCITY
		velocity.y = JUMP_VERTICAL_VELOCITY
		print("SlimeKing: Setting velocity to X:", velocity.x, " Y:", velocity.y) # New debug print
	else:
		print("SlimeKing: Cannot jump (not on floor or player not found). is_on_floor(): ", is_on_floor(), ", player: ", player)
