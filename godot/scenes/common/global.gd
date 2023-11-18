extends Node

const INVENTORY_SIZE:=4

var inventory:Array[Ingridient]=[
	preload("res://resources/recipe/chestnut_paste.tres"),
	preload("res://resources/recipe/chestnut_paste.tres")
]
var prep_table_items:Array[Ingridient]=[]

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

func add_to_prep_table(i:Ingridient)->bool:
	if	prep_table_items.size()>=2:
		Global.show_message("Prep table full.")
		return false
	Global.prep_table_items.append(i)	
	Events.prep_table_updated.emit()
	return true

func clear_prep_table()->Array[Ingridient]:
	var ret:Array[Ingridient]=[]
	ret.append_array(prep_table_items)
	prep_table_items.clear()
	Events.prep_table_updated.emit()
	return ret	

func add_to_inventory(i:Ingridient)->void:
	if inventory.size() < INVENTORY_SIZE:
		inventory.append(i)
		Events.inventory_updated.emit()
	else:
		show_message("No space in inventory.")

func is_inventory_full()->bool:
	return inventory.size() == INVENTORY_SIZE

func discard_item(idx)->Ingridient:
	if idx >=0 and idx < inventory.size():
		var ret = inventory[idx]
		inventory.remove_at(idx)
		Events.inventory_updated.emit()
		return ret
	return null
		

func show_message(msg:String)->void:
	print(msg)

