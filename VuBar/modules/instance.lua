local addon, ns = ...
local V = ns.V

----------------------------------
-- instance Frame
----------------------------------
local instanceFrame = CreateFrame("FRAME","$parentInstance", V.frames.left)
instanceFrame:SetPoint("TOP",0,-294)
instanceFrame:SetSize(V.config.frame.width, 20)
if V.config.debug then
     instanceFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     instanceFrame:SetBackdropColor(0, 0, 0, 0.2)
end
instanceFrame:Hide()

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

]]