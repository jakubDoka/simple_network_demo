extends Control


func _ready():
	var index=0
	for i in globals.skins:
		$c/skin_menu.add_item(i,index)
		index+=1
	network.connect("connection_succeeded", self, "_on_connection_success")
	network.connect("game_ended", self, "_on_game_ended")


func _on_host_pressed():
	if $c/name.text=="":
		network.host_game("player",$c/skin_menu.text)
	else: 
		network.host_game($c/name.text,$c/skin_menu.text)
	hide()


func _on_join_pressed():
	if $c/name.text=="":
		network.join_game($c/s_adress.text,"player",$c/skin_menu.text)
	else:
		network.join_game($c/s_adress.text,$c/name.text,$c/skin_menu.text)

func _on_connection_success():
	hide()


func _on_game_ended():
	show()



