local addon, ns = ...
local config = ns.config
local frames = ns.frames

local hour, minutes = 0,0

----------------------------------
-- The Clock Frame
----------------------------------
local clockFrame = CreateFrame("BUTTON","$parentClock", frames.left)
clockFrame:SetPoint("TOP")
clockFrame:SetSize(config.frame.width, 100)
clockFrame:EnableMouse(true)
clockFrame:RegisterForClicks("AnyUp")
if config.debug then
	clockFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
	clockFrame:SetBackdropColor(0, 0, 0, 0.2)
end

local clockText = clockFrame:CreateFontString(nil, "OVERLAY")
clockText:SetPoint("CENTER")
clockText:SetHeight(100)
clockText:SetFont(config.text.font, config.text.bigFontSize)
clockText:SetTextColor(.9,.9,.9)
clockText:SetAllPoints()

local calendarText = clockFrame:CreateFontString(nil, "OVERLAY")
calendarText:SetFont(config.text.font, config.text.normalFontSize)
calendarText:SetPoint("TOP", clockFrame, "TOP", 0, -18)
calendarText:SetTextColor(.6,.6,.6)

local restingText = clockFrame:CreateFontString(nil, "OVERLAY")
restingText:SetFont(config.text.font, config.text.normalFontSize)
restingText:SetPoint("BOTTOM", 0, 30)
restingText:SetTextColor(.6,.6,.6)

local afkText = clockFrame:CreateFontString(nil, "OVERLAY")
afkText:SetFont(config.text.font, config.text.normalFontSize)
afkText:SetPoint("TOPLEFT", 51, -30)
afkText:SetTextColor(.6,.6,.6)

local elapsed = 0
clockFrame:SetScript('OnUpdate', function(self, e)
	elapsed = elapsed + e
	if elapsed >= 1 then
		hour, minutes = GetGameTime()
		if hour < 10 then hour = ("0"..hour) end
		if minutes < 10 then minutes = ("0"..minutes) end		
		if ( GetCVarBool("timeMgrUseLocalTime") ) then
			if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
				clockText:SetText(date("%H:%M"))
				--amText:SetText("")	
			else
				clockText:SetText(date("%I:%M"))
				--amText:SetText(date("%p"))		
			end			
		else
			if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
				clockText:SetText(hour..":"..minutes)
				--amText:SetText("")	
			else
				if hour > 12 then 
					hour = hour - 12
					hour = ("0"..hour)
					--AmPmTimeText = "PM"
				else 
					--AmPmTimeText = "AM"
				end
				clockText:SetText(hour..":"..minu)
				--amText:SetText(AmPmTimeText)		
			end			

		end
		if (CalendarGetNumPendingInvites() > 0) then
			calendarText:SetText(string.format("%s  (|cffffff00%i|r)", "New Event!", (CalendarGetNumPendingInvites())))
		else
			calendarText:SetText("")
		end
		--clockFrame:SetWidth(clockText:GetStringWidth() + amText:GetStringWidth())
		--clockFrame:SetPoint("CENTER", config.lframe)		
		elapsed = 0
	end
end)

-- Resting Text
clockFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
clockFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
clockFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

clockFrame:SetScript("OnEvent", function(self, event, arg)
	if IsResting() then
		restingText:SetText("resting")
	else
		restingText:SetText("")
	end
	if UnitIsAFK("player") then
		afkText:SetText("afk")
	else
		afkText:SetText("")
	end
end)

clockFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	clockText:SetTextColor(1,1,1)
	--if cfg.clock.showTooltip then
	hour, minutes = GetGameTime()
	if minutes < 10 then minutes = ("0"..minutes) end
	GameTooltip:SetOwner(clockFrame,"ANCHOR_BOTTOMRIGHT",0,0)
	GameTooltip:AddLine("[|cff6699FFClock|r]")
	GameTooltip:AddLine(" ")
	if ( GetCVarBool("timeMgrUseLocalTime") ) then
		GameTooltip:AddDoubleLine("Realm Time", hours..":"..minutes, 1, 1, 0, 1, 1, 1)
	else
		GameTooltip:AddDoubleLine("Local Time", date("%H:%M"), 1, 1, 0, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("<Left-click>", "Open Calendar", 1, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("<Right-click>", "Open Clock", 1, 1, 0, 1, 1, 1)
	GameTooltip:Show()
	--end	
end)

clockFrame:SetScript("OnLeave", function() 
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end clockText:SetTextColor(.9,.9,.9) 
end)

clockFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleCalendar()
	elseif button == "RightButton" then 
		ToggleTimeManager()
	end
end)
