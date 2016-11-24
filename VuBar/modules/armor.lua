local addon, ns = ...
local V = ns.V

----------------------------------
-- Armor Frame
----------------------------------
local armorFrame = CreateFrame("FRAME","$parentArmor", V.frames.left)
armorFrame:SetPoint("TOP",0,-294)
armorFrame:SetSize(V.config.frame.width, 20)
if V.config.debug then
     armorFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     armorFrame:SetBackdropColor(0, 0, 0, 0.2)
end

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
end)