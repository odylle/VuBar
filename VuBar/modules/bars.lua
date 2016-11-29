local addon, ns = ...
local V = ns.V
local readableNumbers = V.readableNumbers

local pairs = pairs

local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local REPUTATION, STANDING = REPUTATION, STANDING
local C_ArtifactUIGetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local HasArtifactEquipped = HasArtifactEquipped

----------------------------------
-- Configuration
----------------------------------
V.frames.bars = {
     experience = true,
     reputation = true,
     artifact = true,
     honor = true,
}
local maxlevel = 110 -- Preparing for future expansions! :o

--[[
Plan:
    Frame Height based on bars active
    Tooltip Reputation: Show current expansion rep status + tracked
]]

----------------------------------
-- Bars Frame
----------------------------------
local bars = V.frames.bars
local frameheight = 0
if UnitLevel("player") == maxlevel then V.frames.bars.experience = false end
for i, bar in pairs(bars) do
    if bar == bars.experience then
        print("Gevonden")
    end
    if bar then
        frameheight = frameheight + 20
    end
end
local barsFrame = CreateFrame("FRAME","$parentBars", V.frames.right)
barsFrame:SetPoint("TOP",0,-210)
barsFrame:SetSize(V.config.frame.width, frameheight)
if V.config.debug then
     barsFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     barsFrame:SetBackdropColor(0, 0, 0, 0.2)
end

----------------------------------
-- Experience Bar
----------------------------------
local experienceFrame = CreateFrame("FRAME", "$parentXP", barsFrame)
experienceFrame:SetPoint("TOP",0,-11)
experienceFrame:SetSize(V.config.frame.width-2, 9)
experienceFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
experienceFrame:SetBackdropColor(0, 0, 0, 0.3)

local experienceBar = CreateFrame("STATUSBAR", "$parentBar", experienceFrame)
experienceBar:SetSize(V.config.frame.width-4, 7)
experienceBar:SetPoint("CENTER", 0, 0)
experienceBar:SetFrameStrata("BACKGROUND")
experienceBar:SetStatusBarTexture(V.config.media.path..V.config.media.statusbar)
experienceBar:SetStatusBarColor(0, 0.4, 1, .8)

local experienceRBar = CreateFrame("STATUSBAR", "$parentRBar", experienceFrame)
experienceRBar:SetSize(V.config.frame.width-4, 7)
experienceRBar:SetPoint("CENTER", 0, 0)
experienceRBar:SetFrameStrata("BACKGROUND")
experienceRBar:SetStatusBarTexture(V.config.media.path..V.config.media.statusbar)
experienceRBar:SetStatusBarColor(1, 0, 1, .4)
experienceRBar:SetMinMaxValues(0, UnitXPMax("player"))

local experienceRText = experienceBar:CreateFontString(nil, "OVERLAY")
experienceRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
experienceRText:SetTextColor(.9,.9,.9)
experienceRText:SetJustifyH("RIGHT")
experienceRText:SetPoint("RIGHT", experienceFrame, "RIGHT", -6, 10)
--experienceRText:SetText("9%")

experienceFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
experienceFrame:RegisterEvent('PLAYER_XP_UPDATE')
experienceFrame:RegisterEvent("DISABLE_XP_GAIN")
experienceFrame:RegisterEvent("ENABLE_XP_GAIN")
experienceFrame:RegisterEvent('UPDATE_EXHAUSTION')
experienceFrame:SetScript("OnEvent", function()
    experienceBar:SetMinMaxValues(0, UnitXPMax("player"))
    experienceBar:SetValue(UnitXP("player"))
    experienceRBar:SetValue(UnitXP("player")+GetXPExhaustion())
    experienceRText:SetText(readableNumbers(UnitXPMax("player")-UnitXP("player")))
    if not GetXPExhaustion() then
        experienceRBar:Hide()
    end
end)

----------------------------------
-- Reputation Bar
----------------------------------
local reputationFrame = CreateFrame("FRAME", "$parentXP", barsFrame)
reputationFrame:SetPoint("TOP",0,-31)
reputationFrame:SetSize(V.config.frame.width-2, 9)
reputationFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
reputationFrame:SetBackdropColor(0, 0, 0, 0.3)

local reputationBar = CreateFrame("STATUSBAR", "$parentBar", reputationFrame)
reputationBar:SetSize(V.config.frame.width-4, 7)
reputationBar:SetPoint("CENTER", 0, 3)
reputationBar:SetFrameStrata("BACKGROUND")
reputationBar:SetStatusBarTexture(V.config.media.path..V.config.media.statusbar)

local reputationLText = reputationBar:CreateFontString(nil, "OVERLAY")
reputationLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
reputationLText:SetTextColor(.9,.9,.9)
reputationLText:SetJustifyH("LEFT")
reputationLText:SetPoint("LEFT", reputationFrame, "LEFT", 6, 0)

local reputationRText = reputationBar:CreateFontString(nil, "OVERLAY")
reputationRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
reputationRText:SetTextColor(.9,.9,.9)
reputationRText:SetJustifyH("RIGHT")
reputationRText:SetPoint("RIGHT", reputationFrame, "RIGHT", -6, 10)

reputationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
reputationFrame:RegisterEvent("UPDATE_FACTION")
reputationFrame:SetScript("OnEvent", function (self, event, arg)
    local name, standing, min, max, value, factionID = GetWatchedFactionInfo()
    local color = FACTION_BAR_COLORS[standing]
    reputationBar:SetMinMaxValues(min, max)
    reputationBar:SetValue(value)
    reputationBar:SetStatusBarColor(color.r, color.g, color.b, .8)
    reputationRText:SetText(readableNumbers(max-value))
end)

----------------------------------
-- Artifact Bar
----------------------------------
local artifactFrame = CreateFrame("FRAME", "$parentXP", barsFrame)
artifactFrame:SetPoint("TOP",0,-40)
artifactFrame:SetSize(V.config.frame.width-2, 10)
artifactFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
artifactFrame:SetBackdropColor(0, 0, 0, 0.3)

local artifactBar = CreateFrame("STATUSBAR", "$parentBar", artifactFrame)
artifactBar:SetSize(V.config.frame.width-4, 8)
artifactBar:SetPoint("CENTER", 0, 0)
artifactBar:SetFrameStrata("BACKGROUND")
artifactBar:SetStatusBarTexture(V.config.media.path..V.config.media.statusbar)

local artifactLText = artifactBar:CreateFontString(nil, "OVERLAY")
artifactLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
artifactLText:SetTextColor(.9,.9,.9)
artifactLText:SetJustifyH("LEFT")
artifactLText:SetPoint("LEFT", artifactFrame, "LEFT", 6, 0)

local artifactRText = artifactBar:CreateFontString(nil, "OVERLAY")
artifactRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
artifactRText:SetTextColor(.9,.9,.9)
artifactRText:SetJustifyH("RIGHT")
artifactRText:SetPoint("RIGHT", artifactFrame, "RIGHT", -6, 0)

artifactFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
artifactFrame:RegisterEvent('ARTIFACT_XP_UPDATE')
artifactFrame:SetScript("OnEvent", function (self, event, arg)
    local _, _, _, _, totalXP, pointsSpent = C_ArtifactUIGetEquippedArtifactInfo()
    local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
    artifactBar:SetMinMaxValues(0, xpForNextPoint)
    artifactBar:SetValue(xp)
    artifactBar:SetStatusBarColor(.901, .8, .601, .8)
    --artifactRText:SetText(readableNumbers(xp))
end)

----------------------------------
-- Honor Bar
----------------------------------


----------------------------------
-- Events Frame
----------------------------------
local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("PLAYER_LEVEL_UP")
eventframe:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4, ...)
    if event == "PLAYER_LEVEL_UP" and arg1 == maxlevel then
        experienceFrame:Hide()
    end
    if not GetWatchedFactionInfo() then
        reputationFrame:Hide()
    end
end)