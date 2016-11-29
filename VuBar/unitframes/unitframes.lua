local name, addon = ...
local V = ns.V

local unpack, select = unpack, select

local UnitClass = UnitClass
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
----------------------------------
-- Premiss
----------------------------------
--[[
Player, Target, Pet, ToT, Focus, Focus Target, Boss Frames
PLAYER: Right Mouse Menu, Left = Target
* fullHPcolor (0, 0, 0, .5)
* classcolor deficit
* .3 opacity for OoR
* threat percentage if DAMAGER and > 85% OR TANK
* party: ReadyCheck
]]
--local cCol = string.format("%02X%02X%02X", RAID_CLASS_COLORS[classFileName].r*255, RAID_CLASS_COLORS[classFileName].g*255, RAID_CLASS_COLORS[classFileName].b*255)
-- local class, classFileName = UnitClass("target")
-- local color = RAID_CLASS_COLORS[classFileName]
-- ChatFrame1:AddMessage(class, color.r, color.g, color.b)

V.unitframes = {
    bgColor = {0, 0, 0, .6},
    normalFontSize = 12,
    largeFontSize = 20,
    width = 160,
    height = 36,
    strata = "LOW",
    player = {
        color = RAID_CLASS_COLORS[select(2, UnitClass("player"))],
        anchor = "BOTTOM",
        oX = -100,
        oY = 240,
    },
    target = {
        color = RAID_CLASS_COLORS[select(2, UnitClass("target"))],
        anchor = "BOTTOM",
        oX = 100,
        oY = 240,    
    },
    party = {
        width = 160-2,
        height = 36,
        padding = 10,
        anchor = "LEFT",
        parent = V.frames.left
    }
}
if V.debug then
    local FakeUnit = {
        player = {"Odylle", "WARRIOR", "DAMAGER"},
        pet = {"Imwithstupid"},
        target = {"Iheartu", "PALADIN", "DAMAGER"},
        tot = {"Suntzu", "MONK"}
        party1 = {"Kindofdead", "DEATHKNIGHT", "TANK"},
        party2 = {"Pewpewlazorz", "MAGE", "DAMAGER"},
        party3 = {"Stickfigure", "DRUID", "HEALER"},
        party4 = {"Stingy", "ROGUE", "DAMAGER"},
    }
end

local function SpawnUF(unit)
    local UF = CreateFrame("Frame","VubarUF"..unit, UIParent)   
    UF:SetSize(V.unitframes.width, V.unitframes.height)
    UF:SetFrameStrata(V.unitframes.strata)
    UF:SetPoint(V.unitframes[unit].anchor, V.unitframes[unit].oX, V.unitframes[unit].oY)
    UF:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    UF:SetBackdropColor(unpack(V.unitframes.bgColor))

    ----------------------------------
    -- Health
    ----------------------------------    
    local HP = CreateFrame("FRAME", "$parentHP", UF)
    HP:SetPoint("TOP",0,-1)
    HP:SetSize(V.unitframes.width-2, 30-2)
    -- BAR
    local HPBar = CreateFrame("STATUSBAR", "$parentBar", HP)
    HPBar:SetSize(V.unitframes.width-2, 30-2)
    HPBar:SetPoint("CENTER", 0, 0)
    HPBar:SetFrameStrata("BACKGROUND")
    HPBar:SetStatusBarTexture(V.config.media.path..V.config.media.statusbar)
    HPBar:SetStatusBarColor(V.unitframes[unit].color.r, V.unitframes[unit].color.g, V.unitframes[unit].color.b, .8)
    if unit == "player" then    
        HPBar:SetReverseFill(true)
    end
    UF.HPBar = HPBar
    -- TEXT
    local HPText = experienceBar:CreateFontString(nil, "OVERLAY")
    HPText:SetFont(V.config.text.font, V.unitframes.normalFontSize)
    HPText:SetTextColor(.9,.9,.9)
    HPText:SetJustifyH("RIGHT")
    HPText:SetPoint("RIGHT", HP, "RIGHT", -6, 0)
    HPText:SetText("77")
    UF.HPText = HPText

    ----------------------------------
    -- Power
    ----------------------------------
    local Power = CreateFrame("FRAME", "$parentPower", UF)
    Power:SetPoint("BOTTOM",0,1)
    Power:SetSize(V.unitframes.width-2, 7-2)

    local PowerBar = CreateFrame("STATUSBAR", "$parentBar", P)
    PowerBar:SetSize(V.unitframes.width-2, 7-2)
    PowerBar:SetPoint("CENTER", 0, 0)
    PowerBar:SetFrameStrata("BACKGROUND")
    PowerBar:SetStatusBarTexture(V.config.media.path..V.config.media.statusbar)
    PowerBar:SetStatusBarColor(0, 0.4, 1, .8)
    if unit == "player" then    
        PowerBar:SetReverseFill(true)
    end
    UF.PowerBar = PowerBar

    return UF    
end

local PlayerFrame = SpawnUF("player")
-- test
local current, max = 77, 100
PlayerFrame.HPBar:SetMinMaxValues(0, 100)
PlayerFrame.HPBar:SetValue(max-current)

-- local function SpawnSmallUF()

-- end

-- local function SpawnParty()

-- end

