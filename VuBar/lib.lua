local addon, ns = ...
----------------------------------
-- Globals
----------------------------------
local V = ns.V
local EventHandler = V.EventHandler
local EventFrame = V.EventFrame

----------------------------------
-- Support Functions
----------------------------------
local function Shorten(value)
    local mult = 10^1
    if value > 10000000 then
        value = floor((value/1000000) * mult + 0.5) / mult
        value = value .. "m"
    elseif value > 1000 then
        value = floor((value/1000) * mult + 0.5) / mult
        value = value .. "k"
    end
    return value
end
V.shorten = shorten

local function DebugFrame(frame)
    frame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    frame:SetBackdropColor(0, 0, 0, 0.2)
    return frame
end