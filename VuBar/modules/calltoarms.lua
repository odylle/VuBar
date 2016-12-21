local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, Tooltip, DebugFrame = V.EventHandler, V.Tooltip, V.DebugFrame

----------------------------------
-- Blizz Api & Variables
----------------------------------
local GetAvailableRoles = C_LFGList.GetAvailableRoles
local GetLFGRoleShortageRewards = GetLFGRoleShortageRewards
local GetLFDRoleRestrictions = GetLFDRoleRestrictions
local GetLFGDungeonShortageRewardInfo = GetLFGDungeonShortageRewardInfo
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetNumRandomDungeons = GetNumRandomDungeons
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetNumRFDungeons = GetNumRFDungeons
local GetRFDungeonInfo = GetRFDungeonInfo

-- LUA Functions -----------------


----------------------------------
-- Module Config
----------------------------------
local module = {
name = "CallToArms",
description = "Display LFR/LFG rewards",
height = 0,
padding = 5,
}

----------------------------------
-- Functions
----------------------------------

local function checkStatus()
    local data = {}
    local canTank, canHealer, canDamage = GetAvailableRoles() 
    function updateShortageInfo(dID) 
        for j = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
            local eligible, tank, healer, damage, itemCount, money, xp = GetLFGRoleShortageRewards(dID, j)
            local tankLocked, healerLocked, damageLocked = GetLFDRoleRestrictions(dID)
            tank = tank and canTank and not tankLocked
            healer = healer and canHealer and not healerLocked
            damage = damage and canDamage and not damageLocked
            if(eligible and itemCount > 0 and (tank or healer or damage)) then
                local rewardName, rewardIcon = GetLFGDungeonShortageRewardInfo(dID, j, 1)
                data[dID] = {dID=dID, name=GetLFGDungeonInfo(dID), rewardName=rewardName, rewardIcon=rewardIcon, tank=tank, healer=healer, damage=damage}
            end
        end
    end

    for i = 1, GetNumRandomDungeons() do
        local dID = GetLFGRandomDungeonInfo(i)
        updateShortageInfo(dID)
    end

    for i = 1,GetNumRFDungeons() do
        local dID = GetRFDungeonInfo(i)
        updateShortageInfo(dID)
    end
    return data
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint("BOTTOM",V.frames.left,"BOTTOM",0,0)
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------


-- C_Timer.After(5, function() RequestLFDPlayerLockInfo() end)

-- RequestLFDPlayerLockInfo()",
--             "do_custom": true
--         }


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

end
function EventFrame:LFG_UPDATE_RANDOM_INFO()

end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "LFG_UPDATE_RANDOM_INFO",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
