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
    name = "Chat",
    description = "Display Chat Frames",
    height = 200,
    width = 360,
    hOffset = 160+5,
}

----------------------------------
-- Functions
----------------------------------
local function ChatBase(side)
    local f = CreateFrame("FRAME","$parent."..module.name..side, V.frames[side])
    f:SetParent(V.frames[side])
    if side == "right" then module.hOffset = -(module.hOffset) end
    f:SetPoint("BOTTOM",module.hOffset,5)
    f:SetSize(module.width, module.height)
    f:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    f:SetBackdropColor(0, 0, 0, 0.5)
end


----------------------------------
-- Base Frame
----------------------------------
local sides = {"left", "right"}
for _, side in pairs(sides) do
    local f = ChatBase(side)
    V.module[module.name][side] = f
end

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
