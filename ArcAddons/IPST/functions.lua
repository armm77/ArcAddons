--[[
 ArcAddons
 Copyright (C) 2012 Marforius

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

function mainform()
	IPST_MainForm:Show();
end

SlashCmdList["IPST"] = mainform;
SLASH_IPST1="/ipst";
SLASH_IPST2="/IPST";
print("ipst loaded")