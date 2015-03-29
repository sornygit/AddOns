-- Class icon instead of portrait
hooksecurefunc("UnitFramePortrait_Update",function(self)
        if self.portrait then
                if UnitIsPlayer(self.unit) then                         
                        local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
                        if t then
                                self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                                self.portrait:SetTexCoord(unpack(t))
                        end
                else
                        self.portrait:SetTexCoord(0,1,0,1)
                end
        end
end)

-- Class color healthbar

local function colour(statusbar, unit)
        local _, class, c
        if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
                _, class = UnitClass(unit)
                c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
                PlayerFrameHealthBar:SetStatusBarColor(0,1,0)
        end
end

hooksecurefunc("UnitFrameHealthBar_Update", colour)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
        colour(self, self.unit)
end)

hooksecurefunc("CastingBarFrame_OnUpdate", function(self, elapsed)
	CastingBarFrame:SetScale(1.2)
end)

local frame = CreateFrame("FRAME")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
--frame:RegisterEvent("PLAYER_TARGET_CHANGED")
--frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("UNIT_FACTION")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PET_BATTLE_CLOSE")

-- Scale of frames
local function eventHandler(self, event, ...)
--        if UnitIsPlayer("target") then
                -- c = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
                -- TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
			TargetFrame:SetScale(1.3);
			TargetFrameToT:Show();
--			TargetFrameToT:SetScale(1.3)
			TargetFrameSpellBar:SetScale(1.2);
--        end
--        if UnitIsPlayer("focus") then
                -- c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
                -- FocusFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
			FocusFrame:SetScale(1.3);
			FocusFrameSpellBar:SetScale(1.2);
--        end
--        if UnitIsPlayer("player") then
                -- c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
                -- PlayerFrameBackground:SetVertexColor(c.r, c.g, c.b)
			PlayerFrame:SetScale(1.3);
--			TargetFrame:SetScale(1.3)
--			TargetFrameToT:Show()
--			TargetFrameToT:SetScale(1.3)
--			TargetFrameSpellBar:SetScale(1.2)
--        end
end

-- do an aura if there is a dispellable/spellstealable buff

frame:SetScript("OnEvent", eventHandler)

--hooksecurefunc("TargetFrame_UpdateAuras", function(s)
--        for i = 1, MAX_TARGET_BUFFS do
--                _, _, ic, _, dT = UnitBuff(s.unit, i)
--                if(ic and (not s.maxBuffs or i<=s.maxBuffs)) then
--                        fS=_G[s:GetName()..'Buff'..i..'Stealable']
--                        if(UnitIsEnemy(PlayerFrame.unit, s.unit) and dT=='Magic') then
--                                fS:Show()
--                        else
--                                fS:Hide()
--                        end
--                end
--        end
--end)

-- Health and mana values as 140k for instance
--hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function()
-- TextStatusBar_CapDisplayOfNumericValue doesnt seem to work
--                PlayerFrameHealthBar.TextString:SetText(UnitHealth("player"))
--                PlayerFrameManaBar.TextString:SetText(UnitMana("player"))

--                TargetFrameHealthBar.TextString:SetText(UnitHealth("target"))
--                TargetFrameManaBar.TextString:SetText(UnitMana("target"))

--                FocusFrameHealthBar.TextString:SetText(UnitHealth("focus"))
 --               FocusFrameManaBar.TextString:SetText(UnitMana("focus"))
--end)

--FocusFrameSpellBar:ClearAllPoints()
--FocusFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, -140)
--FocusFrameSpellBar.SetPoint = function() end
--FocusFrameSpellBar:SetScale(1.0)

--local buffz = CreateFrame("Frame")
--buffz:RegisterEvent("COMBAT_LOG_EVENT")
--buffz:RegisterEvent("UNIT_AURA")

--buffz:SetScript("OnEvent", function(...)
--local param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15, param16 = ...
-- and param6 == UnitName("player")
	--if param3 == "SPELL_AURA_APPLIED" then
		--local s = "You placed "..param14.." On "..param10
		--SendChatMessage(s, "SAY", nil, nil)
--	elseif param3 == "SPELL_AURA_REFRESH" and param6 == UnitName("player") then
--		self:Print("You refreshed "..param14.." On "..param10)
	--end
--end)

-- Auto repair/sell grey

local g = CreateFrame("Frame")
g:RegisterEvent("MERCHANT_SHOW")

g:SetScript("OnEvent", function()  
        local bag, slot
        for bag = 0, 4 do
                for slot = 0, GetContainerNumSlots(bag) do
                        local link = GetContainerItemLink(bag, slot)
                        if link and (select(3, GetItemInfo(link)) == 0) then
                                UseContainerItem(bag, slot)
                        end
                end
        end

        if(CanMerchantRepair()) then
                local cost = GetRepairAllCost()
                if cost > 0 then
                        local money = GetMoney()
                        if IsInGuild() then
                                local guildMoney = GetGuildBankWithdrawMoney()
                                if guildMoney > GetGuildBankMoney() then
                                        guildMoney = GetGuildBankMoney()
                                end
                                if guildMoney > cost and CanGuildBankRepair() then
                                        RepairAllItems(1)
                                        print(format("|cfff07100Repair cost covered by G-Bank: %.1fg|r", cost * 0.0001))
                                        return
                                end
                        end
                        if money > cost then
                                RepairAllItems()
                                print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
                        else
                                print("Not enough gold to cover the repair cost.")
                        end
                end
        end
end)

-- Extra slash commands

SlashCmdList["CLCE"] = function() CombatLogClearEntries() end
SLASH_CLCE1 = "/clc"

SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/gm"

SlashCmdList["READYCHECK"] = function() DoReadyCheck() end
SLASH_READYCHECK1 = '/rc'

SlashCmdList["CHECKROLE"] = function() InitiateRolePoll() end
SLASH_CHECKROLE1 = '/cr'

PetHitIndicator:SetText(nil)
PetHitIndicator.SetText = function() end

MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide() -- hide the gryphons

MainMenuExpBar:Hide()
MainMenuBarMaxLevelBar:SetAlpha(0) -- hide the xp bar

