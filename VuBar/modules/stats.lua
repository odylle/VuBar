local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, Tooltip, DebugFrame = V.EventHandler, V.Tooltip, V.DebugFrame

local currencies = {
    ["ANCIENT_MANA"] = 1155,
    ["CURIOUS_COIN"] = 1275,
    ["ORDER_RESOURCES"] = 1220,
    ["SEAL_OF_BROKEN_FATE"] = 1273,
    ["SIGHTLESS_EYE"] = 1149,
    ["NETHERSHARD"] = 1226
}
local stats = {
    ["DEATHKNIGHT"] = {
        ["Blood"] = {
            [1] = "Haste",
            [2] = "Critical Strike",
            [3] = "Versatility",
            [4] = "Mastery"
        },
        ["Frost"] = {
            [1] = "Haste",
            [2] = "Critical Strike",
        }
    },
    ["Hunter"] = {
        ["Marksmanship"] = {
            [1] = "Mastery",
            [2] = 
        }
    }
}

----------------------------------
-- Blizz Api & Variables
----------------------------------

-- LUA Functions -----------------


----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Stats",
    description = "Display Stat Priority",
    height = 0,
    padding = 5,
    showStats = 3
}

----------------------------------
-- Functions
----------------------------------

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint("BOTTOM",0,0,)
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------



-- Recalc. baseFrame height ------
module.height = module.height+module.padding
baseFrame:SetHeight(module.height)

-- CHEAP MODULE REGISTERING ------
V.frames.resources = baseFrame
V.modules.resources = module

----------------------------------
-- Event Handling
----------------------------------
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", V.EventHandler)

function EventFrame:PLAYER_ENTERING_WORLD()

end


-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",

}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
