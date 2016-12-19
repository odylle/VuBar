local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, Shorten, Tooltip, DebugFrame = V.EventHandler, V.EventFrame, V.Shorten, V.Tooltip, V.DebugFrame

----------------------------------
-- Blizz Api & Variables
----------------------------------
local UnitLevel = UnitLevel
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local REPUTATION, STANDING = REPUTATION, STANDING
local GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local HasArtifactEquipped = HasArtifactEquipped
local IsXPUserDisabled = IsXPUserDisabled
local C_ArtifactUIGetTotalPurchasedRanks = C_ArtifactUI.GetTotalPurchasedRanks

-- LUA Functions -----------------
local pairs = pairs

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Bars",
    description = "Display Experience, Reputation, Artifact and Honor bars",
    height = 0,
    padding = 0,
    barHeight = 14
}
-- V.frames.showHonor = true
-- if V.constants.player.level > 101 then
--     V.frames.showArtifact = true
-- end

----------------------------------
-- Functions
----------------------------------
local function SpawnStatusbar(barType, parent)
    local f = CreateFrame("BUTTON", "$parent."..barType, parent)
    f:SetSize(V.defaults.frame.width, module.barHeight)

    local bar = CreateFrame("STATUSBAR", "$parent.Bar", f)
    bar:SetStatusBarTexture(V.defaults.statusbar)
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:SetWidth(V.defaults.frame.width - 2)
    bar:SetHeight(module.barHeight-1)
    bar:SetPoint("TOP",0,0)
    bar:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    bar:SetBackdropColor(0,0,0,0)
    f.bar = bar

    -- Rested Bar
    local rBar = CreateFrame("STATUSBAR", "$parent.rBar", f)
    rBar:SetStatusBarTexture(V.defaults.statusbar)
    rBar:GetStatusBarTexture():SetHorizTile(false)
    rBar:SetWidth(V.defaults.frame.width - 2)
    rBar:SetHeight(module.barHeight-1)
    rBar:SetPoint("TOP",0,0)
    rBar:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    rBar:SetBackdropColor(0,0,0,0)
    f.rBar = rBar

    local textLeft = bar:CreateFontString(nil, "OVERLAY")
    textLeft:SetFont(V.defaults.text.font.bold, V.defaults.text.small)
    textLeft:SetTextColor(unpack(V.defaults.text.color.bright))
    textLeft:SetJustifyH("LEFT")
    textLeft:SetPoint("LEFT", bar, "LEFT", 2, 0)
    bar.textLeft = textLeft

    local textRight = bar:CreateFontString(nil, "OVERLAY")
    textRight:SetFont(V.defaults.text.font.bold, V.defaults.text.small)
    textRight:SetTextColor(unpack(V.defaults.text.color.bright))
    textRight:SetJustifyH("RIGHT")
    textRight:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
    bar.textRight = textRight
    return f
end

local function GetExperience(i)
    local experience
    local min, max = 0, UnitXPMax("player")
    local current = UnitXP("player")
    if not i then
        experience = V.frames.bars.experience
    else
        experience = V.frames.bars["bar"..i]
    end
    experience:Show()
    experience.bar:SetMinMaxValues(min,max)
    experience.bar:SetValue(current)
    experience.bar:SetStatusBarColor(0, .39, .88, 1)
    experience.bar:SetBackdropColor(0, .39, .88, .1)
    if not GetXPExhaustion() then
        experience.rBar:Hide()
    else 
        local rested = GetXPExhaustion()
        experience.rBar:SetValue(current+rested)
        experience.rBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0)
    end
    local textRight = floor(current*(100/max)) .. "%"
    experience.bar.textRight:SetText(textRight)
    V.frames.bars.experience = experience
end

local function GetReputation(i)
    local reputation
    local name, standing, min, max, value, factionID = GetWatchedFactionInfo()
    local color = FACTION_BAR_COLORS[standing]
    if not i then
        reputation = V.frames.bars.reputation
    else    
        reputation = V.frames.bars["bar"..i]
    end
    reputation:Show()
    reputation.rBar:Hide()
    reputation.bar:SetMinMaxValues(min, max)
    reputation.bar:SetValue(value)
    reputation.bar:SetStatusBarColor(color.r, color.g, color.b, .8)
    reputation.bar:SetBackdropColor(color.r, color.g, color.b, .1)
    reputation.bar.textLeft:SetText(name) 
    V.frames.bars.reputation = reputation
end

local function GetArtifactPower(i)
    local artifact
    local artifactItemID, _, _, _, totalXP, pointsSpent = GetEquippedArtifactInfo()
    local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
    local totalRanks = _G.C_ArtifactUI.GetTotalPurchasedRanks()
    if not ns.playerData["artifact"] then ns.playerData["artifact"] = {} end
    if not ns.playerData.artifact[artifactItemID] then ns.playerData.artifact[artifactItemID] = {} end
    if totalRanks ~= 0 then
        ns.playerData.artifact[artifactItemID]["level"] = totalRanks
    else 
        totalRanks = ns.playerData.artifact[artifactItemID]["level"]
    end
    if not i then
        artifact = V.frames.bars.artifact
    else
        artifact = V.frames.bars["bar"..i]
    end
    artifact:Show()
    artifact.rBar:Hide()
    artifact.bar:SetMinMaxValues(0, xpForNextPoint)
    artifact.bar:SetValue(xp)
    artifact.bar:SetStatusBarColor(.901, .8, .601, .8)
    artifact.bar:SetBackdropColor(.901, .8, .601, .1)
    artifact.bar.textLeft:SetText(totalRanks)
    artifact.bar.textRight:SetText()
    V.frames.bars.artifact = artifact
end

local function GetHonor(i)
    local honor
    local current = Shorten(UnitHonor("player"))
    local max = Shorten(UnitHonorMax("player"))
    local level = UnitHonorLevel("player")
    local levelmax = GetMaxPlayerHonorLevel()
    if not i then
        honor = V.frames.bars.honor
    else
        honor = V.frames.bars["bar"..i]
    end
    honor:Show()
    honor.rBar:Hide()
    honor.bar:SetMinMaxValues(0, max)
    honor.bar:SetValue(current)
    honor.bar:SetStatusBarColor(1, .71, 0)
    honor.bar:SetBackdropColor(1, .71, 0, .1)
    honor.bar.textLeft:SetText(level)
    honor.bar.textRight:SetText(current.."/"..max)
    V.frames.bars.honor = honor
end

local function UpdateBars(newLevel)
    local i = 1
    local name, reaction, min, max, value, factionID = GetWatchedFactionInfo();
    if ( not newLevel ) then
        newLevel = UnitLevel("player");
    end
    local showRep = name
    local artifactItemID, _, _, _, artifactTotalXP, artifactPointsSpent, _, _, _, _, _, _, artifactMaxed = C_ArtifactUI.GetEquippedArtifactInfo()
    local showArtifact = artifactItemID and not artifactMaxed --and (UnitLevel("player") >= MAX_PLAYER_LEVEL or GetCVarBool("showArtifactXPBar")) or V.frames.showArtifact
    local showXP = newLevel < MAX_PLAYER_LEVEL and not IsXPUserDisabled()
    local showHonor = newLevel >= MAX_PLAYER_LEVEL --and (IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP()) or V.frames.showHonor
    if showRep then GetReputation(i); i = i + 1; end
    if showArtifact then GetArtifactPower(i); i = i + 1; end
    if showXP then GetExperience(i); i = i + 1; end
    if showHonor then GetHonor(i); i = i + 1; end
    for count = i, 4 do
        V.frames.bars["bar"..i]:Hide()
    end
    --return bars
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.right)
baseFrame:SetParent(V.frames.right)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-200)
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------
for i = 1, 4 do
    local f = SpawnStatusbar(i, baseFrame)
    f:SetPoint("TOP",0,module.barHeight-(i*module.barHeight))
    f:Hide()
    baseFrame["bar"..i] = f
    module.height = module.height + f:GetHeight()
end

-- Recalc. baseFrame height ------
module.height = module.height+module.padding
baseFrame:SetHeight(module.height)

-- CHEAP MODULE REGISTERING ------
V.frames.bars = baseFrame
V.modules.bars = module

----------------------------------
-- Event Handling
----------------------------------
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", V.EventHandler)

function EventFrame:PLAYER_ENTERING_WORLD()
    UpdateBars()
end

function EventFrame:PLAYER_LEVEL_UP()
    newLevel = UnitLevel("player")
    UpdateBars(newLevel)
end

function EventFrame:PLAYER_XP_UPDATE()
    UpdateBars()
end

function EventFrame:UPDATE_EXHAUSTION()
    UpdateBars()
end

function EventFrame:PLAYER_UPDATE_RESTING()
    UpdateBars()
end

function EventFrame:ARTIFACT_XP_UPDATE()
    GetArtifactPower()
end
function EventFrame:UPDATE_FACTION()
    --GetReputation()
    UpdateBars()
end
function EventFrame:CHAT_MSG_COMBAT_HONOR_GAIN()
    UpdateBars()
end

function EventFrame:HONOR_XP_UPDATE()
    UpdateBars()
end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_LEVEL_UP",
    "PLAYER_XP_UPDATE",
    "UPDATE_EXHAUSTION",
    "PLAYER_UPDATE_RESTING",
    "ARTIFACT_XP_UPDATE",
    "UPDATE_FACTION",
    "HONOR_XP_UPDATE",
    "CHAT_MSG_COMBAT_HONOR_GAIN"
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end

-- Overhaul ---
-- local function CreateBars()

-- end

-- local function Update(i)
--     -- I have to get the bar ID
--     -- Experience Data
--     local function Experience(i)

--     end
--     -- Reputation Data
--     local function Reputation(i)

--     end
--     -- Artifact Data
--     local function Artifact(i)

--     end
--     -- Honor Data
--     local function Honor(i)

--     end
-- end