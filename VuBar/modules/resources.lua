local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, Tooltip, DebugFrame = V.EventHandler, V.EventFrame, V.Tooltip, V.DebugFrame

local currencies = {
    ["ANCIENT_MANA"] = 1155,
    ["CURIOUS_COIN"] = 1275,
    ["ORDER_RESOURCES"] = 1220,
    ["SEAL_OF_BROKEN_FATE"] = 1273,
    ["SIGHTLESS_EYE"] = 1149,
    ["NETHERSHARD"] = 1226
}

----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney
local RAID_CLASS_COLORS = RAID_CLASS_COLORS


-- LUA Functions -----------------
local abs = abs
local pairs = pairs
local format = string.format

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Resources",
    description = "Display gold and other resources",
    height = 0,
    padding = 5,
    currency1 = currencies.ORDER_RESOURCES,
    currency2 = currencies.SEAL_OF_BROKEN_FATE,
}

----------------------------------
-- Functions
----------------------------------
local function goldValue()
    local gold = GetMoney()
    gold = abs(gold/10000)
    if gold > 1 then
        gold = string.format("|cffffd700%d|cffffffffg|r ", floor(gold))
    else
        gold = "BROKE" -- Carelevel 0 for broke scrubs! :o
    end
    return gold
end

local function stripSmallChange(money)
    gold = abs(money/10000)
    return floor(gold)
end

local function gold_OnEnter(self)
    local tt = V.tt or Tooltip()
    tt:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, self:GetHeight())
    tt:SetMinimumWidth(160)
    tt:SetBackdropColor(unpack(V.defaults.tooltip.background))
    tt:AddLine(module.name)
    -- Session Gold Statistics
    tt:AddLine("Session Statistics", .6, .6 ,.6)
    -- local session_start = stripSmallChange(VuBarVars[V.constants.player.realm][V.constants.player.name]["gold"] or GetMoney())
    -- local session_current = stripSmallChange(GetMoney())
    local session_start
    if type(VuBarVars) == "table" then
        session_start = VuBarVars[V.constants.player.realm][V.constants.player.name]["gold"] 
    else session_start = ns.playerData["gold"] end
    local session_current = GetMoney()
    tt:AddDoubleLine("Gold", stripSmallChange(session_current).."g", 1, 1, 1, 1, 1, 1)
    if session_start > session_current then
        tt:AddDoubleLine(" Loss", stripSmallChange(session_start-session_current).."g", 1, 0, 0, 1, 0, 0)
    elseif session_start < session_current then
        tt:AddDoubleLine(" Gain", stripSmallChange(session_current-session_start).."g", 0, .8, 0, 0, .8, 0)
    end
    tt:AddLine(" ")
    tt:AddLine("Realm Statistics", .6, .6 ,.6)
    local realmGold = 0
    for name, _ in pairs(VuBarVars[V.constants.player.realm]) do
        if VuBarVars[V.constants.player.realm][name]["gold"] then
            local color = format("%02X%02X%02X", RAID_CLASS_COLORS[VuBarVars[V.constants.player.realm][name]["class"]].r*255, RAID_CLASS_COLORS[VuBarVars[V.constants.player.realm][name]["class"]].g*255, RAID_CLASS_COLORS[VuBarVars[V.constants.player.realm][name]["class"]].b*255)
            local leftText = format("%s |cff%s%s|r", VuBarVars[V.constants.player.realm][name]["level"], color, name)
            local rightText = format("|cffffffff%sg|r", stripSmallChange(VuBarVars[V.constants.player.realm][name]["gold"]))
            tt:AddDoubleLine(leftText, rightText)
            realmGold = realmGold + VuBarVars[V.constants.player.realm][name]["gold"]
        end
    end
    tt:AddDoubleLine(" ", stripSmallChange(realmGold).."g", 1, 1, 1, 1, 1, 1)    
    -- local realmGold = 0
    -- --local gold = 0
    -- for name, _ in pairs(VuBarVars[V.constants.player.realm]) do
    --     local color = format("%02X%02X%02X", RAID_CLASS_COLORS[VuBarVars[V.constants.player.realm][name]["class"]].r*255, RAID_CLASS_COLORS[VuBarVars[V.constants.player.realm][name]["class"]].g*255, RAID_CLASS_COLORS[VuBarVars[V.constants.player.realm][name]["class"]].b*255)
    --     local gold = VuBarVars[V.constants.player.realm][name]["gold"] or 0
    --     name = format("|cff%s%s|r", color, name)
    --     gold = stripSmallChange(gold)
    --     tt:AddDoubleLine(name, gold)
    --     realmGold = realmGold + gold
    -- end
    -- tt:AddDoubleLine(" ", realmGold)

    V.tt = tt
    tt:Show()    
end

local function OnLeave(self)
    if (V.tt:IsShown()) then V.tt:Hide() end
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-(205+module.padding))
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- Gold --------------------------
local goldFrame = CreateFrame("FRAME","$parent.Gold", baseFrame)
goldFrame:SetSize(V.defaults.frame.width, 30)
goldFrame:SetPoint("TOP", 0, -(module.padding))
goldFrame:SetScript("OnEnter", gold_OnEnter) 
goldFrame:SetScript("OnLeave", OnLeave)
module.height = module.height + goldFrame:GetHeight()

local goldText = goldFrame:CreateFontString(nil, "OVERLAY")
goldText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
goldText:SetTextColor(unpack(V.defaults.text.color.bright))
goldText:SetJustifyH("TOP")
goldText:SetPoint("CENTER", goldFrame, "CENTER", 0, -1)
baseFrame.goldText = goldText

-- Currency #1 -------------------
local currency1Frame = CreateFrame("FRAME","$parent.Currency1", baseFrame)
currency1Frame:SetSize(V.defaults.frame.width, 20)
currency1Frame:SetPoint("TOP",0,- (30+module.padding))
module.height = module.height + currency1Frame:GetHeight()

local currency1LText = currency1Frame:CreateFontString(nil, "OVERLAY")
currency1LText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
currency1LText:SetTextColor(unpack(V.defaults.text.color.dim))
currency1LText:SetJustifyH("LEFT")
currency1LText:SetPoint("LEFT", currency1Frame, "LEFT", 8, 0)
currency1LText:SetText("currency1")
baseFrame.currency1Name = currency1LText

local currency1RText = currency1Frame:CreateFontString(nil, "OVERLAY")
currency1RText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
currency1RText:SetTextColor(unpack(V.defaults.text.color.bright))
currency1RText:SetJustifyH("RIGHT")
currency1RText:SetPoint("RIGHT", currency1Frame, "RIGHT",-6,0)
baseFrame.currency1Text = currency1RText

-- Currency #2 -------------------
local currency2Frame = CreateFrame("FRAME","$parent.Currency2", baseFrame)
currency2Frame:SetSize(V.defaults.frame.width, 20)
currency2Frame:SetPoint("TOP",0,- (50+module.padding))
module.height = module.height + currency2Frame:GetHeight()

local currency2LText = currency2Frame:CreateFontString(nil, "OVERLAY")
currency2LText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
currency2LText:SetTextColor(unpack(V.defaults.text.color.dim))
currency2LText:SetJustifyH("LEFT")
currency2LText:SetPoint("LEFT", currency2Frame, "LEFT", 8, 0)
currency2LText:SetText("currency2")
baseFrame.currency2Name = currency2LText

local currency2RText = currency2Frame:CreateFontString(nil, "OVERLAY")
currency2RText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
currency2RText:SetTextColor(unpack(V.defaults.text.color.bright))
currency2RText:SetJustifyH("RIGHT")
currency2RText:SetPoint("RIGHT", currency2Frame, "RIGHT",-6,0)
baseFrame.currency2Text = currency2RText

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
    g = goldValue()
    if not ns.playerData["gold"] then ns.playerData["gold"] = GetMoney() end
    V.frames.resources.goldText:SetText(g)
    -- First Currency:
    name, currentAmount, _, earnedThisWeek, weeklyMax, totalMax = GetCurrencyInfo(module.currency1)
    V.frames.resources.currency1Name:SetText(string.lower(name))
    V.frames.resources.currency1Text:SetText(currentAmount)
    -- Second Currency:
    name, currentAmount, _, earnedThisWeek, weeklyMax, totalMax = GetCurrencyInfo(module.currency2)
    V.frames.resources.currency2Name:SetText(string.lower(name))
    V.frames.resources.currency2Text:SetText(currentAmount)
end

function EventFrame:PLAYER_MONEY()
    V.frames.resources.goldText:SetText(goldValue())
    ns.playerData["gold"] = GetMoney()
end

function EventFrame:CURRENCY_DISPLAY_UPDATE()
    name, currentAmount, _, earnedThisWeek, weeklyMax, totalMax = GetCurrencyInfo(module.currency1)
    V.frames.resources.currency1Name:SetText(string.lower(name))
    V.frames.resources.currency1Text:SetText(currentAmount)
    -- Second Currency:
    name, currentAmount, _, earnedThisWeek, weeklyMax, totalMax = GetCurrencyInfo(module.currency2)
    V.frames.resources.currency2Name:SetText(string.lower(name))
    V.frames.resources.currency2Text:SetText(currentAmount)
end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "CURRENCY_DISPLAY_UPDATE",
    "PLAYER_MONEY"
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
