﻿--[[ Defines the text referring to condition that appears when looking at someone ]]
RealisticDamageCore.InjuriesTable = {
    [0.0] = {
        "Healthy Condition", -- Health at 100%
        Color(46, 204, 113)
    },
    [0.2] = {
        "Critical Condition", -- Health below 20%
        Color(192, 57, 43)
    },
    [0.4] = {
        "Serious Injury", -- Health between 20% and 40%
        Color(231, 76, 60)
    },
    [0.6] = {
        "Moderate Injury", -- Health between 40% and 60%
        Color(255, 152, 0)
    },
    [0.8] = {
        "Minor Injury", -- Health between 60% and 80%
        Color(255, 193, 7)
    },
    [1.0] = {
        "Slight Injury", -- Health between 80% and 99%
        Color(46, 204, 113)
    },
}
