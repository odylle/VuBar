local addon, ns = ...
----------------------------------
-- Globals
----------------------------------
local V = ns.V
local EventHandler = V.EventHandler
local EventFrame = V.EventFrame

-- Class Color when only className is available in localised string
local LOCAL_CLASS_COLORS = {
    ["Hunter"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
    ["Warlock"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788ee" },
    ["Priest"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
    ["Paladin"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
    ["Mage"] = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3fc7eb" },
    ["Rogue"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
    ["Druid"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
    ["Shaman"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
    ["Warrior"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
    ["Death Knight"] = { r = 0.77, g = 0.12 , b = 0.23, colorStr = "ffc41f3b" },
    ["Monk"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "ff00ff96" },
    ["Demon Hunter"] = { r = 0.64, g = 0.19, b = 0.79, colorStr = "ffa330c9" },
}
local function LocalClassColor(class)
    local color = LOCAL_CLASS_COLORS[class]
    if color then
        return color.r, color.g, color.b, color.colorStr
    end

    return 1, 1, 1, "ffffffff"
end
V.LocalClassColor = LocalClassColor

-- LUA Functions -----------------
local _G = _G
local pairs = pairs

--local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]
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

local function DebugTable()
    local f = CreateFrame("FRAME", "$parent.Minimap", UIParent)
    f:SetSize(200, 400)
    f:SetPoint("TOP")
    f:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    f:SetBackdropColor(0, 0, 0, 0.6)

    local t = f:CreateFontString(nil, "OVERLAY")
    t:SetPoint("CENTER")
    t:SetHeight(400)
    t:SetFont(V.defaults.text.font.main, V.defaults.text.small)
    t:SetTextColor(unpack(V.defaults.text.color.bright))
    t:SetAllPoints()
    f.t = t
    return f        
end
V.DebugTable = DebugTable

-- Tooltip -----------------------
local function Tooltip(self)
    local tt = CreateFrame("GameTooltip", "vTooltip", self, "GameTooltipTemplate")
    tt:SetScale(1*UIParent:GetScale())
    tt:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    return tt
end
V.Tooltip = Tooltip