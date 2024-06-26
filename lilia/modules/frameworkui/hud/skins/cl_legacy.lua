﻿local SKIN = {}
SKIN.PrintName = "Dark Derma Skin"
SKIN.GwenTexture = Material("gwenskin/GModDefault.png")
SKIN.Font = "DarkSkinRegular"
SKIN.TextColor = Color(209, 209, 209, 255)
SKIN.HighlightColor = Color(3, 127, 252, 255)
SKIN.CursorColor = Color(255, 255, 255, 255)
SKIN.AccentColor = lia.config.Color
SKIN.BackgroundColor = Color(33, 33, 33, 255)
local DownArrowNormal = GWEN.CreateTextureNormal(496, 272 + 32, 15, 15)
local DownArrowHover = GWEN.CreateTextureNormal(496, 272 + 16, 15, 15)
local DownArrowDisabled = GWEN.CreateTextureNormal(496, 272 + 48, 15, 15)
local DownArrowDown = GWEN.CreateTextureNormal(496, 272, 15, 15)
local MenuBGHover = GWEN.CreateTextureBorder(128, 256, 127, 31, 8, 8, 8, 8)
function SKIN:PaintFrame(pnl, w, h)
    if not pnl.IsDarkReady then
        pnl.lblTitle:SetFont(self.Font)
        pnl.IsDarkReady = true
    end

    surface.SetDrawColor(Color(33, 33, 33, 255))
    surface.DrawRect(1, 1, w - 2, h - 2)
    surface.SetDrawColor(pnl.AccentColor or self.AccentColor)
    surface.DrawOutlinedRect(0, 0, w, h)
    surface.DrawRect(0, 0, w, 25)
end

function SKIN:PaintWindowMaximizeButton()
end

function SKIN:PaintWindowMinimizeButton()
end

function SKIN:PaintListRow(_, width, height)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintTextEntry(pnl, w, h)
    if not pnl.IsDarkReady then
        pnl:SetTextColor(self.TextColor)
        pnl:SetHighlightColor(self.HighlightColor)
        pnl:SetCursorColor(self.CursorColor)
        pnl:SetFont(self.Font)
        pnl:ApplySchemeSettings()
        pnl.IsDarkReady = true
    end

    surface.SetDrawColor(Color(45, 45, 45, 240))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(100, 100, 100, 25))
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    surface.SetDrawColor(pnl.AccentColor or Color(35, 35, 35, 200))
    surface.DrawOutlinedRect(0, 0, w, h)
    if pnl.GetPlaceholderText and pnl.GetPlaceholderColor and pnl:GetPlaceholderText() and pnl:GetPlaceholderText():Trim() ~= "" and pnl:GetPlaceholderColor() and (not pnl:GetText() or pnl:GetText() == "") then
        local oldText = pnl:GetText()
        local str = pnl:GetPlaceholderText()
        if str:StartWith("#") then str = str:sub(2) end
        str = language.GetPhrase(str)
        pnl:SetText(str)
        pnl:DrawTextEntryText(pnl:GetPlaceholderColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())
        pnl:SetText(oldText)
        return
    end

    pnl:DrawTextEntryText(pnl:GetTextColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())
end

function SKIN:PaintMenuOption(pnl, w, h)
    if not pnl.IsDarkReady then
        pnl:SetTextColor(self.TextColor)
        pnl:SetFont(self.Font)
        pnl.IsDarkReady = true
    end

    surface.SetDrawColor(Color(35, 35, 35, 255))
    surface.DrawRect(0, 0, w, h)
    if pnl:IsHovered() then MenuBGHover(0, 0, w, h) end
end

function SKIN:PaintComboDownArrow(pnl, w, h)
    if pnl.ComboBox:GetDisabled() then return DownArrowDisabled(0, 0, w, h) end
    if pnl.ComboBox.Depressed or pnl.ComboBox:IsMenuOpen() then return DownArrowDown(0, 0, w, h) end
    if pnl.ComboBox:IsHovered() then return DownArrowHover(0, 0, w, h) end
    DownArrowNormal(0, 0, w, h)
end

function SKIN:PaintComboBox(pnl, w, h)
    if not pnl.IsDarkReady then
        pnl:SetFont(self.Font)
        pnl:SetTextColor(self.TextColor)
        pnl.IsDarkReady = true
    end

    surface.SetDrawColor(Color(45, 45, 45, 240))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(100, 100, 100, 25))
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    surface.SetDrawColor(Color(35, 35, 35, 200))
    surface.DrawOutlinedRect(0, 0, w, h)
end

function SKIN:PaintButton(pnl, w, h)
    if not pnl.IsDarkReady then
        pnl:SetFont(self.Font)
        pnl.IsDarkReady = true
    end

    surface.SetDrawColor(Color(45, 45, 45, 240))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(100, 100, 100, 25))
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    surface.SetDrawColor(Color(35, 35, 35, 200))
    surface.DrawOutlinedRect(0, 0, w, h)
    if pnl:GetDisabled() or pnl.Depressed then return pnl:SetTextColor(Color(60, 60, 60, 255)) end
    if pnl:IsHovered() then return pnl:SetTextColor(Color(255, 255, 255, 255)) end
    pnl:SetTextColor(self.TextColor)
end

derma.DefineSkin("lilia_legacy", "The legacy dark skin for the Lilia framework.", SKIN)