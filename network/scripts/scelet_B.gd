extends KinematicBody2D
var vel:Vector2
var svel:Vector2
export(int)var knockback
export(float)var live_time=1
func _ready():
	$bullet.texture=get_parent().textures["bullet"]
	if not is_network_master():
		set_physics_process(false)
		$shape.shape=null
		return
	add_to_group("bullets")
	$timer.start(live_time)
func start(pos,rot,speed_,vel_):
	vel=Vector2(speed_,0).rotated(rot)
	position=pos+vel_
	rotation=rot
	svel=vel_
func _physics_process(delta):
	var col=move_and_collide((vel+svel)*delta)
	if col:
		if col.collider.is_in_group("ships"):
			rpc("explode")
			col.collider.rpc("on_hit",vel.normalized()*100)
			
			return
		vel=vel.bounce(col.normal)
		rotation=vel.angle()
		rpc("rotate",rotation)
	rpc("move",position)
	svel-=svel*.05
puppet func move(pos):
	position=pos
puppet func rotate(rot):
	rotation=rot
sync func explode():
	set_physics_process(false)
	$ef.interpolate_property(self,"modulate",modulate,Color(1,1,1,0),.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$ef.interpolate_property(self,"scale",scale,scale*2,.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$ef.start()
	$shape.shape=null
	yield($ef,"tween_all_completed")
	queue_free()

func _on_Timer_timeout():
	rpc("explode")


func _on_bullet_area_entered(area):
	if area==self:
		return
	if not area.is_in_group("ships"):
		var normal=$ray.get_collision_normal()
		if bool(normal.x):
			vel.x=-vel.x
		if bool(normal.y):
			vel.y=-vel.y
		rotation=vel.angle()
		return
	rpc("explode")
	
	area.rpc("on_hit",vel.normalized()*100)
	
