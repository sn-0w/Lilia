﻿lia.net = lia.net or {}
lia.net.globals = lia.net.globals or {}
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
if SERVER then
    function checkBadType(name, object)
        if isfunction(object) then
            ErrorNoHalt("Net var '" .. name .. "' contains a bad object type!")
            return true
        elseif istable(object) then
            for k, v in pairs(object) do
                if checkBadType(name, k) or checkBadType(name, v) then return true end
            end
        end
    end

    function setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        if getNetVar(key) == value then return end
        lia.net.globals[key] = value
        netstream.Start(receiver, "gVar", key, value)
    end

    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    hook.Add("EntityRemoved", "liaNetworkingCleanup", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "liaNetworkingSync", function(client) client:syncVars() end)
    hook.Add("CharDeleted", "liaNetworkingCharDeleted", function(client, character)
        lia.char.names[character:getID()] = nil
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)

    hook.Add("OnCharCreated", "liaNetworkingCharCreated", function(client, character, data)
        lia.char.names[character:getID()] = data.name
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)
else
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
end
