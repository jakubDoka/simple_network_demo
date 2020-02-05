#i vill mark evrithing explaned in godot documentation with "DOCS" 
#you can find everithing on:
#https://docs.godotengine.org/en/3.2/tutorials/networking/high_level_multiplayer.html
extends Node
#DOCS
const DEFAULT_IP="127.0.0.1"
const DEFAULT_PORT=6000
const MAX_PEERS = 5
#thous are the names of variables thet 
#are sent remotly to sinchronise player data.(check get_info() function)
const VARIING_INFO=["nick","skin","health","position"]
var player_scene=preload("res://scenes/ships/player.tscn")
var world_scene=preload("res://scenes/enviroment/world.tscn")
#array holds references for easier accses-unique_id:player_reference.
#(check _player_disconected(),get_info() functions)
var players={}
#helper var holds info from lobby
var this_info={}
#helper var and signal it indikates if player scene is instanced so 
#get_info() can be used safely(see _player_conected(id),start_game())
var ready:bool
signal ready_
#conected to lobby
signal connection_succeeded
signal game_ended
#DOCS
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
#if there is 3 players conected and 4th conects this will 
#be called 3-times on new player and once on ewerion else
func _player_connected(id):
	if not ready:
		yield(self,"ready_")
	var this_id=get_tree().get_network_unique_id()
	var inf=get_info(players[get_tree().get_network_unique_id()],VARIING_INFO)
	rpc_id(id,"add_player",get_tree().get_network_unique_id(),inf)
func _connected_ok():
	emit_signal("connection_succeeded")
	start_game()
func _connected_fail():
	emit_signal("game_ended")
func _player_disconnected(id):
	players[id].queue_free()
func _server_disconnected():
	get_node("/root/world").queue_free()
	emit_signal("game_ended")
#this is used not onli remotly
remote func add_player(id,info):
	var p=player_scene.instance()
	for i in info:
		p.set(i,info[i])
	players[id]=p
	p.name=str(id)
	p.set_network_master(id)
	get_node("/root/world/players").add_child(p)
func get_info(player,variing):
	var info={}
	for i in variing:
		info[i]=player.get(i)
	return info
#DOCS
func host_game(nickname,skin):
	this_info={"name":nickname,"skin":skin}
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)
	start_game()
#DOCS
func join_game(ip,nickname,skin):
	this_info={"name":nickname,"skin":skin}
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
func start_game():
	var world=world_scene.instance()
	get_tree().get_root().add_child(world)
	var id=get_tree().get_network_unique_id()
	add_player(id,this_info)
	ready=true
	emit_signal("ready_")
	
