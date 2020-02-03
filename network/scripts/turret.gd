extends Node2D


export (float) var view
var loadet=true
var in_range:bool

onready var turret_speed=get_parent().turret_speed
onready var start_pos=rotation
func _ready():
	$img/muzzle.position.x=$img.get_rect().size.x/2+2

func _process(delta):
	var vec=Vector2(1,0).rotated($img.global_rotation)
	var norm=Vector2(1,0).rotated(global_rotation)
	var point=(get_global_mouse_position()-$img.global_position).normalized()
	in_range=abs(norm.angle_to(point))<view
	$img.global_rotation=vec.linear_interpolate(
		point if in_range  else norm.rotated(-start_pos)
		,turret_speed*delta).angle()
	rpc("rotate",rotation)
puppet func rotate(rot):
	global_rotation=rot

	






