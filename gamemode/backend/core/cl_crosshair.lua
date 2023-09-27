-- Initialize crosshair-related variables
local aimVector
local punchAngle
local curGap = 0
local curAlpha = 0
local curIconAlpha = 0
local crossSize = 4
local crossGap = 0
local colors = {color_black}
local filter = {}
local sw, sh = ScrW(), ScrH()
local lastIcon = ""
-- Define crosshair drawing function
local function drawdot(pos, size, col)
    surface.SetDrawColor(col[2].r, col[2].g, col[2].b, col[2].a)
    surface.DrawRect(pos[1] - size / 2 + 1, pos[2] - size / 2 + 1, size - 2, size - 2)
    surface.SetDrawColor(0, 0, 0, col[2].a)
    surface.DrawOutlinedRect(pos[1] - size / 2, pos[2] - size / 2, size, size)
end

-- Define HUD drawing function
function GM:PostDrawHUD()
    local client = LocalPlayer()
    if not client:getChar() or not client:Alive() then return end
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    if entity:IsValid() then return end
    local wep = client:GetActiveWeapon()
    if wep and wep:IsValid() and wep.HUDPaint then return end
    if hook.Run("ShouldDrawCrosshair") == false or IsValid(g_ContextMenu) or (IsValid(lia.gui) and IsValid(lia.gui.character) and lia.gui.character:IsVisible()) then return end
    -- Calculate crosshair parameters
    aimVector = client:EyeAngles()
    punchAngle = client:GetViewPunchAngles()
    local ft = FrameTime()
    filter = {client}
    local vehicle = client:GetVehicle()
    if vehicle and IsValid(vehicle) then
        aimVector = aimVector + vehicle:GetAngles()
        table.insert(filter, vehicle)
    end

    local data = {
        start = client:GetShootPos(),
        endpos = client:GetShootPos() + (aimVector + punchAngle):Forward() * 65535,
        filter = filter
    }

    local trace = util.TraceLine(data)
    entity = client:GetTracedEntity()
    local distance = trace.StartPos:DistToSqr(trace.HitPos)
    local screen = trace.HitPos:ToScreen()
    crossSize = 4
    crossGap = 16
    curGap = Lerp(ft * 5, curGap, crossGap)
    colors[2] = Color(255, 255, 255, curAlpha, distance)
    local icon, adx, ady = hook.Run("GetCrosshairIcon", curAlpha, entity, wep, distance)
    local cx, cy = sw / 2, sh / 2
    if client:ShouldDrawLocalPlayer() then
        cx, cy = screen.x, screen.y
    end

    if icon then
        if icon ~= lastIcon then
            lastIcon = icon
        end

        curIconAlpha = Lerp(ft * 10, curIconAlpha, 255)
        curAlpha = Lerp(ft * 30, curAlpha, 0)
    else
        local showCross = not client.isWepRaised or client:isWepRaised()
        curIconAlpha = Lerp(ft * 30, curIconAlpha, 0)
        curAlpha = Lerp(ft * 10, curAlpha, showCross and 150 or 0)
    end

    curAlpha = hook.Run("GetCrosshairAlpha", curAlpha, entity) or curAlpha
    if curAlpha > 1 then
        drawdot({math.Round(cx), math.Round(cy)}, crossSize, colors)
        drawdot({math.Round(cx + curGap), math.Round(cy)}, crossSize, colors)
        drawdot({math.Round(cx - curGap), math.Round(cy)}, crossSize, colors)
        drawdot({math.Round(cx), math.Round(cy + curGap * 0.8)}, crossSize, colors)
        drawdot({math.Round(cx), math.Round(cy - curGap * 0.8)}, crossSize, colors)
    end

    if lastIcon then
        lia.util.drawText(lastIcon or "", cx + (adx or 0), cy + (ady or 0), ColorAlpha(color_white, curIconAlpha), 1, 1, "liaCrossIcons")
    end
end

-- Define crosshair icon retrieval function
function GM:GetCrosshairIcon(_, entity, weapon, distance)
    local client = LocalPlayer()
    local wep = client:GetActiveWeapon()
    if table.Count(lia.menu.list) > 0 then return "", 0, ScreenScale(5) end
    if IsValid(wep) and wep:GetNW2Bool("holdingObject", false) == true then return "" end
    if IsValid(entity) and distance < 16384 and not entity:IsPlayer() and not entity:IsNPC() then
        local entClass = entity:GetClass()
        if not table.HasValue(lia.xhair.entIgnore, entClass) then
            if entClass == "class C_BaseEntity" then return "" end
            if lia.xhair.entIcon[entClass] then return lia.xhair.entIcon[entClass] end
            if IsValid(wep) then
                local wepClass = wep:GetClass()
                if entity.isDoor and entity:isDoor() then
                    if wepClass == "lia_keys" then
                        local owner = entity.GetDTEntity(entity, 0)
                        local hey = entity:checkDoorAccess(wep.Owner)
                        if owner == LocalPlayer() or hey then return "" end
                    end

                    return ""
                end

                if wepClass == "lia_hands" then return "" end
            end
        end
    end
end