extends LineEdit


func _ready():
	max_length = 20
	if HIGHSCORE_SINGLETON.PLAYER_NAME != null:
		self.text = HIGHSCORE_SINGLETON.PLAYER_NAME
		self.select_all()
	var _result = self.connect("text_changed",Callable(self,"text_changed"))
	var _result2 = self.connect("text_submitted",Callable(self,"enter_pressed"))


func text_changed(new_text):
	new_text = remove_naughty_characters(new_text)
	self.text = new_text
	caret_column = len(new_text)
	HIGHSCORE_SINGLETON.PLAYER_NAME = new_text


func enter_pressed(_new_text):
	HIGHSCORE_SINGLETON.PLAYER_NAME = self.text
	$"../Submit"._pressed()


func remove_naughty_characters(naughty_string: String):
	var regex = RegEx.new()
	regex.compile("[^\\x00-\\x7FöäåÖÄÅ]")
	var sanitized_string = regex.sub(naughty_string, "", true)
	return sanitized_string
