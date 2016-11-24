local addon, ns = ...
local V = ns.V

----------------------------------
-- Social Frame
----------------------------------
local socialFrame = CreateFrame("FRAME","$parentSocial", V.frames.left)
socialFrame:SetPoint("TOP",0,-132)
socialFrame:SetSize(V.config.frame.width, 60)
if V.config.debug then
     socialFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     socialFrame:SetBackdropColor(0, 0, 0, 0.2)
end

----------------------------------
-- Header Frame
----------------------------------
local headerFrame = CreateFrame("FRAME","nil", socialFrame)
headerFrame:SetSize(V.config.frame.width, 20)
headerFrame:SetPoint("TOP")

local headerText = headerFrame:CreateFontString(nil, "OVERLAY")
headerText:SetFont(V.config.text.font, V.config.text.normalFontSize)
headerText:SetTextColor(onfig.text.header.color)
headerText:SetJustifyH("CENTER")
headerText:SetPoint("LEFT", headerFrame, "LEFT", 6, 0)
headerText:SetText("social")

----------------------------------
-- Friends Frame
----------------------------------
local friendFrame = CreateFrame("BUTTON",nil, headerFrame)
friendFrame:SetSize(V.config.frame.width, 20)
friendFrame:SetPoint("TOP",0,-20)
-- needs to be clickable for friends pane

local friendText = friendFrame:CreateFontString(nil, "OVERLAY")
friendText:SetFont(V.config.text.font, V.config.text.normalFontSize)
friendText:SetTextColor(.6,.6,.6)
friendText:SetJustifyH("LEFT")
friendText:SetPoint("LEFT", friendFrame, "LEFT", 8, 0)
friendText:SetText("friends")

local fonlineText = friendFrame:CreateFontString(nil, "OVERLAY")
fonlineText:SetFont(V.config.text.font, V.config.text.normalFontSize)
fonlineText:SetTextColor(1,1,1)
fonlineText:SetJustifyH("RIGHT")
fonlineText:SetPoint("RIGHT", friendFrame, "RIGHT", -8, 0)
fonlineText:SetText("0")


friendFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	--friendIcon:SetVertexColor(unpack(V.config.color.hover))
	--if not V.config.micromenu.showTooltip then return end
	local totalBNet, numBNetOnline = BNGetNumFriends()
	if numBNetOnline then
	GameTooltip:SetOwner(friendFrame, "ANCHOR_BOTTOMRIGHT",0,0)
	GameTooltip:AddLine("[|cff6699FFSocial|r]")
	GameTooltip:AddLine(" ")
	--------------------------
	local onlineBnetFriends = false
	for j = 1, BNGetNumFriends() do
		local BNid, BNname, battleTag, _, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note = BNGetFriendInfo(j)
		if ( online ) then
			
			if (not battleTag) then battleTag = "[noTag]" end
			local status = ""
			
			local statusIcon = "Interface\\FriendsFrame\\StatusIcon-Online.blp"
			if ( isafk ) then 
				statusIcon = "Interface\\FriendsFrame\\StatusIcon-Away.blp"
				status = "(AFK)"
			end
			if  ( isdnd ) == "D3" then
				statusIcon = "Interface\\FriendsFrame\\StatusIcon-DnD.blp"
				status = "(DND)"
			end
			
			local gameIcon = "Interface\\Icons\\INV_Misc_QuestionMark.blp"
			if client == "App" then 
				gameIcon = "Interface\\FriendsFrame\\Battlenet-Battleneticon.blp"
				client = "Bnet"
			elseif client == "D3" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-D3icon.blp"
				client = "Diablo III"
			elseif client == "Hero" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-HotSicon.blp"
				client = "Hero of the Storm"
			elseif client == "S2" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-Sc2icon.blp"
				client = "Starcraft 2"
			elseif client == "WoW" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-WoWicon.blp"
			elseif client == "WTCG" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-WTCGicon.blp"
				client = "Heartstone"
			end
			if client == "WoW" then 
				toonname = ("(|cffecd672"..toonname.."|r)")
			else
				toonname = "" 
			end
			
			if not note then
			note = ""
			else
			note = ("(|cffecd672"..note.."|r)")
			end
			
			local lineL = string.format("|T%s:16|t|cff82c5ff %s|r %s",statusIcon, BNname, note)
			local lineR = string.format("%s %s |T%s:16|t",toonname, client or "",  gameIcon)
			GameTooltip:AddDoubleLine(lineL,lineR)
			onlineBnetFriends = true
		end
	end
	
	if onlineBnetFriends then GameTooltip:AddLine(" ") end

	local onlineFriends = false
		for i = 1, GetNumFriends() do
			local name, lvl, class, area, online, status, note = GetFriendInfo(i)
			if ( online ) then
				local status = ""
				local statusIcon = "Interface\\FriendsFrame\\StatusIcon-Online.blp"
				if ( isafk ) then 
					statusIcon = "Interface\\FriendsFrame\\StatusIcon-Away.blp"
					status = "(AFK)"
				end
				if  ( isdnd ) == "D3" then
					statusIcon = "Interface\\FriendsFrame\\StatusIcon-DnD.blp"
					status = "(DND)"
				end
				local lineL = string.format("|T%s:16|t %s, lvl:%s %s", statusIcon, name, lvl, class)
				local lineR = string.format("%s", area or "")
				GameTooltip:AddDoubleLine(lineL,lineR)
				onlineFriends = true
			end
		end
		if onlineFriends then GameTooltip:AddLine(" ") end
		GameTooltip:AddDoubleLine("<Left-click>", "Open Friends List", 1, 1, 0, 1, 1, 1)
		-----------------------
		GameTooltip:Show()
		end
	end)

friendFrame:SetScript("OnLeave", function() 
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end 
end)

friendFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleFriendsFrame()
	end
end)

----------------------------------
-- Guild Frame
----------------------------------
local guildFrame = CreateFrame("BUTTON",nil, headerFrame)
guildFrame:SetSize(V.config.frame.width, 20)
guildFrame:SetPoint("TOP",0,-40)
-- needs to be clickable for guilds pane

local guildText = guildFrame:CreateFontString(nil, "OVERLAY")
guildText:SetFont(V.config.text.font, V.config.text.normalFontSize)
guildText:SetTextColor(.6,.6,.6)
guildText:SetJustifyH("LEFT")
guildText:SetPoint("LEFT", guildFrame, "LEFT", 8, 0)
guildText:SetText("guild")

local gonlineText = guildFrame:CreateFontString(nil, "OVERLAY")
gonlineText:SetFont(V.config.text.font, V.config.text.normalFontSize)
gonlineText:SetTextColor(1,1,1)
gonlineText:SetJustifyH("RIGHT")
gonlineText:SetPoint("RIGHT", guildFrame, "RIGHT", -8, 0)
gonlineText:SetText("0")

guildFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	--guildIcon:SetVertexColor(unpack(cfg.color.hover))
	--if not cfg.micromenu.showTooltip then return end
	if ( IsInGuild() ) then
		GameTooltip:SetOwner(guildFrame, "ANCHOR_BOTTOMRIGHT",0,0)
		GameTooltip:AddLine("[|cff6699FFGuild|r]")
		GameTooltip:AddLine(" ")
		--------------------------

		guildList = {}
		guildName, guildRank, _ = GetGuildInfo("player")
		guildMotto = GetGuildRosterMOTD()
			
		GameTooltip:AddDoubleLine("Guild:", guildName, 1, 1, 0, 0, 1, 0)
		for i = 0, select(1, GetNumGuildMembers()) do
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR = GetGuildRosterInfo(i)
			if ( online ) then
				if status == 0 then status = "" elseif status == 1 then status = "AFK" elseif status == 2 then status = "DND" end
			local cCol = string.format("%02X%02X%02X", RAID_CLASS_COLORS[classFileName].r*255, RAID_CLASS_COLORS[classFileName].g*255, RAID_CLASS_COLORS[classFileName].b*255)
			local lineL = string.format("%s |cff%s%s|r %s %s", level, cCol, name, status, note)
			local lineR = string.format("%s|cffffffff %s", isMobile and "|cffffff00[M]|r " or "", zone or "")
			GameTooltip:AddDoubleLine(lineL,lineR)
			end
		end
	else
		--GameTooltip:AddLine("No Guild")
	end
	GameTooltip:AddLine(" ")
	if ( IsInGuild() ) then GameTooltip:AddDoubleLine("<Left-click>", "Open Guild Page", 1, 1, 0, 1, 1, 1) end
	-----------------------
	GameTooltip:Show()
end)

guildFrame:SetScript("OnLeave", function() 
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end 
end)

guildFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then 
		if ( IsInGuild() ) then
			ToggleGuildFrame()
			GuildFrameTab2:Click()
		else
			print"|cff6699FFSXUI|r: You are not in a guild"
		end
	end
end)


local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")

eventframe:RegisterEvent("FRIENDLIST_UPDATE")
eventframe:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
eventframe:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")

eventframe:RegisterEvent("GUILD_ROSTER_UPDATE")
eventframe:RegisterEvent("GUILD_TRADESKILL_UPDATE")
eventframe:RegisterEvent("GUILD_MOTD")
eventframe:RegisterEvent("GUILD_NEWS_UPDATE")
eventframe:RegisterEvent("PLAYER_GUILD_UPDATE")

eventframe:SetScript("OnEvent", function(self,event, ...)
	local numOnline = ""
	if IsInGuild() then
		_, numOnline, _ = GetNumGuildMembers()
	end
	gonlineText:SetText(numOnline)
	--guildTextBG:SetSize(guildText:GetWidth()+4,guildText:GetHeight()+2)
	--guildTextBG:SetPoint("CENTER",guildText)
	
	local totalBNet, numBNetOnline = BNGetNumFriends()
	fonlineText:SetText(numBNetOnline)
	
	if numBNetOnline == 0 then
		fonlineText:SetText("")
	else
		
	end
	--friendTextBG:SetSize(friendText:GetWidth()+4,friendText:GetHeight()+2)
	--friendTextBG:SetPoint("CENTER",friendText)
	
end)

