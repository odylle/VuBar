local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame

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


-- LUA Functions -----------------
local abs = abs

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Resources",
    description = "Display gold and other resources",
    height = 0,
    padding = 0,
    currency1 = currencies.ORDER_RESOURCES,
    currency2 = currencies.SEAL_OF_BROKEN_FATE,
}

----------------------------------
-- Functions
----------------------------------
local function goldText()
    local gold = GetMoney()
    local gold = abs(gold/10000)
    if gold > 1 then
        gold = string.format("|cffffd700%d|cffffffffg|r ", floor(gold))
    else
        gold = "BROKE" -- Carelevel 0 for broke scrubs! :o
    end
    return gold
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-195)
baseFrame:SetSize(V.defaults.frame.width, module.height)

if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- Gold --------------------------
local goldFrame = CreateFrame("FRAME","$parent.Gold", baseFrame)
goldFrame:SetSize(V.defaults.frame.width, 20)
goldFrame:SetPoint("TOP")

local goldText = goldFrame:CreateFontString(nil. "OVERLAY")
goldText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
goldText:SetTextColor(unpack(V.defaults.text.color.bright))
goldText:SetJustifyH("TOP")
goldText:SetPoint("CENTER", goldFrame, "CENTER", 0, -1)
baseFrame.goldText = goldText

-- Currency #1 -------------------
local currency1Frame = CreateFrame("FRAME","$parent.Currency1", baseFrame)
currency1Frame:SetSize(V.defaults.frame.width, 20)
currency1Frame:SetPoint("TOP",0,-20)

local currency1LText = currency1Frame:CreateFontString(nil, "OVERLAY")
currency1LText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
currency1LText:SetTextColor(unpack(V.defaults.text.color.header))
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
currency2Frame:SetPoint("TOP",0,-40)

local currency2LText = currency2Frame:CreateFontString(nil, "OVERLAY")
currency2LText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
currency2LText:SetTextColor(unpack(V.defaults.text.color.header))
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
module.height = module.height+goldFrame:GetHeight()+currency1Frame:GetHeight()+currency2Frame:GetHeight()+module.padding
baseFrame:SetHeight(module.height)

-- CHEAP MODULE REGISTERING ------
V.frames.resources = baseFrame
V.modules.resources = module

----------------------------------
-- Event Handling
----------------------------------
function EventFrame:PLAYER_ENTERING_WORLD()
    V.frames.resources.goldText:SetText(goldText())
    -- First Currency:
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
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
