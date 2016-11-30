local addon, ns = ...
local V = ns.V

----------------------------------
-- Armor Frame
----------------------------------
local armorFrame = CreateFrame("FRAME","$parentArmor", V.frames.left)
armorFrame:SetPoint("TOP",0,-290)
armorFrame:SetSize(V.config.frame.width, 20)
if V.config.debug then
     armorFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     armorFrame:SetBackdropColor(0, 0, 0, 0.2)
end
-- Start Animations
local point, relativeTo, relativePoint, xOfs, yOfs = systemFrame:GetPoint(1)
local AnimOffSet = GetScreenHeight() + yOfs
-- Down
local ag1 = armorFrame:CreateAnimationGroup()
ag1:SetScript("onFinished", function() 
	armorFrame:ClearAllPoints()
	armorFrame:SetPoint("BOTTOM", 0, 40)
end)
local slideDown = ag1:CreateAnimation("Translation")
slideDown:SetOffset(0,- (AnimOffSet-40))
slideDown:SetDuration(.6)
slideDown:SetSmoothing("OUT")
-- Up
local ag2 = armorFrame:CreateAnimationGroup()
ag2:SetScript("onFinished", function() 
	armorFrame:ClearAllPoints()
	armorFrame:SetPoint("TOP",0,-290)
end)
local slideUp = ag2:CreateAnimation("Translation")
slideUp:SetOffset(0, AnimOffSet-40)
slideUp:SetDuration(.6)
slideUp:SetSmoothing("OUT")
-- End Animations

local armorLText = armorFrame:CreateFontString(nil, "OVERLAY")
armorLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
armorLText:SetTextColor(.6,.6,.6)
armorLText:SetJustifyH("LEFT")
armorLText:SetPoint("LEFT", armorFrame, "LEFT", 8, 0)

local armorRText = armorFrame:CreateFontString(nil, "OVERLAY")
armorRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
armorRText:SetJustifyH("RIGHT")
armorRText:SetPoint("RIGHT", armorFrame, "RIGHT",-6,0)
--armorText:SetText("100%")

----------------------------------
-- Events Frame
----------------------------------
local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
eventframe:SetScript("OnEvent", function(self,event, ...)
	local durMin, durCol
		durMin, durCol = 100, "ffffff"
		for i = 1, 18 do
			local durCur, durMax = GetInventoryItemDurability(i)
			if ( durCur ~= durMax ) then durMin = min(durMin, durCur*(100/durMax)) end
		end

	if durMin >= 75 then 
		local overallilvl, equippedilvl = GetAverageItemLevel()
		armorLText:SetText("ilevel")
		armorRText:SetText(floor(equippedilvl))
	else
		if durMin >= 40 then
			durMin = string.format("|cffee4000%d|r", floor(durMin))
			armorLText:SetText(string.format("|cffee4000durability|r"))
			armorRText:SetText(durMin)
		else
			durMin = string.format("|cffff0000%d|r", floor(durMin))
			armorLText:SetText(string.format("|cffff0000durability|r"))
			armorRText:SetText(durMin)
		end
	end
	-- Movement Controls
	if not IsResting then
		ag1:Play()
	else
		ag2:Play()
	end
end)