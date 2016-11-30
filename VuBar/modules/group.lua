local addon, ns = ...
local V = ns.V

local format = format
----------------------------------
-- group Frame - For Party and Raid
----------------------------------
local groupFrame = CreateFrame("FRAME","$parentGroup", V.frames.left)
groupFrame:SetPoint("TOP",0,-374)
groupFrame:SetSize(V.config.frame.width, 60)
if V.config.debug then
     groupFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     groupFrame:SetBackdropColor(0, 0, 0, 0.2)
end

local leaderFrame = CreateFrame("FRAME", "$parentLeader", groupFrame)
leaderFrame:SetSize(V.config.frame.width, 20)
leaderFrame:SetPoint("TOP", 0, 0)

local leaderLText = leaderFrame:CreateFontString(nil, "OVERLAY")
leaderLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
leaderLText:SetTextColor(.6,.6,.6)
leaderLText:SetJustifyH("LEFT")
leaderLText:SetPoint("LEFT", leaderFrame, "LEFT", 8, 0)
leaderLText:SetText("leader")

local leaderRText = leaderFrame:CreateFontString(nil, "OVERLAY")
leaderRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
leaderRText:SetJustifyH("RIGHT")
leaderRText:SetPoint("RIGHT", leaderFrame, "RIGHT",-6,0)
leaderRText:SetText("Odylle")


local lootTypeFrame = CreateFrame("FRAME", "$parentlootType", groupFrame)
lootTypeFrame:SetSize(V.config.frame.width, 20)
lootTypeFrame:SetPoint("TOP", 0, -20)

local lootTypeLText = lootTypeFrame:CreateFontString(nil, "OVERLAY")
lootTypeLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
lootTypeLText:SetTextColor(.6,.6,.6)
lootTypeLText:SetJustifyH("LEFT")
lootTypeLText:SetPoint("LEFT", lootTypeFrame, "LEFT", 8, 0)
lootTypeLText:SetText("loot")

local lootTypeRText = lootTypeFrame:CreateFontString(nil, "OVERLAY")
lootTypeRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
lootTypeRText:SetJustifyH("RIGHT")
lootTypeRText:SetPoint("RIGHT", lootTypeFrame, "RIGHT",-6,0)
lootTypeRText:SetText("personal")

-- lootTypeFrame:RegisterEvent()
-- lootTypeFrame:SetScript("onEvent", function(self, event, arg1, arg2, arg3, ...)

-- end)
local roles = {
    TANK = [[|TInterface\AddOns\Vubar\media\tank.tga:15:15:0:0:64:64:2:56:2:56|t]],
    HEALER = [[|TInterface\AddOns\Vubar\media\healer.tga:15:15:0:0:64:64:2:56:2:56|t]],
    DAMAGER = [[|TInterface\AddOns\Vubar\media\dps.tga:15:15|t]]
}
local groupHealthFrame = CreateFrame("FRAME", "$parentghealth", groupFrame)
groupHealthFrame:SetSize(V.config.frame.width, 20)
groupHealthFrame:SetPoint("TOP", 0, -40)

local groupHealthLText = groupHealthFrame:CreateFontString(nil, "OVERLAY")
groupHealthLText:SetWidth(80)
groupHealthLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
groupHealthLText:SetTextColor(.6,.6,.6)
groupHealthLText:SetJustifyH("RIGHT")
groupHealthLText:SetPoint("LEFT", groupHealthFrame, "LEFT", -4, 0)
groupHealthLText:SetText(format("2/2 %s", roles.TANK))

local groupHealthRText = groupHealthFrame:CreateFontString(nil, "OVERLAY")
groupHealthRText:SetWidth(80)
groupHealthRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
groupHealthRText:SetJustifyH("LEFT")
groupHealthRText:SetPoint("RIGHT", groupHealthFrame, "RIGHT",4,0)
groupHealthRText:SetText(format("%s 4/4", roles.HEALER))

-- local ghealthText = ghealthFrame:CreateFontString(nil, "OVERLAY")
-- ghealthText:SetFont(V.config.text.font, V.config.text.normalFontSize)
-- ghealthText:SetTextColor(.9,.9,.9)
-- ghealthText:SetJustifyH("CENTER")
-- ghealthText:SetPoint("CENTER", ghealthFrame, "CENTER", 0, 0)
--ghealthText:SetText("loot")


-- local health = format("%s 2/2 %s 4/4 %s 12/12", roles.TANK, roles.HEALER, roles.DAMAGER)
-- ghealthText:SetText(health)


--groupFrame:Hide()




--[[
Plan:
    Group Health
    Group Leader
    Loot Method if not personal
    Ready Check Button
]]