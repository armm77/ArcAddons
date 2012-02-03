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

_G.GameMasterOptionsFrameCheckButtons = {
["GAMEMASTER_ALERTS"] = {index = 1, configBase = "Alerts", configIndex = "enable",   },
["GAMEMASTER_ALERTS_TICKETS"] = {index = 2, configBase = "Alerts", configIndex = "tickets", dependency = "GAMEMASTER_ALERTS", },
};

_G.GameMasterOptionsFrameEditBoxes = {
--~ ["CHANNEL_CHANNEL_NAME"] = { index = 1, configBase = "SyncChannel", configIndex = "name"},
--~ ["PASSWORD"] = { index = 2, configBase = "SyncChannel", configIndex = "password"},
};

--~ _G.GAMEMASTER_OPTIONS_SYNC_CHANNEL_TABBING = {
--~ "GameMasterOptionsFrameEditBox1",
--~ "GameMasterOptionsFrameEditBox2",
--~ };

_G.GAMEMASTER_OPTIONS_FRAME_WIDTH = 495;
_G.UIPanelWindows["GameMasterOptionsFrame"] = {area = "center", pushable = 0, whileDead = 1};

local GameMaster = _G.GameMaster;

local pairs = _G.pairs;

function GameMasterOptionsFrame_Init(self)
	
end

function GameMasterOptionsFrame_Load()
	for index, value in pairs(_G.GameMasterOptionsFrameCheckButtons) do
		_G["GameMasterOptionsFrameCheckButton"..value.index.."Text"]:SetText(getglobal(index));
		OptionsFrame_EnableCheckBox(_G["GameMasterOptionsFrameCheckButton"..value.index], 1, GameMaster.options[value.configBase][value.configIndex]);
	end
	
	GameMasterOptionsFrame_UpdateCheckboxes();
	
	GameMasterOptionsFrame:SetWidth(_G.GAMEMASTER_OPTIONS_FRAME_WIDTH);
	GameMasterOptionsFrameAlerts:SetWidth(_G.GAMEMASTER_OPTIONS_FRAME_WIDTH - 25);
end

function GameMasterOptionsFrame_Save()
	for index, value in pairs(_G.GameMasterOptionsFrameCheckButtons) do
		GameMaster.options[value.configBase][value.configIndex] = _G["GameMasterOptionsFrameCheckButton"..value.index]:GetChecked() and true or false;
	end
end

function GameMasterOptionsFrame_Cancel()
end

function GameMasterOptionsCheckButton_OnClick()
	if ( this:GetChecked() ) then
		_G.PlaySound("igMainMenuOptionCheckBoxOff");
	else
		_G.PlaySound("igMainMenuOptionCheckBoxOn");
	end
	GameMasterOptionsFrame_UpdateCheckboxes();
end

function GameMasterOptionsFrame_UpdateCheckboxes()
	for index, value in pairs(_G.GameMasterOptionsFrameCheckButtons) do
		if ( value.dependency ) then
			local button = _G["GameMasterOptionsFrameCheckButton"..value.index];
			local dependency = _G["GameMasterOptionsFrameCheckButton"..GameMasterOptionsFrameCheckButtons[value.dependency].index];
			local enable = dependency:GetChecked();
			if ( enable ) then
				OptionsFrame_EnableCheckBox(button);
			else
				OptionsFrame_DisableCheckBox(button);
			end
		end
	end
end

function GameMasterOptionsFrame_SetDefaults()
	for index, value in pairs(_G.GameMasterOptionsFrameCheckButtons) do
		_G["GameMasterOptionsFrameCheckButton"..value.index]:SetChecked(GameMaster_DefaultOptions[value.configBase][value.configIndex]);
	end
	GameMasterOptionsFrame_UpdateCheckboxes();
end

