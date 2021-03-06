local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, Tooltip, DebugFrame = V.EventHandler, V.Tooltip, V.DebugFrame

local primary = { [1] = "Strength", [2] = "Agility", [3] = "Intellect"}
local secondary = {
    [1] = "Haste",                  --         GetHaste()
    [2] = "Haste",                  -- Ranged: GetRangedHaste()
    [3] = "Haste",                  -- Melee:  GetMeleeHaste()
    [4] = "Critical Strike",        -- Ranged: GetRangedCritChance()
    [5] = "Critical Strike",        -- Melee:  GetCritChance()
    [6] = "Critical Strike",        -- Caster: GetSpellCritChance()
    [7] = "Mastery",                --         GetMastery()
    [8] = "Versatility"             --         GetVersatilityBonus()

}
local stats = {
    ["DEATHKNIGHT"] = {
        ["Blood"] = {3,5,8,7},
        ["Frost"] = {3,5,8,7},
        ["Unholy"] = {5,3,7,8},
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
