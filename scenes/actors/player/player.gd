extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 3.5

var velocity_ = 0.0

@onready var NECK = $Neck
@onready var CAMERA = $Neck/Camera3D

enum {
	MOVE,
	INTERACT,
}
var STATE = MOVE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	switchState(MOVE)

func switchState(to):
	STATE = to
	match STATE:
		MOVE:
			CAMERA.current = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		INTERACT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event):
	if event:
		if Input.is_action_just_pressed("ui_cancel"):
			toggleMouseMode()

### Change Mouse Mode
func toggleMouseMode():
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

### Capture mouse motions
func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			NECK.rotate_y(-event.relative.x * 0.005)
			$Body.rotate_y(-event.relative.x * 0.005)
			CAMERA.rotate_x(-event.relative.y * 0.005)
			CAMERA.rotation.x = clamp(CAMERA.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta):
	match STATE:
		MOVE:
			moveHandler(delta)
		
		INTERACT:
			interactionHandler()

# Contains interaction script
func interactionHandler():
	pass

# Contains movement / input script
func moveHandler(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("key_a", "key_d", "key_w", "key_s")
	var direction = (NECK.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		# Check if player wants to sprint
		if (Input.is_action_pressed("key_shift")):
			if (velocity_ < 8):
				velocity_ = lerp(velocity_, 8.0, .125)
		
		else:
			# Reduce velocity to normal walk speed
			if (velocity_ < 5):
				velocity_ = lerp(velocity_, SPEED, .125)
			else:
				if (velocity_ > 5):
					velocity_ = lerp(velocity_, SPEED, .125)
		
		velocity.x = (direction.x * velocity_)
		velocity.z = (direction.z * velocity_)
	else:
		if (velocity_ > 0):
			velocity_ = lerp(velocity_, 0.0, .25)
		velocity.x = move_toward(velocity.x, 0, velocity_)
		velocity.z = move_toward(velocity.z, 0, velocity_)

	move_and_slide()

