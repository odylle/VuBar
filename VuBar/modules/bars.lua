local addon, ns = ...
local V = ns.V

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
local frameheight = nil
if UnitLevel("player") == maxlevel then V.frames.bars.experience = false end
for i, bar in ipairs(V.frames.bars) do
    if bar then
        frameheight = frameheight + 20
    end
end
local barsFrame = CreateFrame("FRAME","$parentBars", V.frames.right)
barsFrame:SetPoint("TOP",0,-400)
barsFrame:SetSize(V.config.frame.width, frameheight)
if config.debug then
     barsFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     barsFrame:SetBackdropColor(0, 0, 0, 0.2)
end

----------------------------------
-- Experience Bar
----------------------------------
local experienceFrame = CreateFrame("FRAME",barsFrame)

----------------------------------
-- Artifact Bar
----------------------------------


----------------------------------
-- Reputation Bar
----------------------------------


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
end)