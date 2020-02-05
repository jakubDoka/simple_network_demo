#finds its own texture and can change it dinamicly
extends Sprite

export (String)var texture_type
export (String)var root_name="tank"
onready var root=find_parent(str(get_network_master()))
func _ready():
	root.connect("skin_change",self,"on_change_texture")
	texture_type=texture_type if texture_type else name
	on_change_texture(root.skin)
func on_change_texture(skin):
	texture=load("res://textures/"+skin+"/"+texture_type+".png")
