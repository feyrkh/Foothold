VAR save_data_exists = false

EXTERNAL signal(signal_name)
EXTERNAL signal1(signal_name, signal_arg)

-> main_menu

== main_menu
#clear
Eyes open, blinking in dim light. Memory rushes back, and you sit up from your bed, eager to return to your work.
+ New Game ->
    { not save_data_exists:
        -> start_new_game
    - else:
        -> start_new_game_sure
    }
+ { save_data_exists } [Continue] ->
    Continuing an existing world...
    ~ signal("continue_game")
    -> END
+ [Exit Game] ->
    ~ signal("exit_game")
    -> END

== start_new_game_sure
(Are you sure you want to start a new game? Your existing data will be overwritten.)
+ Yes, erase my progress and start a new story -> start_new_game
+ Wait, let me choose again -> main_menu 

== start_new_game
todo - intro to "preparing an environment"

+ Get started -> 
    ~signal("new_game")
-> END
