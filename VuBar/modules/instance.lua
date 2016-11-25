local addon, ns = ...
local V = ns.V

local unpack = unpack
local GetInstanceInfo = GetInstanceInfo
----------------------------------
-- instance Frame
----------------------------------
local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
local function InstanceData(instanceType, difficultyID)
    local shortText, texture, coords = nil, nil, nil
    if instanceType == "party" then
        if difficultyID == 1 then -- Normal
            shortText = "N"
            texture = "Interface\\AchievementFrame\\UI-Achievement-Shield-Desaturated"
            coords = ""
        elseif difficultyID == 2 then -- Heroic
            shortText = "HC"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {.5, 1, 0, .5}
        elseif difficultyID == 23 then -- Mythic
            shortText = "M"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {.5, 1, .5, 1}
        elseif difficultyID == 8 then -- Challenge Mode (M+?)
            shortText = "M+"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {0, .5, .5, 1}
        else print("Unknown Difficulty: "..difficultyID) end
    elseif instanceType == "raid" then
        if difficultyID == 14 then -- Normal
            shortText = "N"
            texture = "Interface\\AchievementFrame\\UI-Achievement-Shield"
            coords = ""
        elseif difficultyID == 15 then -- Heroic
            shortText = "HC"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {0, .5, 0, .5}
        elseif difficultyID == 16 then -- Mythic
            shortText = "M"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {0, .5, .5, 1}
        else return end
    elseif instanceType == "pvp" then
            shortText = ""
            texture = "Interface\\PVPFrame\\Icons\\prestige-icon-4"
            coords = ""         
    else return end
end

----------------------------------
-- Instance Frame
----------------------------------
local instanceFrame = CreateFrame("FRAME","$parentInstance", V.frames.left)
instanceFrame:SetPoint("TOP",0,-294)
instanceFrame:SetSize(V.config.frame.width, 20)
if V.config.debug then
     instanceFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     instanceFrame:SetBackdropColor(0, 0, 0, 0.2)
end

local instanceTypeFrame = CreateFrame("FRAME", nil, instanceFrame)
instanceTypeFrame:SetSize(V.config.frame.width, 100)
instanceTypeFrame:SetPoint("TOP")

-- instanceFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- instanceFrame:RegisterEvent("EJ_DIFFICULTY_UPDATE") -- Change of Difficulty
-- instanceFrame:RegisterEvent("CHALLENGE_MODE_START") -- M+
-- instanceFrame:HookScript('OnUpdate', function()
--     if IsInInstance() then
--         instanceFrame:Show()
--     else
--         instanceFrame:Hide()
--     end
-- end)

local instanceTypeFrame = CreateFrame("FRAME", nil, instanceFrame)
instanceTypeFrame:SetSize(V.config.frame.width, 100)
instanceTypeFrame:SetPoint("CENTER")
instanceTypeFrame:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Shields-NoPoints")
instanceTypeFrame:SetTextCoords(0, .5, 0, .5)




--[[
Media:
    Dungeon Normal:     UI-Achievement-Shield-Desaturated
    Dungeon Heroic:     UI-ACHIEVEMENT-SHIELDS (TOPRIGHT)
    Dungeon Mythic:     UI-ACHIEVEMENT-SHIELDS (BOTTOMRIGHT)
    Dungeon Mythic+:    UI-ACHIEVEMENT-SHIELDS (BOTTOMLEFT)
    Timewalking:   
    Raid Normal:        UI-Achievement-Shield
    Raid Heroic:        UI-ACHIEVEMENT-SHIELDS (TOPLEFT)
    Raid Mythic:        UI-ACHIEVEMENT-SHIELDS (BOTTOMLEFT)
    PVP:                prestige-icon-4
    Arena = UI-Achievement-Shield-Desaturated.tga + (PVP-Conquest-Misc.tga - Horde/Alliance Icons?)
]]

--instanceFrame:Hide()

--[[
Plan:
    Dungeon, Raid (PVP?)
    
    Show instance info. 
    name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
    Mythic, Heroic, Normal?
    /run for i=1, 25 do print(i, (GetDifficultyInfo(i))) end
    -GetDungeonDifficultyID()
        1 = "Normal", 2 = "Heroic", etc
    -GetRaidDifficultyID()
    Bosses Killed
    Mythic+ timers/ progress?
    local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
    local zoneName, _, maxTime = C_ChallengeMode.GetMapInfo(currentZoneID);
    local bonus = C_ChallengeMode.GetPowerLevelDamageHealthMod(cmLevel);
    Am I Saved?
    Playercount

]]