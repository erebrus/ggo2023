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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not active_virtual:
		return
	
	delay_timer += delta
	if delay_timer < move_delay:
		return

	var follow_player = active_virtual.follow_player
	var lock_x = active_virtual.lock_x
	var lock_y = active_virtual.lock_y
	var lock_z = active_virtual.lock_z

	var target_position = active_virtual.global_position
	if follow_player and player:
		if not lock_x:
			target_position.x = player.global_position.x
		if not lock_y:
			target_position.y = player.global_position.y
		if not lock_z:
			target_position.z = player.global_position.z

	var direction = global_position.direction_to(target_position)
	if global_position.distance_squared_to(target_position) > 2:
		current_speed = min(current_speed + acceleration*delta, max_speed)
		global_position += direction * current_speed * delta
	elif global_position.distance_squared_to(target_position) > .5:
		print("SLOWING DOWN")
		current_speed = max(current_speed - deceleration*delta, min_speed)
		global_position += direction * current_speed * delta
	else:
		delay_timer = 0
		
