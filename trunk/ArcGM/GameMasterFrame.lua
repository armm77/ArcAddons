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

_G.GAMEMASTERFRAME_SUBFRAMES = {"GameMasterGameMasterFrame", "GameMasterToolsFrame"};
_G.GAMEMASTERFRAME_SYNC_CHANNEL_TABBING = {
"GameMasterGameMasterFrameDaughterFrameChannelPassword",
"GameMasterGameMasterFrameDaughterFrameChannelName",
};

_G.UIPanelWindows["GameMasterFrame"] = {area = "left", pushable = 5, whileDead = 1};

local GameMaster = _G.GameMaster;

function ToggleGameMaster(tab)
	local subFrame = _G[tab];
	if ( subFrame ) then
		_G.PanelTemplates_SetTab(GameMasterFrame, subFrame:GetID());
		if ( GameMasterFrame:IsShown() ) then
			if ( subFrame:IsShown() ) then
				HideUIPanel(GameMasterFrame);
			else
				PlaySound("igCharacterInfoTab");
				GameMasterFrame_ShowSubFrame(tab);
			end
		else
			ShowUIPanel(GameMasterFrame);
			GameMasterFrame_ShowSubFrame(tab);
		end
	end
end

function GameMasterFrame_ShowSubFrame(frameName)
	for _, value in pairs(GAMEMASTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			getglobal(value):Show();
		else
			getglobal(value):Hide();
		end
	end
end

function GameMasterFrameTab_OnClick()
	GameMasterFrame_ShowSubFrame(GAMEMASTERFRAME_SUBFRAMES[this:GetID()]);
	PlaySound("igCharacterInfoTab");
end

function GameMasterFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
	
	GameMasterFrameTitleText:SetText(_G.NORMAL_FONT_COLOR_CODE.._G.GAME_MASTER.._G.FONT_COLOR_CODE_CLOSE.." "..GameMaster.version);
end

function GameMasterFrame_OnEvent(self, event, ...)
end

function GameMasterFrame_UpdateChannelStatus()
	local syncChannel = GameMaster.syncChannel;
	local text = _G.GameMasterGameMasterFrameChannelNameText;
	local str = syncChannel.name;
	if ( str ~= "" ) then
		text:SetText(str);
		text:SetTextColor(1.0, 1.0, 1.0);
	else
		text:SetText(GAMEMASTERFRAME_CHANNEL_NAME_NONE);
		local GRAY_FONT_COLOR = _G.GRAY_FONT_COLOR;
		text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	
	text = _G.GameMasterGameMasterFrameChannelPasswordText;
	str = syncChannel.password;
	if ( str and str ~= "" ) then
		text:SetText(str);
		text:SetTextColor(1.0, 1.0, 1.0);
	else
		if ( str ) then
			text:SetText(GAMEMASTERFRAME_CHANNEL_PASSWORD_NONE);
		else
			text:SetText(GAMEMASTERFRAME_CHANNEL_PASSWORD_UNKNOWN);
		end
		local GRAY_FONT_COLOR = _G.GRAY_FONT_COLOR;
		text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	
	local status = syncChannel.status;
	if ( status == nil ) then
		text = _G.GameMasterGameMasterFrameChannelStatusText;
		text:SetText(GAMEMASTERFRAME_CHANNEL_STATUS_NOT_CONNECTED);
		local RED_FONT_COLOR = _G.RED_FONT_COLOR;
		text:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		
		local button = GameMasterGameMasterFrameChannelConnectButton;
		button:SetText(GAMEMASTERFRAME_CHANNEL_BUTTON_CONNECT);
		button:Enable();
	elseif ( status == 1 ) then
		text = _G.GameMasterGameMasterFrameChannelStatusText;
		text:SetText(GAMEMASTERFRAME_CHANNEL_STATUS_CONNECTED);
		local GREEN_FONT_COLOR = _G.GREEN_FONT_COLOR;
		text:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		
		if ( syncChannel.password ) then
			local button = GameMasterGameMasterFrameChannelConnectButton;
			button:SetText(GAMEMASTERFRAME_CHANNEL_BUTTON_DISCONNECT);
			button:Enable();
		else
			local button = GameMasterGameMasterFrameChannelConnectButton;
			button:SetText(GAMEMASTERFRAME_CHANNEL_BUTTON_RECONNECT);
			button:Enable();
		end
	elseif ( status == 0 ) then
		local button = GameMasterGameMasterFrameChannelConnectButton;
		button:SetText(GAMEMASTERFRAME_CHANNEL_BUTTON_CONNECT);
		button:Disable();
		
		local text = _G.GameMasterGameMasterFrameChannelStatusText;
		text:SetText(GAMEMASTERFRAME_CHANNEL_STATUS_CONNECTING);
		local YELLOW_FONT_COLOR = _G.YELLOW_FONT_COLOR;
		if ( not YELLOW_FONT_COLOR ) then
			text:SetTextColor(1.0, 1.0, 0.0);
		else
			text:SetTextColor(YELLOW_FONT_COLOR.r or 1.0, YELLOW_FONT_COLOR.g or 1.0, YELLOW_FONT_COLOR.b or 0.0);
		end
	end
end

function GameMasterFrame_OnUpdate(self, elapsed)
end

function GameMasterFrame_OnShow()
	PlaySound("igCharacterInfoOpen");
end

function GameMasterFrame_OnHide()
	PlaySound("igCharacterInfoClose");
end

function GameMasterGameMasterFrame_ChannelSet_OnClick()
	if ( GameMasterGameMasterFrameDaughterFrame:IsShown() ) then
		GameMasterGameMasterFrameDaughterFrame:Hide();
	else
		local SyncChannelOptions = GameMaster.options.SyncChannel;
		GameMasterGameMasterFrameDaughterFrameChannelName:SetText(SyncChannelOptions.name);
		GameMasterGameMasterFrameDaughterFrameChannelPassword:SetText(SyncChannelOptions.password);
		GameMasterGameMasterFrameDaughterFrame:Show();
	end
end

function GameMasterGameMasterFrameDaughterFrame_Okay()
	local name, password = GameMasterGameMasterFrameDaughterFrameChannelName:GetText(), GameMasterGameMasterFrameDaughterFrameChannelPassword:GetText();
	local SyncChannelOptions = GameMaster.options.SyncChannel;
	SyncChannelOptions.name = name;
	SyncChannelOptions.password = password;
	GameMaster_SetChannel(GameMaster, name);
	
	-- Clear Out Values
	GameMasterGameMasterFrameDaughterFrame:Hide();
end

function GameMasterGameMasterFrameDaughterFrame_Cancel()
	this:GetParent():Hide();
end

function GameMasterGameMasterFrameDaughterFrame_OnHide()
	GameMasterGameMasterFrameDaughterFrameChannelName:SetText("");
	GameMasterGameMasterFrameDaughterFrameChannelPassword:SetText("");
end
