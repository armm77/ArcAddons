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

_G.GameMaster_UnitPopupButtons = {
{index = "WHOIS", value = {text = WHOIS, dist = 0, tooltipText = TOOLTIP_WHOIS, }},
{index = "ADD_GMTARGET", value = {text = ADD_GMTARGET, dist = 0, tooltipText = TOOLTIP_ADD_GMTARGET, }},
{index = "REMOVE_GMTARGET", value = {text = REMOVE_GMTARGET, dist = 0, tooltipText = TOOLTIP_REMOVE_GMTARGET, }},
{index = "TELEPORT_TO_PLAYER", value = {text = TELEPORT_TO_PLAYER, dist = 0, tooltipText = TOOLTIP_TELEPORT_TO_PLAYER, }},
{index = "SUMMON_PLAYER", value = {text = SUMMON_PLAYER, dist = 0, tooltipText = TOOLTIP_SUMMON_PLAYER, }},
{index = "REVIVE_PLAYER", value = {text = REVIVE_PLAYER, dist = 0, tooltipText = TOOLTIP_REVIVE_PLAYER, }},
{index = "KILL_PLAYER", value = {text = KILL_PLAYER, dist = 0, tooltipText = TOOLTIP_KILL_PLAYER, }},
{index = "SERVER_KICK", value = {text = SERVER_KICK, dist = 0, tooltipText = TOOLTIP_SERVER_KICK, }},
{index = "SERVER_BAN", value = {text = SERVER_BAN, dist = 0, tooltipText = TOOLTIP_SERVER_BAN, }},
};

local buttonHandlers = {
WHOIS = function()
GMConsoleExec("whois", UIDROPDOWNMENU_INIT_MENU.name);
end,
ADD_GMTARGET = function()
GMConsoleExec("addgmtarget", UIDROPDOWNMENU_INIT_MENU.name);
end,
REMOVE_GMTARGET = function()
GMConsoleExec("remgmtarget", UIDROPDOWNMENU_INIT_MENU.name);
end,
TELEPORT_TO_PLAYER = function()
GMConsoleExec("appear", UIDROPDOWNMENU_INIT_MENU.name);
end,
SUMMON_PLAYER = function()
GMConsoleExec("summon", UIDROPDOWNMENU_INIT_MENU.name);
end,
REVIVE_PLAYER = function()
GMConsoleExec("rese", UIDROPDOWNMENU_INIT_MENU.name);
end,
KILL_PLAYER = function()
GMConsoleExec("kille", UIDROPDOWNMENU_INIT_MENU.name);
end,
SERVER_KICK = function()
local plrname = UIDROPDOWNMENU_INIT_MENU.name;
local dialog = StaticPopup_Show("SERVER_KICK_REASON", plrname);
if ( dialog ) then
	dialog.data = plrname;
end
end,
SERVER_BAN = function()
local plrname = UIDROPDOWNMENU_INIT_MENU.name;
local dialog = StaticPopup_Show("SERVER_BAN_DURATION", plrname);
if ( dialog ) then
	dialog.data = plrname;
end
end,
};

function GameMaster_UnitPopup_OnClick()
	local handler = buttonHandlers[this.value];
	if ( handler ) then
		handler();
	end
end

local UnitPopupMenus = _G.UnitPopupMenus;

local ipairs = _G.ipairs;
local table_insert = _G.table.insert;

local function insertButton(menu, button)
local t = UnitPopupMenus[menu];
local pos;
for index, value in ipairs(t) do
	if ( value == "CANCEL" ) then
		pos = index - 1;
	end
end
if ( pos == nil ) then
	pos = #t + 1;
end
table_insert(t, pos, button);
end

local UnitPopupButtons = _G.UnitPopupButtons;

local orig_UIDropDownMenu_AddButton;

local originfo = {};

local function addSeparator(info, UIDropDownMenu_AddButton)
for k, v in pairs(info) do
	originfo[k] = v;
	info[k] = nil;
end
info.disabled = 1;
orig_UIDropDownMenu_AddButton(info);
info.disabled = nil;
for k, v in pairs(originfo) do
	info[k] = v;
	originfo[k] = nil;
end
end

local function _UIDropDownMenu_AddButton(info, level, ...)
local retval;
local value = info.value;
if ( value == GameMaster_UnitPopupButtons[1].index ) then
	addSeparator(info, orig_UIDropDownMenu_AddButton);
end
retval = orig_UIDropDownMenu_AddButton(info, level, ...);
if ( value == "REMOVE_GMTARGET" or value == "SERVER_BAN" ) then
	addSeparator(info, orig_UIDropDownMenu_AddButton);
end
return retval;
end

function GameMaster_SetUpUnitPopupHooks()
	StaticPopupDialogs["SERVER_KICK_REASON"] = {
	text = SERVER_KICK_REASON_LABEL,
	button1 = SERVER_KICK,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 255,
	hasWideEditBox = 1,
	OnShow = function(self, data)
	self:SetWidth(420);
	local editBox = getglobal(self:GetName().."WideEditBox");
	editBox:SetMaxLetters(255 - #(GetGMCommandString("kick").." "..(data or "123456789012")));
	editBox:SetFocus();
	end,
	OnHide = function(self)
	-- if ( ChatFrameEditBox:IsShown() ) then
	-- ChatFrameEditBox:SetFocus();
	-- end
	getglobal(self:GetName().."WideEditBox"):SetText("");
	end,
	OnAccept = function(self, data)
	GMConsoleExec("kick", data, getglobal(self:GetParent():GetName().."WideEditBox"):GetText());
	end,
	EditBoxOnEnterPressed = function(self, data)
	GMConsoleExec("kick", data, getglobal(self:GetParent():GetName().."WideEditBox"):GetText());
	self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
	self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	};
	StaticPopupDialogs["SERVER_BAN_DURATION"] = {
	text = SERVER_BAN_DURATION_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 7,
	OnShow = function(self, data)
	getglobal(self:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function(self)
	-- if ( ChatFrameEditBox:IsShown() ) then
	-- ChatFrameEditBox:SetFocus();
	-- end
	getglobal(self:GetName().."EditBox"):SetText("");
	end,
	OnAccept = function(self, data)
	local duration = getglobal(self:GetParent():GetName().."EditBox"):GetText();
	local dialog = StaticPopup_Show("SERVER_BAN_REASON", data, duration);
	if ( dialog ) then
		dialog.data = {plrname = data, duration = duration};
	end
	end,
	EditBoxOnEnterPressed = function(self, data)
	local duration = getglobal(self:GetParent():GetName().."EditBox"):GetText();
	self:GetParent():Hide();
	local dialog = StaticPopup_Show("SERVER_BAN_REASON", data, duration);
	if ( dialog ) then
		dialog.data = {plrname = data, duration = duration};
	end
	end,
	EditBoxOnEscapePressed = function(self)
	self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	};
	StaticPopupDialogs["SERVER_BAN_REASON"] = {
	text = SERVER_BAN_REASON_LABEL,
	button1 = SERVER_BAN,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 255,
	hasWideEditBox = 1,
	OnShow = function(self, data)
	self:SetWidth(420);
	local editBox = getglobal(self:GetName().."WideEditBox");
	editBox:SetMaxLetters(255 - #(GetGMCommandString("nuke").." "..(data and data.plrname or "123456789012").." "..(data and data.duration or "596523h")));
	editBox:SetFocus();
	end,
	OnHide = function(self)
	-- if ( ChatFrameEditBox:IsShown() ) then
	-- ChatFrameEditBox:SetFocus();
	-- end
	getglobal(self:GetName().."WideEditBox"):SetText("");
	end,
	OnAccept = function(self, data)
	GMConsoleExec("nuke", data.plrname, data.duration, getglobal(self:GetParent():GetName().."WideEditBox"):GetText());
	end,
	EditBoxOnEnterPressed = function(self, data)
	GMConsoleExec("nuke", data.plrname, data.duration, getglobal(self:GetParent():GetName().."WideEditBox"):GetText());
	self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
	self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	};
	
	for _, data in ipairs(GameMaster_UnitPopupButtons) do
		local index = data.index;
		UnitPopupButtons[index] = data.value;
		insertButton("FRIEND", index);
		insertButton("PLAYER", index);
		insertButton("TEAM", index);
		insertButton("RAID_PLAYER", index);
		insertButton("PARTY", index);
	end
	
	hooksecurefunc("UnitPopup_OnClick", GameMaster_UnitPopup_OnClick);
	
	orig_UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton;
	_G.UIDropDownMenu_AddButton = _UIDropDownMenu_AddButton;
end

