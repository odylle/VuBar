local addon, ns = ...
local V = ns.V

----------------------------------
-- group Frame - For Party and Raid
----------------------------------
local groupFrame = CreateFrame("FRAME","$parentGroup", V.frames.left)
groupFrame:SetPoint("TOP",0,-294)
groupFrame:SetSize(V.config.frame.width, 20)
if V.config.debug then
     groupFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     groupFrame:SetBackdropColor(0, 0, 0, 0.2)
end
groupFrame:Hide()




--[[
Plan:
    Group Health
    Group Leader
    Loot Method if not personal
    Ready Check Button
]]