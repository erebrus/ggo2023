extends Resource
class_name Ingridient

@export var name:String
@export var collect_time:=3.0
@export_multiline var haiku:String
@export var empty_board_png:Texture
@export var written_board_png:Texture
@export var raw_icon_png:Texture
@export var prepare_action:String="Prepare"
@export var prepared_ingridient:Ingridient
@export var required_ingridients:Array[Ingridient]



