local addon, ns = ...
local V = ns.V
--local V.config = ns.V.config

--[[
Zoom, InstanceDifficulty, ClassHall link, Ping, 
]]
-- shape
MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -1, 0)
MinimapCluster:EnableMouse(false)
MinimapCluster:SetClampedToScreen(false)
MinimapCluster:SetSize(138,138)

----------------------------------
-- Minimap Frame
----------------------------------
local minimapFrame = CreateFrame("FRAME","$parentMinimap", V.frames.right)
minimapFrame:SetPoint("TOP",0,-20)
minimapFrame:SetSize(V.config.frame.width, 140)
if V.config.debug then
     minimapFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     minimapFrame:SetBackdropColor(0, 0, 0, 0.2)
end

MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', 0, 0)
MinimapCluster:EnableMouse(false)
MinimapCluster:SetClampedToScreen(false)
MinimapCluster:SetSize(V.config.frame.width,140)

Minimap:SetParent(minimapFrame)
Minimap:SetSize(138, 138)
Minimap:SetMaskTexture[[Interface\ChatFrame\ChatFrameBackground]]
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT",-1,-1)

function GetMinimapShape() return 'SQUARE' end

-- click functionality
Minimap:SetScript('OnMouseUp', function(self, button)
    Minimap:StopMovingOrSizing()
    if button == 'RightButton' then
        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * .7), -3)
    elseif button == 'MiddleButton' then
        ToggleCalendar()
    else
        Minimap_OnClick(self)
    end
end)

Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, arg1)
    if arg1 > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)

--     -- WORLD STATE CAP BAR
-- hooksecurefunc('UIParent_ManageFramePositions', function()
--     if NUM_EXTENDED_UI_FRAMES then
--         for i = 1, NUM_EXTENDED_UI_FRAMES do
--             local bar = _G['WorldStateCaptureBar'..i]
--             if bar and bar:IsVisible() then
--                 bar:ClearAllPoints()
--                 if i == 1 then
--                     bar:SetPoint('TOP', MinimapCluster, 'BOTTOM', 5, -30)
--                 else
--                     bar:SetPoint('TOP', _G['WorldStateCaptureBar'..(i - 1)], 'BOTTOM', 0, -20)
--                 end
--             end
--         end
--     end
-- end)


--     -- DURABILITY
-- hooksecurefunc(DurabilityFrame, 'SetPoint', function(self, _, parent)
--     if parent == 'MinimapCluster' or parent == _G['MinimapCluster'] then
--         self:ClearAllPoints()
--         self:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -20, 10)
--         self:SetScale(.55)
--         self:SetParent(Minimap)
--     end
-- end)


--     -- VEHICLE SEAT INDICATOR
-- hooksecurefunc(VehicleSeatIndicator,'SetPoint', function(self, _, parent)
--     if parent=='MinimapCluster' or parent==_G['MinimapCluster'] then
--         self:ClearAllPoints()
--         self:SetPoint('TOP', Minimap, 'BOTTOM', -100, 50)
--         self:SetScale(.7)
--     end
-- end)

MinimapBackdrop:Hide()
MinimapBorder:Hide()
MinimapBorderTop:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MiniMapVoiceChatFrame:Hide()
GameTimeFrame:Hide()
MinimapZoneTextButton:Hide()
MiniMapTracking:Hide()
MiniMapMailBorder:Hide()
MinimapNorthTag:SetAlpha(0)
Minimap:SetArchBlobRingScalar(0)
Minimap:SetArchBlobRingAlpha(0)
Minimap:SetQuestBlobRingScalar(0)
Minimap:SetQuestBlobRingAlpha(0)

LoadAddOn('Blizzard_TimeManager')
local region = TimeManagerClockButton:GetRegions()
region:Hide()
TimeManagerClockButton:Hide()

----------------------------------
-- Location Frame
----------------------------------
-- zone text color
local function GetZoneColor()
    local zoneType = GetZonePVPInfo()
    if (zoneType == 'sanctuary') then
        return 0.4, 0.8, 0.94
    elseif (zoneType == 'arena') then
        return 1, 0.1, 0.1
    elseif (zoneType == 'friendly') then
        return 0.1, 1, 0.1
    elseif (zoneType == 'hostile') then
        return 1, 0.1, 0.1
    elseif (zoneType == 'contested') then
        return 1, 0.8, 0
    else
        return 1, 1, 1
    end
end

local locationFrame = CreateFrame("FRAME","$parentLocation", minimapFrame)
locationFrame:SetSize(V.config.frame.width,20)
locationFrame:SetPoint("TOP",0,20)

local locationText = locationFrame:CreateFontString(nil, "OVERLAY")
locationText:SetFont(V.config.text.font, 12)
locationText:SetPoint("CENTER",0,2)
locationText:SetTextColor(GetZoneColor())
if GetSubZoneText() == '' then
    locationText:SetText(GetZoneText())
else
    locationText:SetText(GetSubZoneText())
end

locationFrame:HookScript('OnUpdate', function()
    if GetSubZoneText() == '' then
        locationText:SetText(GetZoneText())
    else
        locationText:SetText(GetSubZoneText())
    end
    locationText:SetTextColor(GetZoneColor())
end)

----------------------------------
-- Mail Frame
----------------------------------
MiniMapMailIcon:Hide()

local mailFrame = CreateFrame("FRAME","$parentMail", minimapFrame)
mailFrame:SetSize(V.config.frame.width,20)
mailFrame:SetPoint("BOTTOM",0,-20)

MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetParent(mailFrame)
MiniMapMailFrame:SetSize(V.config.frame.width,20)
MiniMapMailFrame:SetFrameStrata('HIGH')
MiniMapMailFrame:SetPoint('BOTTOMRIGHT', mailFrame, 0, 0)

local mailText = mailFrame:CreateFontString(nil, "OVERLAY")
mailText:SetFont(V.config.text.font, V.config.text.normalFontSize)
mailText:SetPoint("CENTER",0,2)
mailText:SetTextColor(.6,.6,.6)
--mailText:SetText(string.format("|cffff0000new mail waiting|r"))

local ag = mailFrame:CreateAnimationGroup()
local a1 = ag:CreateAnimation("Alpha")
a1:SetChange(-0.5)
a1:SetDuration(3)
a1:SetSmoothing("OUT")

local a2 = ag:CreateAnimation("Alpha")
a2:SetChange(0.5)
a2:SetDuration(3)
a2:SetSmoothing("OUT")

----------------------------------
-- Event Frame
----------------------------------
local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("UPDATE_PENDING_MAIL")
eventframe:SetScript("OnEvent", function(self,event, ...)
    if HasNewMail() then
        mailText:SetText(string.format("|cffff0000new mail|r"))
        ag:Play()
    else
        mailText:SetText("")
        ag:Stop()
    end    
end)
