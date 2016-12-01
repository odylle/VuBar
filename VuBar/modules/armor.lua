local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame

----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetInventoryItemDurability = GetInventoryItemDurability
local GetAverageItemLevel = GetAverageItemLevel

-- LUA Functions -----------------
local min = min
local format = string.format

----------------------------------
-- Module Config
----------------------------------
module = {
    name = "Armor",
    description = "Display durability and ilevel",
    height = 0,
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
    return durability
end

----------------------------------
-- Event Handling
----------------------------------
local function EventFrame:PLAYER_ENTERING_WORLD()

end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end


----------------------------------
-- Base Frame
----------------------------------


----------------------------------
-- Content Frame(s)
----------------------------------


-- CHEAP MODULE REGISTERING ------
V.modules.armor = module