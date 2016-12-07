local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame
local elapsed = 0

----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetInventoryItemDurability = GetInventoryItemDurability
local GetAverageItemLevel = GetAverageItemLevel

-- LUA Functions -----------------
local min = min
local format = string.format
local unpack = unpack

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Gear",
    description = "Display durability and ilevel",
    height = 0,
    padding = 5
}

----------------------------------
-- Functions
----------------------------------
local function Durability()
    -- ADD COLORING
    local durability = 100
    for i = 1, 18 do
        local current, max = GetInventoryItemDurability(i)
        if ( current ~= max ) then durability = min(durability, current*(100/max)) end
    end
    return floor(durability)
end

local function OnUpdate(self, e)
    elapsed = elapsed + e
    if elapsed >= 1 then
            local _, equipped = GetAverageItemLevel()
            if self.iLevelText:GetText() ~= floor(equipped) then
                self.iLevelText:SetText(floor(equipped))
            end
        elapsed = 0
    end
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-120)
baseFrame:SetSize(V.defaults.frame.width, module.height)
baseFrame:SetScript('OnUpdate', OnUpdate)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- ILEVEL ------------------------
local iLevelFrame = CreateFrame("FRAME", "$parent.iLevel", baseFrame)
iLevelFrame:SetSize(V.defaults.frame.width, 20)
iLevelFrame:SetPoint("TOP", 0, -(0+module.padding))

local iLevelLText = iLevelFrame:CreateFontString(nil, "OVERLAY")
iLevelLText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
iLevelLText:SetTextColor(unpack(V.defaults.text.color.header))
iLevelLText:SetJustifyH("LEFT")
iLevelLText:SetPoint("LEFT", iLevelFrame, "LEFT", 8, 0)
iLevelLText:SetText("ilevel")

local iLevelRText = iLevelFrame:CreateFontString(nil, "OVERLAY")
iLevelRText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
iLevelRText:SetTextColor(unpack(V.defaults.text.color.bright))
iLevelRText:SetJustifyH("RIGHT")
iLevelRText:SetPoint("RIGHT", iLevelFrame, "RIGHT",-6,0)
baseFrame.iLevelText = iLevelRText

-- DURABILITY --------------------
local durabilityFrame = CreateFrame("FRAME", "$parent.Durability", baseFrame)
durabilityFrame:SetSize(V.defaults.frame.width, 20)
durabilityFrame:SetPoint("TOP", 0 , -(20+module.padding))

local durabilityLText = durabilityFrame:CreateFontString(nil, "OVERLAY")
durabilityLText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
durabilityLText:SetTextColor(unpack(V.defaults.text.color.header))
durabilityLText:SetJustifyH("LEFT")
durabilityLText:SetPoint("LEFT", durabilityFrame, "LEFT", 8, 0)
durabilityLText:SetText("durability")

local durabilityRText = durabilityFrame:CreateFontString(nil, "OVERLAY")
durabilityRText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
durabilityRText:SetTextColor(unpack(V.defaults.text.color.bright))
durabilityRText:SetJustifyH("RIGHT")
durabilityRText:SetPoint("RIGHT", durabilityFrame, "RIGHT",-6,0)
baseFrame.durabilityText = durabilityRText


-- Recalc. baseFrame height ------
module.height = module.height+iLevelFrame:GetHeight()+durabilityFrame:GetHeight()+module.padding
baseFrame:SetHeight(module.height)

-- CHEAP MODULE REGISTERING ------
V.frames.gear = baseFrame
V.modules.gear = module

----------------------------------
-- Event Handling
----------------------------------
function EventFrame:PLAYER_ENTERING_WORLD()
    V.frames.gear.durabilityText:SetText(Durability().."%")
end

function EventFrame:UPDATE_INVENTORY_DURABILITY()
    V.frames.gear.durabilityText:SetText(Durability().."%")
end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "UPDATE_INVENTORY_DURABILITY",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
