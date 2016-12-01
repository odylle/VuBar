local addon, ns = ...

local V = {}
ns.V = V
----------------------------------
-- SetUp Mode Helper
----------------------------------
V.debug = true

----------------------------------
-- Blizz Api & Variables
----------------------------------
local UnitName = UnitName
local UnitClass = UnitClass
local GetRealmName = GetRealmName
local GetScreenHeight = GetScreenHeight
-- LUA Functions -----------------
local select = select

----------------------------------
-- Media & Fonts
----------------------------------
local media = {
    fonts = "Interface\\AddOns\\"..addon.."\\media\\fonts\\",
    textures = "Interface\\AddOns\\"..addon.."\\media\\textures\\",
}
V.media = media

local fonts = {
    homizio = {
        bold = media.fonts.."homizio_bold.ttf",
        black = media.fonts.."homizio_black.ttf",
        light = media.fonts.."homizio_light.ttf",
        medium = media.fonts.."homizio_medium.ttf",
        regular = media.fonts.."homizio_regular.ttf",
        thin = media.fonts.."homizio_thin.ttf",    
    }
}
----------------------------------
-- Defaults (Font, Sizes)
----------------------------------
local defaults = {
    text = {
        font = {
            main = fonts.homizio.bold,
            bold = fonts.homizio.black,
        },
        small = 11,
        normal = 12,
        large = 16,
        xlarge = 20,
        color = {
            bright = { .9, .9, .9},
            dim = { .6, .6 ,.6},
            header = { .4, .4, .4}
    },
    statusbar = media.textures.."Flat",
    frame = {
        width = 160,
        maxheight = GetScreenHeight(),
        strata = "BACKGROUND",
        background = { 0, 0, 0, .35 },
        anchor = "TOP",
    }
}
V.defaults = defaults

----------------------------------
-- Config Parameters
----------------------------------
local config = {
    player = {
        name = Unitname("player"),
        class = select(2, UnitClass("player")),
        realm = GetRealmName()
    }
}
V.config = config

----------------------------------
-- Modules Handling
----------------------------------
local function IterateModules(modules)

end

local modules = {}
V.modules = modules

----------------------------------
-- Sidebars
----------------------------------
local function SpawnSidebar(side)
    local frame = CreateFrame("Frame","VuBarSide"..side, UIParent)   
    frame:SetSize(V.defaults.frame.width, V.defaults.frame.height)
    frame:SetFrameStrata(V.defaults.frame.strata)
    frame:SetPoint(string.upper(side))

    local background = frame:CreateTexture(nil,"BACKGROUND",nil,-8)
    background:SetAllPoints()
    background:SetColorTexture(unpack(V.defaults.frame.background))
    frame.background = background

    return frame    
end

----------------------------------
-- Event Handling - Experimental
----------------------------------
local function EventHandler(self, event, ...)
    self[event](self, ...)
end
V.EventHandler = EventHandler
-- function EventFrame:{EVENTNAME}()

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", EventHandler)
V.EventFrame = EventFrame


----------------------------------
-- Events
----------------------------------
local function EventFrame:ADDON_LOADED(arg)
    if arg ~= addon then return end
    -- Load Saved variables
    
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_LOGOUT")
    self:UnregisterEvent("ADDON_LOADED")    
end

local function EventFrame:PLAYER_LOGIN()
    -- Spawn Sidebars
    left = SpawnSidebar("Left")
    left:Show()
    right = SpawnSidebar("Right")
    right:Show()
    V.frames = {
        left = left,
        right = right
    }
end

local function EventFrame:PLAYER_LOGOUT()
    -- Save Variables
end

----------------------------------
EventFrame:RegisterEvent("ADDON_LOADED")