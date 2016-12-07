local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame

----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetMinimapShape = GetMinimapShape
local Minimap_ZoomIn = Minimap_ZoomIn 
local Minimap_ZoomOut = Minimap_ZoomOut

-- LUA Functions -----------------


----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Minimap",
    side = "right",
    description = "Shows Minimap and more nifty little features.",
    height = 0,
}

----------------------------------
-- Functions
----------------------------------
local function HideStuff()
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
end

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

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("BUTTON","$parent."..module.name, V.frames.right)
baseFrame:SetParent(V.frames.right)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-20)
baseFrame:SetSize(V.defaults.frame.width, module.height)
-- baseFrame:EnableMouse(true)
-- baseFrame:RegisterForClicks("AnyUp")
-- baseFrame:SetScript('OnUpdate', OnUpdate)
-- baseFrame:SetScript("OnEnter", OnEnter) 
-- baseFrame:SetScript("OnLeave", OnLeave)
-- baseFrame:SetScript("OnClick", OnClick)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- Minimap -----------------------
local minimapFrame = CreateFrame("FRAME", "$parent.Minimap", baseFrame)
minimapFrame:SetSize(V.defaults.frame.width-2, V.defaults.frame.width-2)
minimapFrame:SetPoint("TOP", 1, -1)

-- Define Minimap Shape:
MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint('TOP', minimapFrame, 'TOP', 1, -1)
MinimapCluster:EnableMouse(false)
MinimapCluster:SetClampedToScreen(false)
MinimapCluster:SetSize(V.defaults.frame.width-2,V.defaults.frame.width-2)
function GetMinimapShape() return 'SQUARE' end

Minimap:SetParent(minimapFrame)
Minimap:SetSize(V.defaults.frame.width-2, V.defaults.frame.width-2)
Minimap:SetMaskTexture[[Interface\ChatFrame\ChatFrameBackground]]
Minimap:ClearAllPoints()
Minimap:SetPoint("TOP", 1, -1)
Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, arg1)
    if arg1 > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)
HideStuff()

-- CHEAP MODULE REGISTERING ------
V.frames.minimap = baseFrame
V.modules.minimap = module

----------------------------------
-- Event Handling
----------------------------------

-- EVENTS ------------------------
local events = {
    --"PLAYER_ENTERING_WORLD",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
