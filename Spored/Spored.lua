local text_color = "|cffafdfd0";
local debugFlag = false;
local enabled = true;
local c_output = "SOUND";

-- Frame Creation & Event Registration
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
EventFrame:RegisterEvent("UNIT_AURA")

-- Output functions
local function playSporedSoundFile(name)
	local soundFileName = "Interface\\AddOns\\Spored\\sound\\" .. name .. ".mp3";
	if (debugFlag == true) then
		print("Playing sound file: " .. soundFileName);
	end
	PlaySoundFile(soundFileName);
end

local function c_print(message, audiofile)
	if (c_output == "CHAT") then
		DEFAULT_CHAT_FRAME:AddMessage(text_color .. message .. "|r");
	elseif (c_output == "SOUND") then
		DEFAULT_CHAT_FRAME:AddMessage(text_color .. message .. "|r");
		playSporedSoundFile(audiofile);
	else
		SendChatMessage(message, c_output, nil, nil);
	end
end

-- Data structure for storing detected feather usage. Since it's a refreshable unit buff it spams the chat otherwise.
local recentFeathers = {}
local terrorBuffText = "\"Skyterror\" Personal Delivery System";
local featherBuffText = "Aviana's Feather";

-- Various check methods for filtering, currently not used
function InSanctuary()
    return GetZonePVPInfo() == "sanctuary"
end
 
function InInstance()
    return IsInInstance()
end

-- Event Handler
EventFrame:SetScript("OnEvent", function(self,event,...)
-- Filter out instances/sanctuary? (todo: more filters?)
	if (enabled == false) then
		-- Skip detection
	else
		if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
			local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = select(1,...)
			
			-- Filter out all events not related to players.
			if bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
				if (debugFlag) then
					print("Source: a player")
				end
		--		if (event == "SPELL_CAST_SUCCESS") then
		--			spellId, spellName, spellSchool = select(12,...)
		--			if debugFlag then
		--				c_print("Spell cast " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		--			end
		--		else
				
				if (event == "SPELL_AURA_APPLIED") then
					local spellId, spellName, spellSchool, auraType, amount, extraSpellID, extraSpellName, extraSchool
					
					spellId, spellName, spellSchool, auraType = select(12,...)
					
					if spellId == 176064 then
						c_print("SPORED: Sinister Spores applied on " .. tostring(destName) .. " by " .. tostring(sourceName), "SinisterSpores");
					end
					if spellId == 176905 then
						c_print("SPORED: Glitter bomb applied on " .. tostring(destName) .. " by " .. tostring(sourceName), "SuperStickyGlitterBomb");
					end
					
					if debugFlag then
						print("SPOREDEBUG - Aura applied " .. tostring(spellId) .. " " .. tostring(spellName) .. " to " .. tostring(destName));
					end
					
		--		elseif (event == "SPELL_AURA_REMOVED") then
		--			spellId, spellName, spellSchool, auraType = select(12,...)
		--			c_print("Spell aura removed " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		--		elseif (event == "SPELL_AURA_APPLIED_DOSE") then -- 5 maelstrom stacks
		--			spellId, spellName, spellSchool, auraType, amount = select(12,...)
		--			c_print("Aura DOSE applied " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		--		elseif (event == "SPELL_DISPEL" or event == "SPELL_STOLEN") then
		--			spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = select(12,...)
		--			c_print("Dispel cast " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
		--		elseif (event == "SPELL_INTERRUPT") then
		--			spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = select(12,...)
		--			c_print("Interrupt cast " .. tostring(spellId) .. " " .. tostring(spellName) .. " by " .. tostring(sourceName) .. " on " .. tostring(destName));
				end
			end

		elseif (event == "UNIT_AURA") then
			local unit=...
			
			local featherBuff = UnitBuff(unit, featherBuffText);
			local terrorBuff = UnitBuff(unit, terrorBuffText);
			
			if (featherBuff or terrorBuff) then
				local buff = nil;
				local now = GetTime();
				local unitName = GetUnitName(unit, true)
			
				if (featherBuff) then
					buff = featherBuffText;
				elseif (terrorBuff) then
					buff = terrorBuffText;
				end
				
				if debugFlag then
					print("SPOREDEBUG - " .. buff .. " detected on " .. unitName .. " at time: " .. now);
				end
				
				local unitRecentlyGotFeatherBuff = false
				local unitFoundAmongRecent = false
				
				-- todo: Use two separate storages for buffs? Seems inefficient. Maybe we can assume within 60 sec only one of them is used.
				for k,v in pairs(recentFeathers) do
					if k == unitName then
						unitFoundAmongRecent = true;
						local timeSinceUsed = now - v;
						if debugFlag then
							print("SPOREDEBUG - Unit " .. unitName .. " recently got " .. buff .. ": " .. timeSinceUsed);
						end

						if (timeSinceUsed > 60) then
							if debugFlag then
								print("SPOREDEBUG - Unit " .. unitName .. " had more than 60 since last buff, resetting start.");
							end
							recentFeathers[unitName] = now
						else
							unitRecentlyGotFeatherBuff = true
						end
					end
				end
				
				if unitFoundAmongRecent == false then
					recentFeathers[unitName] = now
				end
				
				if unitRecentlyGotFeatherBuff == false then
					if (featherBuff) then
						c_print("SPORED: " .. buff .. " used by " .. tostring(unitName), "AvianasFeather");
					else
						c_print("SPORED: " .. buff .. " used by " .. tostring(unitName), "SkyTerror");
					end
				end
			end
		end
	end
end)

SLASH_SPORED1 = '/spored'

local function slashUsage()
	print("SPORED. Written by Sorny of Defias Brotherhood.");
	print("Detects Sinister Spores, Glitter bomb, Skyterror and Aviana's Feather.");
	print("Syntax:");
	print("/spored output <channel>");
	print("channel = SAY, PARTY, RAID, RAID_WARNING, INSTANCE_CHAT, SOUND (default), or CHAT.");
	print("/spored enable <true or false>");
	print("false means addon is disabled, true enabled.");
end

local function slashCommandHandler(msg, editbox)
	
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	 if (command == "output" and rest ~= "") then
		if (rest == "SAY") then -- Speech to nearby players (/say).
			c_output = "SAY";
	--	else if (rest == "YELL") then -- Yell to not so nearby players (/yell).
	--		c_output = "YELL";
		elseif (rest == "PARTY") then -- Message to party members (/p)
			c_output = "PARTY";
		elseif (rest == "RAID") then -- Message to raid members (/raid)
			c_output = "RAID";
		elseif (rest == "RAID_WARNING") then -- Warning to raid members (/rw)
			c_output = "RAID_WARNING";
		elseif (rest == "INSTANCE_CHAT") then -- Message to battleground instance group (/i)
			c_output = "INSTANCE_CHAT";
		elseif (rest == "SOUND") then -- Play a sound file + print to chat
			c_output = "SOUND";
		elseif (rest == "CHAT") then -- default
			c_output = "CHAT";
		else
			slashUsage();
		end

		print("SPORED output channel set to: " .. c_output);

	 elseif (command == "enable" and rest ~= "") then
		if (rest == "false") then
			enabled = false;
			print("SPORED disabled.");
		else
			enabled = true;
			print("SPORED enabled.");
		end
	 else
		slashUsage();
	 end
end

-- Add slash command /spored
SlashCmdList["SPORED"] = slashCommandHandler


