local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame

local hover = false
local lockoutColorExtended, lockoutColorNormal = { r=0.3,g=1,b=0.3 }, { r=.8,g=.8,b=.8 }
local lockoutInfoFormat = "%s%s |cffaaaaaa(%s, %s/%s)"
local lockoutInfoFormatNoEnc = "%s%s |cffaaaaaa(%s)"
local elapsed, h, m = 0, 0, 0

----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetGameTime = GetGameTime
local GetCVarBool = GetCVarBool
local CalendarGetNumPendingInvites = CalendarGetNumPendingInvites
local RequestRaidInfo = RequestRaidInfo
local SecondsToTime = SecondsToTime
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetDifficultyInfo = GetDifficultyInfo
local InCombatLockdown = InCombatLockdown
local ToggleCalendar = ToggleCalendar
local ToggleTimeManager = ToggleTimeManager
local IsResting = IsResting
local UnitIsAFK = UnitIsAFK

-- LUA Functions -----------------
local unpack = unpack
local pairs = pairs

----------------------------------
-- Module Config
----------------------------------
module = {
    name = "Clock",
    height = 100, -- Hardcoded height for clock
}

----------------------------------
-- Frame Functions
----------------------------------
local function OnEnter(self)
    GameTooltip:SetOwner(self,"ANCHOR_BOTTOMRIGHT",0,0)

    if not hover then
        RequestRaidInfo()
        hover = true
    end

    local lockedInstances = {raids = {}, dungeons = {}}
    for i = 1, GetNumSavedInstances() do
        local name, instanceId, _, difficulty, locked, extended, _, isRaid, _, _, _, _  = GetSavedInstanceInfo(i)
        if (locked or extended) and name then
            if isRaid then
                lockedInstances["raids"][instanceId] = {GetSavedInstanceInfo(i)}
            elseif not isRaid and difficulty == 23 then
                lockedInstances["dungeons"][instanceId] = {GetSavedInstanceInfo(i)}
            end
        end
    end
    -- Raids -------------------------
    if next(lockedInstances["raids"]) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Saved Raid(s)")

        for pos,instance in pairs(lockedInstances["raids"]) do
            name, _, reset, difficultyId, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(instance)

            local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
            local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficultyId)
            if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
                GameTooltip:AddDoubleLine(format(lockoutInfoFormat, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            else
                GameTooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            end
        end
    end
    -- Dungeons ----------------------
    if next(lockedInstances["dungeons"]) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Saved Dungeon(s)")

        for pos,instance in pairs(lockedInstances["dungeons"]) do
            name, _, reset, difficultyId, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(instance)

            local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
            local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficultyId)
            if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
                GameTooltip:AddDoubleLine(format(lockoutInfoFormat, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            else
                GameTooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            end
        end
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("<Left-click>", "Open Calendar", 1, 1, 0, 1, 1, 1)
    GameTooltip:AddDoubleLine("<Right-click>", "Open Clock", 1, 1, 0, 1, 1, 1)
    GameTooltip:Show()
end

local function OnLeave(self)
    if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
    hover = false
end

local function OnClick(self, button, down)
    if InCombatLockdown() then return end
    if button == "LeftButton" then
        ToggleCalendar()
    elseif button == "RightButton" then 
        ToggleTimeManager()
    end
end

local function OnUpdate(self, e) 
    elapsed = elapsed + e
    if elapsed >= 1 then
        h, m = GetGameTime()
        if h < 10 then h = ("0"..h) end
        if m < 10 then m = ("0"..m) end       
        if ( GetCVarBool("timeMgrUseLocalTime") ) then
            if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
                timeText:SetText(date("%H:%M"))
                --amText:SetText("")    
            else
                timeText:SetText(date("%I:%M"))
                --amText:SetText(date("%p"))        
            end         
        else
            if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
                timeText:SetText(h..":"..m)
                --amText:SetText("")    
            else
                if h > 12 then 
                    h = ("0"..(h-12))
                    --AmPmTimeText = "PM"
                else 
                    --AmPmTimeText = "AM"
                end
                timeText:SetText(h..":"..m)
                --amText:SetText(AmPmTimeText)      
            end
        end
        if (CalendarGetNumPendingInvites() > 0) then
            calendarText:SetText(string.format("%s  (|cffffff00%i|r)", "new events", (CalendarGetNumPendingInvites())))
        else
            calendarText:SetText("")
        end
        --baseFrame:SetWidth(clockText:GetStringWidth() + amText:GetStringWidth())
        --baseFrame:SetPoint("CENTER", V.config.lframe)        
        elapsed = 0
    end
end




----------------------------------
-- Event Handling
----------------------------------
local function EventFrame:PLAYER_ENTERING_WORLD()
    local text = ""
    if IsResting() then text = "resting" else text = "" end
    restingText:SetText(text)
    if UnitIsAFK("player") then text = "afk" else text = "" end
    afkText:SetText(text)
end

local function EventFrame:PLAYER_UPDATE_RESTING()
    if IsResting() then text = "resting" else text = "" end
    restingText:SetText(text)
end

local function EventFrame:PLAYER_FLAGS_CHANGED(arg1)
    if arg1 ~= "player" then return end
    if UnitIsAFK("player") then text = "afk" else text = "" end
    afkText:SetText(text)
end

local function EventFrame:UPDATE_INSTANCE_INFO()
    if hover then
        OnEnter(self)
    end
end
-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_UPDATE_RESTING",
    "PLAYER_FLAGS_CHANGED",
    "UPDATE_INSTANCE_INFO",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("BUTTON","$parent."..module.name, V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor)
baseFrame:SetSize(V.defaults.frame.width, module.height)
baseFrame:EnableMouse(true)
baseFrame:RegisterForClicks("AnyUp")
baseFrame:SetScript('OnUpdate', OnUpdate)
baseFrame:SetScript("OnEnter", OnEnter) 
baseFrame:SetScript("OnLeave", OnLeave)
baseFrame:SetScript("OnClick", OnClick)
if V.debug then DebugFrame(baseFrame) end
V.frames.clock = baseFrame

----------------------------------
-- Content
----------------------------------
-- TIME --------------------------
local timeText = baseFrame:CreateFontString(nil, "OVERLAY")
timeText:SetPoint("CENTER")
timeText:SetHeight(module.height)
timeText:SetFont(V.defaults.text.font.main, V.defaults.text.xlarge)
timeText:SetTextColor(unpack(V.defaults.text.color.bright))
timeText:SetAllPoints()
-- CALENDAR ----------------------
local calendarText = clockFrame:CreateFontString(nil, "OVERLAY")
calendarText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
calendarText:SetPoint("TOP", baseFrame, "TOP", 0, -18)
calendarText:SetTextColor(unpack(V.defaults.text.color.dim))
-- RESTING -----------------------
local restingText = baseFrame:CreateFontString(nil, "OVERLAY")
restingText:SetFont(V.defaults.text.font, V.defaults.text.normal)
restingText:SetPoint("BOTTOM", 0, 30)
restingText:SetTextColor(unpack(V.defaults.text.color.dim))
-- AFK ---------------------------
local afkText = baseFrame:CreateFontString(nil, "OVERLAY")
afkText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
afkText:SetPoint("CENTER", -8, 16)
afkText:SetJustifyH("RIGHT")
afkText:SetTextColor(unpack(V.defaults.text.color.dim))

-- CHEAP MODULE REGISTERING ------
V.modules.clock = module