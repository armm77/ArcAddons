--[[
ArcAddons
Copyright (C) 2011 Marforius

This file is part of ArcAddons.

ArcAddons is free software: you can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, version 3.

ArcAddons is distributed in the hope that it will
be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with ArcAddons. If not, see <http://www.gnu.org/licenses/>.

This code is also released under the Attribution-Noncommercial-Share Alike 3.0 United States License its terms overwrite the GNU licence where applicable.
http://creativecommons.org/licenses/by-nc-sa/3.0/us/
]]

local chatCmdPrefix = "!";

local custom_funcs = {};

local _G = getfenv(0);

local AscentCommandTable = {
["addgmtarget"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "gm allowwhispers",}},
["appear"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "appear", }},
["beastmaster"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "invincible", }},
["delticket"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "gmticket delid", }},
["getticket"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "gmticket getid", }},
["gm"] = {execType = "FUNCTION"},
["godmode"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "cheat god", }},
["invisible"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "invisible", }},
["kick"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "kickplayer", }},
["kill"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "kill", }},
["kille"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "killplr", }},
["money"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "modify gold", }},
["nuke"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "ban character", }}, -- Maybe we should use ban all instead?
["paralyze"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "paralyze", }},
["port"] = {execType = "CCONSOLE_CMD", execData = {  cmdStr = "port", }},
["recharge"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "revive", }},
["remgmtarget"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "gm blockwhispers",}},
["rese"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "reviveplr", }},
["summon"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "summon", }},
["ticketlist"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "gmticket get", }},
["ticketsearch"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "gmticket search", }},
["unparalyze"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "unparalyze", }},
["whois"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "playerinfo", }},
["worldport"] = {execType = "CHAT_MSG", execData = {cmdPrefix = chatCmdPrefix, cmdStr = "worldport", }},
};
_G.AscentCommandTable = AscentCommandTable;

local eventHandlers = {
CHAT_MSG_SYSTEM = function(self, msg)
if ( msg == self.ConcatBlueSystemMessage("GM flag set. It will now appear above your name and in chat messages until you use .gm off.") or msg == self.ConcatRedSystemMessage("GM Flag is already set on. Use !gmoff to disable it.") ) then
	self._gm_tag_state = 1;
elseif ( msg == self.ConcatBlueSystemMessage("GM Flag Removed. <GM> Will no longer show in chat messages or above your name.") or msg == self.ConcatRedSystemMessage("GM Flag not set. Use !gmon to enable it.") ) then
	self._gm_tag_state = nil;
end
end,
};

local eventFrame = CreateFrame("FRAME");
eventFrame:Hide();
eventFrame:SetScript("OnEvent", function(self, event, ...)
local handler = eventHandlers[event];
if ( handler ) then
	handler(self, ...);
	return;
end
end);
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM");

eventFrame.ConcatRedSystemMessage = function(msg) return "|cffff6060"..msg.."|r"; end;
eventFrame.ConcatGreenSystemMessage = function(msg) return "|cff00ff00"..msg.."|r"; end;
eventFrame.ConcatBlueSystemMessage = function(msg) return "|cff00ccff"..msg.."|r"; end;

_G.UnitIsGM = function(unit)
unit = strupper(unit);
if ( unit == "PLAYER" ) then
	return eventFrame._gm_tag_state;
end
end;

local execHandlers = {
CHAT_MSG = function(execData, ...)
local msg = execData.cmdPrefix..execData.cmdStr;
for i=1, select("#", ...) do
	msg = msg.." "..select(i, ...);
end
SendChatMessage(msg, "GUILD");
return true;
end,
CCONSOLE_CMD = function(execData, ...)
ConsoleExec(format(execData.cmdStr, ...));
return true;
end,
};

function GMConsoleExec(command, ...)
	local execTable = AscentCommandTable[command];
	if ( execTable ) then
		local execType = execTable.execType;
		if ( execType ~= "FUNCTION" ) then
			return execHandlers[execType](execTable.execData, ...);
		else
			local custom_func = custom_funcs[command];
			if ( custom_func ) then
				return custom_func(...);
			end
		end
	else
		return false;
	end
end

function GetGMCommandString(command)
	local execTable = AscentCommandTable[command];
	if ( execTable ) then
		local execData = execTable.execData;
		if ( execData ) then
			local prefix = execData.cmdPrefix;
			if ( prefix ) then
				return prefix..execData.cmdStr;
			end
			return execData.cmdStr;
		end
	end
end

custom_funcs.gm = function(state)
if ( state == 1 ) then
	SendChatMessage("!gm on", "GUILD");
elseif ( state == 0 ) then
	SendChatMessage("!gm off", "GUILD");
else
	state = eventFrame._gm_tag_state;
	if ( state == nil ) then
		SendChatMessage("!gm on", "GUILD");
	elseif ( state == 1 ) then
		SendChatMessage("!gm off", "GUILD");
	end
end
end;


