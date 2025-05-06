extends CharacterBody2D

@export var gravity := 900.0
@export var max_fall_speed := 900.0

@onready var animator: AnimationPlayer = $AnimationPlayer

func _physics_process(delta):
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
	else:
		velocity.y = 0

	move_and_slide()

	if is_on_floor():
		animator.play("CatStandIdle")
	else:
		if animator.current_animation != "CatLand":
			animator.play("CatLand")
