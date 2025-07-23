extends Area2D

@export var speed = 500.0
@export var damage = 10
var direction = Vector2.RIGHT

func _ready():
	# 총알이 화면 밖으로 나가면 자동으로 삭제
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	timer.start()
	
	# 적과의 충돌 감지
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_timeout():
	queue_free()

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _on_body_entered(body):
	# 보스나 적에게 충돌했을 때
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free() # 총알 삭제
