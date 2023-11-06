class_name PlayerCamera extends Node3D

signal zoomed_in()
signal zoomed_out()

var virtual_cameras: Array[RoomCamera] = []

@export var current: bool = true:
	set(value):
		current = value
		camera.current = value

@export var player: CharacterBody3D

@onready var camera: Camera3D = $Camera3D
@onready var active_virtual: RoomCamera

var current_velocity = Vector3.ZERO
var current_speed = 0
@export var acceleration = 5
@export var deceleration = 20
@export var max_speed = 8
@export var min_speed = 1
@export var move_delay = .2

@export var time_to_rotate: float = .5
var initial_quat: Basis # quaternion before transition to target/target_modified
var target_quat: Basis # virtual camera's quaternion
var target_modified_quat: Basis # virtual camera's quaternion plus any applied rotation requests
var time_since_camera_acquisiton: float = 0
var time_since_rotation_request: float = 0
@export var rotation_amount = 45
var delay_timer = 0
var use_player_cameras = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var rooms = get_tree().get_nodes_in_group("Room")
	for room in rooms:
		room.room_entered.connect(_on_room_entered)

func _on_room_entered(room: WorldRoom)->void:
	var next_virtual: RoomCamera = null
	if room.room_camera:
		next_virtual = room.room_camera
		# should have environment.. if set up properly :)
		camera.environment = next_virtual.environment
		use_player_cameras = false
	elif player and !use_player_cameras:
		use_player_cameras = true
		# default to bird's eye (topdown) camera if transitioning out of room to outside
		next_virtual = player.virtual_bird_camera
		# no camera in room - check for environment override
		if room.room_environment_override:
			camera.environment = room.room_environment_override

	swap_camera(next_virtual)
		

func swap_camera(next_virtual: RoomCamera)->void:
	if next_virtual != active_virtual:
		active_virtual = next_virtual
		initial_quat = transform.basis
		target_quat = active_virtual.transform.basis
		target_modified_quat = active_virtual.transform.basis
		time_since_camera_acquisiton = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not active_virtual:
		return
	
	time_since_camera_acquisiton += delta
	time_since_rotation_request += delta
	delay_timer += delta

	if time_since_camera_acquisiton <= time_to_rotate :
		# rotate to initial camera view
		var slerp_quat = initial_quat.slerp(target_quat, min(1, time_since_camera_acquisiton / time_to_rotate))
		transform.basis = Basis(slerp_quat)
	else:
		if active_virtual.allow_y_rotation:
			# camera rotates around y axis by 45 degrees if requested by the user
			if use_player_cameras and Input.is_action_just_pressed("zoom_in"):
				swap_camera(player.virtual_close_camera)
				# environmental nodes can connect to this to determine if they show
				zoomed_in.emit()
			elif use_player_cameras and Input.is_action_just_pressed("zoom_out"):
				swap_camera(player.virtual_bird_camera)
				# environmental nodes can connect to this to determine if they show
				zoomed_out.emit()
			elif Input.is_action_just_pressed("rotate_clockwise") and time_since_rotation_request > time_to_rotate:
				time_since_rotation_request = 0
				initial_quat  = transform.basis
				target_modified_quat = Basis(transform.basis.rotated(Vector3(0,1,0), deg_to_rad(rotation_amount)))
			elif Input.is_action_just_pressed("rotate_countercwise") and time_since_rotation_request > time_to_rotate:
				time_since_rotation_request = 0
				initial_quat  = transform.basis
				target_modified_quat = Basis(transform.basis.rotated(Vector3(0,1,0), deg_to_rad(-rotation_amount)))
			
			var slerp_quat = initial_quat.slerp(target_modified_quat, min(1, time_since_rotation_request / time_to_rotate))
			transform.basis = Basis(slerp_quat)

	# This code only really makes sense if the camera for player following
	delay_timer += delta
	if delay_timer < move_delay:
		return

	var follow_player = active_virtual.follow_player
	var lock_x = active_virtual.lock_x
	var lock_y = active_virtual.lock_y
	var lock_z = active_virtual.lock_z
	var z_offset= active_virtual.z_offset

	var target_position = active_virtual.global_position
	if follow_player and player:
		if not lock_x:
			target_position.x = player.global_position.x
		if not lock_y:
			target_position.y = player.global_position.y
		if not lock_z:
			var offset = (player.global_position - (transform.basis.z * Vector3(1,0,1)).normalized() * z_offset)
			target_position.x = offset.x
			target_position.z = offset.z

	var direction = global_position.direction_to(target_position)
	# if global_position.distance_squared_to(target_position) > .5:
	# 	current_speed = min(current_speed + acceleration*delta, max_speed)
	# 	global_position += direction * current_speed * delta
	# else:
	# 	delay_timer = 0
	if global_position.distance_squared_to(target_position) > 2:
		current_speed = min(current_speed + acceleration*delta, max_speed)
		global_position += direction * current_speed * delta
	elif global_position.distance_squared_to(target_position) > .5:
		current_speed = max(current_speed - deceleration*delta, min_speed)
		global_position += direction * current_speed * delta
	else:
		delay_timer = 0
		
