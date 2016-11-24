local addon, ns = ...
local V = ns.V

--[[
Frame movement would be awesome. This is to test to see if i can move frames on Event.
I've created 2 animation groups, 1 for sliding in, 1 for sliding back. Initially just on screen, but I would like them to slide inside the ui.
Example of its planned usage:
Automatic swap of content in left frame if you are in an instance.

Question: Can frames be offscreen?
]]

----------------------------------
-- Movement Test Frame
----------------------------------

local moveFrame = CreateFrame("BUTTON","$parentmove", V.frames.left)
moveFrame:SetPoint("BOTTOM",0,100)
moveFrame:SetSize(V.config.frame.width, 20)
if V.config.debug then
    moveFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    moveFrame:SetBackdropColor(0, 0, 0, 0.2)
end

local ag1 = moveFrame:CreateAnimationGroup()
local moveout = ag1:CreateAnimation("Translation")
moveout:SetOffSet(V.config.frames.width,0)
moveout:SetDuration(3)
moveout:SetSmoothing("OUT")

local ag2 = moveFrame:CreateAnimationGroup()
local movein = ag2:CreateAnimation("Translation")
movein:SetOffSet(0,0)
movein:SetDuration(3)
movein:SetSmoothing("OUT")


----------------------------------
-- The Event Trigger
----------------------------------
local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_UPDATE_RESTING")
eventframe:SetScript("onEvent", function(self,event, ...) 
    if IsResting() then
        if ag2:IsPlaying() then
            delay = 3 - ag2:GetElapsed()
            ag1:SetStartDelay(delay)
        end
        ag1:Play()
    else
        if ag1:IsPlaying() then
            delay = 3 - ag1:GetElapsed()
            ag2:SetStartDelay(delay)
        end
        ag2:Play()
    end

end)
