extends Node

var found_ingridients:Array[String]=[
#	"Chestnut Paste"
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_ingridient_found(str:String)->bool:
	return str in found_ingridients
