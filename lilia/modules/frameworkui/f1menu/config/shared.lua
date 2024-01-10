﻿--[[ Enable Rules Display ]]
F1MenuCore.RulesEnabled = false
--[[ Enable Tutorial Display ]]
F1MenuCore.TutorialEnabled = false
--[[ Enable FAQ Display ]]
F1MenuCore.FAQEnabled = false
--[[ Enable Automatic Description ]]
F1MenuCore.AutomaticDescriptionEnabled = true
F1MenuCore.F1MenuLaunchUnanchor = "buttons/lightswitch2.wav"
F1MenuCore.MenuButtonRollover = "ui/buttonrollover.wav"
F1MenuCore.SoundMenuButtonPressed = "ui/buttonclickrelease.wav"
F1MenuCore.FAQQuestions = {
    ["Where am I?"] = [[Here. Here is home.]],
    ["Who am I?"] = [[You are you. You are a.... human-like thing.]],
    ["Why am I here?"] = [[You're here for scientific purposes. You will find out, soon.]],
    ["Where can I go?"] = [[You can find out. You will know when.]],
}

F1MenuCore.AutomaticDescriptionCustomizationOptions = {
    {
        Name = "Eye Color",
        Options = {"Brown", "Hazel", "Blue", "Green", "Gray", "Amber"}
    },
    {
        Name = "Hair Color",
        Options = {"Bald", "Brown", "Blond", "Black", "Auburn", "Red", "Gray"}
    },
    {
        Name = "Gender",
        Options = {"Male", "Female"}
    },
    {
        Name = "Height",
        Options = {"5'0", "5'1", "5'2", "5'3", "5'4", "5'5", "5'6", "5'7", "5'8", "5'9", "5'10", "5'11", "6'0", "6'1", "6'2", "6'3", "6'4", "6'5"}
    },
}
