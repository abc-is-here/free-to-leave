extends CharacterBody2D

@export var speed := 200.0
@export var gravity := 700.0
@export var jump_force := -400.0
@export var flying_speed_multiplier := 1.3
@export var acceleration := 800.0
@export var friction := 600.0
@export var max_fall_speed := 900.0

@onready var BirdAnimator: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var is_flying := false
var takeoff_played := false
var is_pecking := false
var is_squeaking := false

var flight_multiplier := 0.2

func _physics_process(delta):
	var is_right_pressed = Input.is_action_pressed("right")
	var is_left_pressed = Input.is_action_pressed("left")
	var space_held := Input.is_action_pressed("space")
	var is_peck_pressed := Input.is_action_just_pressed("peck")
	var is_squeak_pressed := Input.is_action_just_pressed("squeak")
	
	var direction := 0
	if is_left_pressed:
		direction = -1
	elif is_right_pressed:
		direction = 1

	var target_speed = 0.0
	if is_flying:
		target_speed = direction * speed * flying_speed_multiplier
	else:
		target_speed = direction * speed

	if direction != 0 and not (is_pecking or is_squeaking):
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	if space_held:
		if is_on_floor() and direction != 0 and not (takeoff_played or is_squeaking or is_pecking):
			velocity.y = jump_force
			BirdAnimator.play("BirdTakeOff")
			is_flying = true
			takeoff_played = true
		elif not is_on_floor():
			velocity.y = jump_force * flight_multiplier
			is_flying = true
	else:
		is_flying = false

	if not is_on_floor():
		if is_flying and direction == 0 and space_held:
			flight_multiplier = 0
		else:
			velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
			flight_multiplier = 0.2
	else:
		if not space_held:
			velocity.y = 0
		takeoff_played = false

	move_and_slide()

	if direction != 0:
		sprite.flip_h = direction < 0

	if is_on_floor() and not is_flying:
		if is_peck_pressed and not is_pecking:
			BirdAnimator.play("BirdPeck")
			is_pecking = true
		elif is_squeak_pressed and not is_squeaking:
			BirdAnimator.play("BirdSqueak")
			is_squeaking = true

	if is_pecking and not BirdAnimator.is_playing():
		is_pecking = false
	if is_squeaking and not BirdAnimator.is_playing():
		is_squeaking = false

	if not is_on_floor():
		if is_flying and not takeoff_played:
			BirdAnimator.play("BirdFlying")
		elif velocity.y > 0:
			BirdAnimator.play("BirdLanding")
	elif not is_pecking and not is_squeaking:
		if direction == 0:
			if Input.is_action_just_pressed("space"):
				BirdAnimator.play("BirdIdleHop")
			elif not BirdAnimator.is_playing():
				BirdAnimator.play("BirdIdle")
		else:
			BirdAnimator.play("BirdHop")
