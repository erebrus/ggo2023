extends MarginContainer
class_name Inventory

const itemScene:PackedScene = preload("res://scenes/ui/inventory/inventory_item.tscn")
var selected_idx:int = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Global.INVENTORY_SIZE):
		$vbox.add_child(itemScene.instantiate())
	Events.inventory_updated.connect(update_inventory)
	update_inventory()

func _process(_delta):
	if Input.is_action_just_pressed("next_ingridient"):
		if Global.inventory.is_empty():
			selected_idx=-1
		else:
			selected_idx = wrap(selected_idx+1, 0, Global.inventory.size())
		update_selection()
	if Input.is_action_just_pressed("drop"):
		Global.discard_item(selected_idx)
		if Global.inventory.is_empty():
			selected_idx=-1
		else:
			selected_idx = wrap(selected_idx, 0, Global.inventory.size())
		update_selection()
		

func update_inventory():
	for i in range($vbox.get_child_count())	:
		if i >= Global.inventory.size():
			$vbox.get_child(i).ingridient=null
		else:
			$vbox.get_child(i).ingridient = Global.inventory[i]

	update_selection()
	
func update_selection():
	if selected_idx > Global.inventory.size():
		selected_idx=-1
	for i in range($vbox.get_child_count()):
		var item:InventoryItem = $vbox.get_child(i)		
		item.selected=selected_idx == i	
	
