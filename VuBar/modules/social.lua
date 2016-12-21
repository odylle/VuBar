local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, DebugFrame, LocalClassColor = V.EventHandler, V.DebugFrame, V.LocalClassColor

----------------------------------
-- Blizz Api & Variables
----------------------------------
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local GetNumGuildMembers = GetNumGuildMembers
local BNGetNumFriends = BNGetNumFriends
local ToggleGuildFrame = ToggleGuildFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local WrapTextInColorCode = WrapTextInColorCode
local GetClassColor = GetClassColor

-- LUA Functions -----------------
local unpack = unpack
local format = string.format

----------------------------------
-- Module Config
----------------------------------
module = {
    name = "Social",
    description = "Display friends and guild members",
    height = 40,
}

----------------------------------
-- Functions
----------------------------------
local function gOnline()
    local online = 0
    if IsInGuild() then
        _, online, _ = GetNumGuildMembers()
    end
    return online    
end

local function fOnline()
    local online = 0
    _, online = BNGetNumFriends()
    return online    
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor, 0, -170)
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- Friends -----------------------
local friendsFrame = CreateFrame("BUTTON","$parent.Friends", baseFrame)
friendsFrame:SetSize(V.defaults.frame.width/2, module.height)
friendsFrame:SetPoint("TOPLEFT")
friendsFrame:EnableMouse(true)
friendsFrame:RegisterForClicks("AnyUp")
friendsFrame:SetScript("OnClick", function(self, button, down)
    if InCombatLockdown() then return end
    if button == "LeftButton" then
        ToggleFriendsFrame()
    end    
end)
friendsFrame:SetScript("OnEnter", function()
    local tt = V.tt or Tooltip()
    tt:SetOwner(self, "ANCHOR_BOTTOMRIGHT", self:GetWidth(), self:GetHeight())
    tt:SetMinimumWidth(160)
    tt:SetMaxResize(200, V.default.frame.height)
    tt:SetBackdropColor(unpack(V.defaults.tooltip.background))
    tt:AddLine(module.name..": Friends")
    tt:AddLine("")    
    tt:AddLine("Online", .6, .6 ,.6)
    -- InGame
    for i = 1, GetNumFriends() do
        local name, lvl, class, area, online, status, note = GetFriendInfo(i)
        if (online) then
            classColor = select(4, LocalClassColor(class))
            if not status then status = "" end
            lText = format("%s %s %s", lvl, WrapTextInColorCode(name, classColor), status)
            rText = WrapTextInColorCode(area, "ffffffff")
            tt:AddDoubleLine(lText, rText)
        end
    end
    -- Battle.Net
    tt:AddLine(" ")
    for i = 1, BNGetNumFriends() do
        local BNid, BNname, battleTag, _, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note = BNGetFriendInfo(i)
        if client ~= "WoW" and (online) then
            lText = format("%s %s", WrapTextInColorCode(BNname,"ff4876ff"),WrapTextInColorCode(toonname, "ff888888"))
            rText = WrapTextInColorCode(client, "ffffffff")
            tt:AddDoubleLine(lText, rText)
        end
    end
end)
friendsFrame:SetScript("OnLeave", function()
    if (V.tt:IsShown()) then V.tt:Hide() end
end)

local friendsTText = friendsFrame:CreateFontString(nil, "OVERLAY")
friendsTText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
friendsTText:SetTextColor(unpack(V.defaults.text.color.bright))
friendsTText:SetJustifyH("TOP")
friendsTText:SetPoint("CENTER", friendsFrame, "CENTER", 0, -1)
baseFrame.friendsText = friendsTText

local friendsBText = friendsFrame:CreateFontString(nil, "OVERLAY")
friendsBText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
friendsBText:SetTextColor(unpack(V.defaults.text.color.dim))
friendsBText:SetJustifyH("CENTER")
friendsBText:SetPoint("BOTTOM", friendsFrame, "BOTTOM", 0, 1)
friendsBText:SetText("friends")

-- Guildies ----------------------
local guildFrame = CreateFrame("BUTTON","$parent.Guild", baseFrame)
guildFrame:SetSize(V.defaults.frame.width/2, module.height)
guildFrame:SetPoint("TOPRIGHT")
guildFrame:EnableMouse(true)
guildFrame:RegisterForClicks("AnyUp")
guildFrame:SetScript("OnClick", function(self, button, down)
    if InCombatLockdown() then return end
    if button == "LeftButton" then 
        if ( IsInGuild() ) then
            ToggleGuildFrame()
            GuildFrameTab2:Click()
        else
            print"|cff6699FFSXUI|r: You are not in a guild"
        end
    end
end)
guildFrame:SetScript("OnEnter", function()
    if not (IsInGuild()) then return end
    local tt = V.tt or Tooltip()
    tt:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, self:GetHeight())
    tt:SetMinimumWidth(160)
    tt:SetMaxResize(200, V.default.frame.height)
    tt:SetBackdropColor(unpack(V.defaults.tooltip.background))
    tt:AddLine(select(1, GetGuildInfo("player")))
    tt:AddLine(" ")
    -- MOTD    
    local guildMOTD = GetGuildRosterMOTD()
    if guildMOTD ~= nil then
        tt:AddLine("Message:", .6, .6, .6)
        tt:AddLine(guildMOTD, 1, 1, 1)
        tt:AddLine(" ")
    end
    -- Members Online
    local numOnline = select(2, GetNumGuildMembers())
    for i = 1, numOnline do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR = GetGuildRosterInfo(i)
        name = WrapTextInColorCode(name, select(4, GetClassColor(classFileName)))
        level = WrapTextInColorCode(level, "ffffffff")
        if status == 1 then status = WrapTextInColorCode("AFK", "ffffffff") else status = "" end
        if note ~= "" then note = WrapTextInColorCode(note, "ff888888") end
        if isMobile then
            zone = WrapTextInColorCode("Remote", "ff666666")
        else 
            zone = WrapTextInColorCode(zone, "ffffffff")
        end
        lText = format("%s %s%s %s", level, status, name, note)
        rText = zone
        tt:AddDoubleLine(lText, rText)
    end
end)
guildFrame:SetScript("OnLeave", function()
    if (V.tt:IsShown()) then V.tt:Hide() end
end)

local guildTText = guildFrame:CreateFontString(nil, "OVERLAY")
guildTText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
guildTText:SetTextColor(unpack(V.defaults.text.color.bright))
guildTText:SetJustifyH("TOP")
guildTText:SetPoint("CENTER", guildFrame, "CENTER", 0, -1)
guildTText:SetText("0")
baseFrame.guildText = guildTText

local guildBText = guildFrame:CreateFontString(nil, "OVERLAY")
guildBText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
guildBText:SetTextColor(unpack(V.defaults.text.color.dim))
guildBText:SetJustifyH("CENTER")
guildBText:SetPoint("BOTTOM", guildFrame, "BOTTOM", 0, 1)
guildBText:SetText("guild")




-- CHEAP MODULE REGISTERING ------
V.frames.social = baseFrame
V.modules.social = module

----------------------------------
-- Event Handling
----------------------------------
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", V.EventHandler)

function EventFrame:PLAYER_ENTERING_WORLD()
    V.frames.social.guildText:SetText(gOnline())
    V.frames.social.friendsText:SetText(fOnline())
end

function EventFrame:PLAYER_GUILD_UPDATE()
    V.frames.social.guildText:SetText(gOnline())
end

function EventFrame:GUILD_ROSTER_UPDATE()
    V.frames.social.guildText:SetText(gOnline())
end

function EventFrame:FRIENDLIST_UPDATE()
    V.frames.social.friendsText:SetText(fOnline())
end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_GUILD_UPDATE",
    "FRIENDLIST_UPDATE",
    "GUILD_ROSTER_UPDATE",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
