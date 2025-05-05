extends CharacterBody2D

@export var speed := 200.0
@export var gravity := 700.0
@export var jump_force := -400.0

@onready var BirdAnimator: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var is_flying := false
var takeoff_played := false

func _physics_process(delta):
	var direction = 0

	if Input.is_action_pressed("left"):
		direction = -1
	elif Input.is_action_pressed("right"):
		direction = 1

	velocity.x = direction * speed

	# --- Flying logic ---
	var space_held = Input.is_action_pressed("space")
	var space_just_pressed = Input.is_action_just_pressed("space")

	if space_just_pressed and is_on_floor():
		velocity.y = jump_force
		BirdAnimator.play("BirdTakeOff")
		is_flying = true
		takeoff_played = true
	elif space_held and not is_on_floor():
		velocity.y = jump_force * 0.5  # Hold to glide or flap slowly upward
		is_flying = true
	elif not space_held:
		is_flying = false

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		takeoff_played = false

	move_and_slide()

	# Sprite flip
	if direction != 0:
		sprite.flip_h = direction < 0

	# --- Animation logic ---
	if not is_on_floor():
		if is_flying and not takeoff_played:
			BirdAnimator.play("BirdFlying")
		elif velocity.y > 0:
			BirdAnimator.play("BirdLanding")
	elif is_on_floor():
		if direction == 0:
			if space_held:
				BirdAnimator.play("BirdIdleHop")  # prepping for flight
			else:
				BirdAnimator.play("BirdIdle")
		else:
			BirdAnimator.play("BirdHop")
