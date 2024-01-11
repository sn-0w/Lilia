﻿local Variables = {"disabled", "name", "price", "noSell", "faction", "factions", "class", "hidden"}
local DarkRPVariables = {
    ["DarkRPNonOwnable"] = function(ent, _) ent:setNetVar("noSell", true) end,
    ["DarkRPTitle"] = function(ent, val) ent:setNetVar("name", val) end,
    ["DarkRPCanLockpick"] = function(ent, val) ent.noPick = tobool(val) end
}

function DoorsCore:EntityKeyValue(ent, key, value)
    if ent:isDoor() and DarkRPVariables[key] then DarkRPVariables[key](ent, value) end
end

function DoorsCore:copyParentDoor(child)
    local parent = child.liaParent
    if IsValid(parent) then
        for _, v in ipairs(Variables) do
            local value = parent:getNetVar(v)
            if child:getNetVar(v) ~= value then child:setNetVar(v, value) end
        end
    end
end

function DoorsCore:LoadData()
    local data = self:getData()
    if not data then return end
    for k, v in pairs(data) do
        local entity = ents.GetMapCreatedEntity(k)
        if IsValid(entity) and entity:isDoor() then
            for k2, v2 in pairs(v) do
                if k2 == "children" then
                    entity.liaChildren = v2
                    for index, _ in pairs(v2) do
                        local door = ents.GetMapCreatedEntity(index)
                        if IsValid(door) then door.liaParent = entity end
                    end
                else
                    entity:setNetVar(k2, v2)
                end
            end
        end
    end
end

function DoorsCore:SaveData()
    local data = {}
    local doors = {}
    for _, v in ipairs(ents.GetAll()) do
        if v:isDoor() then doors[v:MapCreationID()] = v end
    end

    local doorData
    for k, v in pairs(doors) do
        doorData = {}
        for _, v2 in ipairs(Variables) do
            local value = v:getNetVar(v2)
            if value then doorData[v2] = v:getNetVar(v2) end
        end

        if v.liaChildren then doorData.children = v.liaChildren end
        if v.liaClassID then doorData.class = v.liaClassID end
        if v.liaFactionID then doorData.faction = v.liaFactionID end
        if table.Count(doorData) > 0 then data[k] = doorData end
    end

    self:setData(data)
end

function DoorsCore:callOnDoorChildren(entity, callback)
    local parent
    if entity.liaChildren then
        parent = entity
    elseif entity.liaParent then
        parent = entity.liaParent
    end

    if IsValid(parent) then
        callback(parent)
        for k, _ in pairs(parent.liaChildren) do
            local child = ents.GetMapCreatedEntity(k)
            if IsValid(child) then callback(child) end
        end
    end
end

function DoorsCore:InitPostEntity()
    local doors = ents.FindByClass("prop_door_rotating")
    for _, v in ipairs(doors) do
        local parent = v:GetOwner()
        if IsValid(parent) then
            v.liaPartner = parent
            parent.liaPartner = v
        else
            for _, v2 in ipairs(doors) do
                if v2:GetOwner() == v then
                    v2.liaPartner = v
                    v.liaPartner = v2
                    break
                end
            end
        end
    end
end

function DoorsCore:PlayerUse(client, entity)
    if entity:isDoor() then
        local result = hook.Run("CanPlayerUseDoor", client, entity)
        if result == false then
            return false
        else
            result = hook.Run("PlayerUseDoor", client, entity)
            if result ~= nil then return result end
        end
    end
end

function DoorsCore:CanPlayerUseDoor(_, entity)
    if entity:getNetVar("disabled") then return false end
end

function DoorsCore:CanPlayerAccessDoor(client, door, _)
    local factions = door:getNetVar("factions")
    if factions ~= nil then
        local facs = util.JSONToTable(factions)
        if facs ~= nil and facs ~= "[]" then if facs[client:Team()] then return true end end
    end

    local class = door:getNetVar("class")
    local classData = lia.class.list[class]
    local charClass = client:getChar():getClass()
    local classData2 = lia.class.list[charClass]
    if class and classData and classData2 then
        if classData.team then
            if classData.team ~= classData2.team then return false end
        else
            if charClass ~= class then return false end
        end
        return true
    end
end

function DoorsCore:PostPlayerLoadout(client)
    client:Give("lia_keys")
end

function DoorsCore:ShowTeam(client)
    local entity = client:GetTracedEntity()
    if IsValid(entity) and entity:isDoor() and not entity:getNetVar("faction") and not entity:getNetVar("class") then
        if entity:checkDoorAccess(client, DOOR_TENANT) then
            local door = entity
            if IsValid(door.liaParent) then door = door.liaParent end
            netstream.Start(client, "doorMenu", door, door.liaAccess, entity)
        elseif not IsValid(entity:GetDTEntity(0)) then
            lia.command.run(client, "doorbuy")
        else
            client:notifyLocalized("notAllowed")
        end
        return true
    end
end

function DoorsCore:PlayerDisconnected(client)
    for _, v in ipairs(ents.GetAll()) do
        if v == client then return end
        if v.isDoor and v:isDoor() and v:GetDTEntity(0) == client then v:removeDoorAccessData() end
    end
end



function DoorsCore:KeyLock(client, entity, time)
    if not IsValid(entity) then return end
    if  entity:IsVehicle() and entity:GetCreator() == client then
        client:setAction("@locking", time, function() self:ToggleLock(client, entity, true) end)
        return true 
    end
end

function DoorsCore:KeyUnlock(client, entity, time)
    if not IsValid(entity) then return end 
    if IsValid(owner) and owner:GetPos():Distance(door:GetPos()) > 96 then return end
    self:ToggleLock(client, entity, true)
    return true 
end

function DoorsCore:ToggleLock(owner, door, state)
    if IsValid(owner) and owner:GetPos():Distance(door:GetPos()) > 96 then return end
    local partner = door:getDoorPartner()


    if entity:isDoor() and entity:checkDoorAccess(owner) then
        if state then
            owner:setAction("@locking", time, function()
                if IsValid(partner) then partner:Fire("lock") end
                door:Fire("lock")
                owner:EmitSound("doors/door_latch3.wav")
            end)
        else
            owner:setAction("@unlocking", time, function()
                if IsValid(partner) then partner:Fire("unlock") end
                door:Fire("unlock")
                owner:EmitSound("doors/door_latch1.wav")
            end)
        end
    elseif door:IsVehicle() then
        if state then
            owner:setAction("@locking", time, function()
                door:Fire("lock")
                owner:EmitSound("doors/door_latch3.wav")
            end)
        else
            owner:setAction("@unlocking", time, function()
                door:Fire("unlock")
                owner:EmitSound("doors/door_latch1.wav")
            end)
        end
    end
end