local addon, ns = ...
local V = ns.V

----------------------------------
-- System Frame
----------------------------------
local systemFrame = CreateFrame("BUTTON","$parentSystem", V.frames.left)
systemFrame:SetPoint("TOP",0,-101)
systemFrame:SetSize(V.config.frame.width, 20)
systemFrame:EnableMouse(true)
systemFrame:RegisterForClicks("AnyUp")
if V.config.debug then
     systemFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     systemFrame:SetBackdropColor(0, 0, 0, 0.2)
end

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