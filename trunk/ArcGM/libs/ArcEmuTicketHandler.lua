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

local queries = {};
local currentQuery, queryResult, queryWaiting = nil, {}, false;

local eventFrame = CreateFrame("Frame");
eventFrame:Hide();

local eventCallbackFunc = {};

local isLegacy = false;

local tickets = {};

local _G = getfenv(0);
local table_insert = _G.table.insert;
local table_remove = _G.table.remove;
local pairs = _G.pairs;
local type = _G.type;

local function table_clear(t)
for k, v in pairs(t) do
	if ( type(v) == "table" ) then
		table_clear(v);
	end
	t[k] = nil;
end
end

_G.TICKETHANDLER_GET_TIMEOUT = 1;

local function initNextQuery()
local query = queries[1];
currentQuery = query;

queryWaiting = false;
table_clear(queryResult);
table_clear(tickets);
if ( query.type == "GM_TICKET_SETUP_LOAD" ) then
	GMConsoleExec("ticketlist", query.pageIndex, query.pageSize);
elseif ( query.type == "GM_TICKET_QUERY_LOAD" ) then
	if ( not isLegacy ) then
		GMConsoleExec("ticketsearch", query.pageIndex, query.pageSize, query.categoryIndex, query.searchText);
	else
		GMConsoleExec("ticketlist", 0, 0);
	end
elseif ( query.type == "GM_TICKET_TICKET_LOAD" ) then
	GMConsoleExec("getticket", query.ticketId);
end

eventFrame.timer = TICKETHANDLER_GET_TIMEOUT;
eventFrame:Show();
end

local function sendResults()
local query = currentQuery;
if ( query.type == "GM_TICKET_SETUP_LOAD" or query.type == "GM_TICKET_QUERY_LOAD" ) then
	eventCallbackFunc[query.frameName](query.type.."_"..query.result, queryResult, #tickets);
else
	eventCallbackFunc[query.frameName](query.type.."_"..query.result, queryResult);
end
end

local function finishQuery()
if ( #queries <= 1 ) then
	eventFrame:Hide();
	eventFrame.timer = nil;
else
	table_remove(queries, 1);
	initNextQuery();
end
end

local function eventFrame_OnUpdate(self, elapsed)
self.timer = self.timer - elapsed;
if ( self.timer <= 0 ) then
	if ( (not queryResult or #queryResult == 0) and queryWaiting == false ) then
		currentQuery.result = "FAILURE";
	else
		currentQuery.result = "SUCCESS";
	end
	sendResults();
	finishQuery();
end
end
eventFrame:SetScript("OnUpdate", eventFrame_OnUpdate);

function TicketHandler_RegisterForEvents(frameName, callbackFunc)
	eventCallbackFunc[frameName] = callbackFunc;
end

function TicketHandler_UnregisterForEvents(frameName)
	eventCallbackFunc[frameName] = nil;
end

local messageHandlers = {
TICKETLIST = function(data)
if ( currentQuery.type ~= "GM_TICKET_SETUP_LOAD" and currentQuery.type ~= "GM_TICKET_QUERY_LOAD" ) then
	return;
end

local tickets = data.ticketList;
queryResult, currentQuery.ticketCountTotal = tickets, data.ticketCountTotal;
eventCallbackFunc[currentQuery.frameName](currentQuery.type.."_SUCCESS", tickets, data.ticketCountTotal);
currentQuery.result = "SUCCESS";
finishQuery();
end,
TICKETGETRESULT = function(data)
if ( currentQuery.type ~= "GM_TICKET_TICKET_LOAD" or data.queryId ~= currentQuery.ticketId ) then
	return;
end

queryResult.id, queryResult.data = data.queryId, data.queryResult;
currentQuery.result = "SUCCESS";
sendResults();
finishQuery();
end,
};

local string_find = _G.string.find;
local function isFiltered(data, query)
local name, category = query.searchText, query.categoryIndex;
return (name ~= nil and name ~= "" and not string_find(strlower(data.author), name)) or (category ~= 0 and data.categoryId ~= category);
end

local WhoLib_Object = nil;

local function WhoLib_Init()
if ( not WhoLib_Object ) then
	WhoLib_Object = LibStub and LibStub('LibWho-2.0'):Library();
end
end

local function WhoLib_isLoaded()
if ( LibStub ) then
	if ( LibStub('LibWho-2.0', true) ) then
		WhoLib_Init();
		return true;
	else
		return false;
	end
else
	return false;
end
end

local function WhoLib_CallBack(result)
if ( result.Online ) then
	local Name = result.Name;
	local idx, ticket;
	for i, v in ipairs(queryResult) do
		if ( v.author == Name ) then
			idx = i;
			ticket = v;
			break;
		end
	end
	if ( ticket ) then
		ticket.authorGuild = result.Guild;
		ticket.authorLevel = result.Level;
		ticket.authorRace = result.Race;
		ticket.authorClass = result.Class;
		ticket.authorGuild = result.Guild;
		ticket.authorLocation = result.Zone;
		ticket.authorClassFileName = result.NoLocaleClass;
		if ( eventFrame.timer == nil ) then
			eventCallbackFunc[currentQuery.frameName]("GM_TICKET_UPDATE_TICKET", idx, ticket);
		end
	end
end
end

local function WhoLib_SendWho(theUser)
local result = WhoLib_Object:UserInfo(theUser, {
queue = WhoLib_Object.WHOLIB_QUEUE_QUIET,
timeout = 0,
flags = WhoLib_Object.WHOLIB_FLAG_ALLWAYS_CALLBACK,
callback = WhoLib_CallBack
});
if ( result ) then
	WhoLib_CallBack(result);
end
end

local function addTicket(data)
eventFrame.timer = TICKETHANDLER_GET_TIMEOUT;
eventFrame:Show();

if ( currentQuery.type == "GM_TICKET_QUERY_LOAD" and isFiltered(data, currentQuery) ) then
	return;
end

table_insert(tickets, data);
local pageSize, pageIndex = currentQuery.pageSize, currentQuery.pageIndex;
local size = #tickets;
if ( size > pageSize * (pageIndex - 1) and size <= pageSize * pageIndex ) then
	table_insert(queryResult, data);
	if ( WhoLib_isLoaded() ) then
		WhoLib_SendWho(data.author);
	end
	if ( #queryResult == pageSize ) then
		currentQuery.result = "SUCCESS";
		sendResults();
		finishQuery();
	end
end
end

local function delTicket(id)
local changed = false;
for index, value in pairs(tickets) do
	if ( value.id == id ) then
		table_remove(tickets, index);
		changed = true;
	end
end
for index, value in pairs(queryResult) do
	if ( value.id == id ) then
		table_remove(queryResult, index);
	end
end
if ( changed ) then
	sendResults();
end
end

local legacyMessageHandlers = {
TICKET_ADD = function(data)
if ( currentQuery.type ~= "GM_TICKET_SETUP_LOAD" and currentQuery.type ~= "GM_TICKET_QUERY_LOAD" ) then
	return;
end

addTicket(data.ticketData);
end,
TICKET_DEL = function(data)
if ( currentQuery.type ~= "GM_TICKET_SETUP_LOAD" and currentQuery.type ~= "GM_TICKET_QUERY_LOAD" ) then
	return;
end

delTicket(data.ticketId);
end,
TICKET_FLUSHALL = function()
if ( currentQuery.type ~= "GM_TICKET_SETUP_LOAD" and currentQuery.type ~= "GM_TICKET_QUERY_LOAD" ) then
	return;
end

table_clear(tickets);
table_clear(queryResult);
queryWaiting = true;
eventFrame.timer = TICKETHANDLER_GET_TIMEOUT;
eventFrame:Show();
end,
TICKETGETRESULT = function(data)
if ( currentQuery.type ~= "GM_TICKET_TICKET_LOAD" or data.queryId ~= currentQuery.ticketId ) then
	return;
end

queryResult.id, queryResult.data = data.queryId, data.queryResult;
currentQuery.result = "SUCCESS";
sendResults();
finishQuery();
end,
TICKETGETRESULT_APPEND = function(data)
if ( currentQuery.type ~= "GM_TICKET_TICKET_LOAD" or data.queryId ~= currentQuery.ticketId ) then
	return;
end

queryResult.data.ticketText = queryResult.data.ticketText.."\n"..data.queryResult.ticketText;
sendResults();
end,
};

function TicketHandler_HandleMessage(data)
	if ( not data.legacy ) then
		isLegacy = false;
		local handler = messageHandlers[data.opcode];
		if ( handler ) then
			if ( currentQuery ) then
				handler(data);
			end
			return true;
		end
	else
		isLegacy = true;
		local handler = legacyMessageHandlers[data.opcode];
		if ( handler ) then
			if ( currentQuery ) then
				handler(data);
			end
			return true;
		end
	end
end

local function newQuery(query)
if ( #queries == 1 and eventFrame.timer == nil ) then
	table_remove(queries, 1);
end
table_insert(queries, query);
if ( #queries == 1 ) then
	initNextQuery();
end
end

function GMTicketSetup_IsLoaded(frameName)
	return eventCallbackFunc[frameName] ~= nil;
end

function GMTicketSetup_BeginLoading(frameName, pageSize, pageIndex)
	newQuery({frameName = frameName, type = "GM_TICKET_SETUP_LOAD", pageSize = pageSize, pageIndex = pageIndex});
end

function GMTicketSetup_GetCategoryCount()
	return #categories;
end

function GMTicketSetup_GetCategoryData()
	return categories;
end

function GMTicketSetup_GetSubCategoryCount()
	return 0;
end

function GMTicketSetup_GetSubCategoryData()
	return {};
end

function GMTicketQuery_BeginLoading(frameName, searchText, categoryIndex, subcategoryIndex, pageSize, pageIndex)
	newQuery({frameName = frameName, type = "GM_TICKET_QUERY_LOAD", searchText = strlower(searchText), categoryIndex = categoryIndex, subcategoryIndex = subcategoryIndex, pageSize = pageSize, pageIndex = pageIndex});
end

function GMTicket_BeginLoading(frameName, ticketId)
	newQuery({frameName = frameName, type = "GM_TICKET_TICKET_LOAD", ticketId = ticketId});
end


