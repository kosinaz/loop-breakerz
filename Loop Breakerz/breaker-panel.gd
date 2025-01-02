extends CanvasLayer

var access_commands = [
	["activate", "initiate", "calibrate", "elevate", "replicate", "generate", "terminate", "validate", "coordinate", "simulate"],
	["cybernetic", "telemetric", "magnetic", "synthetic", "electric", "dynamic", "static", "kinetic", "bionic", "cryogenic"],
	["xenovector", "nexalith", "exodrive", "vortexium", "xylotron", "quantaflux", "axionet", "neuromatrix", "protonexus", "preparadox"],
	["module", "field", "link", "core", "hub", "network", "node", "unit", "grid", "array"]
]
var maintenance_commands = ["deploy", "entity", "unlock", "gateway"]
var reset_commands = ["reset", "looper"]
var coords = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega"]
var responses = [
	"Enter a valid command of 4 keywords to continue!",
	"Access denied!\nEnter a valid command of 4 keywords to continue!",
	"Access granted!\nEnter a valid zone maintenance command!",
	"Invalid command!\nEnter a valid zone maintenance command!",
	"The UPGRADE generator is deployed at POSITION!\nEnter a valid zone maintenance command!",
	"The UPGRADE gateway is unlocked at POSITION!\nEnter a valid zone maintenance command!",
	"Target neutralized! Enter a valid command to reset!",
	"Invalid command! Enter a valid command to reset!",
]
enum STATES {
	WELCOME,
	DENIED,
	GRANTED,
	INVALID,
	DEPLOYED,
	UNLOCKED,
	ELIMINATED,
	RESET,
}
var state = STATES.WELCOME
var access_command = ""
var entered_line = null
var keywords = []
var keywords_revealed = []
var revealed = -1
var guesses = []
var zones = []
var factory = Vector2()
var upgrade = ""
var severity_min = 4
var severity_max = 10
var time = 0
onready var time_label = $"%Time"
onready var level_label = $"%Level"
onready var adaptibility_label = $"%Adaptibility"
onready var velocity_label = $"%Velocity"
onready var frequency_label = $"%Frequency"
onready var severity_label = $"%Severity"
onready var zone_label = $"%Zone"
onready var response_label = $"%Response"
onready var keywords_label = $"%Keywords"
onready var guesses_container = $"%Guesses"
onready var command_label = $"%Command"
onready var overlay = $Overlay


func _ready():
	randomize()
	
func init():
	state = STATES.WELCOME
	response_label.text = responses[state].replace("UPGRADE", upgrade)
	update_stats()
	generate()
	
func update_stats():
	var player = get_parent().player
	level_label.text = "Target acquired: Looper V" + str(player.level)
	adaptibility_label.text = "Adaptibility: " + str(player.adaptabilities[player.adaptability])
	velocity_label.text = "Velocity: " + str(player.velocities[player.velocity])
	frequency_label.text = "Frequency: " + str(player.frequencies[player.frequency])
	severity_label.text = "Severity: " + str(player.severities[player.severity][0]) + "-" + str(player.severities[player.severity][1])
	
func generate():
	print("f", factory)
	keywords = []
	keywords_revealed = []
	revealed = -1
	access_command = ""
	for guess in guesses_container.get_children():
		guess.queue_free()
	if state == STATES.WELCOME:
		for i in access_commands.size():
			access_commands[i].shuffle()
			keywords += access_commands[i].slice(0, 3)
			access_command += access_commands[i][0] + " "
		access_command = access_command.rstrip(" ")
		print(access_command)
	if state == STATES.GRANTED:
		keywords += maintenance_commands
		for zone in zones:
			if not keywords.has(coords[zone.door.room_position.x]):
				keywords.append(coords[zone.door.room_position.x])
			if not keywords.has(str(zone.door.room_position.y)):
				keywords.append(str(zone.door.room_position.y))
		if factory and not keywords.has(coords[factory.x]):
			keywords.append(coords[factory.x])
		if factory and not keywords.has(str(factory.y)):
			keywords.append(str(factory.y))
	if state == STATES.ELIMINATED:
		keywords += reset_commands
		var player_position = get_parent().get_player_room_position()
		keywords.append(coords[player_position.x])
		keywords.append(str(player_position.y))
		for _i in range(3):
			var r = randi() % 10
			if not keywords.has(coords[r]):
				keywords.append(coords[r])
			if not keywords.has(str(r)):
				keywords.append(str(r))
	keywords.sort()
	keywords_revealed = keywords.duplicate()
	keywords_revealed.fill(0)
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
	var command = command_label.text.rstrip(" ")
	var words = command.split(" ")
	if state == STATES.WELCOME or state == STATES.DENIED:
		if command == access_command:
			state = STATES.GRANTED
			generate()
			command_label.text = ""
			response_label.text = responses[state]
			return
		elif words.size() == 4:
			var guess = command_label.duplicate()
			guess.text = guess.text.rstrip(" ")
			guesses_container.add_child(guess)
		state = STATES.DENIED
		command_label.text = ""
		response_label.text = responses[state]
		return
	if state == STATES.ELIMINATED or state == STATES.RESET:
		if command.begins_with("reset looper") and words.size() == 4:
			var pos = Vector2(coords.find(words[2]), int(words[3]))
			if get_parent().get_player_room_position() == pos:
				state = STATES.WELCOME
				command_label.text = ""
				response_label.text = responses[state].replace("UPGRADE", upgrade)
				generate()
				get_parent().player.revive()
				time = 0
				return
		state = STATES.RESET
		command_label.text = ""
		response_label.text = responses[state]
		return
	if words.size() != 4:
		state = STATES.INVALID
		command_label.text = ""
		response_label.text = responses[state]
		return
	if command.begins_with("deploy entity"):
		if upgrade == "Void":
			state = STATES.INVALID
			command_label.text = ""
			response_label.text = responses[state]
			return
		var pos = Vector2(coords.find(words[2]), int(words[3]))
		if factory == pos:
			state = STATES.DEPLOYED
			command_label.text = ""
			response_label.text = responses[state].replace("UPGRADE", upgrade).replace("POSITION", words[2] + " " + words[3])
			get_parent().deploy_upgrade()
			return
	if command.begins_with("unlock gateway"):
		var pos = Vector2(coords.find(words[2]), int(words[3]))
		for zone in zones:
			if zone.door and zone.door.room_position == pos:
				zone.door.unlock()
				state = STATES.UNLOCKED
				command_label.text = ""
				response_label.text = responses[state].replace("UPGRADE", zone.upgrade).replace("POSITION", words[2] + " " + words[3])
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
			guess.bbcode_text = "[color=#00ff00]deploy entity[/color] [color=red][s]omega 99[/s][/color] "
			guesses_container.add_child(guess)
		elif guesses_container.get_child_count() == 1:
			var guess = command_label.duplicate()
			guess.bbcode_text = "[color=#00ff00]unlock gateway[/color] [color=red][s]omega 99[/s][/color] "
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
			keywords_revealed[keywords.find(words[i])] = 3
			continue
		if expected_words.has(words[i]):
			revealed_text += "[color=yellow][u]" + words[i] + "[/u][/color] "
			keywords_revealed[keywords.find(words[i])] = max(keywords_revealed[keywords.find(words[i])], 2)
			continue
		revealed_text += "[color=red][s]" + words[i] + "[/s][/color] "
		keywords_revealed[keywords.find(words[i])] = 1
	guess.bbcode_text = revealed_text
	var revealed_words = ""
	for i in range(keywords.size()):
		if keywords_revealed[i] == 0:
			revealed_words += keywords[i] + " "
		if keywords_revealed[i] == 1:
			revealed_words += "[color=red][s]" + keywords[i] + "[/s][/color] "
		if keywords_revealed[i] == 2:
			revealed_words += "[color=yellow][u]" + keywords[i] + "[/u][/color] "
		if keywords_revealed[i] == 3:
			revealed_words += "[color=#00ff00]" + keywords[i] + "[/color] "
	keywords_label.bbcode_text = "Traced keywords:\n" + revealed_words

func eliminate():
	state = STATES.ELIMINATED
	command_label.text = ""
	response_label.text = responses[state]
	generate()


func _on_timer_timeout():
	if get_parent().player.died:
		return
	time += 0.09
	var minutes = int(time / 60)
	var secs = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)  # Extract milliseconds
	time_label.text = "Time since breach: %02d:%02d.%02d" % [minutes, secs, milliseconds]
