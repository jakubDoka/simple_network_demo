#loads the texture for scenes instanced by script 
#and stores them in dictionary
extends Node
export(String)var root_name="worm"
export(Dictionary) var textures
onready var root=find_parent(str(get_network_master()))
func _ready():
	textures=textures.duplicate()
	root.connect("skin_change",self,"on_change_texture")
	on_change_texture(root.skin)
func on_change_texture(skin):
	for texture_name in textures:
		textures[texture_name]=globals.textures[skin][texture_name]
