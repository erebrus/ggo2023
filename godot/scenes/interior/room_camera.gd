@tool
class_name RoomCamera extends Node3D

signal triggered(camera: RoomCamera)

@onready var camera3D: Camera3D = $Camera3D

var initial_position = Vector3.ZERO
var player: Node3D

@export var current: bool:
	set(value):
		current = value
		if camera3D:
			camera3D.current = current

@export var environment: Environment:
	set(value):
		environment = value
		if camera3D:
			camera3D.environment = environment

@export var lock_y: bool = true
@export var lock_x: bool = false
@export var lock_z: bool = false
@export var follow_player: bool = false
@export var z_offset: float = 0

@export var allow_y_rotation: bool = false


func _on_room_entered(body: Node3D):
	triggered.emit(self)
	player = body

func _on_room_exited():
	global_position = initial_position

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	

