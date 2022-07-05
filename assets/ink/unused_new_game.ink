VAR save_data_exists = false
VAR selected_character = ""

EXTERNAL signal(signal_name)

-> main_menu

== main_menu
#clear
Eyes open, blinking in dim light. Memory rushes back, and you sit up from your bed, eager to return to your work.
+ [New Game] ->
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
+ [Yes, erase my progress and start a new story] -> start_new_game
+ [Wait, let me choose again] -> main_menu 

== start_new_game
The colonization effort begins today, with you. You splash water on your face and dress quickly, glancing into the mirror to ensure that you're presentable. Your people are hard-pressed and every wasted moment increases the danger, but morale is nearly as important as haste. The demonic forces besieging your world grind away at the hopes of humanity and every advantage must be seized, even so small a thing as ensuring their savior doesn't look like they just rolled out of bed.

In the mirror you see...<>
+ [Valefor, explorer and archaeologist]
    ~selected_character="valefor"
    a rugged man, with a slightly wild tangle of loose red waves cascading down over his shoulders. You sigh as you comb fingers through your dense beard, darker red and streaked with brown. Another twenty minutes of personal grooming wouldn't go amiss, but if the public isn't used to your untameable mane by now then they haven't been paying attention. Lifting a hand, you examine it for tremors - just the slightest bit, same as ever as you prepare to step out into the unknown. Funny - you would have expected something more dramatic today. You roll the idea around in your mind. Today you set foot on a new planet, not just the ruins of some ancient civilization in the depths of the rainforest or the mausoleum of some long-dead ruler, filled with traps and treasures. 
Your grin widens, and suddenly you can't wait any longer. You snatch up your rucksack, packed the night before, and exit your quarters without a single glance back, striding toward the portal room with barely contained excitement, the pre-expedition tremors already forgotten.
    -> DONE

+ [Trinity, the civil engineer]
    ~selected_character="trinity"
    a tremulous smile that disappears as you bind your long white-blonde hair into a quick ponytail. Today you leave your friends, your family, your [i]entire world[/i] behind. Will the sacrifice be worth it? You take a shuddering breath and hold it for a slow count of five before exhaling. It will be worth it, it has to be. If you fail, after all, there won't be a world to return to, so there's hardly another option, is there? Today you go to prepare a place of safety for your people.
    -> DONE

+ [Grantham, the theoretical magitechnician]
    ~selected_character="grantham"
    a fierce scowl, piercing eyes like the depths of a glacier, a short shock of gray hair that's quickly tamed with a comb and dab of pomade. You take a deep breath to tame the anxiety that roils your stomach. You school the scowl into pleasant blandness, then try on a smile for size. No, that's not right, you're stepping through a portal into a new world, possibly even a new [i]universe[/i], not waiting in line at the bank. Lift the chin, clench the jaw just a bit - no, don't grind your teeth, just flex the muscle a bit. There - heroic resolve, that's the look. 
    Nodding sharply at your reflection, you make your way to the portal room. With every step you leave behind a bit of the fear that fills you, transforming the facade of steely resolve you wear into a reality through sheer force of will. That will be the least of the alchemies you will effect in this new world, if your theories bear fruit. 
    -> DONE


~ signal("new_game")

-> END
