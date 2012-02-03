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

itemNumber = {}
itemCount = {}
itemLocation = {}

------------------------------------------------------------------------
-- not used (todo:prevent target swap close addon if target swap) --
-- function GetTarget(self)           --
--  name, realm = UnitName("target");        --
--  getglobal(self.."Label"):SetText(name);      --
-- end                --
------------------------------------------------------------------------

function ShowItems()
	outSAY("server save");
	outSAY("character showitems");
end

function EmptyAll()
	outSAY("character clearinventory");
	outSAY("server save");
end

-- Fired when a server message is sent to the client
function Chat_OnMyEvent(event, text)
	if string.find(text, "Link:") then
		
		itemStart, itemEnd = string.find(text, "Item:");
		countStart, countEnd = string.find(text, "Count:");
		containerStart, containerEnd = string.find(text, "Container:");
		slotStart, slotEnd = string.find(text, "Slot:");
		
		item = tonumber(string.sub(text, itemEnd+1, countStart-2));
		count = tonumber(string.sub(text, countEnd+1, containerStart-2));
		container = tonumber(math.abs(string.sub(text, containerEnd+1, slotStart-2)));
		slot = tonumber(string.sub(text, slotEnd+1, -1));
		location = ( container.."_".. slot );
		
		BuildSearchTable(location, item, count, container, slot);
		
	end
end

function BuildSearchTable(location, item, count, container, slot)
	if (location) then
		itemNumber[location] = item;
		itemCount[location] = count;
		itemLocation[location] = {container, slot}
	end
end

function SendContainerName(sentname)
	ContainerSelectorForm:Hide();
	containername = string.sub(sentname,22 );
	getglobal(containername.."Form"):Show();
end

function GetTexture(item)
	local itemIcon = GetItemIcon(item)
	return itemIcon
end

function GetItem(fieldname)
	nameStart, nameEnd = string.find(fieldname, "Texture");
	location = string.sub(fieldname, nameEnd+1, -1);
	getglobal(fieldname.."Texture"):Hide();
	for i,v in pairs(itemNumber) do
		if (i == location) then
			getglobal(fieldname.."Texture"):SetTexture(GetTexture("item:"..v));
			getglobal(fieldname.."Texture"):Show();
		end
	end
end

function GetCount(fieldname)
	nameStart, nameEnd = string.find(fieldname, "Count");
	location = string.sub(fieldname, nameEnd+1, -1);
	getglobal(fieldname.."Label"):Hide();
	for i,v in pairs(itemCount) do
		if ( i == location) and ( v > 1 ) then
			getglobal(fieldname.."Label"):SetText(v);
			getglobal(fieldname.."Label"):SetTextColor(255, 255, 255);
			getglobal(fieldname.."Label"):Show();
		end
	end
end

function ShowTooltip(button, self)
	buttonStart, buttonEnd = string.find(button, "Button");
	buttonItem = string.sub(button, buttonEnd+1, -1);
	for i,v in pairs(itemNumber) do
		if ( i == buttonItem) then
			GameTooltip:ClearLines();
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 24)
			GameTooltip:SetHyperlink("item:"..v..":0:0:0:0:0:0:0");
			GameTooltip:AddLine("Click to remove from inventory", .3, .7,.4);
			GameTooltip:Show();
		end
	end
end

function RemoveFromContainerSlot(buttonname)
	nameStart, nameEnd = string.find(buttonname, "Button");
	location = string.sub(buttonname, nameEnd+1, -1);
	tempcontainer, slot = strsplit("_", location);
	
	--change 1 back to -1
	if (tonumber(tempcontainer) == 1) then
		container = -1;
	else
		container = tempcontainer;
	end
	
	outSAY("character removeitemslot "..container.." "..slot);
	
	getglobal(buttonname):Hide();
	count = string.gsub(buttonname, "Button", "Count")
	getglobal(count):Hide();
	texture = string.gsub(buttonname, "Button", "Texture")
	getglobal(texture):Hide();
end

function ClearTables()
	wipe(itemNumber);
	wipe(itemCount);
	wipe(itemLocation);
end

