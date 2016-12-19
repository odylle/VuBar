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
local GetLootSpecialization = GetLootSpecialization
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID

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

-- local function OnUpdate(self, e)
--     elapsed = elapsed + e
--     if elapsed >= 1 then
--             local _, equipped = GetAverageItemLevel()
--             if self.iLevelText:GetText() ~= floor(equipped) then
--                 self.iLevelText:SetText(floor(equipped))
--             end
--         elapsed = 0
--     end
-- end

local function LootSpec()
    local specID = GetLootSpecialization()
    if specID == 0 then
        local currentSpec = GetSpecialization()
        local _, currentSpecName = GetSpecializationInfo(currentSpec)
        return currentSpecName
    else
        _, lootSpecName = GetSpecializationInfoByID(specID)
        return string.lower(lootSpecName)
    end
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-120)
baseFrame:SetSize(V.defaults.frame.width, module.height)
--baseFrame:SetScript('OnUpdate', OnUpdate)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- ILEVEL ------------------------
local iLevelFrame = CreateFrame("FRAME", "$parent.iLevel", baseFrame)
iLevelFrame:SetSize(V.defaults.frame.width, 16)
iLevelFrame:SetPoint("TOP", 0, -(0+module.padding))
module.height = module.height + iLevelFrame:GetHeight()

local iLevelLText = iLevelFrame:CreateFontString(nil, "OVERLAY")
iLevelLText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
iLevelLText:SetTextColor(unpack(V.defaults.text.color.dim))
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
durabilityFrame:SetSize(V.defaults.frame.width, 16)
durabilityFrame:SetPoint("TOP", 0 , -(16+module.padding))
module.height = module.height + durabilityFrame:GetHeight()

local durabilityLText = durabilityFrame:CreateFontString(nil, "OVERLAY")
durabilityLText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
durabilityLText:SetTextColor(unpack(V.defaults.text.color.dim))
durabilityLText:SetJustifyH("LEFT")
durabilityLText:SetPoint("LEFT", durabilityFrame, "LEFT", 8, 0)
durabilityLText:SetText("durability")

local durabilityRText = durabilityFrame:CreateFontString(nil, "OVERLAY")
durabilityRText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
durabilityRText:SetTextColor(unpack(V.defaults.text.color.bright))
durabilityRText:SetJustifyH("RIGHT")
durabilityRText:SetPoint("RIGHT", durabilityFrame, "RIGHT",-6,0)
baseFrame.durabilityText = durabilityRText

-- Loot Specialisation -----------
local lootspecFrame = CreateFrame("FRAME", "$parent.LootSpec", baseFrame)
lootspecFrame:SetSize(V.defaults.frame.width, 16)
lootspecFrame:SetPoint("TOP", 0 , -(32+module.padding))
module.height = module.height + lootspecFrame:GetHeight()

local lootspecLText = lootspecFrame:CreateFontString(nil, "OVERLAY")
lootspecLText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
lootspecLText:SetTextColor(unpack(V.defaults.text.color.dim))
lootspecLText:SetJustifyH("LEFT")
lootspecLText:SetPoint("LEFT", lootspecFrame, "LEFT", 8, 0)
lootspecLText:SetText("loot spec")

local lootspecRText = lootspecFrame:CreateFontString(nil, "OVERLAY")
lootspecRText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
lootspecRText:SetTextColor(unpack(V.defaults.text.color.bright))
lootspecRText:SetJustifyH("RIGHT")
lootspecRText:SetPoint("RIGHT", lootspecFrame, "RIGHT",-6,0)
baseFrame.lootspecText = lootspecRText


-- Recalc. baseFrame height ------
module.height = module.height+module.padding
baseFrame:SetHeight(module.height)

-- CHEAP MODULE REGISTERING ------
V.frames.gear = baseFrame
V.modules.gear = module

----------------------------------
-- Event Handling
----------------------------------
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", V.EventHandler)

function EventFrame:PLAYER_ENTERING_WORLD()
    V.frames.gear.durabilityText:SetText(Durability().."%")
    V.frames.gear.lootspecText:SetText(LootSpec())
end

function EventFrame:UPDATE_INVENTORY_DURABILITY()
    V.frames.gear.durabilityText:SetText(Durability().."%")
end

function EventFrame:ACTIVE_TALENT_GROUP_CHANGED()
    V.frames.gear.lootspecText:SetText(LootSpec())
end

function EventFrame:PLAYER_SPECIALIZATION_CHANGED()
    V.frames.gear.lootspecText:SetText(LootSpec())
end

function EventFrame:PLAYER_LOOT_SPEC_UPDATED()
    V.frames.gear.lootspecText:SetText(LootSpec())
end

function EventFrame:PLAYER_AVG_ITEM_LEVEL_UPDATE()
    local _, equipped = GetAverageItemLevel()
    if V.frames.gear.iLevelText:GetText() ~= floor(equipped) then
        V.frames.gear.iLevelText:SetText(floor(equipped))
    end    
end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "UPDATE_INVENTORY_DURABILITY",
    "ACTIVE_TALENT_GROUP_CHANGED",
    "PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_LOOT_SPEC_UPDATED",
    "PLAYER_AVG_ITEM_LEVEL_UPDATE",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
