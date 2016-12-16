local addon, ns = ...

local V = {}
ns.V = V
----------------------------------
-- SetUp Mode Helper
----------------------------------
V.debug = false

----------------------------------
-- Blizz Api & Variables
----------------------------------
local UnitName = UnitName
local UnitClass = UnitClass
local GetRealmName = GetRealmName
local UnitLevel = UnitLevel
local UnitFactionGroup = UnitFactionGroup
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
    },
    myriad = {
        bold = media.fonts.."MyriadPro-Bold.ttf",
        bold_cond = media.fonts.."MyriadPro-BoldCond.ttf",
        bold_cond_it = media.fonts.."MyriadPro-BoldCondIt.ttf",
        bold_it = media.fonts.."MyriadPro-BoldIt.ttf",
        cond = media.fonts.."MyriadPro-Cond.ttf",
        cond_it = media.fonts.."MyriadPro-CondIt.ttf",
        it = media.fonts.."MyriadPro-It.ttf",
        regular = media.fonts.."MyriadPro-Regular.ttf",
        semi_bold = media.fonts.."MyriadPro-Semibold.ttf",
        semi_bold_it = media.fonts.."MyriadPro-SemiboldIt.ttf",
    },
}
----------------------------------
-- Defaults (Font, Sizes)
----------------------------------
local defaults = {
	text = {
		font = {
			main = fonts.myriad.cond,
			bold = fonts.myriad.bold_cond,
            italic = fonts.myriad.cond_it
		},
		small = 11,
		normal = 13,
		large = 16,
		xlarge = 20,
		color = {
			bright = {.9, .9, .9},
			dim = {.6, .6 ,.6},
			header = {.4, .4, .4},
		},
	},
	statusbar = media.textures.."Flat",
	frame = {
		width = 160,		
		height = GetScreenHeight(),
		strata = "BACKGROUND",
		background = {0, 0, 0, .35 },
		anchor = "TOP",
	},
    tooltip = {
        width = 160,
        strata = "TOOLTIP",
        background = {0, 0, 0, .6},
        show = false
    }
}
V.defaults = defaults

----------------------------------
-- Config Parameters & SavedVariables
----------------------------------
local constants = {
    player = {
        name = UnitName("player"),
        class = select(2, UnitClass("player")),
        realm = GetRealmName(),
        level = UnitLevel("player"),
        faction = UnitFactionGroup("player")
    }
}
V.constants = constants

----------------------------------
-- Modules Handling - NEW
----------------------------------
local function IterateModules(modules)

end

local modules = {}
V.modules = modules

----------------------------------
-- Saved Variables
----------------------------------
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
-- Spawn Sidebar Frames
----------------------------------
V.frames= {}
local function SpawnSidebar(side)
    local f = CreateFrame("Frame","VuBarSide"..side, UIParent)   
    f:SetSize(V.defaults.frame.width, V.defaults.frame.height)
    f:SetFrameStrata(V.defaults.frame.strata)
    f:SetPoint(string.upper(side))

    local background = f:CreateTexture(nil,"BACKGROUND",nil,-8)
    background:SetAllPoints()
    background:SetColorTexture(unpack(V.defaults.frame.background))
    f.background = background
    return f    
end

-- Spawn Sidebars
left = SpawnSidebar("Left")
left:Show()
V.frames.left = left
right = SpawnSidebar("Right")
right:Show()
V.frames.right = right

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
local D = {}
function EventFrame:ADDON_LOADED(arg)
    if arg ~= addon then return end
    -- Load Saved variables
    local VARS = CopyTable(D, VuBarVars)
    ns.VARS = VARS

    if not VARS[constants.player.realm] then VARS[constants.player.realm] = {} end
    if not VARS[constants.player.realm][constants.player.name] then VARS[constants.player.realm][constants.player.name] = {} end
    ns.playerData = VARS[constants.player.realm][constants.player.name]

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_LOGOUT")
    self:UnregisterEvent("ADDON_LOADED")    
end

function EventFrame:PLAYER_LOGIN()
    if not ns.playerData["class"] then ns.playerData["class"] = constants.player.class end
    if not ns.playerData["level"] then ns.playerData["level"] = constants.player.level end
    if not ns.playerData["faction"] then ns.playerData["faction"] = constants.player.faction end
    self:UnregisterEvent("PLAYER_LOGIN")
end

function EventFrame:PLAYER_LOGOUT()
    -- Save Variables
    VuBarVars = DiffTable(D, ns.VARS)
end

----------------------------------
EventFrame:RegisterEvent("ADDON_LOADED")