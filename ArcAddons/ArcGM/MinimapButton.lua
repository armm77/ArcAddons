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
local GameMaster = _G.GameMaster;

function ArcGMMinimap_Show()
	GameTooltip:SetOwner( this, "ANCHOR_LEFT" );
	GameTooltip:AddLine( "|cFF00FF00ArcGM "..ArcGMversion.." r"..ArcGMbuild.."|r" );
	local session = GameMaster.currentSession;
	if ( not session.id ) then
		local GRAY_FONT_COLOR = _G.GRAY_FONT_COLOR;
		GameTooltip:AddLine(_G.GMMINIMAPTOOLTIP_NOT_IN_SESSION, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	else
		local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR;
		GameTooltip:AddLine(format(_G.GMMINIMAPTOOLTIP_IN_SESSION, session.name), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	GameTooltip:AddLine( "|cFF00FFCCLeft click to show/hide|r" );
	GameTooltip:AddLine( "|cFFFF0000Right click to drag this|r" );
	GameTooltip:Show();
end

function ArcGMMiniMap_OnUpdate(self, elapsed)
	if ( self.alertFlashTimer ) then
		self.alertFlashTimer = self.alertFlashTimer - elapsed;
		if ( self.alertFlashTimer <= 0 ) then
			if ( ArcGMMiniMapAlert:IsShown() ) then
				ArcGMMiniMapAlert:Hide();
			else
				ArcGMMiniMapAlert:Show();
			end
			self.alertFlashTimer = 0.5;
		end
	end
end

function ArcGMMinimap_Initialize()
	if not ArcGMMinimapPosition then
		ArcGMMinimapPosition = -25;
	end
end

function ArcGMMinimap_BeingDragged()
	local xpos,ypos = GetCursorPosition();
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();
	xpos = xmin-xpos/UIParent:GetScale()+70;
	ypos = ypos/UIParent:GetScale()-ymin-70;
	ArcGMMinimap_SetPosition(math.deg(math.atan2(ypos,xpos)));
end

function ArcGMMinimap_SetPosition(v)
	if(v < 0) then
	v = v + 360;
end
ArcGMMinimapPosition = v;
ArcGMMinimap_UpdatePosition();
end

function ArcGMMinimap_UpdatePosition()
	ArcGM_MinimapButton:SetPoint(
	"TOPLEFT",
	"Minimap",
	"TOPLEFT",
	54 - (78 * cos(ArcGMMinimapPosition)),
	(78 * sin(ArcGMMinimapPosition)) - 55
	);
end

---------------------------------------------
-- This is called on addon init
	 ShowMessage("ArcGM "..ArcGMversion.." r"..ArcGMbuild.." loaded!", "00FF00");
	 ShowMessage("For ArcGM slash commands type \"/ArcGM\" many high level commands have been consolidated for macro use.");
	 if select(4, GetBuildInfo()) ~= 30300 then 
	 print("Your WoW Client \("..GetBuildInfo().."\) is not supported by ArcGM "..ArcGMversion.." r"..ArcGMbuild.."!")
	 print("You may experience undesired results, please report issues on the ArcAddon forums. You may also look for an update for this version \("..GetBuildInfo().."\) or please state it in the report.")
	 end
