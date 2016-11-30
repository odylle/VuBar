local addon, ns = ...
local V = ns.V

----------------------------------
-- Talent Frame
----------------------------------
local talentFrame = CreateFrame("FRAME","$parentTalent", V.frames.left)
talentFrame:SetPoint("TOP",0,-344)
talentFrame:SetSize(V.config.frame.width, 20)
if V.debug then
     talentFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     talentFrame:SetBackdropColor(0, 0, 0, 0.2)
end
--talentFrame:Hide()

local talentLText = talentFrame:CreateFontString(nil, "OVERLAY")
talentLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
talentLText:SetTextColor(.6,.6,.6)
talentLText:SetJustifyH("LEFT")
talentLText:SetPoint("LEFT", talentFrame, "LEFT", 8, 0)
talentLText:SetText("loot spec")

local talentRText = talentFrame:CreateFontString(nil, "OVERLAY")
talentRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
talentRText:SetJustifyH("RIGHT")
talentRText:SetPoint("RIGHT", talentFrame, "RIGHT",-6,0)
talentRText:SetText(string.lower("Marksmanship"))


talentFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
talentFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
talentFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
talentFrame:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
talentFrame:SetScript("onEvent", function(self, event, arg1, arg2, arg3, ...)
    local specID = GetLootSpecialization()
    if specID == 0 then
        local currentSpec = GetSpecialization()
        local _, currentSpecName = GetSpecializationInfo(currentSpec)
        talentRText:SetText(currentSpecName)
    else
        _, lootSpecName = GetSpecializationInfoByID(specID)
        talentRText:SetText(string.lower(lootSpecName))
    end
end)



--[[
Plan:
    Show Talent Specialisation. Highlight when different than current spec.
    Switch Spec/ Loot Spec through tooltip?
]]