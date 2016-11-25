local addon,ns = ...
local V = ns.V

----------------------------------
-- Vehicle Frame
----------------------------------
local vehicleFrame = CreateFrame("FRAME","$parentVehicle", V.frames.left)
vehicleFrame:SetPoint("TOP",0,-203)
vehicleFrame:SetSize(V.config.frame.width, 80)
if V.config.debug then
     vehicleFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     vehicleFrame:SetBackdropColor(0, 0, 0, 0.2)
end
vehicleFrame:Hide()

vehicleFrame:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
vehicleFrame:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")