extends KinematicBody2D
export (int) var max_speed=400
export (int) var acc=30

export (float) var rot_speed=6
export (String) var skin="default" setget set_skin
export (PackedScene) var bullet 
export (float) var reload_speed=1
export (int) var bullet_speed
export (int) var demige
export (int) var max_health

const FRIC=.005

var vel:Vector2
var speed:Vector2
var health:int setget set_health

signal skin_change

#setter
sync func set_skin(value):
	skin=value
	emit_signal("skin_change",skin)
puppet func set_health(value):
	health=value
	$displays/health.text=str(value)
	if health==0:
		respawn()
func respawn():
	set_health(max_health)
	position=Vector2(200,200)
	vel=Vector2()
func _ready():
	acc=Vector2(acc,0)
	add_to_group("ships")
	position=get_viewport_rect().size/2
	set_physics_process(is_network_master())
	
func _physics_process(delta):
	control(delta)
	rpc("move",position,rotation,vel)
func control(delta):
	pass
var loadet=true
var id=0
func shoot():
	if loadet:
		id=(id+1)%1000
		rpc("make_bullet",str(id),rand_range(-.05,.05))
		loadet=false
		$reload.start(reload_speed)

sync func make_bullet(id,inaccuracy=0):
	var b=bullet.instance()
	b.start($muzzle.global_position,global_rotation+inaccuracy,bullet_speed,speed)
	b.name=id
	
	$c.add_child(b)
master func on_hit(knock):
	vel+=knock
	
	set_health(health-1)
	rpc("set_health",health)

puppet func move(pos,rot,vel):
	position=pos
	rotation=rot
	self.vel=vel
func _on_reload_timeout():
	loadet=true
