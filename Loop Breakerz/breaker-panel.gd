extends CanvasLayer

var access_commands = [
	["amplify", "calibrate", "realign", "transfer", "activate", "trigger", "initiate", "unseal", "locate", "engage", "elevate", "decrypt", "access", "disrupt", "crack"],
	["sigma", "synthetic", "hyperion", "echo", "viral", "cascade", "parallel", "grid", "vortex", "quantum", "axis", "synaptic"],
	["drive", "flux", "paradox", "circuit", "matrix", "frame", "axon", "subroutine", "node", "spectral", "synch", "fusion", "feedback"],
	["essence", "pulse", "bind", "spectrum", "pathway", "stream", "loop", "field", "shield", "link"]
]
var maintenance_commands = ["deploy", "queued", "entity", "at", "unlock", "zone", "gateway"]
var coords = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega"]
var responses = [
	"Welcome to the ZONE zone!\nEnter a valid command to continue!",
	"Access denied!\nEnter a valid command to continue!",
	"Access granted!\nEnter a valid zone maintenance command!",
	"Invalid command!\nEnter a valid zone maintenance command!",
	"UPGRADE is deployed at POSITION!\nEnter a valid zone maintenance command!",
	"ZONE gateway is unlocked at POSITION!\nEnter a valid zone maintenance command!",
]
enum STATES {
	WELCOME,
	DENIED,
	GRANTED,
	INVALID,
	DEPLOYED,
	UNLOCKED,
}
var state = STATES.WELCOME
var access_command = ""
var entered_line = null
var keywords = []
var revealed = -1
var guesses = []
var zones = []
var spawners = []
var factory = Vector2()
onready var response_label = $"%Response"
onready var keywords_label = $"%Keywords"
onready var guesses_container = $"%Guesses"
onready var command_label = $"%Command"
onready var overlay = $Overlay

func _ready():
	randomize()
	state = STATES.WELCOME
	response_label.text = responses[state]
	generate()
	
func generate():
	for zone in zones:
		print(zone.room_position)
	keywords = []
	revealed = -1
	access_command = ""
	for guess in guesses_container.get_children():
		guess.queue_free()
	if state == STATES.WELCOME:
		for i in access_commands.size():
			access_commands[i].shuffle()
			keywords += access_commands[i].slice(0, 5)
			access_command += access_commands[i][0] + " "
	if state == STATES.GRANTED:
		keywords += maintenance_commands
		for zone in zones:
			if not keywords.has(coords[zone.room_position.x]):
				keywords.append(coords[zone.room_position.x])
			if not keywords.has(str(zone.room_position.y)):
				keywords.append(str(zone.room_position.y))
		for spawner in spawners:
			if not keywords.has(coords[spawner.room_position.x]):
				keywords.append(coords[spawner.room_position.x])
			if not keywords.has(str(spawner.room_position.y)):
				keywords.append(str(spawner.room_position.y))
		if factory and not keywords.has(coords[factory.room_position.x]):
			keywords.append(coords[factory.room_position.x])
		if factory and not keywords.has(str(factory.room_position.y)):
			keywords.append(str(factory.room_position.y))
		
	access_command = access_command.rstrip(" ")
	print(access_command)
	keywords.sort()
	keywords_label.text = "Traced keywords:\n"
	for keyword in keywords:
		keywords_label.text += keyword + " "

func _input(event):
	if not (event is InputEventKey and event.pressed):
		return
	var c = event.as_text().to_lower()
	if c == "enter":
		execute_command()
		return
	if c.length() == 1:
		handle_input(c)

func execute_command():
	if state == STATES.WELCOME or state == STATES.DENIED:
		if command_label.text.rstrip(" ") == access_command:
			state = STATES.GRANTED
			generate()
			command_label.text = ""
			response_label.text = responses[state]
			return
		elif command_label.text.rstrip(" ").split(" ").size() == 4:
			var guess = command_label.duplicate()
			guess.text = guess.text.rstrip(" ")
			guesses_container.add_child(guess)
		state = STATES.DENIED
		command_label.text = ""
		response_label.text = responses[state]
		return
	var command = command_label.text.rstrip(" ")
	var words = command.split(" ")
	if words.size() != 6:
		state = STATES.INVALID
		command_label.text = ""
		return
	if command.begins_with("deploy queued entity at"):
		var pos = Vector2(coords.find(words[4]), int(words[5]))
		if factory == pos:
			state = STATES.DEPLOYED
			command_label.text = ""
			response_label.text = responses[state]
			return
		if spawners.has(pos):
			state = STATES.DEPLOYED
			command_label.text = ""
			response_label.text = responses[state]
			return
	if command.begins_with("unlock zone gateway at"):
		var pos = Vector2(coords.find(words[4]), int(words[5]))
		for zone in zones:
			if zone.room_position == pos:
				zone.unlock()
				state = STATES.UNLOCKED
				command_label.text = ""
				response_label.text = responses[state]
				return
	state = STATES.INVALID
	command_label.text = ""
	response_label.text = responses[state]

func handle_input(c):
	var current_word = Array(command_label.text.split(" ")).back()
	for keyword in keywords:
		if keyword.begins_with(current_word + c):
			command_label.text += c
			if keyword == current_word + c:
				command_label.text += " " 
			break


func reveal_next():
	if not (state == STATES.WELCOME or state == STATES.DENIED):
		if guesses_container.get_child_count() == 0:
			var guess = command_label.duplicate()
			guess.bbcode_text = "[color=#00ff00]deploy queued entity at[/color] [color=red][s]alpha 1[/s][/color] "
			guesses_container.add_child(guess)
		elif guesses_container.get_child_count() == 1:
			var guess = command_label.duplicate()
			guess.bbcode_text = "[color=#00ff00]unlock zone gateway at[/color] [color=red][s]alpha 1[/s][/color] "
			guesses_container.add_child(guess)
		return
	if guesses_container.get_child_count() <= revealed + 1:
		return
	revealed += 1
	var guess = guesses_container.get_child(revealed)
	var words = guess.text.split(" ")
	var expected_words = access_command.split(" ")
	var revealed_text = ""
	for i in range(words.size()):
		if expected_words[i] == words[i]:
			revealed_text += "[color=#00ff00]" + words[i] + "[/color] "
			continue
		if expected_words.has(words[i]):
			revealed_text += "[color=yellow][u]" + words[i] + "[/u][/color] "
			continue
		revealed_text += "[color=red][s]" + words[i] + "[/s][/color] "
	guess.bbcode_text = revealed_text
