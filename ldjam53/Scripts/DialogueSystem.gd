extends Control

@onready var json = JSON.new()
@export var play_on_start : bool = false
@export var dialogue_path : String = ""
@export var text_speed : float = 0.05

var dialogue

var phrase_num = 0
var finished = false

signal next_phrase_requested
signal dialog_box_closed


func _ready():
	if play_on_start:
		start_dialogue()


func _process(_delta):
	$Continue/Indicator.visible = finished
	if Input.is_action_just_pressed("skip_dialogue"):
		if self.visible == true:
			if finished:
				next_phrase()
				emit_signal("next_phrase_requested")
			else:
				$Text.visible_characters = len($Text.text)
	

func start_dialogue():
	visible = true
	phrase_num = 0
	$Timer.wait_time = text_speed
	dialogue = get_dialogue()
	assert(dialogue, "Dialogue not found")
	next_phrase()


func get_dialogue():
	var file = FileAccess.open(dialogue_path,FileAccess.READ)
	var content = file.get_as_text()
	var output = JSON.parse_string(content)
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return[]


func next_phrase() -> void:
	if phrase_num >= len(dialogue):
		visible = false
		emit_signal("dialog_box_closed")
		return
	
	finished = false
	
	$Name.text = dialogue[phrase_num]["Name"]
	$Text.text = dialogue[phrase_num]["Text"]
	
	$Text.visible_characters = 0
	print($Text.text)
	while $Text.visible_characters < len($Text.text):
		#$Text.bbcode_text.size()
		$Text.visible_characters += 1
		
		$Timer.start()
		await $Timer.timeout
	
	finished = true
	phrase_num += 1
	return


func trigger_dialogue(path):
	dialogue_path = path
	start_dialogue()


func _on_continue_pressed():
	next_phrase()
	emit_signal("next_phrase_requested")
