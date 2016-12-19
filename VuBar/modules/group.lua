local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame
local elapsed = 0
local roles = { ["DAMAGER"] = 0, ["HEALER"] = 0, ["TANK"] = 0 }
local dead = CopyTable(roles)

----------------------------------
-- Blizz Api & Variables
----------------------------------
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GetLootMethod = GetLootMethod
local UnitIsUnit = UnitIsUnit
local CopyTable = CopyTable

-- LUA Functions -----------------
local format = string.format

----------------------------------
-- Module Config
----------------------------------
local module = {
    name = "Group",
    description = "Display party and raid info",
    height = 0,
    padding = 20,

}

----------------------------------
-- Functions
----------------------------------

-- Unit Naming in Group ----------
local function GetUnit()
    local unit
    if IsInGroup() then
        unit = "party"
        if IsInRaid() then
            unit = "raid"
        else
            local isInstance, instanceType = IsInInstance()
            if isInstance then
                if instanceType == "arena" then
                    unit = "arena"
                end
            end
        end
    else return end
    return unit
end

-- Leader ------------------------
local function GroupLeader()
    local leader
    if UnitIsGroupLeader("player") then
        local color = format("%02X%02X%02X", RAID_CLASS_COLORS[V.constants.player.class].r*255, RAID_CLASS_COLORS[V.constants.player.class].g*255, RAID_CLASS_COLORS[V.constants.player.class].b*255)
        leader = format("|cff%s%s|r", color, V.constants.player.name)
    else
        local unit = GetUnit()
        local groupSize = GetNumGroupMembers()
        for i = 1, groupSize do
            unit = unit .. i
            if UnitIsGroupLeader(unit) then
                local class, classFileName, classIndex = UnitClass(unit)
                local color = format("%02X%02X%02X", RAID_CLASS_COLORS[classFileName].r*255, RAID_CLASS_COLORS[classFileName].g*255, RAID_CLASS_COLORS[classFileName].b*255)
                leader = format("|cff%s%s|r", color, UnitName(unit)) 
            end
        end
    end
    return leader
end

-- SubGroup in Raids -------------
local function InSubGroup()
    local groupSize = GetNumGroupMembers()
    for i = 1, groupSize do
        local _, _, subgroup = GetRaidRosterInfo(i)
        local unit = GetUnit()
        if (UnitIsUnit(unit..i, "player")) then
            return subgroup
        end
    end
end

-- DPS, Healers & Tanks ----------
local function GroupComposition()
    -- local roles = {}
    -- roles.DAMAGER, roles.HEALER, roles.TANK = 0,0,0 
    local groupSize = GetNumGroupMembers()
    if not IsInRaid() then
        local isArena = IsActiveBattlefieldArena()
        if not isArena and IsInGroup() then
            local role = UnitGroupRolesAssigned("player")
            roles[role] = roles[role] + 1
            for i = 1, (groupSize-1) do
                local role = UnitGroupRolesAssigned("party"..i)
                roles[role] = roles[role] + 1
            end
        else
            for i = 1, groupSize do
                local role = UnitGroupRolesAssigned("arena"..i)
                roles[role] = roles[role] + 1                
            end
        end
    else
        for i = 1, groupSize do
            local role = UnitGroupRolesAssigned("raid"..i)
            roles[role] = roles[role] + 1             
        end
    end
    return roles
end

-- Loot Method -------------------
local function LootMethod()
    local method, _, _ = GetLootMethod()
    if method == "freeforall" then
        return "ffa"
    elseif method == "group" then
        return "group loot"
    elseif method == "master" then
        return "master loot"
    elseif method == "needbeforegreed" then
        return "need > greed"
    elseif method == "personalloot" then
        return "personal"
    elseif method == "roundrobin" then
        return "round robin"
    end
end

-- Type of Group -----------------
local function GroupTypeText()
    local text
    local isInstance, instanceType = IsInInstance()
    local inGuildGroup = InGuildParty()
    if isInstance then
        local name, groupType, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
        if groupType == "arena" then
            text = "Arena"
        elseif groupType == "party" then
            text = "Party"
        elseif groupType == "pvp" then
            text = "Battleground"
        elseif groupType == "raid" then
            text = "Raid"
        else
            text = "Unknown"
        end 
    else
        if IsInRaid() then
            text = "Raid"
        else
            text = "Party"
        end
    end
    if inGuildGroup then
        text = format("|cffff7f3f%s|r", text)
    end
    return text
end

-- Group Health ------------------
local function GroupOnUpdate(self, e)
    local groupSize = GetNumGroupMembers()
    local damagerHealth, healerHealth, tankHealth
    elapsed = elapsed + e
    if elapsed >= 1 then
        roles.DAMAGER = V.frames.group.dpsTotalText:GetText() or 0
        roles.HEALER = V.frames.group.healerTotalText:GetText() or 0
        roles.TANK = V.frames.group.tankTotalText:GetText() or 0
        if IsInRaid() then
            for i = 1, groupSize do
                local role = UnitGroupRolesAssigned("raid"..i)
                local _, _, _, _, _, _, _, _, isDead = GetRaidRosterInfo(i)
                if isDead then
                    dead[role] = dead[role] + 1
                end
            end
        else
            local isArena = IsActiveBattlefieldArena()
            if not isArena then
                local role = UnitGroupRolesAssigned("player")
                if UnitIsDeadOrGhost("player") then
                    dead[role] = dead[role] + 1
                end
                for i = 1, (groupSize-1) do
                    local role = UnitGroupRolesAssigned("party"..i)
                    if UnitIsDeadOrGhost("party"..i) then
                        dead[role] = dead[role] + 1
                    end
                end
            else
                for i = 1, groupSize do
                    local role = UnitGroupRolesAssigned("arena"..i)
                    if UnitIsDeadOrGhost("arena"..i) then
                        dead[role] = dead[role] + 1
                    end
                end
            end
        end
        -- DAMAGERS
        if roles.DAMAGER > dead.DAMAGER then
            damagerHealth = format("|cffff0000%s|r/%s", roles.DAMAGER, dead.DAMAGER)
        else
            damagerHealth = roles.DAMAGER
        end
        V.frames.group.dpsTotalText:SetText(damagerHealth) 
        -- HEALER
        if roles.HEALER > dead.HEALER then
            healerHealth = format("|cffff0000%s|r/%s", roles.HEALER, dead.HEALER)
        else
            healerHealth = roles.HEALER
        end
        V.frames.group.healerTotalText:SetText(healerHealth) 
        -- DAMAGERS
        if roles.TANK > dead.TANK then
            tankHealth = format("|cffff0000%s|r/%s", roles.TANK, dead.TANK)
        else
            tankHealth = roles.TANK
        end
        V.frames.group.tankTotalText:SetText(tankHealth)
        local dead = { ["DAMAGER"] = 0, ["HEALER"] = 0, ["TANK"] = 0 } 
        elapsed = 0
    end
end

----------------------------------
-- Base Frame
----------------------------------
local baseFrame = CreateFrame("FRAME","$parent."..module.name, V.frames.left)
baseFrame:SetParent(V.frames.left)
baseFrame:SetPoint(V.defaults.frame.anchor,0,-(260+module.padding))
baseFrame:SetSize(V.defaults.frame.width, module.height)
if V.debug then DebugFrame(baseFrame) end

----------------------------------
-- Content Frame(s)
----------------------------------

-- Type of Group -----------------
local groupTypeFrame = CreateFrame("FRAME", "$parent.Type", baseFrame)
groupTypeFrame:SetParent(baseFrame)
groupTypeFrame:SetSize(V.defaults.frame.width, 20)
groupTypeFrame:SetPoint("TOP", 0, -(module.padding))
module.height = module.height+groupTypeFrame:GetHeight()

local groupTypeLText = groupTypeFrame:CreateFontString(nil, "OVERLAY")
groupTypeLText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
groupTypeLText:SetTextColor(unpack(V.defaults.text.color.bright))
groupTypeLText:SetJustifyH("LEFT")
groupTypeLText:SetPoint("LEFT", groupTypeFrame, "LEFT", 8, 0)
groupTypeLText:SetText("groupType")
baseFrame.groupTypeName = groupTypeLText

local groupTypeRText = groupTypeFrame:CreateFontString(nil, "OVERLAY")
groupTypeRText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
groupTypeRText:SetTextColor(unpack(V.defaults.text.color.dim))
groupTypeRText:SetJustifyH("RIGHT")
groupTypeRText:SetPoint("RIGHT", groupTypeFrame, "RIGHT",-6,-3)
--groupTypeRText:SetText("group 1")
baseFrame.groupTypeGroup = groupTypeRText

-- Leader ------------------------
local leaderFrame = CreateFrame("FRAME", "$parent.Leader", baseFrame)
leaderFrame:SetSize(V.defaults.frame.width, 20)
leaderFrame:SetPoint("TOP", 0, -(20+module.padding))
module.height = module.height+leaderFrame:GetHeight()

local leaderLText = leaderFrame:CreateFontString(nil, "OVERLAY")
leaderLText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
leaderLText:SetTextColor(unpack(V.defaults.text.color.bright))
leaderLText:SetJustifyH("LEFT")
leaderLText:SetPoint("LEFT", leaderFrame, "LEFT", 10, -2)
leaderLText:SetText("leader")

local leaderRText = leaderFrame:CreateFontString(nil, "OVERLAY")
leaderRText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
leaderRText:SetTextColor(unpack(V.defaults.text.color.dim))
leaderRText:SetJustifyH("RIGHT")
leaderRText:SetPoint("RIGHT", leaderFrame, "RIGHT",-6,-2)
baseFrame.leaderName = leaderRText

-- Loot Method -------------------
local lootMethodFrame = CreateFrame("FRAME", "$parent.LootMethod", baseFrame)
lootMethodFrame:SetSize(V.defaults.frame.width, 20)
lootMethodFrame:SetPoint("TOP", 0, -(40+module.padding))
module.height = module.height+lootMethodFrame:GetHeight()

local lootMethodLText = lootMethodFrame:CreateFontString(nil, "OVERLAY")
lootMethodLText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
lootMethodLText:SetTextColor(unpack(V.defaults.text.color.bright))
lootMethodLText:SetJustifyH("LEFT")
lootMethodLText:SetPoint("LEFT", lootMethodFrame, "LEFT", 10, -2)
lootMethodLText:SetText("loot method")

local lootMethodRText = lootMethodFrame:CreateFontString(nil, "OVERLAY")
lootMethodRText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
lootMethodRText:SetTextColor(unpack(V.defaults.text.color.dim))
lootMethodRText:SetJustifyH("RIGHT")
lootMethodRText:SetPoint("RIGHT", lootMethodFrame, "RIGHT",-6,-2)
--lootMethodRText:SetText("personal")
baseFrame.lootMethod = lootMethodRText

-- Group Composition -------------
local groupCompositionFrame = CreateFrame("FRAME", "$parent.Composition", baseFrame)
groupCompositionFrame:SetSize(V.defaults.frame.width, 40)
groupCompositionFrame:SetPoint("TOP", 0, -(55+module.padding))
--groupCompositionFrame:SetScript("OnUpdate", GroupOnUpdate)
module.height = module.height+groupCompositionFrame:GetHeight()

-- Tanks -------------------------
local tankFrame = CreateFrame("FRAME", "$parent.tank", baseFrame)
tankFrame:SetParent(groupCompositionFrame)
tankFrame:SetSize(V.defaults.frame.width/3, 40)
tankFrame:SetPoint("TOPLEFT")

local tankTotalTText = tankFrame:CreateFontString(nil, "OVERLAY")
tankTotalTText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
tankTotalTText:SetTextColor(unpack(V.defaults.text.color.bright))
tankTotalTText:SetJustifyH("TOP")
tankTotalTText:SetPoint("CENTER", tankFrame, "CENTER", 0, -1)
baseFrame.tankTotalText = tankTotalTText

local tankTotalBText = tankFrame:CreateFontString(nil, "OVERLAY")
tankTotalBText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
tankTotalBText:SetTextColor(unpack(V.defaults.text.color.dim))
tankTotalBText:SetJustifyH("CENTER")
tankTotalBText:SetPoint("BOTTOM", tankFrame, "BOTTOM", 0, 1)
tankTotalBText:SetText("tank")

-- Healers -----------------------
local healerFrame = CreateFrame("FRAME", "$parent.healer", baseFrame)
healerFrame:SetParent(groupCompositionFrame)
healerFrame:SetSize(V.defaults.frame.width/3, 40)
healerFrame:SetPoint("CENTER")

local healerTotalTText = healerFrame:CreateFontString(nil, "OVERLAY")
healerTotalTText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
healerTotalTText:SetTextColor(unpack(V.defaults.text.color.bright))
healerTotalTText:SetJustifyH("TOP")
healerTotalTText:SetPoint("CENTER", healerFrame, "CENTER", 0, -1)
baseFrame.healerTotalText = healerTotalTText

local healerTotalBText = healerFrame:CreateFontString(nil, "OVERLAY")
healerTotalBText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
healerTotalBText:SetTextColor(unpack(V.defaults.text.color.dim))
healerTotalBText:SetJustifyH("CENTER")
healerTotalBText:SetPoint("BOTTOM", healerFrame, "BOTTOM", 0, 1)
healerTotalBText:SetText("healer")

-- DPS ---------------------------
local dpsFrame = CreateFrame("FRAME", "$parent.DPS", baseFrame)
dpsFrame:SetParent(groupCompositionFrame)
dpsFrame:SetSize(V.defaults.frame.width/3, 40)
dpsFrame:SetPoint("TOPRIGHT")

local dpsTotalTText = dpsFrame:CreateFontString(nil, "OVERLAY")
dpsTotalTText:SetFont(V.defaults.text.font.main, V.defaults.text.large)
dpsTotalTText:SetTextColor(unpack(V.defaults.text.color.bright))
dpsTotalTText:SetJustifyH("TOP")
dpsTotalTText:SetPoint("CENTER", dpsFrame, "CENTER", 0, -1)
baseFrame.dpsTotalText = dpsTotalTText

local dpsTotalBText = dpsFrame:CreateFontString(nil, "OVERLAY")
dpsTotalBText:SetFont(V.defaults.text.font.main, V.defaults.text.normal)
dpsTotalBText:SetTextColor(unpack(V.defaults.text.color.dim))
dpsTotalBText:SetJustifyH("CENTER")
dpsTotalBText:SetPoint("BOTTOM", dpsFrame, "BOTTOM", 0, 1)
dpsTotalBText:SetText("dps")


-- Recalc. baseFrame height ------
module.height = module.height+module.padding
baseFrame:SetHeight(module.height)

-- CHEAP MODULE REGISTERING ------
V.frames.group = baseFrame
V.modules.group = module

----------------------------------
-- Event Handling
----------------------------------
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", V.EventHandler)

function EventFrame:PLAYER_ENTERING_WORLD()
    if IsInGroup() or IsInRaid() then
        V.frames.group:Show()
        -- Leader
        V.frames.group.leaderName:SetText(GroupLeader())
        -- Type of group
        V.frames.group.groupTypeName:SetText(GroupTypeText())
        -- Composition
        local roles = GroupComposition()
        V.frames.group.healerTotalText:SetText(roles.HEALER)
        V.frames.group.tankTotalText:SetText(roles.TANK)
        V.frames.group.dpsTotalText:SetText(roles.DAMAGER)        
        -- Subgroup
        if IsInRaid() then
            V.frames.group.groupTypeGroup:SetText(InSubGroup())
        end
        -- Loot Method
        V.frames.group.lootMethod:SetText(LootMethod())         
    else
        V.frames.group:Hide()
    end
end

function EventFrame:GROUP_JOINED()
    V.frames.group:Show()
    -- Leader
    V.frames.group.leaderName:SetText(GroupLeader())
    -- Type of group
    V.frames.group.groupTypeName:SetText(GroupTypeText())    
    -- Composition
    local roles = GroupComposition()
    V.frames.group.healerTotalText:SetText(roles.HEALER)
    V.frames.group.tankTotalText:SetText(roles.TANK)
    V.frames.group.dpsTotalText:SetText(roles.DAMAGER)
    -- Subgroup
    if IsInRaid() then
        V.frames.group.groupTypeGroup:SetText(InSubGroup())
    end
    -- Loot Method
    V.frames.group.lootMethod:SetText(LootMethod()) 
end

function EventFrame:GROUP_ROSTER_UPDATE()
    -- Composition
    local roles = GroupComposition()
    V.frames.group.healerTotalText:SetText(roles.HEALER)
    V.frames.group.tankTotalText:SetText(roles.TANK)
    V.frames.group.dpsTotalText:SetText(roles.DAMAGER)     
    if IsInRaid() then
        V.frames.group.groupTypeGroup:SetText(InSubGroup())
    end
    if not IsInGroup() and not IsInRaid() then
        V.frames.group:Hide()
    end
end

function EventFrame:ZONE_CHANGED_NEW_AREA()
    if not IsInGroup() and not IsInRaid() then
        V.frames.group:Hide()
    end
end

function EventFrame:PARTY_LEADER_CHANGED()
    V.frames.group.leaderName:SetText(GroupLeader())
end

function EventFrame:PARTY_LOOT_METHOD_CHANGED()
    -- Loot Method
    V.frames.group.lootMethod:SetText(LootMethod())
end

function EventFrame:PARTY_CONVERTED_TO_RAID()
    -- Type of group
    V.frames.group.groupTypeName:SetText(GroupTypeText())
    if IsInRaid() then
        V.frames.group.groupTypeGroup:SetText(InSubGroup())
    end 
end

function EventFrame:PARTY_MEMBERS_CHANGED()
    if not IsInGroup() and not IsInRaid() then
        V.frames.group:Hide()
    end
end

function EventFrame:INSTANCE_GROUP_SIZE_CHANGED()
    local roles = GroupComposition()
    V.frames.group.healerTotalText:SetText(roles.HEALER)
    V.frames.group.tankTotalText:SetText(roles.TANK)
    V.frames.group.dpsTotalText:SetText(roles.DAMAGER)
    -- Type of group
    V.frames.group.groupTypeName:SetText(GroupTypeText())
    if not IsInGroup() and not IsInRaid() then
        V.frames.group:Hide()
    end         
end

function EventFrame:PLAYER_SPECIALIZATION_CHANGED()

end

function EventFrame:PLAYER_DIFFICULTY_CHANGED()

end

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "GROUP_ROSTER_UPDATE",
    "GROUP_JOINED",
    "PARTY_CONVERTED_TO_RAID",
    "PARTY_LEADER_CHANGED",
    "PARTY_LOOT_METHOD_CHANGED",
    "PARTY_MEMBERS_CHANGED",
    "INSTANCE_GROUP_SIZE_CHANGED",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_DIFFICULTY_CHANGED",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
