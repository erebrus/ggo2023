extends Node3D

@export var watch_object:Node3D

@export var SPEED:float = 25.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(name)
	set_position(watch_object.get_position())
	var look_dir = Input.get_axis("ui_page_up", "ui_page_down")
	rotation_degrees.y += look_dir * SPEED * delta
