local addon, ns = ...
local config = ns.config

----------------------------------
-- Details! Object
----------------------------------
local details = _G.Details
--local IsInParty = IsInParty

----------------------------------
-- Functions
----------------------------------
local function SpawnDetailsBar(idx,height)
    statusbar = CreateFrame("STATUSBAR", "VuBarDetailsBar"..idx, VuBarCoreRightDetailsDPS)
    statusbar:SetStatusBarTexture(config.media.path..config.media.statusbar)
    statusbar:GetStatusBarTexture():SetHorizTile(false)
    statusbar:SetWidth(config.media.width - 2)
    statusbar:SetHeight(height-1)
    statusbar:SetPoint("TOP",0,- (idx*height))
    statusbar:SetMinMaxValues(1, 100)
    statusbar:SetValue(100-(8*idx))
    statusbar:SetStatusBarColor(0,1,0)

    return statusbar
end

local function readableNumbers(value)
    local mult = 10^1
    if value > 10000000 then
        value = floor((value/1000000) * mult + 0.5) / mult
        value = value .. "m"
    elseif value > 1000 then
        value = floor((value/1000) * mult + 0.5) / mult
        value = value .. "k"
    end
    return value
end

----------------------------------
-- Details Frame
----------------------------------
local detailsFrame = CreateFrame("FRAME","$parentDetails", config.rframe)
detailsFrame:SetPoint("TOP",0,-200)
--detailsFrame:SetSize(140, 60)
if config.debug then
    detailsFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
    detailsFrame:SetBackdropColor(0, 0, 0, 0.2)
end


----------------------------------
-- DPS Frame
----------------------------------
local dpsheaderFrame = CreateFrame("FRAME",nil, detailsFrame)
dpsheaderFrame:SetSize(140, 20)
dpsheaderFrame:SetPoint("TOP")

local dpsheaderText = dpsheaderFrame:CreateFontString(nil, "OVERLAY")
dpsheaderText:SetFont(config.text.font, 12)
dpsheaderText:SetTextColor(.4,.4,.4)
dpsheaderText:SetJustifyH("CENTER")
dpsheaderText:SetPoint("RIGHT", dpsheaderFrame, "RIGHT", -6, 0)
dpsheaderText:SetText("damage")

local dpsFrame = CreateFrame("FRAME", "$parentDPS", detailsFrame)
dpsFrame:SetPoint("CENTER",0,0)

local dpsText = dpsFrame:CreateFontString(nil, "OVERLAY")
dpsText:SetTextColor(.8,.8,.8)



local healFrame = CreateFrame("FRAME", nil, detailsFrame)

----------------------------------
-- Details Test Text - WORKS. Will update active combat dps.
----------------------------------
-- local detailsText = detailsFrame:CreateFontString(nil, "OVERLAY")
-- detailsText:SetFont(config.text.font, 12)
-- detailsText:SetTextColor(.4,.4,.4)
-- detailsText:SetJustifyH("CENTER")
-- detailsText:SetPoint("LEFT", detailsFrame, "LEFT", 6, 0)


-- detailsFrame:HookScript('OnUpdate', function()
--      local damageActor = details:GetActor("current", DETAILS_ATTRIBUTE_DAMAGE, details.playername)
--      detailsText:SetText(details.playername..":"..floor(damageActor.total))
-- end)


----------------------------------
-- Details Actors Frame
----------------------------------
-- Important functions
-- local damageActors = details:GetActorsOnDamageCache()
-- only usable while in combat, it returns a numeric table with all damage actors in the group (combatlog flag matching 0x00000007).
-- this table can be freely sorted.

-- local healingActors = details:GetActorsOnHealingCache()
-- only usable while in combat, it returns a numeric table with all healing actors in the group (combatlog flag matching 0x00000007).
-- this table can be freely sorted.

-- damageactorList = combat:GetActorList(DETAILS_ATTRIBUTE_DAMAGE)

----------------------------------
-- Plan
----------------------------------
--[[
2 Windows Possible: DPS and HPS

Solo Mode: DPS
Big Number in the middle

Party Mode 
Event: Something_with_party spawns 2 windows 5 bars

Raid Mode
Event: Something_with_raid





]]
local combat = details:GetCurrentCombat()
local actor = details:GetActor("current", DETAILS_ATTRIBUTE_DAMAGE, details.playername)

dpsFrame:HookScript('OnUpdate', function()
    if not IsInGroup() and not IsInRaid() then
        local combat = details:GetCurrentCombat()
        local actor = details:GetActor("current", DETAILS_ATTRIBUTE_DAMAGE, details.playername)
        local dps = actor.total / combat:GetCombatTime()
        dps = readableNumbers(dps)
        dpsText:SetText(dps)
    end
end)
----------------------------------
-- Event Frame
----------------------------------
local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("GROUP_ROSTER_UPDATE")
eventframe:RegisterEvent("PARTY_CONVERTED_TO_RAID")

eventframe:SetScript("OnEvent", function(self,event, ...)
    if not IsInRaid() then
        local barheight = 16
        detailsFrame:SetSize(140, 9*(barheight+1)+1)
        dpsFrame:SetSize(140,9*(barheight+1))
        dpsFrame:SetPoint("TOP",0,-20)
        dpsText:SetFont(config.text.font, 12)
        dpsText:SetPoint("CENTER",0,2)
        --dpsText:SetText(5*barheight)
        for i = 0,9 do
            unit = "party"..i
            if i == 0 then unit = "player" end
            SpawnDetailsBar(i,barheight)
        end

    elseif not IsInGroup() then
        local barheight = 20
        detailsFrame:SetSize(140, 120)
        dpsFrame:SetSize(140,5*barheight)
        dpsFrame:SetPoint("TOP",0,-20)
        dpsText:SetFont(config.text.font, 12)
        dpsText:SetPoint("CENTER",0,2)
        --dpsText:SetText(5*barheight)
        for i = 0,4 do
            unit = "party"..i
            if i == 0 then unit = "player" end
            SpawnDetailsBar(i,dpsframe)
        end
    else
        detailsFrame:SetSize(140, 60)
        dpsFrame:SetSize(140,40)
        dpsText:SetFont(config.text.font, 20)
        dpsText:SetPoint("CENTER",0,-4)
        dpsText:SetJustifyH("CENTER")
        --dpsText:SetText("SOLO")
    end
     
end)

