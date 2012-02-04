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

_G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE = 20;
_G.GMTICKETFRAME_NUM_FAKE_CATEGORIES = 1;
_G.GMTICKETFRAME_NUM_FAKE_SUBCATEGORIES = 1;
_G.GMTICKETFRAME_SEARCH_BUTTON_DELAY = 1;
_G.GMTICKETFRAME_DEFAULT_SEARCH_TEXT = "("..NAME..")";
_G.GMTICKETFRAME_CURRENT_PAGE = 1;
_G.GMTICKETFRAME_SEARCH_PERFORMED = 0;
_G.GMTICKETFRAME_SETUP_LOADED = 0;
_G.GMTICKETFRAME_ENABLE_SEARCH = 1;
_G.UIPanelWindows["GameMasterTicketFrame"] = {area = "center", pushable = 0, whileDead = 1};

local GameMaster = _G.GameMaster;

function GameMasterTicketFrame_OnLoad()
	TicketHandler_RegisterForEvents("GameMasterTicketFrame", GameMasterTicketFrame_OnEvent);
	GameMasterTicketFrame_DisableButtons();
	GameMasterTicketFrameEditBox:SetMaxLetters(12);
	GameMasterTicketFrameEditBox:SetText(_G.GMTICKETFRAME_DEFAULT_SEARCH_TEXT);
	UIDropDownMenu_Initialize(GameMasterTicketFrameCategoryDropDown, GameMasterTicketFrameCategoryDropDown_Initialize);
	GameMasterTicketListFrameCount:SetPoint("TOPRIGHT", "GameMasterTicketListFramePreviousButton", "TOPLEFT", -6, -7);
	GameMasterTicketTicketScrollChildFrameText:SetWidth(GameMasterTicketTicketScrollChildFrame:GetWidth() - 10);
	GameMasterTicketListFramePreviousButton:SetPoint("RIGHT", "GameMasterTicketListFrameNextButton", "LEFT", - (GameMasterTicketListFramePreviousButtonText:GetWidth() + GameMasterTicketListFrameNextButtonText:GetWidth() + 5), 0);
end

function GameMasterTicketFrame_OnShow()
	PlaySound("igCharacterInfoOpen");
	if ( _G.GMTICKETFRAME_SETUP_LOADED == 0 ) then
		GMTicketSetup_BeginLoading("GameMasterTicketFrame", GMTICKETFRAME_NUM_TICKETS_PER_PAGE, GMTICKETFRAME_CURRENT_PAGE);
	end
	
	UpdateGameMasterSessionStatus();
end

function GameMasterTicketFrame_OnHide()
	PlaySound("igCharacterInfoClose");
end

local events = {
GM_TICKET_SETUP_LOAD_SUCCESS = function(result, totalTicketHeaderCount)
UIDropDownMenu_Initialize(GameMasterTicketFrameSubCategoryDropDown, GameMasterTicketFrameSubCategoryDropDown_Initialize);

GameMasterTicketListFrameTitle:SetText(_G.GMTICKETFRAME_UNREAD_PETITIONS);

local ticketHeaderCount = #result;
GameMasterTicketFrame_EnableButtons(ticketHeaderCount, totalTicketHeaderCount);

if ( ticketHeaderCount > 0 ) then
	_G.GMTICKETFRAME_SETUP_LOADED = 1;
	GameMasterTicketListFrame_PopulateTicketList(ticketHeaderCount, totalTicketHeaderCount, result);
	GameMasterTicketFrame_ShowSearchFrame();
else
	_G.GMTICKETFRAME_SETUP_LOADED = 0;
	GameMasterTicketErrorFrame_SetErrorMessage(_G.GMTICKETFRAME_ERROR_NO_RESULTS);
	GameMasterTicketFrame_ShowErrorFrame();
end
end,
GM_TICKET_SETUP_LOAD_FAILURE = function()
GameMasterTicketErrorFrame_SetErrorMessage(_G.GMTICKETFRAME_ERROR_LOAD_FAILURE);
GameMasterTicketFrame_ShowErrorFrame();
GameMasterTicketFrame_DisableButtons(nil);
GameMasterTicketFrameUnreadPetitionsButton:Enable();

_G.GMTICKETFRAME_SETUP_LOADED = 0;
end,
GM_TICKET_QUERY_LOAD_SUCCESS = function(result, totalTicketHeaderCount)
GameMasterTicketListFrameTitle:SetText(_G.GMTICKETFRAME_SEARCH_RESULTS);

local ticketHeaderCount = #result;
GameMasterTicketFrame_EnableButtons(ticketHeaderCount, totalTicketHeaderCount);

if ( ticketHeaderCount > 0 ) then
	GameMasterTicketListFrame_PopulateTicketList(ticketHeaderCount, totalTicketHeaderCount, result);
	GameMasterTicketFrame_ShowSearchFrame();
else
	GameMasterTicketErrorFrame_SetErrorMessage(_G.GMTICKETFRAME_ERROR_NO_RESULTS);
	GameMasterTicketFrame_ShowErrorFrame();
end
end,
GM_TICKET_QUERY_LOAD_FAILURE = function()
GameMasterTicketErrorFrame_SetErrorMessage(_G.GMTICKETFRAME_ERROR_LOAD_FAILURE);
GameMasterTicketFrame_ShowErrorFrame();
GameMasterTicketFrame_DisableButtons(nil);
GameMasterTicketFrameUnreadPetitionsButton:Enable();
end,
GM_TICKET_UPDATE_TICKET = function(number, ticket)
local frame = _G["GameMasterTicketListItem"..number];
frame.ticketId = ticket.id;
frame.ticketAuthor = ticket.author;
frame.ticketCategoryId = ticket.categoryId;
frame.isTicketUnread = ticket.isUnread;
frame.isTicketUpdated = ticket.isUpdated;
frame.ticketAge = ticket.age;
frame.authorFaction = ticket.authorFaction;
frame.authorGender = ticket.authorGender;
frame.authorGuild = ticket.authorGuild;
frame.authorLevel = ticket.authorLevel;
frame.authorRace = ticket.authorRace;
frame.authorClass = ticket.authorClass;
frame.authorLocation = ticket.authorLocation;
frame.authorClassFileName = ticket.authorClassFileName;

GameMasterTicketListItem_Update(frame);
frame:Show();
end,
GM_TICKET_TICKET_LOAD_SUCCESS = function(result)
local id, data = result.id, result.data;
local author = data.ticketAuthor;
GameMasterTicketTicketFrameTitle:SetText(format(_G.GMTICKETFRAME_TICKET_HEADER, _G.HIGHLIGHT_FONT_COLOR_CODE..author.._G.FONT_COLOR_CODE_CLOSE));
GameMasterTicketTicketScrollChildFrameText:SetText(data.ticketText);
GameMasterTicketTicketScrollChildFrameArticleId:SetFormattedText(_G.GMTICKETFRAME_TICKET_ID, id);
GameMasterTicketTicketFrame.id = id;
GameMasterTicketTicketFrame.author = author;
GameMasterTicketTicketFrame.location = data.ticketLocation;

GameMasterTicketTicketScrollFrameScrollBar:SetValue(0);

GameMasterTicketFrame_ShowTicketFrame();
end,
GM_TICKET_TICKET_LOAD_FAILURE = function()
-- GameMasterTicketErrorFrame_SetErrorMessage(_G.GMTICKETFRAME_ERROR_LOAD_FAILURE);
-- GameMasterTicketFrame_ShowErrorFrame();
end
};

function GameMasterTicketFrame_OnEvent(event, ...)
	events[event](...);
end

function ToggleGameMasterTicketFrame()
	if ( not GameMasterTicketFrame:IsShown() ) then
		ShowUIPanel(GameMasterTicketFrame);
	else
		HideUIPanel(GameMasterTicketFrame);
	end
end

function GameMasterTicketFrame_Search(resetCurrentPage)
	if ( not GMTicketSetup_IsLoaded("GameMasterTicketFrame") ) then
		return;
	end
	
	GameMasterTicketFrame_DisableButtons();
	
	local categoryIndex = (UIDropDownMenu_GetSelectedID(GameMasterTicketFrameCategoryDropDown) or 1) - _G.GMTICKETFRAME_NUM_FAKE_CATEGORIES;
	local subcategoryIndex = (UIDropDownMenu_GetSelectedID(GameMasterTicketFrameSubCategoryDropDown) or 1) - _G.GMTICKETFRAME_NUM_FAKE_SUBCATEGORIES;
	
	local searchText = GameMasterTicketFrameEditBox:GetText();
	if ( searchText == "" ) then
		GameMasterTicketFrameEditBox:SetText(_G.GMTICKETFRAME_DEFAULT_SEARCH_TEXT);
	end
	if ( searchText == _G.GMTICKETFRAME_DEFAULT_SEARCH_TEXT ) then
		searchText = "";
	end
	
	if ( resetCurrentPage == 1 ) then
		_G.GMTICKETFRAME_CURRENT_PAGE = 1;
	end
	
	GMTicketQuery_BeginLoading("GameMasterTicketFrame",
	searchText,
	categoryIndex,
	subcategoryIndex,
	_G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE,
	_G.GMTICKETFRAME_CURRENT_PAGE);
	
	_G.GMTICKETFRAME_SEARCH_PERFORMED = 1;
end

function GameMasterTicketFrame_LoadUnreadPetitions()
	GameMasterTicketFrame_DisableButtons();
	_G.GMTICKETFRAME_SEARCH_PERFORMED = 0;
	_G.GMTICKETFRAME_CURRENT_PAGE = 1;
	_G.GMTICKETFRAME_SETUP_LOADED = 0;
	GMTicketSetup_BeginLoading("GameMasterTicketFrame", _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE, _G.GMTICKETFRAME_CURRENT_PAGE);
end

function GameMasterTicketFrame_DisableButtons()
	_G.GMTICKETFRAME_ENABLE_SEARCH = 0;
	GameMasterTicketFrameUnreadPetitionsButton:Disable();
	GameMasterTicketFrameSearchButton:Disable();
	
	GameMasterTicketFrameUnreadPetitionsButton.enableDelay = _G.GMTICKETFRAME_SEARCH_BUTTON_DELAY;
	GameMasterTicketFrameSearchButton.enableDelay = _G.GMTICKETFRAME_SEARCH_BUTTON_DELAY;
	
	UIDropDownMenu_DisableDropDown(GameMasterTicketFrameCategoryDropDown);
	UIDropDownMenu_DisableDropDown(GameMasterTicketFrameSubCategoryDropDown);
	
	DisablePagingButton(GameMasterTicketListFrameNextButton);
	DisablePagingButton(GameMasterTicketListFramePreviousButton);
end

function GameMasterTicketFrame_EnableButtons(ticketCount, totalTicketCount)
	_G.GMTICKETFRAME_ENABLE_SEARCH = 1;
	
	UIDropDownMenu_EnableDropDown(GameMasterTicketFrameCategoryDropDown);
	UpdateSubCategoryEnabledState();
	
	if ( _G.GMTICKETFRAME_CURRENT_PAGE == 1 ) then
		DisablePagingButton(GameMasterTicketListFramePreviousButton);
	else
		EnablePagingButton(GameMasterTicketListFramePreviousButton);
	end
	
	if ( ticketCount ) then
		if ( ticketCount == _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE and totalTicketCount > _G.GMTICKETFRAME_CURRENT_PAGE * _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE ) then
			EnablePagingButton(GameMasterTicketListFrameNextButton);
		else
			DisablePagingButton(GameMasterTicketListFrameNextButton);
		end
	end
end

function GameMasterTicketFrame_ShowSearchFrame()
	GameMasterTicketListFrame:Show();
	GameMasterTicketTicketFrame:Hide();
	GameMasterTicketErrorFrame:Hide();
end

function GameMasterTicketFrame_ShowTicketFrame()
	GameMasterTicketListFrame:Hide();
	GameMasterTicketTicketFrame:Show();
	GameMasterTicketErrorFrame:Hide();
end

function GameMasterTicketFrame_ShowErrorFrame()
	GameMasterTicketListFrame:Hide();
	GameMasterTicketTicketFrame:Hide();
	GameMasterTicketErrorFrame:Show();
end

local ticketCategories = {};
do
	local categories = {_G.GetGMTicketCategories()};
	for i=1, #categories, 2 do
		ticketCategories[categories[i]] = categories[i + 1];
	end
end

function GameMasterTicketFrameCategoryDropDown_OnLoad()
	UIDropDownMenu_SetWidth(GameMasterTicketFrameCategoryDropDown, 120);
	UIDropDownMenu_SetText(GameMasterTicketFrameCategoryDropDown, _G.CATEGORY);
end

function GameMasterTicketFrameCategoryDropDown_Initialize()
	GameMasterTicketFrameCategoryDropDown_AddInfo(0, _G.ALL);
	for index, value in pairs(ticketCategories) do
		GameMasterTicketFrameCategoryDropDown_AddInfo(index, value);
	end
end

function GameMasterTicketFrameCategoryDropDown_AddInfo(id, caption)
	local info = UIDropDownMenu_CreateInfo();
	info.value = id;
	info.text = caption;
	info.func = GameMasterTicketFrameCategoryButton_OnClick;
	local checked = nil;
	local selectedId = UIDropDownMenu_GetSelectedID(GameMasterTicketFrameCategoryDropDown);
	if (selectedId and selectedId - _G.GMTICKETFRAME_NUM_FAKE_CATEGORIES == id ) then
		checked = 1;
	end
	info.checked = checked;
	UIDropDownMenu_AddButton(info);
end

function GameMasterTicketFrameCategoryButton_OnClick()
	local oldSelectedCategoryId = UIDropDownMenu_GetSelectedID(GameMasterTicketFrameCategoryDropDown);
	local selectedCategoryId = this:GetID();
	
	if ( selectedCategoryId == oldSelectedCategoryId) then
		return;
	end
	
	UIDropDownMenu_SetSelectedID(GameMasterTicketFrameCategoryDropDown, selectedCategoryId);
	
	UIDropDownMenu_SetSelectedID(GameMasterTicketFrameSubCategoryDropDown, 0);
	UIDropDownMenu_ClearAll(GameMasterTicketFrameSubCategoryDropDown);
	UIDropDownMenu_SetText(_G.SUBCATEGORY, GameMasterTicketFrameSubCategoryDropDown);
	
	UpdateSubCategoryEnabledState();
end

function GameMasterTicketFrameSubCategoryDropDown_OnLoad()
	UIDropDownMenu_SetWidth(GameMasterTicketFrameSubCategoryDropDown, 120);
	UIDropDownMenu_SetText(GameMasterTicketFrameSubCategoryDropDown, _G.SUBCATEGORY);
end

function UpdateSubCategoryEnabledState()
	local selectedCategoryId = UIDropDownMenu_GetSelectedID(GameMasterTicketFrameCategoryDropDown);
	if ( not selectedCategoryId or selectedCategoryId == 1 ) then
		UIDropDownMenu_DisableDropDown(GameMasterTicketFrameSubCategoryDropDown);
		return;
	end
	
	local numSubCategories = GMTicketSetup_GetSubCategoryCount(selectedCategoryId - _G.GMTICKETFRAME_NUM_FAKE_CATEGORIES);
	if ( numSubCategories == 0 ) then
		UIDropDownMenu_DisableDropDown(GameMasterTicketFrameSubCategoryDropDown);
	else
		UIDropDownMenu_EnableDropDown(GameMasterTicketFrameSubCategoryDropDown);
	end
end

function GameMasterTicketFrameSubCategoryDropDown_Initialize()
	local selectedCategoryId = UIDropDownMenu_GetSelectedID(GameMasterTicketFrameCategoryDropDown);
	if ( not selectedCategoryId or selectedCategoryId == 1 ) then
		return;
	end
	selectedCategoryId = selectedCategoryId - _G.GMTICKETFRAME_NUM_FAKE_CATEGORIES;
	
	GameMasterTicketFrameSubCategoryDropDown_AddInfo(0, _G.ALL);
	local numCategories = GMTicketSetup_GetSubCategoryCount(selectedCategoryId);
	for i=1, numCategories do
		local categoryId, categoryCaption = GMTicketSetup_GetSubCategoryData(selectedCategoryId, i);
		GameMasterTicketFrameSubCategoryDropDown_AddInfo(i, categoryCaption);
	end
	
	UpdateSubCategoryEnabledState();
end

function GameMasterTicketFrameSubCategoryDropDown_AddInfo(id, caption)
	local info = UIDropDownMenu_CreateInfo();
	info.value = id;
	info.text = caption;
	info.func = GameMasterTicketFrameSubCategoryButton_OnClick;
	local checked = nil;
	local selectedId = UIDropDownMenu_GetSelectedID(GameMasterTicketFrameSubCategoryDropDown);
	if ( selectedId and selectedId - _G.GMTICKETFRAME_NUM_FAKE_SUBCATEGORIES == id ) then
		checked = 1;
	end
	info.checked = checked;
	UIDropDownMenu_AddButton(info);
end

function GameMasterTicketFrameSubCategoryButton_OnClick()
	UIDropDownMenu_SetSelectedID(GameMasterTicketFrameSubCategoryDropDown, this:GetID());
end

local raceIndices = {
["Human"] = 1,
["Dwarf"] = 2,
["Night Elf"] = 4,
["Gnome"] = 3,
["Draenei"] = 5,
["Orc"] = 4,
["Undead"] = 2,
["Tauren"] = 1,
["Troll"] = 3,
["Blood Elf"] = 5,
}
local teamMap = {
["Human"] = 0,
["Dwarf"] = 0,
["Night Elf"] = 0,
["Gnome"] = 0,
["Draenei"] = 0,
["Orc"] = 1,
["Undead"] = 1,
["Tauren"] = 1,
["Troll"] = 1,
["Blood Elf"] = 1,
};

local GetClassButtonTexCoords;
do
	local CLASS_BUTTONS = _G.CLASS_BUTTONS;
	local unpack = _G.unpack;
	GetClassButtonTexCoords = function(class)
	local b = CLASS_BUTTONS[class];
	if ( b ) then
		return unpack(b);
	end
	return nil, nil, nil, nil;
end
end

function GameMasterTicketListFrame_HideTicketList()
	for i=1, _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE do
		_G["GameMasterTicketListItem"..i]:Hide();
	end
end

function GameMasterTicketListFrame_PopulateTicketList(ticketCount, totalTicketCount, data)
	GameMasterTicketListFrame_HideTicketList();
	for i=1, ticketCount do
		local ticket = data[i];
		local frame = _G["GameMasterTicketListItem"..i];
		frame.number = (_G.GMTICKETFRAME_CURRENT_PAGE - 1) * _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE + i;
		frame.ticketId = ticket.id;
		frame.ticketAuthor = ticket.author;
		frame.ticketCategoryId = ticket.categoryId;
		frame.isTicketUnread = ticket.isUnread;
		frame.isTicketUpdated = ticket.isUpdated;
		frame.ticketAge = ticket.age;
		frame.authorFaction = ticket.authorFaction;
		frame.authorGender = ticket.authorGender;
		frame.authorGuild = ticket.authorGuild;
		frame.authorLevel = ticket.authorLevel;
		frame.authorRace = ticket.authorRace;
		frame.authorClass = ticket.authorClass;
		frame.authorLocation = ticket.authorLocation;
		frame.authorClassFileName = ticket.authorClassFileName;
		GameMasterTicketListItem_Update(frame);
		frame:Show();
	end
	
	GameMasterTicketListFrameCount:SetFormattedText(_G.GMTICKETFRAME_TICKET_COUNT,
	(_G.GMTICKETFRAME_CURRENT_PAGE - 1) * _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE + 1,
	min(ticketCount, _G.GMTICKETFRAME_CURRENT_PAGE * _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE) + (_G.GMTICKETFRAME_CURRENT_PAGE - 1) * _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE,
	totalTicketCount);
end

function GameMasterTicketListItem_Update(frame)
	local name = frame:GetName();
	
	_G[name.."Number"]:SetText(frame.number..".");
	if ( frame.isTicketUpdated ) then
		_G[name.."UpdatedIcon"]:Show();
	else
		_G[name.."UpdatedIcon"]:Hide();
	end
	if ( frame.isTicketUnread ) then
		_G[name.."HotIcon"]:Show();
	else
		_G[name.."HotIcon"]:Hide();
	end
	
	_G[name.."Author"]:SetText(frame.ticketAuthor);
	_G[name.."Category"]:SetText(ticketCategories[frame.ticketCategoryId]);
	_G[name.."Age"]:SetText(SecondsToTime(frame.ticketAge));
	
	_G[name.."Level"]:SetText(frame.authorLevel);
	
	local race = frame.authorRace;
	local raceIndex = raceIndices[race];
	local team = teamMap[race];
	if ( raceIndex and team ) then
		local raceIcon = _G[name.."RaceIcon"];
		local x, y = raceIndex * 0.125, frame.authorGender * 0.5 + team * 0.25;
		raceIcon:SetTexCoord(x - 0.125, x, y, y + 0.25);
		raceIcon:Show();
	else
		_G[name.."RaceIcon"]:Hide();
	end
	
	local classText = _G[name.."Class"];
	classText:SetText(frame.authorClass);
	local classFileName = frame.authorClassFileName;
	local classTextColor = _G.RAID_CLASS_COLORS[classFileName] or _G.HIGHLIGHT_FONT_COLOR;
	classText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
	if ( classFileName ) then
		local classIcon = _G[name.."ClassIcon"];
		classIcon:SetTexCoord(GetClassButtonTexCoords(classFileName));
		classIcon:Show();
	else
		_G[name.."ClassIcon"]:Hide();
	end
	
	_G[name.."Location"]:SetText(frame.authorLocation);
end

function GameMasterTicketListFrame_PreviousPage()
	
	if ( _G.GMTICKETFRAME_CURRENT_PAGE == 1 ) then
		return;
	end
	
	_G.GMTICKETFRAME_CURRENT_PAGE = _G.GMTICKETFRAME_CURRENT_PAGE - 1;
	
	GameMasterTicketFrame_DisableButtons();
	
	if ( _G.GMTICKETFRAME_SEARCH_PERFORMED == 1 ) then
		GameMasterTicketFrame_Search(0);
	else
		_G.GMTICKETFRAME_SETUP_LOADED = 0;
		GMTicketSetup_BeginLoading("GameMasterTicketFrame", _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE, _G.GMTICKETFRAME_CURRENT_PAGE);
	end
end

function GameMasterTicketListFrame_NextPage()
	
	_G.GMTICKETFRAME_CURRENT_PAGE = _G.GMTICKETFRAME_CURRENT_PAGE + 1;
	
	GameMasterTicketFrame_DisableButtons();
	
	if ( _G.GMTICKETFRAME_SEARCH_PERFORMED == 1 ) then
		GameMasterTicketFrame_Search(0);
	else
		_G.GMTICKETFRAME_SETUP_LOADED = 0;
		GMTicketSetup_BeginLoading("GameMasterTicketFrame", _G.GMTICKETFRAME_NUM_TICKETS_PER_PAGE, _G.GMTICKETFRAME_CURRENT_PAGE);
	end
end

function GameMasterTicketErrorFrame_SetErrorMessage(message)
	GameMasterTicketErrorFrameText:SetText(message);
end

function GameMasterTicketListItem_OnClick(button)
	if ( button ~= "RightButton" ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		local searchText = GameMasterTicketFrameEditBox:GetText();
		local searchType = 2;
		if (searchText == _G.GMTICKETFRAME_DEFAULT_SEARCH_TEXT or searchText == "") then
			searchType = 1;
		end
		GMTicket_BeginLoading("GameMasterTicketFrame", this.ticketId, searchType);
	else
		GameMasterTicketFrame_ShowDropdown(this.ticketId, this.ticketAuthor);
	end
end

function GameMasterTicketDropDown_Initialize()
	local dropdown = GameMasterTicketDropDown;
	local parent = dropdown.frame;
	
	local info = UIDropDownMenu_CreateInfo();
	if ( parent == GameMasterTicketTicketFrame ) then
		info.text = _G.COPY_TICKET;
		info.value = "COPY_TICKET";
		info.func = GameMasterTicketDropDown_OnClick;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
		
		info = UIDropDownMenu_CreateInfo();
		info.text = _G.REFRESH_TICKET;
	else
		info.text = _G.VIEW_TICKET;
	end
	info.value = "VIEW_TICKET";
	info.func = GameMasterTicketDropDown_OnClick;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
	
	info = UIDropDownMenu_CreateInfo();
	info.text = _G.DELETE_TICKET;
	info.value = "DELETE_TICKET";
	info.func = GameMasterTicketDropDown_OnClick;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
	
	if ( parent == GameMasterSessionStatusButton ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = _G.GMTICKETFRAME_END_SESSION;
		info.value = "END_SESSION";
		info.func = GameMasterTicketDropDown_OnClick;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end
	
	--~ PlaySound("igMainMenuOpen");
	
	UnitPopup_ShowMenu(_G.UIDROPDOWNMENU_OPEN_MENU, "FRIEND", nil, dropdown.name);
end

function GameMasterTicketFrame_ShowDropdown(id, author)
	HideDropDownMenu(1);
	GameMasterTicketDropDown.initialize = GameMasterTicketDropDown_Initialize;
	GameMasterTicketDropDown.displayMode = "MENU";
	GameMasterTicketDropDown.frame = this;
	GameMasterTicketDropDown.ticketId = id;
	GameMasterTicketDropDown.name = author;
	ToggleDropDownMenu(1, nil, GameMasterTicketDropDown, "cursor");
end

function GameMasterTicketDropDown_OnClick()
	local button = this.value;
	if ( button == "COPY_TICKET" ) then
		local ticketFrame, str = GameMasterTicketTicketFrame;
		str = format(_G.GMTICKETFRAME_TICKET_HEADER, ticketFrame.author)
		.."\n"..GameMasterTicketTicketScrollChildFrameText:GetText()
		.."\n"..format(_G.GMTICKETFRAME_TICKET_ID, ticketFrame.id);
		local copyFrame = GameMasterTicketFrameCopyTicket;
		copyFrame.str = str;
		GameMasterTicketFrameCopyTicketText:SetText(str);
		copyFrame:Show();
	elseif ( button == "VIEW_TICKET" ) then
		ShowUIPanel(GameMasterTicketFrame);
		GMTicket_BeginLoading("GameMasterTicketFrame", GameMasterTicketDropDown.ticketId);
	elseif ( button == "DELETE_TICKET" ) then
		GMConsoleExec("delticket", GameMasterTicketDropDown.ticketId);
	elseif ( button == "END_SESSION" ) then
		GameMasterTicketFrameEndSession_OnClick();
	end
	--~ PlaySound("UChatScrollButton");
end

function GameMasterTicketListItem_OnEnter()
	local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR;
	local GameTooltip = _G.GameTooltip;
	do
		local UIParent = _G.UIParent;
		local x, y = GetCursorPosition();
		local effectiveScale = UIParent:GetEffectiveScale();
		GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", x / effectiveScale - UIParent:GetWidth(), y / effectiveScale - 20);
	end
	GameTooltip:SetText(this.ticketAuthor, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	
	if ( this.isTicketUnread ) then
		GameTooltip:AddLine(_G.GMTICKETFRAME_UNREAD_PETITION);
		GameTooltip:AddTexture("Interface\\HelpFrame\\HotIssueIcon");
	end
	
	if ( this.isTicketUpdated ) then
		GameTooltip:AddLine(_G.GMTICKETFRAME_RECENTLY_UPDATED);
		GameTooltip:AddTexture("Interface\\GossipFrame\\AvailableQuestIcon");
	end
	
	do
		local level, race, class = this.authorLevel, this.authorRace, this.authorClass;
		if ( level and race and class ) then
			GameTooltip:AddLine(format(_G.PLAYER_LEVEL, level, race, class), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	end
	do
		local guild = this.authorGuild;
		if ( guild ) then
			GameTooltip:AddLine(guild, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	end
	do
		local location = this.authorLocation;
		if ( location ) then
			GameTooltip:AddLine(location, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	end
	
	GameTooltip:AddDoubleLine(CATEGORY, ticketCategories[this.ticketCategoryId], nil, nil, nil, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(AGE, SecondsToTime(this.ticketAge), nil, nil, nil, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	
	GameTooltip:SetMinimumWidth(220, 1);
	GameTooltip:Show();
end

function GameMasterTicketListItem_OnLeave()
	local GameTooltip = _G.GameTooltip;
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

function GameMasterTicketFrameSearchButton_OnUpdate(elapsed)
	if ( _G.GMTICKETFRAME_ENABLE_SEARCH == 0 ) then
		return;
	end
	
	if ( not this.enableDelay ) then
		return;
	end
	
	this.enableDelay = this.enableDelay - elapsed;
	if ( this.enableDelay > 0 ) then
		return;
	end
	
	this.enableDelay = nil;
	this:Enable();
end

function GameMasterTicketFrameCopyTicket_OnTextChanged()
	local str = this:GetParent():GetParent():GetParent().str;
	if ( this:GetText() ~= str ) then
		this:SetText(str);
	end
	local s = GameMasterTicketFrameCopyTicketScrollFrameScrollBar;
	this:GetParent():UpdateScrollChildRect();
	local _, m = s:GetMinMaxValues();
	if ( m > 0 and this.max ~= m ) then
		this.max = m;
		s:SetValue(m);
	end
end

-- OPEN TICKET
local currentSession = GameMaster.currentSession;
function GameMasterTicketTicketFrameStartSession_OnClick()
	if ( currentSession.id ) then
		return;
	end
	
	local frame = GameMasterTicketTicketFrame;
	currentSession.id = frame.id;
	currentSession.name = frame.author;
	currentSession.message = GameMasterTicketTicketScrollChildFrameText:GetText();
	currentSession.timer = 0;
	currentSession.location = frame.location;
	
	outSAY("gm on");
	outSAY("gm allowwhispers "..currentSession.name.."");
	outSAY("gma has started a session with "..currentSession.name..". ");
	
	UpdateGameMasterSessionStatus();
end

-- DELETE TICKET AND RECORD STATS
function GameMasterTicketFrameEndSession_OnClick()
	
	local playerName = UnitName("player");
	
	outSAY("gma has closed a session with "..currentSession.name..". ");
	outSAY("gm blockwhispers "..currentSession.name.."");
	outSAY("gmticket delid "..currentSession.name.."");
	GameMaster.AddSessionStatistics();
	
	currentSession.id = nil;
	currentSession.name = nil;
	currentSession.timer = nil;
	currentSession.location = nil;
	
	UpdateGameMasterSessionStatus();
	PlaySound("igMainMenuOptionCheckBoxOn");
	GameMasterTicketFrame_LoadUnreadPetitions(); -- cool story bro
end

_G.GMTICKET_SESSIONSTATUS_FRAME_EXPANDED_FRAMES = {
{bar = "GameMasterSessionStatusFrameMessageBar", isExpanded = 0, expandButton = "GameMasterSessionStatusExpandMessageButton"},
{bar = "GameMasterSessionStatusFrameToolsBar", isExpanded = 0, expandButton = "GameMasterSessionStatusExpandToolsButton"},
};

function GameMasterSessionStatusFrame_OnLoad()
	this:RegisterForDrag("LeftButton");
	
	UpdateGameMasterSessionStatusFrameSections();
end

function GameMasterSessionStatusFrame_OnEvent()
	UpdateGameMasterSessionStatusFrameSections();
end

function UpdateGameMasterSessionStatus()
	GameMasterSessionStatusName:SetText(currentSession.name);
	GameMasterSessionStatusFrameMessageScrollChildFrameText:SetText(currentSession.message);
	if ( currentSession.location ) then
		GameMasterSessionStatusFrameTeleportButton:Enable();
	else
		GameMasterSessionStatusFrameTeleportButton:Disable();
	end
	
	if ( currentSession.id ) then
		GameMasterTicketTicketFrameStartSession:Disable();
		GameMasterTicketFrameViewSession:Enable();
		GameMasterTicketFrameEndSession:Enable();
		GameMasterSessionStatusFrame:Show();
	else
		GameMasterTicketTicketFrameStartSession:Enable();
		GameMasterTicketFrameViewSession:Disable();
		GameMasterTicketFrameEndSession:Disable();
		GameMasterSessionStatusFrame:Hide();
	end
end

function GameMasterSessionStatus_OnUpdate(elapsed)
	if ( GameMasterSessionStatusExpandMessageButton:IsShown() ) then
		if ( MouseIsOver(GameMasterSessionStatusFrameExpandTabsHitArea) ) then
			GameMasterSessionStatusFrameExpandTabs:Show();
		else
			GameMasterSessionStatusFrameExpandTabs:Hide();
		end
	end
	if ( currentSession.id ) then
		if ( currentSession.timer ) then
			currentSession.timer = currentSession.timer + elapsed;
			GameMasterSessionStatusTime:SetFormattedText(GMTICKET_SESSIONSTATUSFRAME_TIMER, SecondsToTime(currentSession.timer));
		end
	end
end

function ShowGameMasterSessionStatusFrameSection(frame)
	_G.GMTICKET_SESSIONSTATUS_FRAME_EXPANDED_FRAMES[frame:GetID()].isExpanded = 1;
	UpdateGameMasterSessionStatusFrameSections();
end

function HideGameMasterSessionStatusFrameSection(frame)
	_G.GMTICKET_SESSIONSTATUS_FRAME_EXPANDED_FRAMES[frame:GetID()].isExpanded = 0;
	UpdateGameMasterSessionStatusFrameSections();
end

function UpdateGameMasterSessionStatusFrameSections()
	local height = GameMasterSessionStatusFrameTitleBar:GetHeight();
	local lastShownFrame = GameMasterSessionStatusFrameTitleBar;
	for index, value in ipairs(_G.GMTICKET_SESSIONSTATUS_FRAME_EXPANDED_FRAMES) do
		if ( value.isExpanded == 1 ) then
			local frame = _G[value.bar];
			frame:Show();
			_G[value.expandButton]:Hide();
			height = height + frame:GetHeight();
			frame:SetPoint("TOPLEFT", lastShownFrame, "BOTTOMLEFT", 0, 0);
			lastShownFrame = frame;
		else
			_G[value.bar]:Hide();
			_G[value.expandButton]:Show();
		end
	end
	GameMasterSessionStatusFrame:SetHeight(height);
end

