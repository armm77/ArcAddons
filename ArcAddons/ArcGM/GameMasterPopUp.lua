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

local function startAnim(popup, animation, height)
local speed = GameMaster.options.PopUps.animSpeed;
local moveDist = GameMaster.options.PopUps.animMoveDist;
popup.animIndexSize = height / moveDist;
popup.animInterval = moveDist;
popup.animSpeed = speed;
popup.animIndex = 1;
popup.timer = 0;
popup.animation = animation;
end

local math_floor = _G.math.floor;
local animation, speed, indexSize, timer, framesElapsed, index;
function GameMasterPopUp_OnUpdate(self, elapsed)
	if ( self.animation ) then
		animation = self.animation;
		speed = self.animSpeed;
		indexSize = self.animIndexSize;
		
		timer = self.timer + elapsed;
		framesElapsed = math_floor(timer / speed);
		index = self.animIndex + framesElapsed;
		if ( index > indexSize ) then
			index = indexSize;
		end
		if ( index ~= self.animIndex ) then
			self:SetHeight((animation == 0 and index or indexSize + 1 - index) * self.animInterval);
			self.animIndex = index;
		end
		if ( index == indexSize ) then
			if ( animation == 1 ) then
				self:Hide();
			end
			self.animation = nil;
		else
			self.timer = timer - (framesElapsed * speed);
		end
	end
	
	if ( self.idleTimer ) then
		timer = self.idleTimer - elapsed;
		if ( timer < 0 ) then
			timer = 0;
		end
		self.idleTicker:SetFormattedText("%.1f", timer);
		if ( timer ~= 0 ) then
			self.idleTimer = timer;
		else
			self.idleTimer = nil;
			startAnim(self, 1, self:GetHeight());
		end
	end
end

local GameMaster = _G.GameMaster;

local table_insert = _G.table.insert;

local GameFontNormal = _G.GameFontNormal;
local GameFontHighlight = _G.GameFontHighlight;

function GameMaster:PopUp(msg, onClickFunc)
	local popup;
	local framepointers;
	
	this.popupCount = this.popupCount + 1;
	this.popupIndex = this.popupIndex + 1;
	
	ArcGMMiniMapAlert:Show();
	ArcGMMiniMapAlert.alertFlashTimer = 0.5;
	
	local height = this.options.PopUps.height;
	if ( not this.popups[this.popupIndex] ) then
		popup = CreateFrame("Frame", nil, UIParent, "GameMasterPopUp");
		local width = this.options.PopUps.width;
		popup:SetWidth(width);
		local offsetY = this.options.PopUps.offsetY;
		local popupspercolumn = math_floor((GetScreenHeight() - offsetY) / height);
		local verticaloverflow = math_floor((this.popupIndex - 1) / popupspercolumn);
		popup:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", this.options.PopUps.offsetX + verticaloverflow * -width, offsetY + (verticaloverflow > 0 and (this.popupIndex - 1) % popupspercolumn or this.popupIndex - 1) * height);
		popup:SetScript("OnUpdate", function(self, elapsed) GameMasterPopUp_OnUpdate(self, elapsed) end);
		popup:SetScript("OnEnter", function(self) GameMasterPopUp_OnEnter(self) end);
		popup:SetScript("OnLeave", function(self) if ( not MouseIsOver(popup) ) then GameMasterPopUp_OnLeave(self); end; end);
		popup:SetScript("OnHide", function(self) GameMasterPopUp_OnHide(self) end);
		framepointers = {frame = popup, };
		table_insert(this.popups, framepointers);
		
		popup.idleTicker = popup:CreateFontString(nil, "OVERLAY");
		popup.idleTicker:SetFontObject(GameFontNormal);
		popup.idleTicker:SetPoint("CENTER", popup, "TOPLEFT", 20, -11);
		
		framepointers.title = popup:CreateFontString(nil, "OVERLAY");
		framepointers.title:SetFontObject(GameFontNormal);
		framepointers.title:SetPoint("CENTER", popup, "TOP", 0, -11);
		
		framepointers.message = CreateFrame("Button", nil, popup);
		framepointers.message:SetPoint("TOP", popup, "TOP", 0, -25);
		framepointers.message:SetWidth(width - 14);
		framepointers.message:SetHeight(height - 30);
		framepointers.message:SetScript("OnClick", function(self)
		self:onClickFunc();
		popup:Hide();
	end
	);
	framepointers.message:SetScript("OnEnter", function(self)
	if ( MouseIsOver(popup) ) then
		GameMasterPopUp_OnEnter(self:GetParent());
	end
	local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR;
	self:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetText(self:GetFontString():GetText());
	GameTooltip:Show();
	end);
	framepointers.message:SetScript("OnLeave", function(self)
	local NORMAL_FONT_COLOR = _G.NORMAL_FONT_COLOR;
	self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	GameTooltip:Hide();
	if ( not MouseIsOver(popup) ) then
		GameMasterPopUp_OnLeave(self:GetParent());
	end
	end);
	framepointers.message:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight");
	
	framepointers.messagetext = framepointers.message:CreateFontString(nil, "OVERLAY");
	framepointers.messagetext:SetFontObject(GameFontNormal);
	framepointers.messagetext:SetPoint("TOPLEFT", framepointers.message, "TOPLEFT");
	framepointers.messagetext:SetPoint("BOTTOMRIGHT", framepointers.message, "BOTTOMRIGHT");
	framepointers.message:SetFontString(framepointers.messagetext);
	
	framepointers.title:SetText(GAME_MASTER);
else
	framepointers = this.popups[this.popupIndex];
	popup = framepointers.frame;
	
	popup.idleTicker:SetText();
	popup.idleTimer = nil;
end

framepointers.message.onClickFunc = onClickFunc;
framepointers.messagetext:SetText(msg);

popup:SetHeight(1);
popup:Show();

startAnim(popup, 0, height);
end

function GameMasterPopUp_OnHide(self)
	GameMaster.popupCount = GameMaster.popupCount - 1;
	if ( GameMaster.popupCount <= 0 ) then
		if ( GameMaster.popupCount < 0 ) then
			DEFAULT_CHAT_FRAME:AddMessage("GM TICKET HANDLER: Null occured in popupcount.");
			GameMaster.popupCount = 0;
		end
		GameMaster.popupIndex = 0;
		ArcGMMiniMapAlert.alertFlashTimer = nil;
		ArcGMMiniMapAlert:Hide();
	end
end

function GameMasterPopUp_OnEnter(self)
	self.idleTicker:SetText();
	self.idleTimer = nil;
	if ( self.animation == 1 ) then
		self.animation = nil;
		self:SetHeight(GameMaster.options.PopUps.height);
	end
end

function GameMasterPopUp_OnLeave(self)
	local idleTime = GameMaster.options.PopUps.idleTime;
	self.idleTicker:SetText(idleTime);
	self.idleTimer = idleTime;
end

