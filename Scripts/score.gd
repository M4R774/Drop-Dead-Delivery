extends Label

func _ready():
	HIGHSCORE_SINGLETON.SCORE = 0

func _process(_delta):
	self.text = "Score: " + str(HIGHSCORE_SINGLETON.SCORE)
