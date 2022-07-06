EXTERNAL signal(signal_name)
EXTERNAL signal1(signal_name, signal_arg)
EXTERNAL get_quest_flag(flag_name)
EXTERNAL set_quest_flag(flag_name, val)

-> check_quests
-> END

=== function get_quest_flag(flag_name)
{0}

=== check_quests
-> intro_quest ->
-> DONE

=== intro_quest
{
- not intro_quest.step1: -> step1 ->
- {not intro_quest.step2 && get_quest_flag("room_rubbish") <= 0}: -> step2 ->
}
->->

= step1
>>> QUEST: An inauspicious beginning
>>> GOAL: room_rubbish > 3
->->
= step2
Step 2!
->->
= step3
Step 3!
->->