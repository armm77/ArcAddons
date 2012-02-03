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

local _collectgarbage = _G.collectgarbage
_collectgarbage("stop")
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
_G.collectgarbage = _collectgarbage
collectgarbage("collect")
collectgarbage("restart")
f:SetScript("OnEvent", nil)
end)

-- Improves loading time by 40-70%
-- stops garbage collection during loading screens.
