local addon, ns = ...
local V = ns.V
local unpack = unpack
----------------------------------
-- Resources Frame
----------------------------------
local resourcesFrame = CreateFrame("FRAME","$parentResources", V.frames.left)
resourcesFrame:SetPoint("TOP",0,-200)
resourcesFrame:SetSize(V.config.frame.width, 80)
if V.config.debug then
     resourcesFrame:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 })
     resourcesFrame:SetBackdropColor(0, 0, 0, 0.2)
end

----------------------------------
-- Header Frame
----------------------------------
local headerFrame = CreateFrame("FRAME",nil, resourcesFrame)
headerFrame:SetSize(V.config.frame.width, 20)
headerFrame:SetPoint("TOP")

local headerText = headerFrame:CreateFontString(nil, "OVERLAY")
headerText:SetFont(V.config.text.font, V.config.text.normalFontSize)
headerText:SetTextColor(unpack(V.config.text.header.color))
headerText:SetJustifyH("CENTER")
headerText:SetPoint("LEFT", headerFrame, "LEFT", 6, 0)
headerText:SetText("resources")

----------------------------------
-- Gold Frame
----------------------------------
local goldFrame = CreateFrame("BUTTON",nil, headerFrame)
goldFrame:SetSize(V.config.frame.width, 20)
goldFrame:SetPoint("TOP",0,-20)

local goldText = goldFrame:CreateFontString(nil, "OVERLAY")
goldText:SetFont(V.config.text.font, V.config.text.normalFontSize)
goldText:SetTextColor(1,1,1)
goldText:SetJustifyH("RIGHT")
goldText:SetPoint("RIGHT", goldFrame, "RIGHT", -8, 0)
goldText:SetText("0")

----------------------------------
-- Reroll Frame
----------------------------------
local rerollFrame = CreateFrame("BUTTON",nil, headerFrame)
rerollFrame:SetSize(V.config.frame.width, 20)
rerollFrame:SetPoint("TOP",0,-40)
-- needs to be clickable for rerolls pane

local rerollLText = rerollFrame:CreateFontString(nil, "OVERLAY")
rerollLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
rerollLText:SetTextColor(.6,.6,.6)
rerollLText:SetJustifyH("LEFT")
rerollLText:SetPoint("LEFT", rerollFrame, "LEFT", 8, 0)
rerollLText:SetText("seals")

local rerollRText = rerollFrame:CreateFontString(nil, "OVERLAY")
rerollRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
rerollRText:SetTextColor(1,1,1)
rerollRText:SetJustifyH("RIGHT")
rerollRText:SetPoint("RIGHT", rerollFrame, "RIGHT", -8, 0)
rerollRText:SetText("0")

rerollFrame:SetScript("OnEnter", function()
     if InCombatLockdown() then return end
     --rerollIcon:SetVertexColor(unpack(V.config.color.hover))
     --if not V.config.currency.showTooltip then return end
     GameTooltip:SetOwner(resourcesFrame, "ANCHOR_BOTTOMRIGHT",0,0)
     GameTooltip:AddLine("[|cff6699FFReroll|r]")
     GameTooltip:AddLine(" ")
     local SoIFname, SoIFamount, SoIFicon, SoIFearnedThisWeek, SoIFweeklyMax, SoIFtotalMax, SoIFisDiscovered = GetCurrencyInfo(1129)
     if SoIFamount > 0 then 
          GameTooltip:AddLine(SoIFname,1,1,0)
          GameTooltip:AddDoubleLine("|cffffff00Weekly: |cffffffff"..SoIFearnedThisWeek.."|cffffff00/|cffffffff"..SoIFweeklyMax, "|cffffff00Total: |cffffffff"..SoIFamount.."|cffffff00/|cffffffff"..SoIFtotalMax)
     else
          local SoTFname, SoTFamount, SoTFicon, SoTFearnedThisWeek, SoTFweeklyMax, SoTFtotalMax, SoTFisDiscovered = GetCurrencyInfo(994)
          if SoTFamount > 0 then 
               GameTooltip:AddDoubleLine(SoTFname, "|cffffff00Total: |cffffffff"..SoTFamount.."|cffffff00/|cffffffff"..SoTFtotalMax)
          end
     end
     GameTooltip:Show()
end)

rerollFrame:SetScript("OnLeave", function() 
     if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
     --rerollIcon:SetVertexColor(unpack(cfg.color.inactive))
end)

rerollFrame:SetScript("OnClick", function(self, button, down)
     if InCombatLockdown() then return end
     if button == "LeftButton" then
          ToggleCharacter("TokenFrame")
     end
end)

----------------------------------
-- Order Resources - 1220
----------------------------------
local orderFrame = CreateFrame("BUTTON",nil, headerFrame)
orderFrame:SetSize(V.config.frame.width, 20)
orderFrame:SetPoint("TOP",0,-60)
-- needs to be clickable for orders pane

local orderLText = orderFrame:CreateFontString(nil, "OVERLAY")
orderLText:SetFont(V.config.text.font, V.config.text.normalFontSize)
orderLText:SetTextColor(.6,.6,.6)
orderLText:SetJustifyH("LEFT")
orderLText:SetPoint("LEFT", orderFrame, "LEFT", 8, 0)
orderLText:SetText("order resources")

local orderRText = orderFrame:CreateFontString(nil, "OVERLAY")
orderRText:SetFont(V.config.text.font, V.config.text.normalFontSize)
orderRText:SetTextColor(1,1,1)
orderRText:SetJustifyH("RIGHT")
orderRText:SetPoint("RIGHT", orderFrame, "RIGHT", -8, 0)
orderRText:SetText("0")


----------------------------------
-- Events Frame
----------------------------------
local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("PLAYER_MONEY")
eventframe:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
eventframe:RegisterEvent("SEND_MAIL_COD_CHANGED")
eventframe:RegisterEvent("PLAYER_TRADE_MONEY")
eventframe:RegisterEvent("TRADE_MONEY_CHANGED")
eventframe:RegisterEvent("TRADE_CLOSED")
eventframe:RegisterEvent("MODIFIER_STATE_CHANGED")

eventframe:SetScript("OnEvent", function(this, event, arg1, arg2, arg3, arg4, ...)
     -- goldFrameOnEnter()
     -- if event == "MODIFIER_STATE_CHANGED" then
     --      if InCombatLockdown() then return end
     --      if arg1 == "LSHIFT" or arg1 == "RSHIFT" then
     --           if arg2 == 1 then
     --                goldFrameOnEnter()
     --           elseif arg2 == 0 then
     --                goldFrameOnEnter()
     --           end
     --      end
     -- end     
     local gold = GetMoney()
     
     -- ns.playerData["money_on_log_out"] = gold
     
     local g, s, c = abs(gold/10000), abs(mod(gold/100, 100)), abs(mod(gold, 100))
     
     if g > 1 then
          g = string.format("|cffffd700%d|cffffffffg|r ", floor(g))
          goldText:SetText(g)
     elseif s > 1 then 
          goldText:SetText(floor(s).."s")
     else 
          goldText:SetText(floor(c).."c")
     end
     if gold == 0 then goldText:SetText("0") end

     -- reroll currency
     local SoIFname, SoIFamount, _, _, _, SoIFtotalMax, SoIFisDiscovered = GetCurrencyInfo(1129)
     if SoIFamount > 0 then 
          rerollRText:SetText(SoIFamount)
     else
          local SoTFname, SoTFamount, _, _, _, SoTFtotalMax, SoTFisDiscovered = GetCurrencyInfo(994)
          if SoTFamount > 0 then rerollcountText:SetText(SoTFamount) end
     end
     --rerollFrame:SetSize(rerollText:GetStringWidth()+18, 16)
     -- class hall currency
     local chName, chAmount, _, chEarnedThisWeek, chWeeklyMax, chTotalMax, chIsDiscovered = GetCurrencyInfo(1220)
     orderRText:SetText(chAmount)
     --garrisonFrame:SetSize(garrisonText:GetStringWidth()+18, 16)

end)