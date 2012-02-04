--[[
 ArcGM
 Copyright (C) 2012 Marforius

 This file is part of ArcGM.

 ArcGM is free software: you can redistribute it
 and/or modify it under the terms of the GNU General Public License as
 published by the Free Software Foundation, version 3.

 ArcGM is distributed in the hope that it will
 be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with ArcGM. If not, see <http://www.gnu.org/licenses/>.

 This code is also released under the Attribution-Noncommercial-Share Alike 3.0 United States License its terms overwrite the GNU licence where applicable.
 http://creativecommons.org/licenses/by-nc-sa/3.0/us/
]]

local _G = getfenv(0);

_G.GameMaster_DefaultOptions = {
 SyncChannel = {
 autoJoin = true,
 name = "gm_sync_channel",
 password = "",
 },
 Alerts = {
 enable = true,
 tickets = true,
 cheaters = true,
 },
 PopUps = {
 width = 200,
 height = 160,
 offsetX = -18,
 offsetY = 55,
 animSpeed = 0.0075,
 animMoveDist = 1.0,
 idleTime = 5.0,
 },
 AutoToggle = {
 gmtag = false,
 invisible = false,
 beastmaster = false,
 autojoingmchannel = true,
 },
};

_G.GameMaster_DefaultStatistics = {
 sessions = 0,
 time = 0,
};

--~ _G.GameMaster_DefaultMessagePresets = {
--~ {title = "Greetings", msg = "Greetings, I am Game Master $me. What can I help you with, $st?"},
--~ };

function GameMaster_OnLoad(self)
 DEFAULT_CHAT_FRAME:AddMessage("");

 self.popups = {};
 self.popupIndex = 0;
 self.popupCount = 0;

 self.syncChannel = {
 status = nil,
 cid = 0,
 cname = "",
 name = "",
 password = "",
 };

 self.currentSession = {};

 self.version = GetAddOnMetadata("ArcGM", "Version");

 self:RegisterEvent("ADDON_LOADED");
 self:RegisterEvent("PLAYER_LOGIN");
end

local events = {};

function GameMaster_OnEvent(self, event, ...)
 events[event](self, ...);
end

function GameMaster_OnUpdate(self, elapsed)
 if ( not self.initTimer ) then
 return;
 end

 self.initTimer = self.initTimer - elapsed;
 if ( self.initTimer <= 0 ) then
 self.initTimer = nil;
 GameMaster_DelayInit(self);
 end
end

function GameMaster_DelayInit(self)

 local SyncChannelOptions = self.options.SyncChannel;
 if ( SyncChannelOptions.autoJoin ) then
 GameMaster_OpenChannel(self);
 else
 GameMaster_SetChannel(self, SyncChannelOptions.name);
 end
end

local function setScreenRatio(self)
 local screenX, screenY = GetScreenWidth(), GetScreenHeight();
 if ( screenX and screenY ) then
 self.screenRatio = screenX / screenY;
 return;
 end
 self.screenRatio = nil;
end

function events.ADDON_LOADED(self, name)
 if ( name ~= "ArcGM" ) then
 return;
 end

 GameMaster_InitSettings(self);

 if ( _G.GAMEMASTER_INITIALIZED ) then
 return;
 end
 _G.GAMEMASTER_INITIALIZED = true;

 setScreenRatio(self);
 self:RegisterEvent("CVAR_UPDATE");

 if ( not GameMaster_SetChannel(self, self.options.SyncChannel.name) ) then
 self.initTimer = 5;
 end
 self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");

 GameMaster_SetUpUnitPopupHooks();
end

function events.PLAYER_LOGIN(self)
 if ( self.options.AutoToggle.gmtag ) then
 GMConsoleExec("gm", 1);
 end
 if ( self.options.AutoToggle.invisible ) then
 GMConsoleExec("invisible");
 elseif ( self.options.AutoToggle.beastmaster ) then
 GMConsoleExec("beastmaster");
 end
 if ( self.options.AutoToggle.autojoingmchannel ) then
 GameMaster_ToggleChannelConnection(); -- derp
 ConsoleAddMessage(" Automatically joined GM channel. ")
 end
end

local _password;

function events.CHAT_MSG_CHANNEL_NOTICE(self, noticeType, _, _, _, _, _, _, chanid, channame)
 if ( noticeType == "YOU_JOINED" ) then
 if ( strupper(channame) ~= strupper(self.options.SyncChannel.name) ) then
 return;
 end
 self.initTimer = nil;
 GameMaster_SetChannel(self, channame, _password);
 _password = nil;
 elseif ( noticeType == "YOU_LEFT" ) then
 if ( chanid ~= self.syncChannel.cid ) then
 return;
 end
 GameMaster_RemoveChannel(self, nil, true);
 end
end

function GameMaster_SetChannel(self, name, password, only_set, old_cname)
 local syncChannel = self.syncChannel;
 local channelId, channelName = GetChannelName(name);
 local cname = channelName and strupper(channelName);
 if ( syncChannel.status == 1 ) then
 if ( cname ~= syncChannel.cname ) then
 if ( syncChannel.password ) then
 return;
 elseif ( channelId == 0 ) then
 GameMaster_RemoveChannel(self, true);
 return;
 end
 else
 return true;
 end
 end

 if ( channelId ~= 0 ) then
 if ( not old_cname or cname ~= old_cname ) then
 syncChannel.password = password;
 syncChannel.name = channelName;
 syncChannel.cname = cname;
 syncChannel.cid = channelId;
 syncChannel.status = 1;
 self:RegisterEvent("CHAT_MSG_CHANNEL");
 GameMasterFrame_UpdateChannelStatus();
 end
 return true;
 elseif ( not only_set ) then
 GameMaster_RemoveChannel(self);
 end
end

function GameMaster_RemoveChannel(self, forced, triggered)
 local syncChannel = self.syncChannel;
 local old_name = syncChannel.cname;
 local old_password = syncChannel.password;
 local SyncChannelOptions = self.options.SyncChannel;
 local name = SyncChannelOptions.name;
 self:UnregisterEvent("CHAT_MSG_CHANNEL");
 syncChannel.status = nil;
 syncChannel.cid = 0;
 syncChannel.cname = "";
 syncChannel.name = name;
 syncChannel.password = SyncChannelOptions.password;
 GameMasterFrame_UpdateChannelStatus();

 if ( not forced and (old_name ~= strupper(name) or not old_password) ) then
 GameMaster_SetChannel(self, name, nil, true, triggered and old_name);
 end
end

function GameMaster_OpenChannel(self)
 local options = self.options;
 local name = options.SyncChannel.name;
 local password = options.SyncChannel.password;
 if ( not GameMaster_SetChannel(self, name, nil, true) ) then
 self.syncChannel.password = password;
 self.syncChannel.name = name;
 self.syncChannel.status = 0;
 GameMasterFrame_UpdateChannelStatus();

 _password = password;
 JoinChannelByName(name, password);
 end
end

function GameMaster_CloseChannel(self)
 local syncChannel = self.syncChannel;
 if ( syncChannel.password ) then
 LeaveChannelByName(syncChannel.cid);
 else
 GameMaster_RemoveChannel(self);
 end
end

function GameMaster_ToggleChannelConnection()
 local status = GameMaster.syncChannel.status;
 if ( status == nil ) then
 GameMaster_OpenChannel(GameMaster);
 elseif ( status == 1 ) then
 GameMaster_CloseChannel(GameMaster);
 end
end

local ParseData = ParseGMSyncMessage;

function events.CHAT_MSG_CHANNEL(self, msg, author, _, _, _, _, _, _, channame)
 if ( strupper(channame) ~= self.syncChannel.cname ) then
 return;
 end

 -- if ( author == "" ) then
 local msgType, data = ParseData(msg);
 if ( data ) then
 if ( self.options.Alerts.enable ) then
 if ( msgType == "CHEATER" ) then
  if ( self.options.Alerts.cheaters ) then
  local name = data.cheaterName;
  self:PopUp(format(data.cheat_msg, name), function() ChatFrame_SendTell(name); end);
  return;
  end
 elseif ( msgType == "TICKET" ) then
  if ( data.opcode ) then
  TicketHandler_HandleMessage(data);
  if ( self.options.Alerts.tickets ) then
  local action = data.opcode;
  local text, name;
  if ( action == "NEWTICKET" ) then
  name = data.ticketAuthor;
  text = "New ticket:\n"..name;
 --~  elseif ( action == "TICKET_DEL" ) then
 --~  name = data.ticketId;
 --~  text = "Ticket deleted:\n"..name;
  else
  return;
  end
  self:PopUp(text, function() ShowUIPanel(GameMasterTicketFrame); GMTicket_BeginLoading("GameMasterTicketFrame", name); end);
  return;
  end
  end
 end
 end
--~ else
--~ DEFAULT_CHAT_FRAME:AddMessage("Game Master: event CHAT_MSG_CHANNEL : could not parse data");
--~ self:PopUp(author.." says:\n"..msg, function() ChatFrame_SendTell(author); end);
 end
 -- else
 -- local prefix, data = strmatch(msg, "^([^:]+):?(.*)");
 -- end
end

function events.CVAR_UPDATE(self, name, value)
 if ( name ~= "USE_UISCALE" ) then
 return;
 end

 setScreenRatio(self);
end

local type = _G.type;
local pairs = _G.pairs;

local function table_fill(table1, table2)
 for k, v in pairs(table2) do
 if ( type(v) == "table" ) then
 if ( type(table1[k]) ~= "table" ) then
 table1[k] = {};
 end
 table_fill(table1[k], v);
 elseif ( table1[k] == nil ) then
 table1[k] = v;
 end
 end
end

local function table_trim(t, template)
 for k, v in pairs(t) do
 if ( template[k] == nil ) then
 t[k] = nil;
 elseif ( type(v) == "table" ) then
 table_trim(v, template[k]);
 end
 end
end

function GameMaster_InitSettings(self)
 local savedVariable = _G.GAMEMASTER_OPTIONS;
 if ( type(savedVariable) ~= "table" ) then
 DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating SavedVariable: options");
 savedVariable = {};
 _G.GAMEMASTER_OPTIONS = savedVariable;
 end
 local realmName = GetCVar("realmName");
 local subtable = savedVariable[realmName];
 if ( type(subtable) ~= "table" ) then
 DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating SavedVariable: options[\""..realmName.."\"]");
 subtable = {};
 savedVariable[realmName] = subtable;
 end
 do
 local defaultOptions = _G.GameMaster_DefaultOptions;
 table_fill(subtable, defaultOptions);
 table_trim(subtable, defaultOptions);
 end
 self.options = subtable;

 savedVariable = _G.GAMEMASTER_STATISTICS;
 if ( type(savedVariable) ~= "table" ) then
 DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating SavedVariable: statistics");
 savedVariable = {};
 _G.GAMEMASTER_STATISTICS = savedVariable;
 end
 subtable = savedVariable[realmName];
 if ( type(subtable) ~= "table" ) then
 DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating SavedVariable: statistics[\""..realmName.."\"]");
 subtable = {};
 savedVariable[realmName] = subtable;
 end
 self.statistics = subtable;
 GameMaster_InitStatistics(self);

--~ savedVariable = _G.GAMEMASTER_MESSAGEPRESETS;
--~ if ( type(savedVariable) ~= "table" ) then
--~ DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating SavedVariable: messagepresets");
--~ savedVariable = {};
--~ _G.GAMEMASTER_MESSAGEPRESETS = savedVariable;
--~ end
--~ if ( #savedVariable == 0 ) then
--~ table_fill(savedVariable, _G.GameMaster_DefaultMessagePresets);
--~ end
--~ self.messagepresets = savedVariable;
end

function GameMaster_CheckStatistics(self)
 local stats = self.statistics;
 local pDate = date("*t");
 local per_year = stats[pDate.year];
 if ( type(per_year) ~= "table" ) then
 DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating statistics table for year "..pDate.year);
 per_year = {};
 stats[pDate.year] = per_year;
 end
 local per_month = per_year[pDate.month];
 if ( type(per_month) ~= "table" ) then
 DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating statistics table for month "..pDate.month);
 per_month = {};
 per_year[pDate.month] = per_month;
 end
 local per_day = per_month[pDate.day];
 if ( type(per_day) ~= "table" ) then
 DEFAULT_CHAT_FRAME:AddMessage("Game Master: creating statistics table for day "..pDate.day);
 per_day = {};
 per_month[pDate.day] = per_day;
 end
 table_fill(per_day, _G.GameMaster_DefaultStatistics);

 return per_day;
end

function GameMaster_InitStatistics(self)
 GameMaster_CheckStatistics(self);

 self.AddSessionStatistics = function()
 local per_day = GameMaster_CheckStatistics(self);
 per_day.sessions = per_day.sessions + 1;
 per_day.time = per_day.time + self.currentSession.timer;
 end;
end


