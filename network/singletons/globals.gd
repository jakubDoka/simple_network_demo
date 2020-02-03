extends Node
onready var textures=preload_all_from("res://textures/",4,"import")
var world:Node2D
var skins=[]
func _ready():
	pass
func preload_all_from(path,type,exclude,res={}):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			while file_name.ends_with("."):
				file_name = dir.get_next()
			if dir.current_is_dir():
				skins.append(file_name)
				res[file_name]=preload_all_from(path+file_name+"/",type,exclude,{})
			else:
				if not file_name in res and file_name.find(exclude)==-1:
					res[file_name.left(file_name.length()-type)]=load(path+file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		return res
