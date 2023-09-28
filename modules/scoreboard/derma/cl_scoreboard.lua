--------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------
local function teamGetPlayers(teamID)
    local players = {}
    for _, ply in next, player.GetAll() do
        local isDisguised = hook.Run("GetDisguised", ply)
        if isDisguised and isDisguised == teamID then
            table.insert(players, ply)
        elseif not isDisguised and ply:Team() == teamID then
            table.insert(players, ply)
        end
    end

    return players
end

--------------------------------------------------------------------------------------------------------
local function teamNumPlayers(teamID)
    return #teamGetPlayers(teamID)
end

--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    if IsValid(lia.gui.score) then
        lia.gui.score:Remove()
    end

    lia.gui.score = self
    self:SetSize(ScrW() * lia.config.sbWidth, ScrH() * lia.config.sbHeight)
    self:Center()
    self.title = self:Add("DLabel")
    self.title:SetText(GetHostName())
    self.title:SetFont("liaBigFont")
    self.title:SetContentAlignment(5)
    self.title:SetTextColor(color_white)
    self.title:SetExpensiveShadow(1, color_black)
    self.title:Dock(TOP)
    self.title:SizeToContentsY()
    self.title:SetTall(self.title:GetTall() + 16)
    self.title.Paint = function(this, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(1, 0, 1, 0)
    self.scroll.VBar:SetWide(0)
    self.layout = self.scroll:Add("DListLayout")
    self.layout:Dock(TOP)
    self.teams = {}
    self.slots = {}
    self.i = {}
    local staffCount = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsAdmin() then
            staffCount = staffCount + 1
        end
    end

    local staffList = self.layout:Add("DListLayout")
    staffList:Dock(TOP)
    staffList:SetTall(32)
    self.staffListHeader = staffList:Add("DLabel")
    self.staffListHeader:Dock(LEFT)
    self.staffListHeader:SetText("Staff Online: " .. staffCount)
    self.staffListHeader:SetTextInset(3, 0)
    self.staffListHeader:SetFont("liaMediumFont")
    self.staffListHeader:SetTextColor(color_white)
    self.staffListHeader:SetExpensiveShadow(1, color_black)
    self.staffListHeader:SetTall(28)
    self.staffListHeader:SizeToContents()
    self.staffListHeader.Paint = function(this, w, h)
        surface.SetDrawColor(50, 50, 50, 20)
        surface.DrawRect(0, 0, w, h)
    end

    for k, v in ipairs(lia.faction.indices) do
        if table.HasValue(lia.config.HiddenFactions, k) then continue end
        local color = team.GetColor(k)
        local r, g, b = color.r, color.g, color.b
        local list = self.layout:Add("DListLayout")
        list:Dock(TOP)
        list:SetTall(28)
        list.Think = function(this) end         --[[
            for _, v2 in ipairs(teamGetPlayers(k)) do
                if not IsValid(v2.liaScoreSlot) or v2.liaScoreSlot:GetParent() ~= this then
                    if IsValid(v2.liaScoreSlot) then
                        v2.liaScoreSlot:SetParent(this)
                    else
                        self:addPlayer(v2, this)
                    end
                end
            end
            ]]
        local header = list:Add("DLabel")
        header:Dock(TOP)
        header:SetText(L(v.name))
        header:SetTextInset(3, 0)
        header:SetFont("liaMediumFont")
        header:SetTextColor(color_white)
        header:SetExpensiveShadow(1, color_black)
        header:SetTall(28)
        header.Paint = function(this, w, h)
            surface.SetDrawColor(r, g, b, 20)
            surface.DrawRect(0, 0, w, h)
        end

        self.teams[k] = list
    end
end

--------------------------------------------------------------------------------------------------------
function PANEL:Think()
    if (self.nextUpdate or 0) < CurTime() then
        self.title:SetText(lia.config.sbTitle)
        local visible, amount
        for k, v in ipairs(self.teams) do
            visible, amount = v:IsVisible(), teamNumPlayers(k)
            if visible and k == FACTION_STAFF and LocalPlayer():Team() == FACTION_STAFF then
                v:SetVisible(true)
                self.layout:InvalidateLayout()
            elseif visible and k == FACTION_STAFF then
                v:SetVisible(false)
                self.layout:InvalidateLayout()
            end

            if visible and amount == 0 then
                v:SetVisible(false)
                self.layout:InvalidateLayout()
            elseif not visible and amount > 0 and k ~= FACTION_STAFF then
                v:SetVisible(true)
            end
        end

        for _, v in pairs(self.slots) do
            if IsValid(v) then
                v:update()
            end
        end

        self.nextUpdate = CurTime() + 0.1
    end
end

--------------------------------------------------------------------------------------------------------
function PANEL:OnRemove()
    CloseDermaMenus()
end

--------------------------------------------------------------------------------------------------------
function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    surface.SetDrawColor(30, 30, 30, 100)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawOutlinedRect(0, 0, w, h)
end

--------------------------------------------------------------------------------------------------------
vgui.Register("liaScoreboard", PANEL, "EditablePanel")
--------------------------------------------------------------------------------------------------------
concommand.Add(
    "dev_reloadsb",
    function()
        if IsValid(lia.gui.score) then
            lia.gui.score:Remove()
        end
    end
)
--------------------------------------------------------------------------------------------------------