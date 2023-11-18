extends Control
class_name  InventoryItem
var selected:bool = false:
	set(val):
		selected=val
		$outline.visible=selected


var ingridient:Ingridient:
	set(val):
		ingridient=val
		if ingridient == null:
			$icon.texture = null
		else:	
			$icon.texture = ingridient.raw_icon_png
		
# Called when the node enters the scene tree for the first time.
func _ready():
	selected=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
