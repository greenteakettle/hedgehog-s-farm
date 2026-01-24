extends Resource
class_name CropData

@export_group("main")
@export var crop_name: String = "Plant Name"
@export var inventory_icon: Texture2D 
@export var is_seed: bool = false

@export_group("beds settings")

@export var animation_name: String = ""
@export_group("harvest")
@export var produce_data: CropData
