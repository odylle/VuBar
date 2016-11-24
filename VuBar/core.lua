local addon, ns = ...

local V = {}
ns.V = V

--local V.config.= {}
--ns.V.config.= config
--local frames = {}
--ns.frames = frames

local unpack = unpack
----------------------------------
-- V.configuration
----------------------------------
--V.config.media = "Interface\\AddOns\\"..addon.."\\media\\"
V.config.player = UnitName("player")
V.config.class = select(2, UnitClass("player"))
V.config.realm = GetRealmName()
-- Media Defaults
V.config.media = {
     path = "Interface\\AddOns\\"..addon.."\\media\\",
     statusbar = "Flat"
}
-- Text Defaults
V.config.text = {
    font = V.config.media.."homizio_bold.ttf",
    normalFontSize = 12,
    bigFontSize = 20,
    header = {
        color = { .4, .4, .4}
    },
}
-- Core Frame Defaults
V.config.frame = {
    width = 140,
    height = GetScreenHeight(),
    strata = "BACKGROUND",
    background = { 0, 0, 0, .35}
    left = true,
    right = true,
}
-- Modules Defaults
V.config.modules = {
    clock = {
        order = 0,
        side = "Left",
    },
    system = {
        order = 1,
        side="Left"
    },
    social = {
        order = 2,
        side = "Left"
    },
    resources = {
        order = 3,
        side = "Left",
    },
    armor = {
        order = 4,
        side = "Left",
    },
    talent = {
        order = 5,
        side = "Left",
    },
}

-- debug functions
V.config.debug = true

---------------------------------------------
-- SAVED VARIABLES TABLE
---------------------------------------------
-- copies missing fields from source table
function CopyTable(src, dest)
    if type(dest) ~= "table" then
        dest = {}
    end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = CopyTable(v, dest[k])
        elseif type(v) ~= type(dest[k]) then
            dest[k] = v
        end
    end

    return dest
end

-- removes everything that is present in source table from another table
function DiffTable(src, dest)
    if type(dest) ~= "table" then
        return {}
    end

    if type(src) ~= "table" then
        return dest
    end

    for k, v in pairs(dest) do
        if type(v) == "table" then
            if not next(DiffTable(src[k], v)) then
                dest[k] = nil
            end
        elseif v == src[k] then
            dest[k] = nil
        end
    end

    return dest
end

----------------------------------
-- Functions
----------------------------------
local function SpawnFrame(side)
    local VuBarCore = CreateFrame("Frame","VuBarCore"..side, UIParent)   
    VuBarCore:SetSize(V.config.frame.width, V.config.frame.height)
    VuBarCore:SetFrameStrata(V.config.frame.strata)
    VuBarCore:SetPoint(string.upper(side))

    local background = VuBarCore:CreateTexture(nil,"BACKGROUND",nil,-8)
    background:SetAllPoints()
    background:SetColorTexture(unpack(V.config.frame.background))
    VuBarCore.background = background

    return VuBarCore
end

local function EventHandler(self, event, arg)
    if event == "ADDON_LOADED" and arg == addon then    
        -- Load Savedvariables
        -- local VuBarVars = CopyTable(D, VuBarVars)
        -- if type(VuBarVars) ~= "table" then
        --     ns.VuBarVars = {}
        --     ns.VuBarVars[V.config.realm] = {}
        --     ns.VuBarVars[V.config.realm][V.config.player] = {}
        -- else            
        --     ns.VuBarVars = VuBarVars
        -- end
    elseif event == "PLAYER_LOGIN" then
        -- Do something with the SavedVariables

    elseif event == "PLAYER_LOGOUT" then

        -- Save SavedVariables
        -- VuBarVars = DiffTable(D, ns.VuBarVars)
    elseif event == "PET_BATTLE_OPENING_START" then

        -- Hide VuBar Frames
    elseif event == "PET_BATTLE_CLOSE" then

        -- Show VuBar Frames
    end
end

----------------------------------
-- Spawn Frames
----------------------------------
if V.config.frame.left then
    lframe = SpawnFrame("Left")
    lframe:Show()
    V.frames.left = lframe
end
if V.config.frame.right then
    rframe = SpawnFrame("Right")
    rframe:Show()
    V.frames.right = rframe
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
