﻿
util.AddNetworkString("F1AlterDescription")

net.Receive("F1AlterDescription", function(_, client)
    local character = client:getChar()
    local newDesc = net.ReadString()
    character:setDesc(newDesc)
end)

