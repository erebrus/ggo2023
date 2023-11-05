class_name PlayerCamera extends Node3D

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

@export var time_to_rotate = 1
var initial_quat: Basis
var target_quat: Basis
var target_modified_quat: Basis
var time_since_camera_acquisiton: float = 0
var time_since_rotation_request: float = 0
@export var rotation_amount = 45
var delay_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var cameras = get_tree().get_nodes_in_group("Camera")
	for node in cameras:
		if node is RoomCamera:
			virtual_cameras.push_back(node)
			node.triggered.connect(_on_camera_triggered)

func _on_camera_triggered(room_camera: RoomCamera)->void:
	active_virtual = room_camera
	initial_quat = transform.basis
	target_quat = room_camera.transform.basis
	target_modified_quat = room_camera.transform.basis
	time_since_camera_acquisiton = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not active_virtual:
		return
	
	time_since_camera_acquisiton += delta
	time_since_rotation_request += delta

	# rotate
	if time_since_camera_acquisiton <= time_to_rotate :
		var slerp_quat = initial_quat.slerp(target_quat, min(1, time_since_camera_acquisiton / time_to_rotate))
		transform.basis = Basis(slerp_quat)
	else:
		if active_virtual.allow_y_rotation:
			if Input.is_action_just_pressed("rotate_clockwise") and time_since_rotation_request > time_to_rotate:
				time_since_rotation_request = 0
				initial_quat  = transform.basis
				target_modified_quat = Basis(transform.basis.rotated(Vector3(0,1,0), deg_to_rad(rotation_amount)))
			elif Input.is_action_just_pressed("rotate_countercwise") and time_since_rotation_request > time_to_rotate:
				time_since_rotation_request = 0
				initial_quat  = transform.basis
				target_modified_quat = Basis(transform.basis.rotated(Vector3(0,1,0), deg_to_rad(-rotation_amount)))
			
			var slerp_quat = initial_quat.slerp(target_modified_quat, min(1, time_since_rotation_request / time_to_rotate))
			transform.basis = Basis(slerp_quat)

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
			var offset = (transform.basis.z * Vector3(1,0,1)).normalized() * z_offset
			target_position.x = (player.global_position - (transform.basis.z * Vector3(1,0,1)).normalized() * z_offset).x
			target_position.z = (player.global_position - (transform.basis.z * Vector3(1,0,1)).normalized() * z_offset).z

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
		
