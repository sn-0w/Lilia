﻿--[[ Defines the text referring to condition that appears when looking at someone ]]
RealisticDamageCore.InjuriesTable = {
    [0.2] = {"Critical Condition", Color(192, 57, 43)},
    [0.4] = {"Serious Injury", Color(231, 76, 60)},
    [0.6] = {"Moderate Injury", Color(255, 152, 0)},
    [0.8] = {"Minor Injury", Color(255, 193, 7)},
}

-- Health between 80% and 99%
--[[ Sounds played when a male character dies   ]]
RealisticDamageCore.MaleDeathSounds = {Sound("vo/npc/male01/pain07.wav"), Sound("vo/npc/male01/pain08.wav"), Sound("vo/npc/male01/pain09.wav")}
--[[ Sounds played when a male character is hurt   ]]
RealisticDamageCore.MaleHurtSounds = {Sound("vo/npc/male01/pain01.wav"), Sound("vo/npc/male01/pain02.wav"), Sound("vo/npc/male01/pain03.wav"), Sound("vo/npc/male01/pain04.wav"), Sound("vo/npc/male01/pain05.wav"), Sound("vo/npc/male01/pain06.wav")}
--[[ Sounds played when a female character dies   ]]
RealisticDamageCore.FemaleDeathSounds = {Sound("vo/npc/female01/pain07.wav"), Sound("vo/npc/female01/pain08.wav"), Sound("vo/npc/female01/pain09.wav")}
--[[ Sounds played when a female character is hurt   ]]
RealisticDamageCore.FemaleHurtSounds = {Sound("vo/npc/female01/pain01.wav"), Sound("vo/npc/female01/pain02.wav"), Sound("vo/npc/female01/pain03.wav"), Sound("vo/npc/female01/pain04.wav"), Sound("vo/npc/female01/pain05.wav"), Sound("vo/npc/female01/pain06.wav")}
--[[ Sounds played when a character is drowning   ]]
RealisticDamageCore.DrownSounds = {Sound("player/pl_drown1.wav"), Sound("player/pl_drown2.wav"), Sound("player/pl_drown3.wav"),}
