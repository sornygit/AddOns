local text_color = "|cffafdfd0";
local debugFlag = false;

local function c_print(message)
    DEFAULT_CHAT_FRAME:AddMessage(text_color .. message .. "|r"); -- Change this to what type of message it should be. todo: configurable - raid, say, rw ...
end

local function c_debug(message)
	if debugFlag then
		DEFAULT_CHAT_FRAME:AddMessage(text_color .. "SPOREDEBUG - " .. message .. "|r");
	end
end

-- Frame Creation & Event Registration
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
EventFrame:RegisterEvent("UNIT_AURA")

-- Data structure for storing detected feather usage. Since it's a refreshable unit buff it spams the chat otherwise.
local recentFeathers = {}

-- Event Handler
EventFrame:SetScript("OnEvent", function(self,event,...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = select(1,...)
		local spellId, spellName, spellSchool, auraType, amount, extraSpellID, extraSpellName, extraSchool
		if (event == "SPELL_CAST_SUCCESS") then
			spellId, spellName, spellSchool = select(12,...)
			c_debug("Spell cast " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		elseif (event == "SPELL_AURA_APPLIED") then
			spellId, spellName, spellSchool, auraType = select(12,...)
			if spellId == 176064 then
				c_print("SPORED: Sinister Spores applied on " .. tostring(destName) .. " by " .. tostring(sourceName));
			end
			if spellId == 176905 then
				c_print("SPORED: Glitter bomb applied on " .. tostring(destName) .. " by " .. tostring(sourceName));
			end
			c_debug("Aura applied " .. tostring(spellId) .. " " .. tostring(spellName) .. " to " .. tostring(destName));
		elseif (event == "SPELL_AURA_REMOVED") then
			spellId, spellName, spellSchool, auraType = select(12,...)
			c_debug("Spell aura removed " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		elseif (event == "SPELL_AURA_APPLIED_DOSE") then -- 5 maelstrom stacks
			spellId, spellName, spellSchool, auraType, amount = select(12,...)
			c_debug("Aura DOSE applied " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		elseif (event == "SPELL_DISPEL" or event == "SPELL_STOLEN") then
			spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = select(12,...)
			c_debug("Dispel cast " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		elseif (event == "SPELL_INTERRUPT") then
			spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = select(12,...)
			c_debug("Interrupt cast " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		end

	elseif (event == "UNIT_AURA") then
		local unit=...
		
        if UnitBuff(unit,"Aviana's Feather") then
			local now = GetTime();
			local unitName = GetUnitName(unit, true)
			local unitNameWithRealm = unitName
			
			c_debug("Aviana's feather buff detected on " .. unitNameWithRealm .. " at time: " .. now);
			
			local unitRecentlyGotFeatherBuff = false
			local numberOfRecentFeathers = 0
			local unitFoundAmongRecent = false
			
			for k,v in pairs(recentFeathers) do
				numberOfRecentFeathers = numberOfRecentFeathers + 1;
				if k == unitNameWithRealm then
					unitFoundAmongRecent = true;
					local timeSinceUsed = now - v;
					c_debug("Unit " .. unitNameWithRealm .. " recently got feathers buff: " .. timeSinceUsed);

					if timeSinceUsed > 60 then
						c_debug("Unit " .. unitNameWithRealm .. " had more than 60s since last feathers buff, resetting start.");
						recentFeathers[unitNameWithRealm] = now
					else
						unitRecentlyGotFeatherBuff = true
					end
				end
			end
			
			if unitFoundAmongRecent == false then
				recentFeathers[unitNameWithRealm] = now
			end
			
			if unitRecentlyGotFeatherBuff == false then
				c_print("SPORED: Aviana's Feather used by " .. tostring(unitNameWithRealm));
			end
        end
	end
end)

-- Add slash command /spored
SlashCmdList["SPORED"] = function() c_print("SPORED active. Written by Sorny of Defias Brotherhood. Currently detects Sinister Spores, Super Sticky Glitter Bomb and Aviana's Feather usage."); end
SLASH_SPORED1 = '/spored'

