﻿lia.command.add("plytransfer", {
    adminOnly = true,
    privilege = "Manage Transfers",
    desc = L("plyTransferDesc"),
    syntax = "[string name] [string faction]",
    alias = {"charsetfaction"},
    onRun = function(client, arguments)
        local targetPlayer = lia.util.findPlayer(client, arguments[1])
        if not targetPlayer or not IsValid(targetPlayer) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local factionName = table.concat(arguments, " ", 2)
        local faction = lia.faction.teams[factionName] or lia.util.findFaction(client, factionName)
        if not faction then
            client:notifyLocalized("invalidFaction")
            return
        end

        local targetChar = targetPlayer:getChar()
        if hook.Run("CanCharBeTransfered", targetChar, faction, targetPlayer:Team()) == false then return end
        targetChar.vars.faction = faction.uniqueID
        targetChar:setFaction(faction.index)
        targetChar:kickClass()
        local defaultClass = lia.faction.getDefaultClass(faction.index)
        if defaultClass then targetChar:joinClass(defaultClass.index) end
        hook.Run("OnTransferred", targetPlayer)
        if faction.OnTransferred then faction:OnTransferred(targetPlayer) end
        hook.Run("PlayerLoadout", targetPlayer)
        client:notifyLocalized("transferSuccess", targetPlayer:Name(), L(faction.name, client))
        if client ~= targetPlayer then targetPlayer:notifyLocalized("transferNotification", L(faction.name, targetPlayer), client:Name()) end
    end
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = L("plyWhitelistDesc"),
    syntax = "[string name] [string faction]",
    alias = {"factionwhitelist"},
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, table.concat(arguments, " ", 2))
        if faction and target:setWhitelisted(faction.index, true) then
            for _, v in player.Iterator() do
                v:notifyLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
            end
        end
    end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = L("plyUnwhitelistDesc"),
    syntax = "[string name] [string faction]",
    alias = {"factionunwhitelist"},
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, table.concat(arguments, " ", 2))
        if faction and target:setWhitelisted(faction.index, false) then
            for _, v in player.Iterator() do
                v:notifyLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
            end
        end
    end
})

lia.command.add("beclass", {
    adminOnly = false,
    desc = L("beClassDesc"),
    syntax = "[string class]",
    onRun = function(client, arguments)
        local className = table.concat(arguments, " ")
        local character = client:getChar()
        if not IsValid(client) or not character then
            client:notifyLocalized("illegalAccess")
            return
        end

        local classID = tonumber(className) or lia.class.retrieveClass(className)
        local classData = lia.class.get(classID)
        if classData and lia.class.canBe(client, classID) then
            if character:joinClass(classID) then
                client:notifyLocalized("becomeClass", L(classData.name))
            else
                client:notifyLocalized("becomeClassFail", L(classData.name))
            end
        else
            client:notifyLocalized("invalidClass")
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    privilege = "Manage Classes",
    desc = L("setClassDesc"),
    syntax = "[string charname] [string class]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local className = table.concat(arguments, " ", 2)
        local classID = lia.class.retrieveClass(className)
        local classData = lia.class.list[classID]
        if classData then
            if target:Team() == classData.faction then
                target:getChar():joinClass(classID, true)
                target:notifyLocalized("classSet", L(classData.name), client:GetName())
                if client ~= target then client:notifyLocalized("classSetOther", target:GetName(), L(classData.name)) end
                hook.Run("PlayerLoadout", target)
            else
                client:notifyLocalized("classFactionMismatch")
            end
        else
            client:notifyLocalized("invalidClass")
        end
    end
})

lia.command.add("classwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = L("classWhitelistDesc"),
    syntax = "[string name] [string class]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        elseif not classID or not lia.class.hasWhitelist(classID) then
            client:notifyLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyLocalized("whitelistFactionMismatch")
        elseif target:hasClassWhitelist(classID) then
            client:notifyLocalized("alreadyWhitelisted")
        else
            target:classWhitelist(classID)
            client:notifyLocalized("whitelistedSuccess")
            target:notifyLocalized("classAssigned", L(classData.name))
        end
    end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    privilege = "Manage Classes",
    desc = L("classUnwhitelistDesc"),
    syntax = "[string name] [string class]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        elseif not classID or not lia.class.hasWhitelist(classID) then
            client:notifyLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyLocalized("whitelistFactionMismatch")
        elseif not target:hasClassWhitelist(classID) then
            client:notifyLocalized("notWhitelisted")
        else
            target:classUnWhitelist(classID)
            client:notifyLocalized("unwhitelistedSuccess")
            target:notifyLocalized("classUnassigned", L(classData.name))
        end
    end
})