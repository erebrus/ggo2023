extends Node

const INVENTORY_SIZE := 4
const INGRIDIENT_FOLDER := "res://resources/recipe/"

var inventory:Array[Ingridient]=[
	preload("res://resources/recipe/chestnuts.tres"),
	preload("res://resources/recipe/goat_milk.tres")
]
var prep_table_items:Array[Ingridient]=[]

var found_ingridients:Array[Ingridient]=[
#	"Chestnut Paste"
	]


var all_ingridients:Array[Ingridient]=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	var ingridient_files:=DirAccess.get_files_at(INGRIDIENT_FOLDER)
	for ifile in ingridient_files:
		all_ingridients.append(load(INGRIDIENT_FOLDER+ifile))
	print("init done")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_ingridient_found(i:Ingridient)->bool:
	return i in found_ingridients

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

func find_mix_ingridient(ingridient_list:Array[Ingridient]):
	if ingridient_list.is_empty():
		return null
	for i in all_ingridients:
		if ingridients_match(i.required_ingridients, ingridient_list):
			return i
	return null

func ingridients_match(l1:Array[Ingridient], l2:Array[Ingridient])->bool:
	if l1.size() != l2.size():
		return false
	for i in l1:
		if i not in l2:
			return false
	return true
	
func add_ingridient_to_pot(i:Ingridient):
	show_message("Add %s to pot" % i.name)
	found_ingridients.append(i)	
	Events.pot_updated.emit()
