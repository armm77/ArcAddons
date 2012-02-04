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

local _G = getfenv(0);

local tonumber = _G.tonumber;
local table_insert = _G.table.insert;
local bit_band = _G.bit.band;

_G.Ascent_CheaterTypes = {
CHEATER_TYPE_TELEPORTER = 1,
CHEATER_TYPE_SPEEDHACKER = 2,
CHEATER_TYPE_ANTIFALLDMG = 3,
CHEATER_TYPE_FLYHACKER = 4,
};

local dataHandlers = {
TICKET = function(data)
local opcode, data = strmatch(data, "^([^:]+):(.*)");
if ( opcode == "LIST" ) then
	if ( data == "" ) then
		return;
	end
		local count, count_total, data = strmatch(data, "^(%d+):(%d+)(.*)");
	if ( not count ) then
		return;
	end
	count, count_total = tonumber(count), tonumber(count_total);
		local tickets = {};
	for i=1, count do
		local id, author, categoryId, flags;
		id, author, categoryId, flags, age, data = strmatch(data, "^:(%d+):([^:]+):(%d+):(%d+):(%d+)(.*)");
		if ( not id ) then
			break;
		end
		id, categoryId, flags = tonumber(id), tonumber(categoryId), tonumber(flags);
		table_insert(tickets, {
		id = id,
		author = author,
		authorFaction = bit_band(flags, 0x08) ~= 0,
		authorGender = bit_band(flags, 0x10) ~= 0,
		categoryId = categoryId,
		isUnread = bit_band(flags, 0x01) ~= 0,
		isUpdated = bit_band(flags, 0x02) ~= 0,
		isOnline = bit_band(flags, 0x04) ~= 0,
		age = age,
		});
	end
	return "TICKET", {
	opcode = "TICKETLIST",
	ticketCount = count,
	ticketCountTotal = count_total,
	ticketList = tickets,
	};
elseif ( opcode == "GET" ) then
	if ( data == "" ) then
		return;
	end
		local id, name, mapid, posX, posY, posZ, message = strmatch(data, "^(%d+):([^:]+):(%d+):([%-%.%d]+):([%-%.%d]+):([%-%.%d]+):(.*)");
	if ( not id ) then
		return;
	end
	id, mapid, posX, posY, posZ = tonumber(id), tonumber(mapid), tonumber(posX), tonumber(posY), tonumber(posZ);
	return "TICKET", {
	opcode = "TICKETGETRESULT",
	queryId = id,
	queryResult = {
	ticketAuthor = name,
	ticketLocation = {mapid = mapid, x = posX, y = posY, z = posZ},
	ticketText = message,
	},
	};
elseif ( opcode == "NEW" ) then
	if ( data == "" ) then
		return;
	end
		local id, author = strmatch(data, "^(%d+):(.*)");
	return "TICKET", {
	opcode = "NEWTICKET",
	ticketId = id,
	ticketAuthor = author,
	};
end
end,
};

function ParseGMSyncMessage(msg)
	local opcode, data = strmatch(msg, "^([^:%s]+)[:%s]?(.*)");
	if ( dataHandlers[opcode] ) then
		return dataHandlers[opcode](data);
	else
		return opcode, {data = data};
	end
end

local cheatMessages = {
[Ascent_CheaterTypes.CHEATER_TYPE_TELEPORTER] = "%s\nhas just used a teleport hack.",
[Ascent_CheaterTypes.CHEATER_TYPE_SPEEDHACKER] = "%s\nis speed-hacking.",
[Ascent_CheaterTypes.CHEATER_TYPE_ANTIFALLDMG] = "%s\nis using a fall-damage hack.",
[Ascent_CheaterTypes.CHEATER_TYPE_FLYHACKER] = "%s\nis using a fly hack.",
};
local defaultCheatMessage = "%s\nis cheating.";

function dataHandlers.CHEATER(data)
	local name, type, subtype = strmatch(data, "^([^:]+):(%d+):(%d+)");
	if ( type ) then
		type, subtype = tonumber(type), tonumber(subtype);
		return "CHEATER", {
		cheaterName = name,
		cheatType = type,
		cheatTypeSub = subtype,
		cheat_msg = cheatMessages[type] or defaultCheatMessage,
		};
	end
end

local legacyTicketOpcodes = {
[0] = "TICKET_ADD",
"TICKET_DEL",
"TICKET_FLUSHALL",
"TICKETGETRESULT",
"TICKETGETRESULT_APPEND",
"NEWTICKET",
};

function dataHandlers.GmTicket(data)
	local action, data = strmatch(data, "^([^,]+),?(.*)");
	action = legacyTicketOpcodes[tonumber(action)];
	if ( action == "TICKET_ADD" ) then
		if ( data == "" ) then
			return;
		end
		
		-- Data structure: <name>,<level>,<type>,<zone>
		local name, _, type, _ = strmatch(data, "^([^,]+),(%d+),(%d+),(%d+)");
		if ( not name ) then
			return;
		end
		type = tonumber(type);
		return "TICKET", {
		opcode = action,
		legacy = true,
		ticketData = {
		id = name,
		author = name,
		authorGender = 0, -- Cannot be read from the Who queries.
		categoryId = type < 256 and type or type % 256, -- Ascent bug; 8-bit ticket type is prepended with three extra bytes (mapid, 32-bit int) when reading packet
		isUnread = true,
		isUpdated = false,
		age = 0,
		},
		};
	elseif ( action == "TICKET_DEL" or action == "NEWTICKET" ) then
		if ( data == "" ) then
			return;
		end
		
		return "TICKET", {
		opcode = action,
		legacy = true,
		ticketId = data,
		ticketAuthor = data,
		};
	elseif ( action == "TICKETGETRESULT" or action == "TICKETGETRESULT_APPEND" ) then
		if ( data == "" ) then
			return;
		end
		
		local name, message = strmatch(data, "^([^,]+),(.*)");
		if ( not name ) then
			return;
		end
		return "TICKET", {
		opcode = action,
		legacy = true,
		queryId = name,
		queryResult = {
		ticketAuthor = name,
		ticketText = message,
		},
		};
	end
	return "TICKET", {
	opcode = action,
	legacy = true,
	data = data,
	};
end

