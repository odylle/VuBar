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
local HasNewMail = HasNewMail
local GetSubZoneText = GetSubZoneText
local GetZoneText = GetZoneText

-- LUA Functions -----------------


----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Minimap",
    side = "right",
    description = "Shows Minimap and more nifty little features.",
    height = 160,
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
local function QueueOnLoad(self)
--For everything
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("GROUP_ROSTER_UPDATE");

    --For LFG
    self:RegisterEvent("LFG_UPDATE");
    self:RegisterEvent("LFG_ROLE_CHECK_UPDATE");
    self:RegisterEvent("LFG_READY_CHECK_UPDATE");
    self:RegisterEvent("LFG_PROPOSAL_UPDATE");
    self:RegisterEvent("LFG_PROPOSAL_FAILED");
    self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
    self:RegisterEvent("LFG_PROPOSAL_SHOW");
    self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");

    --For LFGList
    self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
    self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
    self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
    self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED");

    --For PvP Role Checks
    self:RegisterEvent("PVP_ROLE_CHECK_UPDATED");

    --For PvP
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");

    --For World PvP stuff
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    self:RegisterEvent("ZONE_CHANGED");
    self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE");
    self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_STATUS_UPDATE");
    self:RegisterEvent("BATTLEFIELD_MGR_EJECT_PENDING");
    self:RegisterEvent("BATTLEFIELD_MGR_EJECTED");
    self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE");
    self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE");
    self:RegisterEvent("BATTLEFIELD_MGR_ENTERED");

    --For Pet Battles
    self:RegisterEvent("PET_BATTLE_QUEUE_STATUS");
end

local function QueueOnEvent(self)
    -- PLugin to Blizz system for the eye.
    if QueueStatusMinimapButton:IsShown() then
        self.queueFrame:SetBackdropColor(0,0,0,.3)
        self.queueText:SetText("queued")
    else
        self.queueFrame:SetBackdropColor(0,0,0,0)
        self.queueText:SetText("")
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
minimapFrame:SetSize(V.defaults.frame.width, V.defaults.frame.width)
minimapFrame:SetPoint("TOP")
minimapFrame:SetFrameStrata("BACKGROUND")

-- Define Minimap Shape:
MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint('TOP', minimapFrame, 'TOP', 1, -1)
MinimapCluster:EnableMouse(false)
MinimapCluster:SetClampedToScreen(false)
MinimapCluster:SetSize(V.defaults.frame.width-2,V.defaults.frame.width-2)

Minimap:SetParent(minimapFrame)
Minimap:SetSize(V.defaults.frame.width-2, V.defaults.frame.width-2)
Minimap:SetMaskTexture[[Interface\ChatFrame\ChatFrameBackground]]
Minimap:ClearAllPoints()
Minimap:SetPoint("TOP")
Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, arg1)
    if arg1 > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)
function GetMinimapShape() return 'SQUARE' end

HideStuff()

-- QueueStatus (LFG Eye) ---------

local queueFrame = CreateFrame("BUTTON", "$parent.Queue", minimapFrame)
queueFrame:SetSize(V.defaults.frame.width-2, 20)
queueFrame:SetPoint("BOTTOM", minimapFrame, "BOTTOM", 0, 0)
queueFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
queueFrame:SetBackdropColor(0, 0, 0, 0.3)
queueFrame:SetScript("OnLoad", QueueOnLoad)
queueFrame:SetScript("OnEvent", QueueOnEvent)
V.frames.queueFrame = queueFrame

local queueText = queueFrame:CreateFontString(nil, "OVERLAY")
queueText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
queueText:SetPoint("CENTER")
queueText:SetTextColor(unpack(V.defaults.text.color.bright))
queueText:SetText("Queued")
V.frames.queueText = queueText

--QueueStatusMinimapButton:SetParent(queueFrame)
--QueueStatusMinimapButton:SetFrameLevel(QueueStatusMinimapButton:GetFrameLevel()+1)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetParent(queueFrame)
QueueStatusMinimapButton:SetSize(V.defaults.frame.width,20)
QueueStatusMinimapButton:SetFrameStrata('HIGH')
QueueStatusMinimapButton:SetPoint('BOTTOMRIGHT', queueFrame, 0, 0)
QueueStatusMinimapButton:DisableDrawLayer("OVERLAY")
QueueStatusMinimapButtonIcon:Hide()
QueueStatusMinimapButton.Highlight:Hide()

-- f = V.DebugTable()
-- local children = { QueueStatusMinimapButton:GetChildren() }
-- local stuff = ""
-- for _, child in pairs(children) do
--     local cname = child:GetName()
--     stuff = stuff .. cname .. "\r\n"
-- end
-- f.t:SetText(stuff)

-- Location Text -----------------
local locationFrame = CreateFrame("FRAME","$parent.Location", minimapFrame)
locationFrame:SetSize(V.defaults.frame.width,20)
locationFrame:SetPoint("TOP",0,20)

local locationText = locationFrame:CreateFontString(nil, "OVERLAY")
locationText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
locationText:SetPoint("BOTTOM",0,2)
locationText:SetTextColor(GetZoneColor())
baseFrame.locationText = locationText

locationFrame:HookScript('OnUpdate', function()
    if GetSubZoneText() == '' then
        locationText:SetText(GetZoneText())
    else
        locationText:SetText(GetSubZoneText())
    end
    locationText:SetTextColor(GetZoneColor())
end)

-- Mail Notification -------------
MiniMapMailIcon:Hide()

local mailFrame = CreateFrame("FRAME","$parent.Mail", minimapFrame)
mailFrame:SetSize(V.defaults.frame.width,20)
mailFrame:SetPoint("BOTTOM",0,-20)

MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetParent(mailFrame)
MiniMapMailFrame:SetSize(V.defaults.frame.width,20)
MiniMapMailFrame:SetFrameStrata('HIGH')
MiniMapMailFrame:SetPoint('BOTTOMRIGHT', mailFrame, 0, 0)

local mailText = mailFrame:CreateFontString(nil, "OVERLAY")
mailText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
mailText:SetPoint("CENTER",0,2)
mailText:SetTextColor(.6,.6,.6)
baseFrame.mailText = mailText

local ag = mailFrame:CreateAnimationGroup()
local a1 = ag:CreateAnimation("Alpha")
a1:SetChildKey("Glow")
a1:SetOrder(1)
a1:SetFromAlpha(0)
a1:SetToAlpha(1)
a1:SetDuration(0.6)

local a2 = ag:CreateAnimation("Alpha")
a2:SetChildKey("Glow")
a2:SetOrder(2)
a2:SetFromAlpha(1)
a2:SetToAlpha(0)
a2:SetDuration(0.6)
mailFrame.ag = ag
baseFrame.mailFrame = mailFrame


-- Class Hall 
GarrisonLandingPageMinimapButton:SetFrameLevel(GarrisonLandingPageMinimapButton:GetFrameLevel()+1)

-- CHEAP MODULE REGISTERING ------
V.frames.minimap = baseFrame
V.modules.minimap = module

----------------------------------
-- Event Handling
----------------------------------
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", V.EventHandler)

function EventFrame:PLAYER_ENTERING_WORLD()
    if GetSubZoneText() == '' then
        V.frames.minimap.locationText:SetText(GetZoneText())
    else
        V.frames.minimap.locationText:SetText(GetSubZoneText())
    end    

    if HasNewMail() then
        V.frames.minimap.mailText:SetText(string.format("|cffff0000new mail|r"))
        V.frames.minimap.mailFrame.ag:Play()
        V.frames.minimap.mailFrame.ag:SetLooping("REPEAT")
    else
        V.frames.minimap.mailText:SetText("")
        V.frames.minimap.mailFrame.ag:Stop()
    end
end

function EventFrame:UPDATE_PENDING_MAIL()
    if HasNewMail() then
        V.frames.minimap.mailText:SetText(string.format("|cffff0000new mail|r"))
        V.frames.minimap.mailFrame.ag:Play()
        V.frames.minimap.mailFrame.ag:SetLooping("REPEAT")        
    else
        V.frames.minimap.mailText:SetText("")
        V.frames.minimap.mailFrame.ag:Stop()
    end
end

function EventFrame:MAIL_CLOSED()
    if HasNewMail() then
        V.frames.minimap.mailText:SetText(string.format("|cffff0000new mail|r"))
        if not V.frames.minimap.mailFrame.ag:IsPlaying() then
            V.frames.minimap.mailFrame.ag:Play()
            V.frames.minimap.mailFrame.ag:SetLooping("REPEAT")
        end     
    else
        V.frames.minimap.mailText:SetText(" ")
        V.frames.minimap.mailFrame.ag:Stop()
    end
end


-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "UPDATE_PENDING_MAIL",
    "MAIL_CLOSED",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
