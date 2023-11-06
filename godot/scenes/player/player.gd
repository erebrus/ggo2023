class_name PlayerController extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5

@onready var sprite: Sprite3D = $Sprite3D

var camera: Camera3D
@onready var virtual_bird_camera = $BirdCamera
@onready var virtual_close_camera = $CloseCamera

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_billboard(enabled: bool)->void:
	if sprite.material_override:
		if sprite.material_override is StandardMaterial3D:
			sprite.material_override.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED if enabled else BaseMaterial3D.BILLBOARD_DISABLED
	else:
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED if enabled else BaseMaterial3D.BILLBOARD_DISABLED

func _ready():
	var rooms = get_tree().get_nodes_in_group("Room")
	for room in rooms:
		room.room_entered.connect(_on_room_entered)
	
	# set virtual camera z-offsets, since these are always determined by the player scene
	virtual_bird_camera.z_offset = virtual_bird_camera.position.z
	virtual_close_camera.z_offset = virtual_close_camera.position.z

func _process(_delta):
	pass

func _physics_process(delta):

	camera = get_tree().root.get_camera_3d()

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3.ZERO
	if camera:
		direction = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		direction.y = 0
		direction = direction.normalized()
	else:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		sprite.flip_h = true if input_dir.x > 0 else false
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_room_entered(room: WorldRoom)->void:
	set_billboard(room.use_player_billboard)

