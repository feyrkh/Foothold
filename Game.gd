extends Control

func _ready() -> void:
	Events.connect("new_game", self, "new_game")
	Events.connect("continue_game", self, "continue_game")
	Events.connect("exit_game", self, "exit_game")
	$InkBook.visible = true
	$InkBook.start_story('res://assets/ink/new_game.ink.json', InkBookSaveData.new('new_game', {'save_data_exists': false}), self, "story_loaded")
	$UI.visible = false

	pass

func story_loaded(successfully):
	var story:InkPlayer = $InkBook.get_story()
	#story.connect("ended", self, 'new_character_created')

func new_game():
	$InkBook.visible = false
	$UI.visible = true
	$InkBook.clear_story()

func continue_game():
	pass

func exit_game():
	save_game()
	get_tree().quit()

func save_game():
	pass
