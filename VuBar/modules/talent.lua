local addon, ns = ...
local V = ns.V

----------------------------------
-- Talent Frame
----------------------------------
local talentFrame = CreateFrame("FRAME","$parentTalent", V.frames.left)
talentFrame:SetPoint("TOP",0,-294)
talentFrame:SetSize(V.config.frame.width, 20)
if V.config.debug then
     talentFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     talentFrame:SetBackdropColor(0, 0, 0, 0.2)
end
talentFrame:Hide()

local talentLText = talentFrame:CreateFontString(nil, "OVERLAY")
talentLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
talentLText:SetTextColor(.6,.6,.6)
talentLText:SetJustifyH("LEFT")
talentLText:SetPoint("LEFT", talentFrame, "LEFT", 8, 0)
talentLText:SetText("Loot Spec")

local talentRText = talentFrame:CreateFontString(nil, "OVERLAY")
talentRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
talentRText:SetJustifyH("RIGHT")
talentRText:SetPoint("RIGHT", talentFrame, "RIGHT",-6,0)
talentRText:SetText("Marksmanship")


--[[
Plan:
    Show Talent Specialisation. Highlight when different than current spec.
    Switch Spec/ Loot Spec through tooltip?
]]