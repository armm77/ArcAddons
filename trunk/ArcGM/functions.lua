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

-- CommScript
function AnnounceChecked()
 if AnnounceCheck:GetChecked() or ScreenCheck:GetChecked() or GMAnnounceCheck:GetChecked() then
 Announce();
 else
 ShowMessage("Please choose where to Announce!");
 end
end

function Announce()
 local ArrCheck = { AnnounceCheck:GetChecked(), ScreenCheck:GetChecked(), GMAnnounceCheck:GetChecked() };
 local ArrChan = { "announce ", "wannounce ", "gmannounce " };
 for a = 1, 3 do
 if(ArrCheck[a]) then
 outSAY(ArrChan[a]..AnnounceText:GetText());
 end
 end
end

function SaveAnnSend(a)
 local b = savedannflag[a];
 if savedannmsg[a] then
 if(b >= 4) then outSAY("gmannounce "..savedannmsg[a]); b = b - 4; end
 if(b >= 2) then outSAY("wannounce "..savedannmsg[a]); b = b - 2; end
 if(b >= 1) then outSAY("wannounce "..savedannmsg[a]); b = b - 1; end
 else
 ShowMessage("wannouncement not set! Please set it in the AnnounceForm.");
 end
end

function ShowSavedAnn(a)
 if savedannmsg[a] then
 ShowMessage("Saved Announcement #"..a..": "..savedannmsg[a], "FFFFFF");
 else
 ShowMessage("wannouncement not set! Please set it in the AnnounceForm.");
 end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- AnnounceScript
function SetAnnouncementChecked()
 if AnnounceCheck:GetChecked() or ScreenCheck:GetChecked() or GMAnnounceCheck:GetChecked() then
 Announce();
 else
 ShowMessage("Please choose where to Announce!")
 end
end

function SaveAnnStore(a)
 local b = 0;
 if(AnnounceSetCheck:GetChecked()) then b = b + 1; end
 if(ScreenAnnounceSetCheck:GetChecked()) then b = b + 2; end
 if(GMAnnounceSetCheck:GetChecked()) then b = b + 4; end
 if(b > 0) then
 savedannmsg[a] = SetAnnounceText:GetText();
 savedannflag[a] = (b);
 ShowMessage("wannouncement #"..a.." Saved!", "00FF00");
 else
 ShowMessage("Please choose where to Announce!");
 end
end

function GoDownButtonCheck()
local a = SavAnnTxtShow:GetNumber();
 if (a >= 2) then
 SavAnnTxtShow:SetNumber(a - 1);
 end
end

function PreviewAnnTxt()
local a = SavAnnTxtShow:GetNumber();
if savedannmsg[a] then
ArcGM_ShowMessage(savedannmsg[a])
else
ShowMessage("wannouncement #"..a.." has not been set yet!")
end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ItemScript

function AddMoney()
 local IntGold = Gold:GetNumber() * 10000;
 local IntSilver = Silver:GetNumber() * 100;
 local IntCopper = Copper:GetNumber();
 if IntCopper == nil then IntCopper = 0; end
 if IntSilver == nil then IntSilver = 0; end
 if IntGold == nil then IntGold = 0; end
 if IntGold and IntSilver and IntCopper == 0 then ShowMessage("Please set a gold value to modify."); end
 outSAY("modify gold " ..(IntGold + IntSilver + IntCopper));
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ModifyScript

function Modify()
local selection = UIDropDownMenu_GetText(ModifyComboBox)
 if selection == "Armor" then
 modify = "armor";
 elseif selection == "HP" then
 modify = "hp";
 elseif selection == "Runic" then
 modify = "runic";
 elseif selection == "Rage" then
 modify = "rage";
 elseif selection == "Mana" then
 modify = "mana";
 elseif selection == "Energy" then
 modify = "energy";
 elseif selection == "Damage" then
 modify = "damage";
 elseif selection == "Spirit" then
 modify = "spirit";
 elseif selection == "Speed" then
 modify = "speed";
 elseif selection == "Scale" then
 modify = "scale";
 elseif selection == "Faction" then
 modify = "faction";
 elseif selection == "Display" then
 modify = "displayid";
 elseif selection == "Talents" then
 modify = "talentpoints";
 elseif selection == "Holy Resist" then
 modify = "holy";
 elseif selection == "Fire Resist" then
 modify = "fire";
 elseif selection == "Nature Resist" then
 modify = "nature";
 elseif selection == "Frost Resist" then
 modify = "frost";
 elseif selection == "Shadow Resist" then
 modify = "shadow";
 elseif selection == "Arcane Resist" then
 modify = "arcane";
 elseif selection == "NPCEmote" then
 modify = "npcemote";
 end
 outSAY("modify "..modify.." "..ModifyEditBox:GetText());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ObjectScript
function PlaceObjectTrue()
 if NoSaveCheck:GetChecked() then a = "" else a = "1" end
 outSAY("go spawn "..ObjectNumber:GetText().." "..a);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OverridesScript
function CheatUpdate()
 if(FlyCheck:GetChecked()) then a = "on"; else a = "off"; end--fly
 outSAY("cheat fly "..a);
 if(GodCheck:GetChecked()) then a = "on"; else a = "off"; end--god
 outSAY("cheat god "..a);
 if(NCDCheck:GetChecked()) then a = "on"; else a = "off"; end--cooldown
 outSAY("cheat cooldown "..a);
 if(NCTCheck:GetChecked()) then a = "on"; else a = "off"; end--casttime
 outSAY("cheat casttime "..a);
 if(PowCheck:GetChecked()) then a = "on"; else a = "off"; end--power
 outSAY("cheat power "..a);
 if(AuraCheck:GetChecked()) then a = "on"; else a = "off"; end--stack
 outSAY("cheat stack "..a);
 if(TrigCheck:GetChecked()) then a = "on"; else a = "off"; end--triggers
 outSAY("cheat triggerpass "..a);
end

function FlySpeed()
if FlyEntry:GetText() == "" then
Fly_Speed = 7.5;
elseif(FlyEntry:GetNumber() < 2) then
Fly_Speed = FlyEntry:GetNumber();
else
Fly_Speed = FlyEntry:GetNumber() / 2; --Divide it before it's sent to get the actual desired speed. .mod speed doubles your input for flying.
end
outSAY("mod speed "..Fly_Speed);
end

function FlightPath()
 if(TaxiCheck:GetChecked()) then a = "on"; else a = "off"; end --Taxi
 outSAY("cheat taxi "..a);
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ProfessionsForm

function LearnProfession()
local selection = UIDropDownMenu_GetText(ProfComboBox)
 if selection == "Alchemy" then
 profession = 171;
 elseif selection == "BSing" then
 profession = 164;
 elseif selection == "Enchanting" then
 profession = 333;
 elseif selection == "Engineering" then
 profession = 202;
 elseif selection == "Herbalism" then
 profession = 182;
 elseif selection == "Tailoring" then
 profession = 197;
 elseif selection == "Fishing" then
 profession = 356;
 elseif selection == "Poisons" then
 profession = 40;
 elseif selection == "Jewelcraft" then
 profession = 755;
 elseif selection == "LWing" then
 profession = 165;
 elseif selection == "Mining" then
 profession = 186;
 elseif selection == "Inscription" then
 profession = 773;
 elseif selection == "Skinning" then
 profession = 393;
 elseif selection == "Cooking" then
 profession = 185;
 elseif selection == "First Aid" then
 profession = 129;
 end
 outSAY("character advancesk "..profession);
 outSAY("character advancesk "..profession.." "..SkillLevel:GetText());
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--QuestScript

function QuestSpawn()
if StartCheckButton:GetChecked() and FinishCheckButton:GetChecked() then
 ShowMessage("Please select Start or Finish! Not Both!", "FF0000", 1);
elseif FinishCheckButton:GetChecked() then
 outSAY("quest finishspawn "..QuestFormBox:GetText());
elseif StartCheckButton:GetChecked() then
 outSAY("quest startspawn "..QuestFormBox:GetText());
else
 ShowMessage("Please select Start or Finish!", "FF0000", 1);
end
end

function QuestAdd()
if StartCheckButton:GetChecked() and FinishCheckButton:GetChecked() then
 outSAY("quest addboth "..QuestFormBox:GetText());
elseif FinishCheckButton:GetChecked() then
 outSAY("quest addfinish "..QuestFormBox:GetText());
elseif StartCheckButton:GetChecked() then
 outSAY("quest addstart "..QuestFormBox:GetText());
else
 ShowMessage("Please select Start, Finish, or Both!", "FF0000", 1);
end
end

function QuestDel()
if StartCheckButton:GetChecked() and FinishCheckButton:GetChecked() then
 outSAY("quest delboth "..QuestFormBox:GetText());
elseif FinishCheckButton:GetChecked() then
 outSAY("quest delfinish "..QuestFormBox:GetText());
elseif StartCheckButton:GetChecked() then
 outSAY("quest delstart "..QuestFormBox:GetText());
else
 ShowMessage("Please select Start, Finish, or Both!", "FF0000", 1);
end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--QuickItemScript
function GmOutfit()
 outSAY("character additem 2586");--Gamemaster's Robe
 outSAY("character additem 11508");--Gamemaster's Slippers
 outSAY("character additem 12064");--Gamemaster's Hood
 outSAY("character additem 18154");-- Blizzard Stationary (for mail)
end

function Potions()
 outSAY("character additem 41166 20");--Runic Healing Injector X20
 outSAY("character additem 42545 20");--Runic Mana Injector X20
end
--ALLIANCE ITEMSETS

function MageAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 47758");--Khadgar's Shoulderpads of Triumph
 outSAY("character additem 47759");--Khadgar's Robe of Triumph
 outSAY("character additem 47760");--Khadgar's Leggings of Triumph
 outSAY("character additem 47761");--Khadgar's Hood of Triumph
 outSAY("character additem 47762");--Khadgar's Gauntlets of Triumph
end

function HunterAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48260");--Windrunner's Spaulders of Triumph
 outSAY("character additem 48261");--Windrunner's Legguards of Triumph
 outSAY("character additem 48262");--Windrunner's Headpiece of Triumph
 outSAY("character additem 48263");--Windrunner's Handguards of Triumph
 outSAY("character additem 48264");--Windrunner's Tunic of Triumph
end

function RogueAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48228");--VanCleef's Pauldrons of Triumph
 outSAY("character additem 48229");--VanCleef's Legplates of Triumph
 outSAY("character additem 48230");--VanCleef's Helmet of Triumph
 outSAY("character additem 48231");--VanCleef's Gauntlets of Triumph
 outSAY("character additem 48232");--VanCleef's Breastplate of Triumph
end

function WarlockAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 47788");--Kel'Thuzad's Gloves of Triumph
 outSAY("character additem 47789");--Kel'Thuzad's Hood of Triumph
 outSAY("character additem 47790");--Kel'Thuzad's Leggings of Triumph
 outSAY("character additem 47791");--Kel'Thuzad's Robe of Triumph
 outSAY("character additem 47792");--Kel'Thuzad's Shoulderpads of Triumph
end

function WarriorAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48381");--Wrynn's Shoulderplates of Triumph
 outSAY("character additem 48382");--Wrynn's Legplates of Triumph
 outSAY("character additem 48383");--Wrynn's Helmet of Triumph
 outSAY("character additem 48384");--Wrynn's Gauntlets of Triumph
 outSAY("character additem 48385");--Wrynn's Battleplate of Triumph
end

function ShamanAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48351");--Nobundo's Shoulderguards of Triumph
 outSAY("character additem 48352");--Nobundo's War-Kilt of Triumph
 outSAY("character additem 48353");--Nobundo's Faceguard of Triumph
 outSAY("character additem 48354");--Nobundo's Grips of Triumph
 outSAY("character additem 48355");--Nobundo's Chestguard of Triumph
end

function PriestAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48029");--Velen's Shoulderpads of Triumph
 outSAY("character additem 48031");--Velen's Robe of Triumph
 outSAY("character additem 48033");--Velen's Leggings of Triumph
 outSAY("character additem 48035");--Velen's Cowl of Triumph
 outSAY("character additem 48037");--Velen's Gloves of Triumph
end

function DruidAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48203");--Malfurion's Handgrips of Triumph
 outSAY("character additem 48204");--Malfurion's Headguard of Triumph
 outSAY("character additem 48205");--Malfurion's Legguards of Triumph
 outSAY("character additem 48206");--Malfurion's Raiments of Triumph
 outSAY("character additem 48207");--Malfurion's Shoulderpads of Triumph
end

function PaladinAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48612");--Turalyon's Shoulderplates of Triumph
 outSAY("character additem 48613");--Turalyon's Legplates of Triumph
 outSAY("character additem 48614");--Turalyon's Helm of Triumph
 outSAY("character additem 48615");--Turalyon's Gauntlets of Triumph
 outSAY("character additem 48616");--Turalyon's Battleplate of Triumph
end

function DeathKnightAT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48491");--Koltira's Battleplate of Triumph
 outSAY("character additem 48492");--Koltira's Gauntlets of Triumph
 outSAY("character additem 48493");--Koltira's Helmet of Triumph
 outSAY("character additem 48494");--Koltira's Legplates of Triumph
 outSAY("character additem 48495");--Koltira's Shoulderplates of Triumph
end

function MageAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51280");--Sanctified Bloodmage Gloves
 outSAY("character additem 51281");--Sanctified Bloodmage Hood
 outSAY("character additem 51282");--Sanctified Bloodmage Leggings
 outSAY("character additem 51283");--Sanctified Bloodmage Robe
 outSAY("character additem 51284");--Sanctified Bloodmage Shoulderpads
end

function HunterAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51285");--Sanctified Ahn'Kahar Blood Hunter's Handguards
 outSAY("character additem 51286");--Sanctified Ahn'Kahar Blood Hunter's Headpiece
 outSAY("character additem 51287");--Sanctified Ahn'Kahar Blood Hunter's Legguards
 outSAY("character additem 51288");--Sanctified Ahn'Kahar Blood Hunter's Spaulders
 outSAY("character additem 51289");--Sanctified Ahn'Kahar Blood Hunter's Tunic
end

function RogueAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51250");--Sanctified Shadowblade Breastplate
 outSAY("character additem 51251");--Sanctified Shadowblade Gauntlets
 outSAY("character additem 51252");--Sanctified Shadowblade Helmet
 outSAY("character additem 51253");--Sanctified Shadowblade Legplates
 outSAY("character additem 51254");--Sanctified Shadowblade Pauldrons
end

function WarlockAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51230");--Sanctified Dark Coven Gloves
 outSAY("character additem 51231");--Sanctified Dark Coven Hood
 outSAY("character additem 51232");--Sanctified Dark Coven Leggings
 outSAY("character additem 51233");--Sanctified Dark Coven Robe
 outSAY("character additem 51234");--Sanctified Dark Coven Shoulderpads
end

function WarriorAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51225");--Sanctified Ymirjar Lord's Battleplate
 outSAY("character additem 51226");--Sanctified Ymirjar Lord's Gauntlets
 outSAY("character additem 51227");--Sanctified Ymirjar Lord's Helmet
 outSAY("character additem 51228");--Sanctified Ymirjar Lord's Legplates
 outSAY("character additem 51229");--Sanctified Ymirjar Lord's Shoulderplates
end

function ShamanAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51240");--Sanctified Frost Witch's Shoulderguards
 outSAY("character additem 51241");--Sanctified Frost Witch's War-Kilt
 outSAY("character additem 51242");--Sanctified Frost Witch's Faceguard
 outSAY("character additem 51243");--Sanctified Frost Witch's Grips
 outSAY("character additem 51244");--Sanctified Frost Witch's Chestguard
end

function PriestAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51260");--Sanctified Crimson Acolyte Gloves
 outSAY("character additem 51261");--Sanctified Crimson Acolyte Hood
 outSAY("character additem 51262");--Sanctified Crimson Acolyte Leggings
 outSAY("character additem 51263");--Sanctified Crimson Acolyte Robe
 outSAY("character additem 51264");--Sanctified Crimson Acolyte Shoulderpads
end

function DruidAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51295");--Sanctified Lasherweave Handgrips
 outSAY("character additem 51296");--Sanctified Lasherweave Headguard
 outSAY("character additem 51297");--Sanctified Lasherweave Legguards
 outSAY("character additem 51298");--Sanctified Lasherweave Raiment
 outSAY("character additem 51299");--Sanctified Lasherweave Shoulderpads
end

function PaladinAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51275");--Sanctified Lightsworn Battleplate
 outSAY("character additem 51276");--Sanctified Lightsworn Gauntlets
 outSAY("character additem 51277");--Sanctified Lightsworn Helmet
 outSAY("character additem 51278");--Sanctified Lightsworn Legplates
 outSAY("character additem 51279");--Sanctified Lightsworn Shoulderplates
end

function DeathKnightAT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51310");--Sanctified Scourgelord Battleplate
 outSAY("character additem 51311");--Sanctified Scourgelord Gauntlets
 outSAY("character additem 51312");--Sanctified Scourgelord Helmet
 outSAY("character additem 51313");--Sanctified Scourgelord Legplates
 outSAY("character additem 51314");--Sanctified Scourgelord Shoulderplates
end

--HORDE ITEMSETS

function MageHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 47758");--Khadgar's Shoulderpads of Triumph
 outSAY("character additem 47759");--Khadgar's Robe of Triumph
 outSAY("character additem 47760");--Khadgar's Leggings of Triumph
 outSAY("character additem 47761");--Khadgar's Hood of Triumph
 outSAY("character additem 47762");--Khadgar's Gauntlets of Triumph
end

function HunterHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48265");--Windrunner's Tunic of Triumph
 outSAY("character additem 48266");--Windrunner's Handguards of Triumph
 outSAY("character additem 48267");--Windrunner's Headpiece of Triumph
 outSAY("character additem 48268");--Windrunner's Legguards of Triumph
 outSAY("character additem 48269");--Windrunner's Spaulders of Triumph
end

function RogueHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48233");--Garona's Breastplate of Triumph
 outSAY("character additem 48234");--Garona's Gauntlets of Triumph
 outSAY("character additem 48235");--Garona's Helmet of Triumph
 outSAY("character additem 48236");--Garona's Legplates of Triumph
 outSAY("character additem 48237");--Garona's Pauldrons of Triumph
end

function WarlockHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 47793");--Gul'dan's Shoulderpads of Triumph
 outSAY("character additem 47794");--Gul'dan's Robe of Triumph
 outSAY("character additem 47795");--Gul'dan's Leggings of Triumph
 outSAY("character additem 47796");--Gul'dan's Hood of Triumph
 outSAY("character additem 47797");--Gul'dan's Gloves of Triumph
end

function WarriorHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48396");--Hellscream's Battleplate of Triumph
 outSAY("character additem 48397");--Hellscream's Gauntlets of Triumph
 outSAY("character additem 48398");--Hellscream's Helmet of Triumph
 outSAY("character additem 48399");--Hellscream's Legplates of Triumph
 outSAY("character additem 48400");--Hellscream's Shoulderplates of Triumph
end

function ShamanHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48356");--Thrall's Chestguard of Triumph
 outSAY("character additem 48357");--Thrall's Grips of Triumph
 outSAY("character additem 48358");--Thrall's Faceguard of Triumph
 outSAY("character additem 48359");--Thrall's War-Kilt of Triumph
 outSAY("character additem 48360");--Thrall's Shoulderguards of Triumph
end

function PriestHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48057");--Zabra's Gloves of Triumph
 outSAY("character additem 48058");--Zabra's Cowl of Triumph
 outSAY("character additem 48059");--Zabra's Leggings of Triumph
 outSAY("character additem 48060");--Zabra's Robe of Triumph
 outSAY("character additem 48061");--Zabra's Shoulderpads of Triumph
end

function DruidHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48198");--Runetotem's Shoulderpads of Triumph
 outSAY("character additem 48199");--Runetotem's Raiments of Triumph
 outSAY("character additem 48200");--Runetotem's Legguards of Triumph
 outSAY("character additem 48201");--Runetotem's Headguard of Triumph
 outSAY("character additem 48202");--Runetotem's Handgrips of Triumph
end

function PaladinHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48617");--Liadrin's Battleplate of Triumph
 outSAY("character additem 48618");--Liadrin's Gauntlets of Triumph
 outSAY("character additem 48619");--Liadrin's Helm of Triumph
 outSAY("character additem 48620");--Liadrin's Legplates of Triumph
 outSAY("character additem 48621");--Liadrin's Shoulderplates of Triumph
end

function DeathKnightHT9()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 48491");--Koltira's Battleplate of Triumph
 outSAY("character additem 48492");--Koltira's Gauntlets of Triumph
 outSAY("character additem 48493");--Koltira's Helmet of Triumph
 outSAY("character additem 48494");--Koltira's Legplates of Triumph
 outSAY("character additem 48495");--Koltira's Shoulderplates of Triumph
end

function MageHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51280");--Sanctified Bloodmage Gloves
 outSAY("character additem 51281");--Sanctified Bloodmage Hood
 outSAY("character additem 51282");--Sanctified Bloodmage Leggings
 outSAY("character additem 51283");--Sanctified Bloodmage Robe
 outSAY("character additem 51284");--Sanctified Bloodmage Shoulderpads
end

function HunterHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51285");--Sanctified Ahn'Kahar Blood Hunter's Handguards
 outSAY("character additem 51286");--Sanctified Ahn'Kahar Blood Hunter's Headpiece
 outSAY("character additem 51287");--Sanctified Ahn'Kahar Blood Hunter's Legguards
 outSAY("character additem 51288");--Sanctified Ahn'Kahar Blood Hunter's Spaulders
 outSAY("character additem 51289");--Sanctified Ahn'Kahar Blood Hunter's Tunic
end

function RogueHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51250");--Sanctified Shadowblade Breastplate
 outSAY("character additem 51251");--Sanctified Shadowblade Gauntlets
 outSAY("character additem 51252");--Sanctified Shadowblade Helmet
 outSAY("character additem 51253");--Sanctified Shadowblade Legplates
 outSAY("character additem 51254");--Sanctified Shadowblade Pauldrons
end

function WarlockHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51230");--Sanctified Dark Coven Gloves
 outSAY("character additem 51231");--Sanctified Dark Coven Hood
 outSAY("character additem 51232");--Sanctified Dark Coven Leggings
 outSAY("character additem 51233");--Sanctified Dark Coven Robe
 outSAY("character additem 51234");--Sanctified Dark Coven Shoulderpads
end

function WarriorHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51225");--Sanctified Ymirjar Lord's Battleplate
 outSAY("character additem 51226");--Sanctified Ymirjar Lord's Gauntlets
 outSAY("character additem 51227");--Sanctified Ymirjar Lord's Helmet
 outSAY("character additem 51228");--Sanctified Ymirjar Lord's Legplates
 outSAY("character additem 51229");--Sanctified Ymirjar Lord's Shoulderplates
end

function ShamanHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51240");--Sanctified Frost Witch's Shoulderguards
 outSAY("character additem 51241");--Sanctified Frost Witch's War-Kilt
 outSAY("character additem 51242");--Sanctified Frost Witch's Faceguard
 outSAY("character additem 51243");--Sanctified Frost Witch's Grips
 outSAY("character additem 51244");--Sanctified Frost Witch's Chestguard
end

function PriestHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51260");--Sanctified Crimson Acolyte Gloves
 outSAY("character additem 51261");--Sanctified Crimson Acolyte Hood
 outSAY("character additem 51262");--Sanctified Crimson Acolyte Leggings
 outSAY("character additem 51263");--Sanctified Crimson Acolyte Robe
 outSAY("character additem 51264");--Sanctified Crimson Acolyte Shoulderpads
end

function DruidHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51295");--Sanctified Lasherweave Handgrips
 outSAY("character additem 51296");--Sanctified Lasherweave Headguard
 outSAY("character additem 51297");--Sanctified Lasherweave Legguards
 outSAY("character additem 51298");--Sanctified Lasherweave Raiment
 outSAY("character additem 51299");--Sanctified Lasherweave Shoulderpads
end

function PaladinHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51275");--Sanctified Lightsworn Battleplate
 outSAY("character additem 51276");--Sanctified Lightsworn Gauntlets
 outSAY("character additem 51277");--Sanctified Lightsworn Helmet
 outSAY("character additem 51278");--Sanctified Lightsworn Legplates
 outSAY("character additem 51279");--Sanctified Lightsworn Shoulderplates
end

function DeathKnightHT10()
 outSAY("modify level 80");--Levels Up To 80
 outSAY("character additem 51310");--Sanctified Scourgelord Battleplate
 outSAY("character additem 51311");--Sanctified Scourgelord Gauntlets
 outSAY("character additem 51312");--Sanctified Scourgelord Helmet
 outSAY("character additem 51313");--Sanctified Scourgelord Legplates
 outSAY("character additem 51314");--Sanctified Scourgelord Shoulderplates
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SkillScript

function LearnRiding()
 outSAY("character learn 33388");--Apprentice Riding
 outSAY("character learn 33391");--Journeyman Riding
 outSAY("character learn 34090");--Expert Riding
 outSAY("character learn 34091");--Artisan Riding
 outSAY("character learn 54197");--Cold Weather Flying
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- WepskScript

function LearnWepsk()
local selection = UIDropDownMenu_GetText(WepskComboBox)
 if selection == "Swords" then
 wepsk = 43;
 elseif selection == "Unarmed" then
 wepsk = 136;
 elseif selection == "Thrown" then
 wepsk = 176;
 elseif selection == "Daggers" then
 wepsk = 173;
 elseif selection == "Maces" then
 wepsk = 54;
 elseif selection == "Dual Wield" then
 wepsk = 118;
 elseif selection == "Crossbow" then
 wepsk = 226;
 elseif selection == "Staves" then
 wepsk = 136;
 elseif selection == "Axes" then
 wepsk = 44;
 elseif selection == "Wand" then
 wepsk = 228;
 elseif selection == "Guns" then
 wepsk = 46;
 elseif selection == "Bows" then
 wepsk = 45;
 elseif selection == "Fist" then
 wepsk = 473;
 elseif selection == "Polearm" then
 wepsk = 229;
 elseif selection == "2H Axe" then
 wepsk = 172;
 elseif selection == "2H Mace" then
 wepsk = 160;
 elseif selection == "2H Swords" then
 wepsk = 55;
 end
 outSAY("character advancesk "..wepsk.." "..WeaponSkillLvl:GetText());
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ArcGM_Main(msg)
msg = string.lower(msg)
if msg == "show" or msg == "hide" then
 ToggleAddon()
else
 ArcGM_MainMsg("ArcGM Version "..ArcGMversion.." r"..ArcGMbuild);
 ArcGM_MainMsg("/ArcGM - displays this menu");
 ArcGM_MainMsg("/ArcGM (show or hide) - Shows or Hides ArcGM");
 ArcGM_MainMsg("/gm (on or off) - Toggles GM");
 ArcGM_MainMsg("/revive - revives yourself");
 ArcGM_MainMsg("/recallport or /recall or /port - Ports yourself to location");
 ArcGM_MainMsg("/npcspawn - spawns NPC - e.g. /npcspawn 1");
 ArcGM_MainMsg("/npcdelete - deleted targeted NPC");
 ArcGM_MainMsg("/additem - adds item to you or target - e.g. /additem 1");
 ArcGM_MainMsg("/announce or /an - broadcasts message to server in chatbox");
 ArcGM_MainMsg("/wannounce or /wan - broadcasts message to server on the screen");
 ArcGM_MainMsg("/gmannounce or /gman - broadcasts message to other GMs in chatbox");
 ArcGM_MainMsg("/savedannounce or /sa - broadcasts saved message");
 ArcGM_MainMsg("/showsavedannounce, /showsaved, or /ssa - Shows you Saved Announcement");
 ArcGM_MainMsg("/advanceall or /advanceallskills - Advances all of your or your target's skills by X.");
 ArcGM_MainMsg("/revive - revives yourself");
 ArcGM_MainMsg("/reviveplr - revives plr x");
 ArcGM_MainMsg("/learn - learns spells to you or targeted player - e.g. /learn all - Learns all spells for your class");
 ArcGM_MainMsg("/unlearn - unlearns spell id on you or targeted player - e.g. /unlearn 1");
 ArcGM_MainMsg("/achievecomplete - Completes achievement on targeted player - e.g. /achievecomplete 1");
 ArcGM_MainMsg("/lookup - Looks up term under specified subject - e.g. /lookup item Gamemaster");
 ArcGM_MainMsg("/kickplayer - Kicks specified player with or without reason. - e.g. /kickplayer Name Reason");
end
end

function ArcGM_MainMsg(msg)
 ShowMessage(msg, "00FF00");
end

function ArcGM_GMToggle(msg)
msg = string.lower(msg)
 if msg == "on" or msg == "off" then
 outSAY("gm "..msg);
 else
 ShowMessage("Available options: on or off");
 end
end

function ArcGM_NPCSpawn(msg)
 outSAY("npc spawn "..msg);
end

function ArcGM_AddItem(msg)
 outSAY("character additem "..msg);
end

function ArcGM_Announce(msg)
 outSAY("wannounce "..msg);
end

function ArcGM_WAnnounce(msg)
 outSAY("wannounce "..msg);
end

function ArcGM_GMAnnounce(msg)
 outSAY("gmannounce "..msg);
end

function ArcGM_RecallPort(msg)
 outSAY("recall port "..msg);
end

function ArcGM_SavedAnnounce(msg)
 SaveAnnSend(tonumber(msg));
end

function ArcGM_ShowSavedAnn(msg)
 ShowSavedAnn(tonumber(msg));
end

function ArcGM_Learn(msg)
 outSAY("char learn "..msg);
end

function ArcGM_UnLearn(msg)
 outSAY("char unlearn "..msg);
end

function ArcGM_Revive(msg)
 outSAY("revive");
end

function ArcGM_RevivePlr(msg)
 outSAY("reviveplr "..msg);
end

function ArcGM_AdvanceAllSkills(msg)
 outSAY("char advanceallskills "..msg);
end

function ArcGM_AchievementComplete(msg)
 outSAY("achieve complete "..msg);
end

function ArcGM_Lookup(msg)
args = {strsplit(" ",msg)};
if args[2] then
outSAY("lookup "..args[1].." "..args[2]);
else
ShowMessage("Please enter a search term.");
end
end

function ArcGM_Kick(msg)
args = {strsplit(" ",msg)};
if args[2] then a2 = string.sub(msg,string.len(args[1])+2) else a2 = "" end
outSAY("kickplayer "..args[1].." "..a2);
end

--Plays sound files named in the DBC
function ArcGM_TableReload(msg)
 outSAY("server reloadtable "..msg);
end

function ArcGM_ShowMessage(msg)
ShowMessage(msg, "FFFFFF")
end

if select(4, GetBuildInfo()) == 30300 then
 SLASH_ArcGMRELOAD1 = "/reload"
 SlashCmdList["ArcGMRELOAD"] =
 function()
 ReloadUI()
 end
end

-- Command list
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SlashCmdList["ArcGM"] = ArcGM_Main;
SLASH_ArcGM1="/ArcGM";
SlashCmdList["ArcGMGMTOGGLE"] = ArcGM_GMToggle;
SLASH_ArcGMGMTOGGLE1="/gm";
SlashCmdList["REVIVE"] = ArcGM_Revive;
SLASH_REVIVE1="/revive";
SlashCmdList["ArcGMSPAWN"] = ArcGM_NPCSpawn;
SLASH_ArcGMSPAWN1="/npcspawn";
SlashCmdList["ArcGMDELETE"] = ArcGM_NPCDelete;
SLASH_ArcGMDELETE1="/npcdelete";
SlashCmdList["ArcGMADDITEM"] = ArcGM_AddItem;
SLASH_ArcGMADDITEM1="/additem";
SlashCmdList["ArcGMANNOUNCE"] = ArcGM_Announce;
SLASH_ArcGMANNOUNCE1="/announce";
SLASH_ArcGMANNOUNCE2="/an";
SlashCmdList["ArcGMGMANNOUNCE"] = ArcGM_GMAnnounce;
SLASH_ArcGMGMANNOUNCE1="/gmannounce";
SLASH_ArcGMGMANNOUNCE2="/gman";
SlashCmdList["ArcGMRECALLPORT"] = ArcGM_RecallPort;
SLASH_ArcGMRECALLPORT1="/recallport";
SLASH_ArcGMRECALLPORT2="/recall";
SLASH_ArcGMRECALLPORT3="/port";
SlashCmdList["ArcGMSAVEDANNOUNCE"] = ArcGM_SavedAnnounce;
SLASH_ArcGMSAVEDANNOUNCE1="/savedannounce";
SLASH_ArcGMSAVEDANNOUNCE2="/sa";
SlashCmdList["ArcGMSHOWSAVEDANNOUNCE"] = ArcGM_ShowSavedAnn;
SLASH_ArcGMSHOWSAVEDANNOUNCE1="/showsavedannounce";
SLASH_ArcGMSHOWSAVEDANNOUNCE2="/showsaved";
SLASH_ArcGMSHOWSAVEDANNOUNCE3="/ssa";
SlashCmdList["ArcGMLEARN"] = ArcGM_Learn;
SLASH_ArcGMLEARN1="/learn";
SlashCmdList["ArcGMUNLEARN"] = ArcGM_UnLearn;
SLASH_ArcGMUNLEARN1="/unlearn";
SlashCmdList["ArcGMREVIVE"] = ArcGM_Revive;
SLASH_ArcGMREVIVE1="/revive";
SlashCmdList["ArcGMREVIVEPLR"] = ArcGM_RevivePlr;
SLASH_ArcGMREVIVEPLR1="/reviveplr";
SlashCmdList["ArcGMADVANCEALL"] = ArcGM_AdvanceAllSkills;
SLASH_ArcGMADVANCEALL1="/advanceall";
SLASH_ArcGMADVANCEALL2="/advanceallskills";
SlashCmdList["ArcGMACHIEVECOMPLETE"] = ArcGM_AchievementComplete;
SLASH_ArcGMACHIEVECOMPLETE1="/achievecomplete";
SlashCmdList["ArcGMLOOKUP"] = ArcGM_Lookup;
SLASH_ArcGMLOOKUP1="/lookup";
SlashCmdList["ArcGMKICK"] = ArcGM_Kick;
SLASH_ArcGMKICK1="/kickplayer";
SlashCmdList["ArcGMSOUND"] = PlaySound;
SLASH_ArcGMSOUND1="/ps";
SlashCmdList["ArcGMTR"] = ArcGM_TableReload;
SLASH_ArcGMTR1="/tr";
SLASH_ArcGMTR2="/table";
SlashCmdList["ArcGMSHOWMESSAGE"] = ArcGM_ShowMessage;
SLASH_ArcGMSHOWMESSAGE1="/showmessage";

---------------------------------------------
-- End of Advance Command --
---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ItemSearchScript

-- Below vars are used throughout the item search
item_search_results = {}
itemName = {}
itemSearched = false

i = 1;

-- Fired when a server message is sent to the client
function Chat_OnEvent(event, text)
 if string.find(text, "Item") and ItemFormSearch:IsShown() and not itemSearched then
 if (i < 26) then
 -- If the detected string is an item result
 idlength, _, _, _ = string.find(text, ":");
 item_search_results[i] = string.sub(text, 6, idlength-1);
 itemName[i] = text;
 ProcessItemSearch(item_search_results[i]);
 i = i + 1;
 end
 elseif string.find(text, "Search completed in ") then
 itemSearched = true
 elseif string.find(text, "Starting search of item ") then -- Reset if its a new search
 for i=1, 25 do
 getglobal("ItemFormSearchTexture"..i):Hide();
 getglobal("ItemFormSearchLabelItemID"..i):Hide();
 getglobal("ItemFormSearchButton"..i):Hide();
 itemSearched = false
 end
 i = 1;
 end
end

function GetItemInfoTexture(name)
_, _, _, _, _, _, _, _, _, texture = GetItemInfo(name);
return texture
end

-- Function to update each button when a result is recieved by the client
function ProcessItemSearch(itemid)
 getglobal("ItemFormSearchTexture"..i):Show();
 getglobal("ItemFormSearchLabelItemID"..i):Show();
 getglobal("ItemFormSearchButton"..i):Show();
 -- Update "number of results" text
 text = "Results Found: "..i;
 ItemFormSearchLabel2Label:SetText(text);
 getglobal("ItemFormSearchLabelItemID"..i.."Label"):SetText(itemName[i]);
 if(GetItemInfoTexture("item:"..itemid)) then
 getglobal("ItemFormSearchTexture"..i.."Texture"):SetTexture(GetItemInfoTexture("item:"..itemid));
 elseif(GetItemIcon("item:"..itemid)) then
 getglobal("ItemFormSearchTexture"..i.."Texture"):SetTexture(GetItemIcon("item:"..itemid));
 else
 getglobal("ItemFormSearchTexture"..i.."Texture"):SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
 end
end

-- When a button is rolled over, show tooltip and update vars based on user cache
function ResultButton_OnEnter(button_number, self)
 GameTooltip:ClearLines();
 GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 24)
 GameTooltip:SetHyperlink("item:"..item_search_results[button_number]..":0:0:0:0:0:0:0");
 GameTooltip:AddLine("Click to add to inventory");
 GameTooltip:Show();
end

function ResultButton_OnClick(button_number)
outSAY("character additem "..item_search_results[button_number]);
end
---------------------------------------------
-- End of Item search  --
---------------------------------------------

-----------------------------------------------------------------------------------------------------

--QuestLogScript

local idTable = {};
local titleTable = {};

function GetTarget()
 player, playerrealm = UnitName("player");
 target, targetrealm = UnitName("target");

if (UnitIsPlayer("target")) then
 if (target == player) then
  TargetFormTargetLabel:SetTextColor(1.0, 0, 0);
  TargetFormTargetLabel:SetText("Showing quest for Yourself");
 else
  TargetFormTargetLabel:SetTextColor(0, 1.0, 0);
  TargetFormTargetLabel:SetText("Showing quest for "..target.."");
end
end
end

function ChatQuestLog_OnEvent(event, text)

 if string.find(text, "Hquest") then
  local _, _, color, linkType, questId, questLvl, questTitle, questSlot
  = string.find(text, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r? Quest slot? (%d*)")

  if (UnitIsPlayer("target")) then
   BuildQuestTable(questSlot, questId, questTitle);
  end
 end

end

function BuildQuestTable(questSlot, questId, questTitle)

  idTable[tonumber(questSlot)] = tonumber(questId);
 titleTable[tonumber(questSlot)] = questTitle;

end

function GetEntry(fieldname)
 nameStart, nameEnd = string.find(fieldname, "Entry");
 formslot = tonumber(string.sub(fieldname, nameEnd+1, -1));
 getglobal(fieldname.."Label"):Hide();
 for i,v in pairs(titleTable) do
  if ( i == formslot) then
   getglobal(fieldname.."Label"):SetTextColor(.9, .8, .2);
   getglobal(fieldname.."Label"):SetText(v);
   getglobal(fieldname.."Label"):Show();
  end
 end
end

function ShowQuestList()
  TargetForm:Hide();
  QuestLogForm:Show();
end

function OpenQuestDetailForm(logSlot)
 nameStart, nameEnd = string.find(logSlot, "Button");
 questSlot = tonumber(string.sub(logSlot, nameEnd+1, -1));

 for i,v in pairs(idTable) do
  if ( i == questSlot) then

   QuestDetailFormQuestTitleLabel:Hide();
   for i,v in pairs(titleTable) do
    if ( i == questSlot) then
    QuestDetailFormQuestTitleLabel:SetTextColor(.9, .8, .2);
    QuestDetailFormQuestTitleLabel:SetText(v);
    QuestDetailFormQuestTitleLabel:Show();
    end
   end
   QuestDetailFormQuestIdLabel:Hide();
   for i,v in pairs(idTable) do
    if ( i == questSlot) then
     QuestDetailFormQuestIdLabel:SetTextColor(.9, .8, .2);
     QuestDetailFormQuestIdLabel:SetText(v);
     QuestDetailFormQuestIdLabel:Show();
    end
   end
   QuestDetailForm:Show();
   QuestLogForm:Hide();
  end
 end

end

function QuestRequirements(questid,reqtype)
 outSAY("quest assist "..questid.." " ..reqtype);
end

function QuestTooltip(button, self)
 buttonStart, buttonEnd = string.find(button, "Button");
 buttonItem = tonumber(string.sub(button, buttonEnd+1, -1));

 for i,v in pairs(idTable) do
  if ( i == buttonItem) then
   GameTooltip:ClearLines();
   GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 24)
   GameTooltip:AddLine("Click title for quest options....", .7, .3, .5);
   GameTooltip:Show();
  end
 end
end

function ClearQuestTables()
 wipe(titleTable);
 wipe(idTable);
end

-----------------------------------------------
--   End Quest Log     --
-----------------------------------------------
