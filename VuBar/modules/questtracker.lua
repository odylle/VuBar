local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, Tooltip, DebugFrame = V.EventHandler, V.Tooltip, V.DebugFrame

----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetNumQuestLogEntries = GetNumQuestLogEntries

-- LUA Functions -----------------
local format = string.format

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Quests",
    description = "Replace the WatchFrame",
    height = 0,
    padding = 5,
}

----------------------------------
-- Functions
----------------------------------


----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-(460+module.padding))
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------
local watchFrame = CreateFrame("FRAME", "$parentWatch", baseFrame)
watchFrame:SetSize(V.defaults.frame.width, 0)
watchFrame:SetPoint("TOP", 0, -(module.padding))
baseFrame.watchFrame = watchFrame

local qHeader = CreateFrame("FRAME", "$parentHeader", baseFrame)
qHeader:SetSize(V.defaults.frame.width, 20)
qHeader:SetPoint("TOP", 0, 0)
baseFrame.watchFrame:SetHeight(qHeader:GetHeight())

qHeaderText = qHeader:CreateFontString(nil, "OVERLAY")
qHeaderText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
qHeaderText:SetTextColor(unpack(V.defaults.text.color.bright))
qHeaderText:SetJustifyH("LEFT")
qHeaderText:SetPoint("LEFT", qHeader, "LEFT", 6, 0)
baseFrame.qHeaderText = qHeaderText


module.height = module.height + watchFrame:GetHeight()

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
    -- Header
    local numEntries, numQuests = GetNumQuestLogEntries()
    V.frames.Quests.qHeaderText:SetText(format("Quests: %s/25", numQuests))
end

function EventFrame:QUEST_ACCEPTED(arg)
    -- arg = (questIndex). Eg. Where it is stuck in the quest log
    -- Header
    local numEntries, numQuests = GetNumQuestLogEntries()
    V.frames.Quests.qHeaderText:SetText(format("Quests: %s/25", numQuests))    
end

function EventFrame:QUEST_LOG_UPDATE()
    -- Header
    local numEntries, numQuests = GetNumQuestLogEntries()
    V.frames.Quests.qHeaderText:SetText(format("Quests: %s/25", numQuests))
    EventFrame:UnregisterEvent("QUEST_LOG_UPDATE")   
end

function EventFrame:UNIT_QUEST_LOG_CHANGED()
    -- Header
    local numEntries, numQuests = GetNumQuestLogEntries()
    V.frames.Quests.qHeaderText:SetText(format("Quests: %s/25", numQuests))    
end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "QUEST_ACCEPTED",
    "QUEST_LOG_UPDATE",
    "UNIT_QUEST_LOG_CHANGED"

}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
