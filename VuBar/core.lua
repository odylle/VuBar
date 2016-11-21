local addon, ns = ...

local config = {}
ns.config = config

local frames = {}
ns.frames = frames

local unpack = unpack
----------------------------------
-- Configuration Things
----------------------------------
--config.media = "Interface\\AddOns\\"..addon.."\\media\\"
config.player = UnitName("player")
config.class = select(2, UnitClass("player"))
config.realm = GetRealmName()
-- Text Defaults
config.text = {
    font = config.media.."homizio_bold.ttf",
    normalFontSize = 12,
    bigFontSize = 20,
    header = {
        color = { .4, .4, .4}
    },
}
-- Media Defaults
config.media = {
     path = "Interface\\AddOns\\"..addon.."\\media\\",
     statusbar = "Flat"
}
-- Core Frame Defaults
config.frame = {
    width = 140,
    height = GetScreenHeight(),
    strata = "BACKGROUND",
    background = { 0, 0, 0, .35}
    left = {
        enabled = true,
    },
    right = {
        enabled = true,
    },
}
-- debug functions
config.debug = true

----------------------------------
-- Functions
----------------------------------
local function SpawnFrame(side)
    local VuBarCore = CreateFrame("Frame","VuBarCore"..side, UIParent)   
    VuBarCore:SetSize(config.frame.width, config.frame.height)
    VuBarCore:SetFrameStrata(config.frame.strata)
    VuBarCore:SetPoint(string.upper(side))

    local background = VuBarCore:CreateTexture(nil,"BACKGROUND",nil,-8)
    background:SetAllPoints()
    background:SetColorTexture(unpack(config.frame.background))
    VuBarCore.background = background

    return VuBarCore
end

local function EventHandler(self, event, arg)
    if event == "ADDON_LOADED" and arg == addon then    
        -- Load Savedvariables
        ns.VuBarVars = VuBarVars
        if type(VuBarVars) ~= "table" then
            VuBarVars = {}
            VuBarVars[config.realm] = {}
            VuBarVars[config.realm][config.player] = {}
        end
    elseif event == "PLAYER_LOGIN" then
        -- Do something with the SavedVariables

    elseif event == "PLAYER_LOGOUT" then

        -- Save SavedVariables
    elseif event == "PET_BATTLE_OPENING_START" then

        -- Hide VuBar Frames
    elseif event == "PET_BATTLE_CLOSE" then

        -- Show VuBar Frames
    end
end


----------------------------------
-- Spawn Frames
----------------------------------
if config.frame.left.enabled then
    lframe = SpawnFrame("Left")
    lframe:Show()
    frames.left = lframe
end
if config.frame.right.enabled then
    rframe = SpawnFrame("Right")
    rframe:Show()
    frames.right = rframe
end

----------------------------------
-- Event Frame
----------------------------------
local eventframe = CreateFrame("Frame",nil, UIParent)
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:RegisterEvent("PLAYER_LOGIN")
--eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("PLAYER_LOGOUT")
eventframe:RegisterEvent("PET_BATTLE_OPENING_START")
eventframe:RegisterEvent("PET_BATTLE_CLOSE")
eventframe:SetScript("OnEvent", EventHandler)
