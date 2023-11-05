class_name WorldRoom extends Node3D

signal room_entered(room: WorldRoom)

var room_camera: RoomCamera
var room_area: Area3D
var room_spawn: Node3D

var hide_on_enter: Array[Node3D]
var hide_on_exit: Array[Node3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	for child in children:
		assign_node(child)
	update_hidden_nodes(false)

func assign_node(node: Node)->void:
	if node is RoomCamera:
		assert(node.is_in_group("Camera"), "Camera isn't in camera group!")
		room_camera = node
	if node is Area3D:
		var area = node as Area3D
		room_area = node
		room_area.body_entered.connect(_on_room_area_entered)
		room_area.body_exited.connect(_on_room_area_exited)
	if node.is_in_group("Spawn"):
		room_spawn = node
	if node.is_in_group("HideOnEnter"):
		hide_on_enter.push_back(node)
	if node.is_in_group("HideOnExit"):
		hide_on_exit.push_back(node)
	var children = node.get_children()
	for child in children:
		assign_node(child)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_room_area_entered(body: Node3D):
	if not body.is_in_group("Player"):
		return

	# if room_camera:
	# 	room_camera.current = true
		
	var children = get_children()
	for child in children:
		if child.has_method("_on_room_entered"):
			child._on_room_entered(body)

	update_hidden_nodes(true)

func _on_room_area_exited(body: Node3D):
	if not body.is_in_group("Player"):
		return
	print("HERE")
	var children = get_children()
	for child in children:
		if child.has_method("_on_room_exited"):
			print("HERE in children iteration")
			child._on_room_exited()
	
	update_hidden_nodes(false)

func update_hidden_nodes(entering: bool):
	if entering:
		for hide_node in hide_on_exit:
			hide_node.visible = true
		for hide_node in hide_on_enter:
			hide_node.visible = false
	else:
		for hide_node in hide_on_enter:
			hide_node.visible = true
		for hide_node in hide_on_exit:
			hide_node.visible = false
	

