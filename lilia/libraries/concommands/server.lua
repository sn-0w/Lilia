﻿concommand.Add(
    "stopsoundall",
    function(client)
        if client:IsSuperAdmin() then
            for _, v in pairs(player.GetAll()) do
                v:ConCommand("stopsound")
            end
        else
            client:Notify("You must be a Super Admin to forcefully stopsound everyone!")
        end
    end
)
