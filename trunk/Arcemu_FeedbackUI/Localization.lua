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

function FeedbackUI_Localize()
	if GetLocale() == "esES" or GetLocale() == "frFR" or GetLocale() == "deDE" then
		FeedbackUI:SetWidth(450);
		FeedbackUIWelcomeFrameSurveysBtn:SetWidth(175);
		FeedbackUIWelcomeFrameSuggestionsBtn:SetWidth(175);
		FeedbackUIWelcomeFrameBugsBtn:SetWidth(175);
		if ( GetLocale() == "deDE" ) then
			FeedbackUISurveyFrameReset:SetWidth(110);
			FeedbackUISurveyFrameBack:SetWidth(110);
			FeedbackUISuggestFrameBack:SetWidth(110);
			FeedbackUISuggestFrameReset:SetWidth(110);
			FeedbackUIBugFrameBack:SetWidth(110);
			FeedbackUIBugFrameReset:SetWidth(110);
			FeedbackUISurveyFrameSkip:SetWidth(80);
		end
	end
end

function FeedbackUI_GetLocalizedCharString (level, race, gender, class)
	if ( GetLocale() == "deDE" ) then
		return FEEDBACKUI_LEVELPREFIX .. " " .. level .. " " .. race .. " " .. class .. " " .. gender;
	else
		return FEEDBACKUI_LEVELPREFIX .. " " .. level .. " " .. race .. " " .. gender .. " " .. class;
	end
end

function FeedbackUI_SetupTargets()
	
	g_FeedbackUI_surveysTable = ( g_FeedbackUI_surveysTable or {} );
	g_FeedbackUI_surveysTable["Targets"] = {};
	
	
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_UTGARDEKEEP .. "1"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_UTGARDEPINNACLE .. "1"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_NEXUS .. "1"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_DRAKTHARONKEEP .. "1"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_ULDUAR .. "1"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_HOL .. "1"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_KAJA] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_TAC .. "1"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_TAC .. "2"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_TAC .. "3"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_TAC .. "4"] = true;
	g_FeedbackUI_surveysTable["Targets"][FEEDBACKUI_IOC .. "3"] = true;
	
end

function QuestAlert_SerializeCSVFileToLua(filename)
	assert(filename, "Syntax: CombatScanner_SerializeCSVFileToLua(filename)");
	
	local newData = "";
	local data = ReadFile(filename);
	if ( not data ) then return; end
	
	for id in gmatch(data, "(%d+)") do
		newData = newData .. "g_FeedbackUI_surveysTable[\"Targets\"][\"" .. id .. "\"] = true;\r\n";
	end
	
	DeleteFile("Interface\\AddOns\\Arcemu_FeedbackUI\\output.txt") 
	AppendToFile("Interface\\AddOns\\Arcemu_FeedbackUI\\output.txt", newData);
end

