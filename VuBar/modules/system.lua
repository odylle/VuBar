local addon, ns = ...
local V = ns.V

----------------------------------
-- ToDo
----------------------------------
-- Parent FPS and Ping frames to System

----------------------------------
-- System Frame
----------------------------------
local systemFrame = CreateFrame("BUTTON","$parentSystem", V.frames.left)
systemFrame:SetPoint("TOP",0,-101)
systemFrame:SetSize(V.config.frame.width, 20)
systemFrame:EnableMouse(true)
systemFrame:RegisterForClicks("AnyUp")
if V.debug then
     systemFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     systemFrame:SetBackdropColor(0, 0, 0, 0.2)
end
------------------------
-- TEST LATER ----------
-- local point, relativeTo, relativePoint, xOfs, yOfs = systemFrame:GetPoint(1)
-- local AnimOffSet = GetScreenHeight() + yOfs
------------------------

-- Moving Animation [DOWN]
local ag1 = systemFrame:CreateAnimationGroup()
ag1:SetScript("onFinished", function()
    systemFrame:SetPoint("BOTTOM",0,0)
end)
local slideDown = ag1:CreateAnimation("Translation")
slideDown:SetOffset(0,-(GetScreenHeight()-81))
slideDown:SetDuration(.8)
slideDown:SetSmoothing("OUT")

-- Moving Animation [DOWN]
local ag2 = systemFrame:CreateAnimationGroup()
ag1:SetScript("onFinished", function()
    systemFrame:SetPoint("TOP",0,-101)
end)
local slideUp = ag2:CreateAnimation("Translation")
slideUp:SetOffset(0, GetScreenHeight()-81)
slideUp:SetDuration(.8)
slideUp:SetStartDelay(.4)
slideUp:SetSmoothing("OUT")


----------------------------------
-- Latency Frame
----------------------------------
local pingFrame = CreateFrame("FRAME",nil, systemFrame)

local pingText = pingFrame:CreateFontString(nil, "OVERLAY")
pingText:SetFont(V.config.text.font, V.config.text.normalFontSize)
pingText:SetTextColor(.6,.6,.6)
pingText:SetJustifyH("LEFT")
pingText:SetPoint("LEFT", systemFrame, "LEFT", 6, 0)

----------------------------------
-- FrameRate Frame
----------------------------------
local fpsFrame = CreateFrame("FRAME",nil, systemFrame)

local fpsText = fpsFrame:CreateFontString(nil, "OVERLAY")
fpsText:SetFont(V.config.text.font, V.config.text.normalFontSize)
fpsText:SetTextColor(.6,.6,.6)
fpsText:SetJustifyH("RIGHT")
fpsText:SetPoint("RIGHT", systemFrame, "RIGHT", -6, 0)

local function updatePerformanceText()
     local fps = floor(GetFramerate())
     local _, _, home, world = GetNetStats()
     pingText:SetText(home.."ms ("..world..")")
     pingFrame:SetSize(pingText:GetStringWidth()+6, 16)
     fpsText:SetText(fps.."fps")
     fpsFrame:SetSize(fpsText:GetStringWidth()+6, 16)
     --if onHover then
     --    systemBarOnEnter()
     --end
end

local elapsed = 0
systemFrame:SetScript('OnUpdate', function(self, e)
     elapsed = elapsed + e
     if elapsed >= 1 then
          updatePerformanceText()
          elapsed = 0
     end
end)


systemFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
systemFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
systemFrame:SetScript("onEvent", function(self, event, ...)
     -- When in instance, move frame to the bottom.
     if not IsResting() then
          ag1:Play()
     else
          ag2:Play()
     end
end)


