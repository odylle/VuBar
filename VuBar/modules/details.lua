local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame, Shorten = V.EventHandler, V.EventFrame, V.DebugFrame, V.Shorten
local max, elapsed = 0, 0

----------------------------------
-- Blizz Api & Variables
----------------------------------
local _G = _G

-- LUA Functions -----------------
local details = _G.Details

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Details",
    description = "DPS Stuff!!",
    height = 0,
    padding = 0,
    bar = {
        number = 10,
        height = 16,
    },
}

----------------------------------
-- Functions
----------------------------------
local function SpawnBar(i, parent)
    local bar = CreateFrame("STATUSBAR", "$parent."..i, parent)
    bar:SetStatusBarTexture(V.defaults.statusbar)
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:SetWidth(V.defaults.frame.width - 2)
    bar:SetHeight(module.bar.height-1)
    bar:SetPoint("TOP",0,- ((i*module.bar.height)-module.bar.height))
    bar:SetMinMaxValues(1, 100)
    bar:SetValue(0)
    bar:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    bar:SetBackdropColor(0,0,0,0)

    local textLeft = bar:CreateFontString(nil, "OVERLAY") 
    textLeft:SetFont(V.defaults.text.font.bold, V.defaults.text.small)
    textLeft:SetTextColor(unpack(V.defaults.text.color.bright))
    textLeft:SetJustifyH("LEFT")
    textLeft:SetPoint("LEFT", bar, "LEFT", 2, 0)
    bar.name = textLeft

    local textRight = bar:CreateFontString(nil, "OVERLAY") 
    textRight:SetFont(V.defaults.text.font.bold, V.defaults.text.small)
    textRight:SetTextColor(unpack(V.defaults.text.color.bright))
    textRight:SetJustifyH("LEFT")
    textRight:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
    bar.value = textRight
    return bar
end

local function UpdateBars(self, attr, total)
    local actors = {}
    local count = 1
    local combat = details:GetCurrentCombat()
    local container = combat:GetContainer(attr)
    container:SortByKey("total")
    for i, actor in container:ListActors() do
        if count <= total then
            if (actor:IsGroupPlayer()) and not (actor:IsEnemy()) then
                if count == 1 then max = actor.total / combat:GetCombatTime() end
                local displayValue = actor.total / combat:GetCombatTime()
                if displayValue > 1000 then
                    local barValue = displayValue*(100/max)
                    local r,g,b = actor:GetBarColor()
                    displayValue = Shorten(displayValue)
                    table.insert(actors, { name = actor:GetOnlyName(), displayValue = displayValue, barValue = barValue, barColor = {r = r,g = g,b = b}})
                    count = count + 1
                end 
            end                      
        end
    end
    if count <= total then
        table.insert(actors, {})
        count = count + 1
    end
    return actors
end

local function DamageOnUpdate(self, e)
    elapsed = elapsed + e
    if elapsed >1 then
        actors = UpdateBars(self, DETAILS_ATTRIBUTE_DAMAGE, 10)
        for i, actor in pairs(actors) do
            local bar = V.frames.details.damageBarsFrame.bar[i]
            local r,g,b,a = 1,1,1,0
            if actor["barColor"] then
                r,g,b,a = actor.barColor.r, actor.barColor.g, actor.barColor.b, .1
            end
            bar:SetStatusBarColor(r,g,b,1)
            bar:SetBackdropColor(r,g,b,a)
            bar:SetValue(actor.barValue or 0)
            -- Text Update
            bar.name:SetText(actor.name or "")
            bar.value:SetText(actor.displayValue or "")
        end
        elapsed = 0
    end
end

local function HealerOnUpdate(self, e)
    elapsed = elapsed + e
    if elapsed >1 then
        actors = UpdateBars(self, DETAILS_ATTRIBUTE_HEAL, 5)
        for i, actor in pairs(actors) do
            local bar = V.frames.details.window2BarsFrame.bar[i]
            local r,g,b,a = 1,1,1,0
            if actor["barColor"] then
                r,g,b,a = actor.barColor.r, actor.barColor.g, actor.barColor.b, .1
            end
            bar:SetStatusBarColor(r,g,b,1)
            bar:SetBackdropColor(r,g,b,a)
            bar:SetValue(actor.barValue or 0)
            -- Text Update
            bar.name:SetText(actor.name or "")
            bar.value:SetText(actor.displayValue or "")
        end        
        elapsed = 0
    end
end

local function ClearWindows(window)
    local bars = { window:GetChildren() }
    for _, bar in pairs(bars) do
        bar:SetValue(0)
        r, g, b = bar:GetBackdropColor()
        bar:SetBackdropColor(r,g,b,0)
        bar.name:SetText("")
        bar.value:SetText("")
    end
end

local 
----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.right)
baseFrame:SetParent(V.frames.right)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-260)
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- Window #1 ---------------------
local damageFrame = CreateFrame("FRAME", "$parent.Damage", baseFrame)
damageFrame:SetSize(V.defaults.frame.width, 180)
damageFrame:SetPoint("TOP",0,0)
module.height = module.height + damageFrame:GetHeight()

local damageHeaderFrame = CreateFrame("FRAME", "$parent.Header", damageFrame)
damageHeaderFrame:SetSize(V.defaults.frame.width, 20)
damageHeaderFrame:SetPoint("TOP", 0, 0)

local damageHeaderText = damageHeaderFrame:CreateFontString(nil, "OVERLAY")
damageHeaderText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
damageHeaderText:SetTextColor(unpack(V.defaults.text.color.dim))
damageHeaderText:SetJustifyH("LEFT")
damageHeaderText:SetPoint("BOTTOMLEFT", damageHeaderFrame, "BOTTOMLEFT", 3, 3)
damageHeaderText:SetText("damage")

local damageBarsFrame = CreateFrame("FRAME", "$parent.Bars", damageFrame)
damageBarsFrame:SetSize(V.defaults.frame.width, module.bar.number*module.bar.height)
damageBarsFrame:SetPoint("TOP", 0, -20)
damageBarsFrame:HookScript("OnUpdate", DamageOnUpdate)
baseFrame.damageBarsFrame = damageBarsFrame


-- Window #2 ---------------------
local window2Frame = CreateFrame("FRAME", "$parent.Window2", baseFrame)
window2Frame:SetSize(V.defaults.frame.width, 100)
window2Frame:SetPoint("TOP",0, -180)
module.height = module.height + window2Frame:GetHeight()

local window2HeaderFrame = CreateFrame("FRAME", "$parent.Header", window2Frame)
window2HeaderFrame:SetSize(V.defaults.frame.width, 20)
window2HeaderFrame:SetPoint("TOP", 0, 0)

local window2HeaderText = window2HeaderFrame:CreateFontString(nil, "OVERLAY")
window2HeaderText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
window2HeaderText:SetTextColor(unpack(V.defaults.text.color.dim))
window2HeaderText:SetJustifyH("LEFT")
window2HeaderText:SetPoint("BOTTOMLEFT", window2HeaderFrame, "BOTTOMLEFT", 3, 3)
window2HeaderText:SetText("healing")

local window2BarsFrame = CreateFrame("FRAME", "$parent.Bars", window2Frame)
window2BarsFrame:SetSize(V.defaults.frame.width, module.bar.number*module.bar.height)
window2BarsFrame:SetPoint("TOP", 0, -20)
window2BarsFrame:HookScript("OnUpdate", HealerOnUpdate)
baseFrame.window2BarsFrame = window2BarsFrame

-- Recalc. baseFrame height ------
module.height = module.height+module.padding
baseFrame:SetHeight(module.height)

-- CHEAP MODULE REGISTERING ------
V.frames.details = baseFrame
V.modules.details = module

-- DamageBars
V.frames.details.damageBarsFrame.bar = {}
for i = 1, 10 do
    local bar = "bar"..i
    bar = SpawnBar(i, V.frames.details.damageBarsFrame)
    V.frames.details.damageBarsFrame.bar[i] = bar    
end

V.frames.details.window2BarsFrame.bar = {}
for i = 1, 5 do
    local bar = "bar"..i
    bar = SpawnBar(i, V.frames.details.window2BarsFrame)
    V.frames.details.window2BarsFrame.bar[i] = bar    
end


----------------------------------
-- Event Handling
----------------------------------
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", V.EventHandler)

function EventFrame:PLAYER_ENTERING_WORLD()

end

function EventFrame:PLAYER_REGEN_DISABLED()
    ClearWindows(V.frames.details.damageBarsFrame)
    ClearWindows(V.frames.details.window2BarsFrame)
end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_ENTER_COMBAT",
    "PLAYER_REGEN_DISABLED"
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
