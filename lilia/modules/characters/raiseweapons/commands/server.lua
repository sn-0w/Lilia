﻿lia.command.add(
    "toggleraise",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client)
            if (client.liaNextToggle or 0) < CurTime() then
                client:toggleWepRaised()
                client.liaNextToggle = CurTime() + RaisedWeaponCore.WeaponToggleDelay
            end
        end
    }
)
