local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame
--local Tooltip = V.Tooltip
local elapsed = 0
----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetNetStats = GetNetStats
local GetFramerate = GetFramerate

-- LUA Functions -----------------
local unpack, select = unpack, select
local min = min
local format = string.format

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "System",
    side = "left",
    description = "Latency, Frame rate and addon memory usage information",
    height = 20,
}

----------------------------------
-- Functions
----------------------------------
local function OnEnter(self)
    if InCombatLockdown() then return end
    -- tt = Tooltip(self)
    --GameTooltip:SetTemplate("Default", nil, true)
    --local r, g, b = GameTooltip:GetBackdropColor()
    -- GameTooltip:SetBackdropColor(0, 0, 0, .45)
    -- GameTooltip:SetBackdropBorderColor(0, 0, 0, 0)
    -- local object = GameTooltip
    -- for i=1, object:GetNumRegions() do
    --     local region = select(i, object:GetRegions())
    --     if region and region:GetObjectType() == "Texture" then
    --         region:SetTexture(nil)
    --     end
    -- end
    --GameTooltip:SetOwner(self,"ANCHOR_BOTTOMRIGHT",0,20)
    -- tt:AddLine(module.name)
    -- tt:AddLine(" ")
    -- tt:AddDoubleLine("links", "rechts")
    -- tt:AddDoubleLine("links", "rechts")

    -- tt:Show()
    --GameTooltip:SetOwner(self,"ANCHOR_BOTTOMRIGHT",0,20)
    -- local object = GameTooltip
    -- for i=1, object:GetNumRegions() do
    --     local region = select(i, object:GetRegions())
    --     if region and region:GetObjectType() == "FontString" then
    --         texture = region:GetName()
    --         print(texture)
    --     end
    -- end
    print(GameTooltip.TextLeft1:GetText())
    GameTooltip:AddLine(module.name)
    GameTooltip:AddDoubleLine("links", "rechts")
    GameTooltip:AddDoubleLine("links", "rechts")
    GameTooltip:Show()

end

local function OnLeave()
    if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
end

local function OnUpdate(self, e)
     elapsed = elapsed + e
     if elapsed >= 1 then
        -- Latency
        local _, _, home, world = GetNetStats()
        self.latencyText:SetText(format("%sms (%s)", home, world))
        -- Framerate
        self.fpsText:SetText(format("%sfps", floor(GetFramerate())))
        elapsed = 0
     end
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("BUTTON","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-100)
baseFrame:SetSize(V.defaults.frame.width, module.height)
baseFrame:EnableMouse(true)
baseFrame:RegisterForClicks("AnyUp")
baseFrame:SetScript('OnUpdate', OnUpdate)
baseFrame:SetScript("OnEnter", OnEnter) 
baseFrame:SetScript("OnLeave", OnLeave)
-- baseFrame:SetScript("OnClick", OnClick)
if V.debug then DebugFrame(baseFrame) end


----------------------------------
-- Content Frame(s)
----------------------------------

-- Latency -----------------------
local latencyFrame = CreateFrame("FRAME","$parent.Latency", baseFrame)

local latencyText = latencyFrame:CreateFontString(nil, "OVERLAY")
latencyText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
latencyText:SetTextColor(unpack(V.defaults.text.color.dim))
latencyText:SetJustifyH("LEFT")
latencyText:SetPoint("LEFT", baseFrame, "LEFT", 6, 0)
baseFrame.latencyText = latencyText

-- Framerate ---------------------
local fpsFrame = CreateFrame("FRAME","$parent.FPS", baseFrame)

local fpsText = fpsFrame:CreateFontString(nil, "OVERLAY")
fpsText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
fpsText:SetTextColor(unpack(V.defaults.text.color.dim))
fpsText:SetJustifyH("RIGHT")
fpsText:SetPoint("RIGHT", baseFrame, "RIGHT", -6, 0)
baseFrame.fpsText = fpsText


-- CHEAP MODULE REGISTERING ------
V.frames.system = baseFrame
V.modules.system = module

----------------------------------
-- Event Handling
----------------------------------

-- EVENTS ------------------------
local events = {
    --"PLAYER_ENTERING_WORLD",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
