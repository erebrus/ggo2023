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

@export var rotation_speed: float = 1
var current_rotation_speed: float = 0

@export var time_to_rotate: float = .5
var initial_quat: Basis # quaternion before transition to target/target_modified
var target_quat: Basis # virtual camera's quaternion
var initial_pos: Vector3
var target_pos: Vector3
var target_distance: float
var target_modified_quat: Basis # virtual camera's quaternion plus any applied rotation requests
var time_since_camera_acquisiton: float = 0
var swap_time: float = 0

var delay_timer = 0
var use_player_cameras = false

var lock_to_camera: bool = false
var lock_speed: float = 50
var lock_acceleration: float = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	var rooms = get_tree().get_nodes_in_group("Room")
	for room in rooms:
		room.room_entered.connect(_on_room_entered)

func _on_room_entered(room: WorldRoom)->void:
	var next_virtual: RoomCamera = null
	var next_swap_time: float = .5
	if room.room_camera:
		next_virtual = room.room_camera
		# should have environment.. if set up properly :)
		camera.environment = next_virtual.environment
		next_swap_time = next_virtual.swap_time
		use_player_cameras = false
	elif player and !use_player_cameras:
		use_player_cameras = true
		# default to bird's eye (topdown) camera if transitioning out of room to outside
		next_virtual = player.virtual_bird_camera
		# no camera in room - check for environment override
		if room.room_environment_override:
			camera.environment = room.room_environment_override

	swap_camera(next_virtual, next_swap_time)

func swap_camera(next_virtual: RoomCamera, in_swap_time: float)->void:
	if not active_virtual:
		transform.basis = next_virtual.global_transform.basis
		global_position = next_virtual.global_position
	active_virtual = next_virtual
	initial_pos = global_position
	target_pos = active_virtual.global_position
	initial_quat = transform.basis
	target_quat = active_virtual.global_transform.basis
	swap_time = in_swap_time
	target_distance = global_position.distance_to(target_pos)
	target_modified_quat = active_virtual.global_transform.basis
	time_since_camera_acquisiton = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not active_virtual:
		return
	
	time_since_camera_acquisiton += delta
	delay_timer += delta
	

	if time_since_camera_acquisiton < swap_time:
		global_position = initial_pos.lerp(target_pos, time_since_camera_acquisiton/swap_time)
		var slerp_quat = initial_quat.slerp(target_quat, time_since_camera_acquisiton/swap_time)
		transform.basis = Basis(slerp_quat)
		return


	if active_virtual.allow_y_rotation and time_since_camera_acquisiton > 1:
		# camera rotates around y axis by 45 degrees if requested by the user
		if use_player_cameras and Input.is_action_just_pressed("zoom_in"):
			swap_camera(player.virtual_close_camera, .5)
			# environmental nodes can connect to this to determine if they show
			zoomed_in.emit()
			return
		elif use_player_cameras and Input.is_action_just_pressed("zoom_out"):
			swap_camera(player.virtual_bird_camera, .5)
			# environmental nodes can connect to this to determine if they show
			zoomed_out.emit()
			return

	# This code only really makes sense if the camera for player following
	delay_timer += delta
	if delay_timer < move_delay:
		return

	var follow_player = active_virtual.follow_player
	var follow_camera = active_virtual.follow_camera
	var lock_x = active_virtual.lock_x
	var lock_y = active_virtual.lock_y
	var lock_z = active_virtual.lock_z
	#var z_offset= active_virtual.z_offset*-1

	var target_modified_pos = active_virtual.global_position
	if follow_player and player:
		if not lock_x:
			target_modified_pos.x = player.global_position.x
		if not lock_y:
			target_modified_pos.y = player.global_position.y


	var direction = global_position.direction_to(target_modified_pos)
	if global_position.distance_to(target_modified_pos) > 10.0:
		# we've lost the camera lock, go faster than typical follow speed so camera isnt too far off center from target
		current_speed = min(current_speed + lock_acceleration*delta, lock_speed)
	elif global_position.distance_to(target_modified_pos) > 2.0:
		if current_speed > max_speed:
			current_speed = max(current_speed - deceleration*delta, min_speed)
		else:
			current_speed = min(current_speed + acceleration*delta, max_speed)
	elif global_position.distance_to(target_modified_pos) > .1:
		current_speed = max(current_speed - deceleration*delta, min_speed)
	else:
		delay_timer = 0

	global_position = global_position.lerp(target_modified_pos, current_speed*delta)

	# rotate to camera quat
	var angle_to_target = abs(initial_quat.get_rotation_quaternion().angle_to(active_virtual.global_transform.basis.get_rotation_quaternion()))

	current_rotation_speed = min(rotation_speed, current_rotation_speed + 10*delta)
	var slerp_quat = transform.basis.slerp(active_virtual.global_transform.basis, min(1, current_rotation_speed*delta / angle_to_target))
	transform.basis = Basis(slerp_quat)
		
