﻿function PACCompatibility:PostPlayerInitialSpawn(client)
    timer.Simple(1, function() client:syncParts() end)
end

function PACCompatibility:PlayerLoadout(client)
    client:resetParts()
end

function PACCompatibility:ModuleLoaded()
    game.ConsoleCommand("sv_pac_webcontent_limit 35840\n")
end

function PACCompatibility:PlayerSpawn(client)
    if not (client:IsValid() or client:Alive() or client:getChar()) then return end
    client:ConCommand("pac_restart")
end
