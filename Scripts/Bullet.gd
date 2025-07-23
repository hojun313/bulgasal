extends Area2D

@export var speed = 500.0
var direction = Vector2.RIGHT

func _ready():
	# 총알이 화면 밖으로 나가면 자동으로 삭제
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	timer.start()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timeout():
	queue_free()

func set_direction(dir: Vector2):
	direction = dir.normalized()
