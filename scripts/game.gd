extends Node

onready var barril = preload("res://scenes/barril.tscn")
onready var barrilEsq = preload("res://scenes/barrilEsq.tscn")
onready var barrilDir =  preload("res://scenes/barrilDir.tscn")


onready var felpudo = get_node("Felpudo")
onready var camera = get_node("Camera")
onready var barris = get_node("Barris")
onready var destBarris = get_node("DestBarris")
onready var barra = get_node("Barra")

onready var labelpontos = get_node("Control/Pontos")


var ultini

var pontos = 0

var estado = JOGANDO

const JOGANDO = 1
const PERDEU = 2



func _ready():
	randomize()
	carregar_dados()
	set_process_input(true)
	
	gerarIni()
	
	barra.connect("perdeu", self, "perder")
	
func _input(event):
	event = camera.make_input_local(event)
	if (event is InputEventScreenTouch) and (event.pressed == true) and estado == JOGANDO:
		if event.position.x < 360:
			felpudo.esq()
		else:
			felpudo.dir()
			
		if !verif():
			felpudo.bater()
			var prim = barris.get_children()[0]
			barris.remove_child(prim)
			destBarris.add_child(prim)
			prim.dest(felpudo.lado)
			
			aleaBarril(Vector2(360, 1090 - 10*172))
			descer()
			
			barra.add(0.014)
			
			pontos += 1
			labelpontos.set_text(str(pontos))
			
			
			if verif():
				salvar_dados()
				perder()
				
		else:
			perder()
		
func aleaBarril(pos):
	var num = rand_range(0, 3)
	if ultini:
		num = 0
	gerarBarril(int(num), pos)
	
func gerarBarril(tipo, pos):
	var novo
	if tipo == 0:
		novo = barril.instance()
		ultini = false
	elif tipo == 1:
		novo = barrilEsq.instance()
		novo.add_to_group("barrilEsq")
		ultini = true
	elif tipo == 2:
		novo = barrilDir.instance()
		novo.add_to_group("barrilDir")
		ultini = true
		
	novo.set_position(pos)
	barris.add_child(novo)
		
	
func gerarIni():
	for i in range(0,3):
		gerarBarril(0, Vector2(360, 1090-i*172))
	
	for i in range(3, 10):
		aleaBarril(Vector2(360, 1090 - i*172))
		

func verif():
	var lado = felpudo.lado
	var prim = barris.get_children()[0]
	if lado == felpudo.ESQ and prim.is_in_group("barrilEsq") or lado == felpudo.DIR and prim.is_in_group("barrilDir"):
		return true
	else:
		return false
		
func descer():
	for b in barris.get_children():
		b.set_position(b.get_position() + Vector2(0, 172))
		
		
func perder():
	felpudo.morrer()
	barra.set_process(false)
	estado = PERDEU
	get_node("Timer").start()


func _on_Timer_timeout():
	get_tree().reload_current_scene()
	
func salvar_dados():
	var arquivo = File.new()
	var erro = arquivo.open("C:/Users/Paulo Roberto/Documents/Meus Projetos/Godot/TimberFelpudo_PauloMec//save.data", File.WRITE)
	
	var dados = {"pontuação" : pontos}
	
	if not erro:
		arquivo.store_var(dados)
	else:
		print("erro ao salvar dados")
	
	arquivo.close()
	
func carregar_dados():
	var arquivo = File.new()
	var erro = arquivo.open("C:/Users/Paulo Roberto/Documents/Meus Projetos/Godot/TimberFelpudo_PauloMec//save.data", File.READ)
	
	if not erro:
		var dados_salvos = arquivo.get_var()
		print(dados_salvos["pontuação"])
	else:
		print("erro ao acessar arquivo")
		
	arquivo.close()
	
	
	
	
	