local addon, ns = ...
local V = ns.V

local unpack = unpack
local GetInstanceInfo = GetInstanceInfo
----------------------------------
-- instance Frame
----------------------------------
local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
local function InstanceData(instanceType, difficultyID)
    local shortText, texture, coords, size = nil, nil, nil, nil
    if instanceType == "party" then
        if difficultyID == 1 then -- Normal
            shortText = "N"
            texture = "Interface\\AchievementFrame\\UI-Achievement-Shield"
            coords = "",
            size = {128, 128}
        elseif difficultyID == 2 then -- Heroic
            shortText = "HC"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {.5, 1, 0, .5},
            size = {64, 64}
        elseif difficultyID == 23 then -- Mythic
            shortText = "M"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {.5, 1, .5, 1},
            size = {64, 64}
        elseif difficultyID == 8 then -- Challenge Mode (M+?)
            shortText = "M+"
            texture = "Interface\\Challenges\\challenges-gold"
            coords = "",
            size = {64, 64}Challenges
        else print("Unknown Difficulty: "..difficultyID) end
    elseif instanceType == "raid" then
        if difficultyID == 7 then -- Normal
            shortText = "LFR"
            texture = "Interface\\AchievementFrame\\UI-Achievement-Shield-Desaturated"
            coords = "",
            size = {128, 128}
        if difficultyID == 14 then -- Normal
            shortText = "N"
            texture = "Interface\\AchievementFrame\\UI-Achievement-Shield"
            coords = "",
            size = {128, 128}
        elseif difficultyID == 15 then -- Heroic
            shortText = "HC"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {0, .5, 0, .5},
            size = {64, 64}
        elseif difficultyID == 16 then -- Mythic
            shortText = "M"
            texture = "Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS"
            coords = {0, .5, .5, 1},
            size = {64, 64}
        else return end
    elseif instanceType == "pvp" then
            shortText = ""
            texture = "Interface\\PVPFrame\\Icons\\prestige-icon-4"
            coords = "",
            size = {64, 64}         
    else return end
    return shortText, texture, coords, size 
end

----------------------------------
-- Instance Frame
----------------------------------
local instanceFrame = CreateFrame("FRAME","$parent.Instance", V.frames.left)
--instanceFrame:SetPoint("TOP",0,-494)
instanceFrame:SetPoint("TOP", -160, -494)
instanceFrame:SetSize(V.config.frame.width, 100)
if V.debug then
     instanceFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     instanceFrame:SetBackdropColor(0, 0, 0, 0.2)
end

--slideIn
local ag1 = instanceFrame:CreateAnimationGroup()
ag1:SetScript("onFinished", function()
    instanceFrame:SetPoint("TOP",0,-494)
end)
local slideIn = ag1:CreateAnimation("Translation")
slideIn:SetOffset(160, 0)
slideIn:SetDuration(.8)
slideIn:SetStartDelay(.4)
slideIn:SetSmoothing("OUT")

--slideOut
local ag2 = instanceFrame:CreateAnimationGroup()
ag2:SetScript("onFinished", function()
    instanceFrame:SetPoint("TOP", -160, -494)
end)
local slideOut = ag2:CreateAnimation("Translation")
slideOut:SetOffset(-160, 0)
slideOut:SetDuration(.8)
--slideOut:SetStartDelay(.4)
slideOut:SetSmoothing("OUT")

-- local instanceTypeFrame = CreateFrame("FRAME", nil, instanceFrame)
-- instanceTypeFrame:SetSize(V.config.frame.width, 100)
-- instanceTypeFrame:SetPoint("TOP")

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

local instanceLockTexture = instanceTypeFrame:CreateTexture()
instanceLockTexture:SetTexture("Interface\\PETBATTLES\\PetBattle-LockIcon")
instanceLockTexture:SetDrawLayer("ARTWORK", 6)
instanceLockTexture:SetPoint("CENTER", -10, -10)
instanceLockTexture:SetSize(16,16)

local instanceTypeTexture = instanceTypeFrame:CreateTexture()
instanceTypeTexture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Shield-Desaturated")
--instanceTypeTexture:SetTexture("Interface\\AchievementFrame\\UI-ACHIEVEMENT-SHIELDS")
--instanceTypeTexture:SetTexCoord(0, .5, 0, .5)
instanceTypeTexture:SetDrawLayer("ARTWORK", 5)
instanceTypeTexture:SetPoint("CENTER")
instanceTypeTexture:SetSize(128,128)

local instanceName = instanceTypeFrame:CreateFontString(nil, "OVERLAY")
instanceName:SetFont(V.config.text.font, V.config.text.normalFontSize)
instanceName:SetTextColor(.9,.9,.9)
instanceName:SetJustifyH("CENTER")
instanceName:SetPoint("CENTER", instanceTypeFrame, "BOTTOM", 0, 10)
instanceName:SetText("instance name")

local instanceDiffText = instanceTypeFrame:CreateFontString(nil, "OVERLAY")
instanceDiffText:SetFont(V.config.text.font, V.config.text.normalFontSize, "OUTLINE")
instanceDiffText:SetTextColor(.9,.9,.9)
instanceDiffText:SetJustifyH("CENTER")
instanceDiffText:SetPoint("CENTER", instanceTypeFrame, "CENTER", 1, 2)
instanceDiffText:SetText("LFR")

instanceFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- TEST --
instanceFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
-- /TEST --
instanceFrame:RegisterEvent("EJ_DIFFICULTY_UPDATE") -- Change of Difficulty
instanceFrame:RegisterEvent("CHALLENGE_MODE_START") -- M+
instanceFrame:RegisterEvent("RAID_INSTANCE_WELCOME") -- ("name", ttl)
instanceFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA") -- Fires when the player moves between major zones or enters/exits an instance
instanceFrame:SetScript("onEvent", function(self, event, arg1, arg2, arg3, ...)
    -- Test
    if IsResting() then
        ag2:Play()
    else
        ag1:Play()
    end
    -- /Test
    if IsInInstance() then
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
        local shortText, texture, coords, size = InstanceData(instanceType, difficultyID)
        instanceName:SetText(string.lower(name))
        instanceDiffText:SetText(shortText)
        instanceTypeTexture:SetTexture(texture)
        if coords then instanceTypeTexture:SetTextCoord(unpack(coords)) end
        instanceTypeTexture:SetSize(unpack(size))
        ag1:Play()
    else
        ag2:Play()
    end
end)

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