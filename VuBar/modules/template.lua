local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, Tooltip, DebugFrame = V.EventHandler, V.Tooltip, V.DebugFrame

----------------------------------
-- Blizz Api & Variables
----------------------------------

-- LUA Functions -----------------


----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Some Name",
    description = "Some Description",
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
