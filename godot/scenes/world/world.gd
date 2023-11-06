extends Node3D

var player: CharacterBody3D
@export var starting_room: WorldRoom

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	for child in children:
		if child.is_in_group("Player"):
			player = child

	if starting_room:
		player.global_position = starting_room.room_spawn.global_position
		starting_room.on_room_area_entered(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
