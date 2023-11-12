extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cameraTransform:Camera3D = get_viewport().get_camera_3d()
	rotation_degrees.x = 0
	rotation_degrees.y = cameraTransform.global_rotation_degrees.y
	rotation_degrees.z = 0
