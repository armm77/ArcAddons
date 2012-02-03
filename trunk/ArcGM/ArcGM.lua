--[[
 ArcGM
 Copyright (C) 2011 Marforius

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

-- SavedVariables
savedannflag = {};
savedannmsg = {};
ArcGMversion = GetAddOnMetadata("ArcGM", "Version");
ArcGMbuild = GetAddOnMetadata("ArcGM", "X-Revision");
BINDING_HEADER_ARCGMHEADER = "ArcGM";

function OpenMain()
 if(ArcGMview == 2) then
 MinipForm:Show();
 elseif(ArcGMview == 3) then
 MiniForm:Show();
 else
 FullForm:Show();
 end
end

function ToggleAddon()
 if addonopen then
 FullForm:Hide();
 MiniForm:Hide();
 MinipForm:Hide();
 AnnounceForm:Hide();
 BanForm:Hide();
 BattlegroundForm:Hide();
 CommForm:Hide();
 IPBanForm:Hide();
 ItemForm:Hide();
 ItemFormSearch:Hide();
 MiscForm:Hide();
 ModifyForm:Hide();
 NPCForm:Hide();
 ObjectForm:Hide();
 OverridesForm:Hide();
 PlayerForm:Hide();
 ProfessionsForm:Hide();
 QuestForm:Hide();
 QuickItemForm:Hide();
 QuickPortalForm:Hide();
 SkillForm:Hide();
 SpellForm:Hide();
 TeleForm:Hide();
 WepskForm:Hide();
 ObjectPlayForm1:Hide();
 TargetForm:Hide();
 QuestLogForm:Hide();
 QuestDetailForm:Hide();
 ContainerSelectorForm:Hide();
 EquipmentForm:Hide();
 BackPackForm:Hide();
 Bag1Form:Hide();
 Bag2Form:Hide();
 Bag3Form:Hide();
 Bag4Form:Hide();
 CurrencyForm:Hide();
 KeyRingForm:Hide();
 BankForm:Hide();
 BankBag1Form:Hide();
 BankBag2Form:Hide();
 BankBag3Form:Hide();
 BankBag4Form:Hide();
 BankBag5Form:Hide();
 BankBag6Form:Hide();
 BankBag7Form:Hide();
 PlaySound("INTERFACESOUND_CHARWINDOWCLOSE");
 addonopen = false;
 else
 OpenMain();
 PlaySound("INTERFACESOUND_CHARWINDOWOPEN");
 addonopen = true;
 end
end

function getridofme()
 FullForm:Hide();
 MiniForm:Hide();
 MinipForm:Hide();
 AnnounceForm:Hide();
 BanForm:Hide();
 BattlegroundForm:Hide();
 CommForm:Hide();
 IPBanForm:Hide();
 ItemForm:Hide();
 ItemFormSearch:Hide();
 MiscForm:Hide();
 ModifyForm:Hide();
 NPCForm:Hide();
 ObjectForm:Hide();
 OverridesForm:Hide();
 PlayerForm:Hide();
 ProfessionsForm:Hide();
 QuestForm:Hide();
 QuickItemForm:Hide();
 QuickPortalForm:Hide();
 SkillForm:Hide();
 SpellForm:Hide();
 TeleForm:Hide();
 WepskForm:Hide();
 ObjectPlayForm1:Hide();
 TargetForm:Hide();
 QuestLogForm:Hide();
 QuestDetailForm:Hide();
 ContainerSelectorForm:Hide();
 EquipmentForm:Hide();
 BackPackForm:Hide();
 Bag1Form:Hide();
 Bag2Form:Hide();
 Bag3Form:Hide();
 Bag4Form:Hide();
 CurrencyForm:Hide();
 KeyRingForm:Hide();
 BankForm:Hide();
 BankBag1Form:Hide();
 BankBag2Form:Hide();
 BankBag3Form:Hide();
 BankBag4Form:Hide();
 BankBag5Form:Hide();
 BankBag6Form:Hide();
 BankBag7Form:Hide();
 PlaySound("INTERFACESOUND_CHARWINDOWCLOSE");
 addonopen = false;
end

function outSAY(text, BoolChat)
local sendto = "GUILD";
ConsoleAddMessage("ARCGM-OUTSAYDEBUGMSG: TEXT:\""..text.."\"");
 if BoolChat then
 SendChatMessage(text, sendto);
 else
 SendChatMessage("."..text, sendto);
 end
end

function ShowMessage(StrMsg, StrHex, BoolFrame)
 if not StrHex then StrHex = "FF0000"; end
 ConsoleAddMessage("ARCGM-SHOWMESSAGE: StrMsg:\""..StrMsg.."\"");
 local StrHex1,StrHex2,StrHex3 = string.match(StrHex, "(..)(..)(..)");
 local IntCol1 = (tonumber(StrHex1, 16) / 255);
 local IntCol2 = (tonumber(StrHex2, 16) / 255);
 local IntCol3 = (tonumber(StrHex3, 16) / 255);
 local color = {r = IntCol1, g = IntCol2, b = IntCol3}
 if(BoolFrame == 1) then
 UIErrorsFrame:AddMessage(StrMsg, IntCol1, IntCol2, IntCol3);
 elseif(BoolFrame == 2) then
 RaidNotice_AddMessage(RaidBossEmoteFrame, StrMsg, color);
 else
 SELECTED_CHAT_FRAME:AddMessage(StrMsg, IntCol1, IntCol2, IntCol3);
 end
end

function ArcGMOnLoad(self)
	self:RegisterForDrag("RightButton");
end

function ArcGM_OnInitialize()
	 ShowMessage("ArcGM "..ArcGMversion.." r"..ArcGMbuild.." loaded!", "00FF00");
	 ShowMessage("For ArcGM slash commands type \"/ArcGM\" many high level commands have been consolidated for macro use.");
	 if select(4, GetBuildInfo()) ~= 30300 then ArcGM_NOTSUPPORTED(); end
 end

local function ArcGM_NOTSUPPORTED()
		 print("Your WoW Client \("..GetBuildInfo().."\) is not supported by ArcGM "..ArcGMversion.." r"..ArcGMbuild.."!")
		 print("You may experience undesired results, please report issues on the ArcAddon forums. You may also look for an update for this version \("..GetBuildInfo().."\) or please state it in the report.")
 end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ArcGM Interface Options

function ArcGM_CancelOrLoad()
 ArcGMGUIFrame_ShowOnLoad:SetChecked(ArcGM_ShowOnLoad);
end

function ArcGM_Close()
 ArcGM_ShowOnLoad = ArcGMGUIFrame_ShowOnLoad:GetChecked();
end

function ArcGM_Defaults()
 ArcGMGUIFrame_ShowOnLoad:SetChecked(false); ArcGM_ShowOnLoad = false;
end

function ArcGMGUI_OnLoad(panel)
 ArcGMGUIFrame_ShowOnLoadText:SetText("Show on Load");
 self:RegisterForDrag("RightButton");
 panel.name = "ArcGM "..ArcGMversion.." r"..ArcGMbuild;
 panel.okay = function (self) ArcGM_Close(); end;
 panel.cancel = function (self) ArcGM_CancelOrLoad(); end;
 panel.default = function (self) ArcGM_Defaults(); end;
 InterfaceOptions_AddCategory(panel);
end

function VIEWGUI_OnLoad(panel)
 VIEWGUIFrame_viewfullText:SetText("Full");
 VIEWGUIFrame_viewminipText:SetText("Mini P");
 VIEWGUIFrame_viewminilText:SetText("Mini L");
 panel.name = "Views"
 panel.okay = function (self) VIEW_Close(); end;
 panel.cancel = function (self) VIEW_CancelOrLoad(); end;
 panel.default = function (self) VIEW_Defaults(); end;
 panel.parent = "ArcGM "..ArcGMversion.." r"..ArcGMbuild;
 InterfaceOptions_AddCategory(panel);
end

function VIEW_CancelOrLoad()
VIEWGUIFrame_viewfull:SetChecked(false);
VIEWGUIFrame_viewminip:SetChecked(false);
VIEWGUIFrame_viewminil:SetChecked(false);
 if(ArcGMview == 2) then
 VIEWGUIFrame_viewminip:SetChecked(true);
 elseif(ArcGMview == 3) then
 VIEWGUIFrame_viewminil:SetChecked(true);
 else
 VIEWGUIFrame_viewfull:SetChecked(true);
 end
end

function VIEW_Close()
if VIEWGUIFrame_viewfull:GetChecked() then ArcGMview=1
elseif VIEWGUIFrame_viewminip:GetChecked() then ArcGMview=2
elseif VIEWGUIFrame_viewminil:GetChecked() then ArcGMview=3 end
end

function VIEW_Defaults()
VIEWGUIFrame_viewfull:SetChecked(true);
VIEWGUIFrame_viewminip:SetChecked(false);
VIEWGUIFrame_viewminil:SetChecked(false);
end
