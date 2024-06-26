﻿local GM = GM or GAMEMODE
function GM:DrawLiliaModelView(_, entity)
    if IsValid(entity.weapon) then entity.weapon:DrawModel() end
end

function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("jump") and client:hasRagdoll() then
        lia.command.send("chargetup")
    elseif (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then return true end
        if bind:find("use") then
            local entity = client:GetTracedEntity()
            if IsValid(entity) then if entity:isItem() or entity.hasMenu then hook.Run("ItemShowEntityMenu", entity) end end
        end
    end
end

function GM:CalcView(client, origin, angles, fov)
    local view = self.BaseClass:CalcView(client, origin, angles, fov)
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    local ragdoll = client:GetRagdollEntity()
    if not client:InVehicle() and client:GetViewEntity() == client and (not client:ShouldDrawLocalPlayer() and IsValid(entity) and entity:IsRagdoll()) or (not LocalPlayer():Alive() and IsValid(ragdoll)) then
        local ent = LocalPlayer():Alive() and entity or ragdoll
        local index = ent:LookupAttachment("eyes")
        if index then
            local data = ent:GetAttachment(index)
            if data then
                view = view or {}
                view.origin = data.Pos
                view.angles = data.Ang
                view.znear = 1
            end
            return view
        end
    end
end

function GM:HUDPaintBackground()
    lia.bar.drawAll()
    lia.menu.drawAll()
    self.BaseClass.PaintWorldTips(self.BaseClass)
end

function GM:CanDisplayCharacterInfo(client, id)
    print("CanDisplayCharacterInfo is deprecated. Use CanDisplayCharInfo for optimization purposes.")
    hook.Run("CanDisplayCharInfo", client, id)
end

function GM:KickedFromCharacter(id, isCurrentChar)
    print("KickedFromCharacter is deprecated. Use KickedFromChar for optimization purposes.")
    hook.Run("KickedFromChar", id, isCurrentChar)
end

function GM:CharacterListLoaded(newCharList)
    print("CharacterListLoaded is deprecated. Use CharListLoaded for optimization purposes.")
    hook.Run("CharListLoaded", newCharList)
end

function GM:CharacterListUpdated(oldCharList, newCharList)
    print("CharacterListUpdated is deprecated. Use CharListUpdated for optimization purposes.")
    hook.Run("CharListUpdated", oldCharList, newCharList)
end

function GM:CharListLoaded()
    timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
        if not IsValid(LocalPlayer()) then return end
        timer.Remove("liaWaitUntilPlayerValid")
        hook.Run("LiliaLoaded")
    end)
end

function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    lia.bar.drawAction()
    vgui.Create("liaQuick")
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    lia.bar.drawAction()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
end

function GM:HUDDrawTargetID()
    return false
end

function GM:HUDDrawPickupHistory()
    return false
end

function GM:HUDAmmoPickedUp()
    return false
end

function GM:DrawDeathNotice()
    return false
end