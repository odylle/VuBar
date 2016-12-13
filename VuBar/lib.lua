local addon, ns = ...
----------------------------------
-- Globals
----------------------------------
local V = ns.V
local EventHandler = V.EventHandler
local EventFrame = V.EventFrame

-- LUA Functions -----------------
local _G = _G
local pairs = pairs

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]
----------------------------------
-- Support Functions
----------------------------------

-- Readable Values ---------------
local function Shorten(value)
    local mult = 10^1
    if value > 1000000 then
        value = floor((value/1000000) * mult + 0.5) / mult
        value = value .. "m"
    elseif value > 1000 then
        value = floor((value/1000) * mult + 0.5) / mult
        value = value .. "k"
    end
    return value
end
V.Shorten = Shorten

-- Find Anchoring Point ----------
local function FindAnchor(side)
    local anchor = 0
    for k, m in pairs(V.modules) do
        anchor = anchor + V.modules.k.height
    end
    return anchor
end
V.FindAnchor = FindAnchor


-- Show Frame Background ---------
local function DebugFrame(f)
    f:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    f:SetBackdropColor(0, 0, 0, 0.2)
    return f
end
V.DebugFrame = DebugFrame

-- Tooltip -----------------------
local function Tooltip(self)
    local tt = CreateFrame("GameTooltip", "vTooltip", UIParent, GameTooltipTemplate)
    tt.GameTooltipHeaderText:SetFont(V.defaults.text.font.main, 12)
    -- GameTooltipText:SetFont(V.defaults.text.font.main, 11)
    -- GameTooltipTextSmall:SetFont(V.defaults.text.font.main, 9)
    return tt
end
V.Tooltip = Tooltip