local addon, ns = ...
----------------------------------
-- Variables
----------------------------------
local V = ns.V
local EventHandler, EventFrame, DebugFrame = V.EventHandler, V.EventFrame, V.DebugFrame
local elapsed = 0

----------------------------------
-- Blizz Api & Variables
----------------------------------
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GetLootMethod = GetLootMethod
local UnitIsUnit = UnitIsUnit

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
local function GroupType()
    if not IsInGroup() then return end
    local groupType = ""
    local inInstanceGroup = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
    if inInstanceGroup then
        local name, gType, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
        groupType = gType
    else
        if IsInRaid() then
            groupType = "Raid"
        else
            groupType = "Party"
        end
    end
    return groupType
end

local function GroupLeader()
    local unit = ""
    local leader, loot, group = "", "", ""
    local groupSize = GetNumGroupMembers()
    local start = 1;
    if IsInRaid() then unit = "raid"; else unit = "party"; local start = 0; end
    for i = start, groupSize do
        if start == 0 then unit = "player" else unit = unit..i end
        if UnitIsGroupLeader(unit) then
            local class, classFileName, classIndex = UnitClass(unit)
            local color = format("%02X%02X%02X", RAID_CLASS_COLORS[classFileName].r*255, RAID_CLASS_COLORS[classFileName].g*255, RAID_CLASS_COLORS[classFileName].b*255)
            leader = format("|cff%s%s|r", color, UnitName(unit))
            return leader
        end
    end
end

local function GroupHealth()
    local unit = ""
    local tank, heal, damage = { alive = 0, total = 0 }, { alive = 0, total = 0 }, { alive = 0, total = 0 }
    local groupSize = GetNumGroupMembers()
    local start = 1;
    if IsInRaid() then unit = "raid"; else unit = "party"; local start = 0; end
    for i = start, groupSize do
        if start == 0 then unit = "player" else unit = unit..i; end
        local role = UnitGroupRolesAssigned(unit)
        if role == "HEALER" then
            heal.total = heal.total  + 1
            if not UnitIsDeadOrGhost(unit) then heal.alive = heal.alive + 1 end
        elseif role == "TANK" then
            tank.total = tank.total + 1
            if not UnitIsDeadOrGhost(unit) then tank.alive = tank.alive + 1 end
        else --if role == "DAMAGER" then
            damage.total = damage.total + 1
            if not UnitIsDeadOrGhost(unit) then damage.alive = damage.alive + 1 end
        end
    end
    if tank.alive == tank.total then 
        tank = tank.total
    else
        tank = format("|cffff0000%s|r/%s", tank.alive, tank.total)
    end
    if heal.alive == heal.total then 
        heal = heal.total
    else
        heal = format("|cffff0000%s|r/%s", heal.alive, heal.total)
    end
    if damage.alive == damage.total then 
        damage = damage.total
    else
        damage = format("|cffff0000%s|r/%s", damage.alive, damage.total)
    end
    return tank, heal, damage
end

local function RaidGroup()
    local unit = ""
    local _i = 1
    if IsInRaid() then unit = "raid" else unit = "party"; _i = 0; end
    for i = _i, GetNumGroupMembers() do 
        unit = unit..i
        if i == 0 then unit = "player" end
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        if (UnitIsUnit(unit,"player")) then
            return subgroup
        end
    end
end

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

local function GroupOnUpdate(self, e)
    elapsed = elapsed + e
    if elapsed > 1 then
       local tanks, healers, dps = GroupHealth()
        V.frames.group.healerTotalText:SetText(healers)
        V.frames.group.tankTotalText:SetText(tanks)
        V.frames.group.dpsTotalText:SetText(dps)
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
module.height = module.height+groupCompositionFrame:GetHeight()
groupCompositionFrame:SetScript("OnUpdate", GroupOnUpdate)

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
        V.frames.group.groupTypeName:SetText(GroupType())
        V.frames.group.leaderName:SetText(GroupLeader())
        local tanks, healers, dps = GroupHealth()
        V.frames.group.healerTotalText:SetText(healers)
        V.frames.group.tankTotalText:SetText(tanks)
        V.frames.group.dpsTotalText:SetText(dps)
        -- Loot Method
        V.frames.group.lootMethod:SetText(LootMethod())
    elseif IsInRaid() then
        V.frames.group.groupTypeGroup:SetText(RaidGroup())
    else
        V.frames.group:Hide()
    end
end

function EventFrame:GROUP_JOINED()
    if IsInGroup() or IsInRaid() then
        V.frames.group:Show()
        V.frames.group.groupTypeName:SetText(GroupType())
        V.frames.group.leaderName:SetText(GroupLeader())
        -- Loot Method
        V.frames.group.lootMethod:SetText(LootMethod())
    elseif IsInRaid() then
        V.frames.group.groupTypeGroup:SetText(RaidGroup())
    else
        V.frames.group:Hide()
    end
end

function EventFrame:GROUP_ROSTER_UPDATE()
    local tanks, healers, dps = GroupHealth()
    V.frames.group.healerTotalText:SetText(healers)
    V.frames.group.tankTotalText:SetText(tanks)
    V.frames.group.dpsTotalText:SetText(dps)
    if IsInRaid() then
        V.frames.group.groupTypeGroup:SetText(RaidGroup())
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

-- EVENTS ------------------------
local events = {
    "PLAYER_ENTERING_WORLD",
    "GROUP_ROSTER_UPDATE",
    "GROUP_JOINED",
    "PARTY_LEADER_CHANGED",
    "ZONE_CHANGED_NEW_AREA",
    "PARTY_LOOT_METHOD_CHANGED",
}
-- REGISTER IF NOT REGISTERED ----
for i, e in ipairs(events) do
    if not EventFrame:IsEventRegistered(e) then EventFrame:RegisterEvent(e) end
end
