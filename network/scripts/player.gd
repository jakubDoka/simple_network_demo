extends "res://scripts/tank_S.gd"
var nick="player" setget set_nick

func set_nick(value):
	$displays/name.text=value
	nick=value
func _ready():
	set_nick(nick)
	if not is_network_master():
		$cam.current=false
	else:
		set_health(max_health)
func _process(delta):
	$displays.global_rotation=0
func control(delta):
	var vec=Vector2(1,0).rotated(rotation)
	var point=(get_global_mouse_position()-position).clamped(150)
	var pov=point.length()
	var trusting:bool
	rotation=vec.linear_interpolate(point.normalized(),rot_speed*delta).angle()
	$pov.clear_points()
	if Input.is_action_pressed("m_left"):
		shoot()
	elif Input.is_action_pressed("m_rigth"):
		$pov.points=[Vector2(),Vector2(pov,0)]
		vel+=acc.rotated(rotation)*pov/150
		trusting=true
	rpc("trust",trusting,point)
	vel=vel.clamped(max_speed)
	if vel.length()<1:
		vel=Vector2()
	speed=vel*delta
	var col=move_and_collide(speed)
	if col:
		if col.collider.is_in_group("bullets"):
			return
		vel=vel.bounce(col.normal)*.8


sync func trust(trusting,point):
	$b_truster.emitting=trusting
	$b_truster.initial_velocity=point.length()*2
	var vec=Vector2(1,0).rotated(rotation)
	if point.angle_to(vec)<-.05:
		$r_truster.emitting=true
	elif point.angle_to(vec)>.05:
		$l_truster.emitting=true
	else:
		$l_truster.emitting=false
		$r_truster.emitting=false
