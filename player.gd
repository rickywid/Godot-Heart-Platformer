extends CharacterBody2D

@export var movement_data:PlayerMovementData

# default gravity settings defined in Project Settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var air_jump = false
var just_wall_jumped = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position

# Games run in a loop. Each frame, you need to update the state of your game world before drawing it on screen. 
# Between each frame, the _physics_process() will be called at a fixed rate (60fps by default).
#
# The game engine will try to run at the highest FPS (frames per second). 
# The function's delta parameter is the time elapsed in seconds since the previous call to _physics_process().
#
# https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html#doc-idle-and-physics-processing
func _physics_process(delta):

	var input_axis = Input.get_axis("ui_left", "ui_right")
	
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()	
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	updated_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	just_wall_jumped = false
	
	if just_left_ledge:
		coyote_jump_timer.start()
		
	# If spacebar key is pressed, load the FasterMovementData property values (make character
	# move faster)
	if Input.is_action_just_pressed("ui_accept"):
		movement_data = load("res://FasterMovementData.tres")
	
func apply_gravity(delta):
		if not is_on_floor():
			velocity.y += gravity * movement_data.gravity_scale * delta
			
func handle_wall_jump():
	# is_on_wall_only() prevents character from wall jumping while also standing on the ground.
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("ui_up"):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true	


# character should only be able to perform double jump (air jump) once when jumping from the ground 
# in order to prevent user from being able to air jump indefinitely.
func handle_jump():
	if is_on_floor(): air_jump = true
	# Perform jump if character is on floor or if user has jumped within the CoyoteJumpTimer's Wait Time
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		# Perform normal jump (long key press)
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = movement_data.jump_velocity   
	elif not is_on_floor():
		# Perform short jump (quick key press)
		if Input.is_action_just_released("ui_up") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		if Input.is_action_just_pressed("ui_up") and air_jump and not just_wall_jumped:
			# perform double jump (air jump) at 80% jump velocity
			velocity.y = movement_data.jump_velocity * 0.8 
			air_jump = false
	
func apply_friction(input_axis, delta):
	if !input_axis and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_air_resistance(input_axis, delta):
	if !input_axis and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func updated_animations(input_axis):
	if input_axis:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area):
	global_position = starting_position
