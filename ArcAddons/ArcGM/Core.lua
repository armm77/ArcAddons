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

ObjectPlay = LibStub("AceAddon-3.0"):NewAddon("ObjectPlay", "AceConsole-3.0", "AceEvent-3.0")

BINDING_HEADER_MYHEADER = "Object Play Ground: Mover";
BINDING_NAME_BIND1 = "Left";
BINDING_NAME_BIND2 = "Right";
BINDING_NAME_BIND3 = "Front"
BINDING_NAME_BIND4 = "Back"
BINDING_NAME_BIND5 = "Up"
BINDING_NAME_BIND6 = "Down"
BINDING_NAME_BIND7 = "Spawn Toggle"
BINDING_NAME_BIND8 = "Get Object ID"
BINDING_NAME_BIND9 = "Single Spawn"
BINDING_NAME_BIND10 = "Single Spawn W/O Port"
BINDING_NAME_BIND11 = "Custom Move"

local options = {
 name = "ObjectPlay",
 handler = ObjectPlay,
 type = "group",
 args = {
  mover = {
   type = "execute",
   func = "ShowWin1",
   name = "Tool to rapidly spawn Game Objects"
  },
 },
}

function ObjectPlay:OnInitialize()
 LibStub("AceConfig-3.0"):RegisterOptionsTable("ObjectPlay", options, {"objectplay", "op"})
end

function ObjectPlay:OnEnable()
 self:RegisterEvent("CHAT_MSG_SYSTEM")
 ObjectIDTxT:Insert("180035")
 ObjectMTxt:Insert("6157")
 ObjectWTxt:Insert("0.5")
 ObjectHTxt:Insert("0.5")
 ObjectLTxt:Insert("12")
 SaveSpawn:SetChecked(true)
 XDirTxt:Insert("0")
 YDirTxt:Insert("0")
 ZDirTxt:Insert("0")
end

function ObjectPlay:OnDisable()
 -- Called when the addon is disabled
end

-- STart of code for Object Mover

local GPS = '.gps'
local cWorking = 0
local cMap = 0
local cX = 0
local cY = 0
local cZ = 0
local incX = 0
local incY = 0
local incZ = 0
local fID = 0

function ObjectPlay:ShowWin1()
 ObjectPlayForm1:Show()
end

function ObjectPlay:ShowWin2()
 ObjectPlayForm3:Show()
end

function ObjectPlay:CHAT_MSG_SYSTEM()
 if string.find(arg1,"Current Position") ~= nil then
  if cWorking == 1 then
   WorkString = string.gsub(arg1, '(|.........)', '') -- This removes any color formating
   cMap = string.gsub(string.match(WorkString,'%s%d*%s')," ","")
   t = {}
   cnt = 1
   for w in string.gmatch(WorkString,'%s.%d*%p%d%d') do
    t[cnt] = string.gsub(w," ","")
    cnt = cnt + 1
   end
   cX = t[1]
   cY = t[2]
   cZ = t[3]
   cO = t[4]
   --Calulate the new x y bassed on incX
   nX = cX + (math.cos(cO) * incX)
   nY = cY + (math.sin(cO) * incX)
   --rotate the O so we can do some math
   tD = math.deg(cO) + 90
   if tD > 360 then tD = tD - 360 end
   nO = math.rad(tD)
   --Calulate the new x y bassed on incX
   nX = nX + (math.cos(nO) * incY)
   nY = nY + (math.sin(nO) * incY)
   --Send the port
   SendChatMessage('.worldport '..cMap..' '..nX..' '..nY..' '..(cZ+incZ)..' '..cO)
   --console reloadui
   incX = 0
   incY = 0
   incZ = 0
   isChecked = CheckSpawn:GetChecked()
   if isChecked == 1 then
    isChecked2 = SaveSpawn:GetChecked()
    ObjectN = ObjectIDTxT:GetText()
    if isChecked2 == 1 then
     SendChatMessage('.go spawn '..ObjectN..' 1')
    else
     SendChatMessage('.go spawn '..ObjectN)
    end
   end
   cWorking = 0
  end
 end
 if string.find(arg1,"Selected GameObject") ~= nil then
  if fID == 1 then
   SendChatMessage('.go info')
   fID = 2
  end
 end
 if string.find(arg1,"Entry:") ~= nil then
  if fID == 2 then
   WorkString = string.gsub(arg1, '(|.........)', '')
   WorkString = string.gsub(WorkString, 'Entry:', '')
   ObjectIDTxT:SetText(WorkString)
   fID = 3
  end
 end
 if string.find(arg1,"Model:") ~= nil then
  if fID == 3 then
   WorkString = string.gsub(arg1, '(|.........)', '')
   WorkString = string.gsub(WorkString, 'Model:', '')
   ObjectMTxt:SetText(WorkString)
   fID = 0
  end
 end
 if string.find(arg1,"Model:") ~= nil then
  WorkString = string.gsub(arg1, '(|.........)', '')
  WorkString = string.match(WorkString, '%d*%d')
  --ObjectPlay:LoadModel(WorkString)
 end
 if string.find(arg1,"No inrange GameObject") ~= nil then
  if fID == 1 then
   fID = 0
  end
 end
end

function ObjectPlay:CheckToggle()
 isChecked = CheckSpawn:GetChecked()
 if isChecked == 1 then
  CheckSpawn:SetChecked(false)
 else
  CheckSpawn:SetChecked(true)
 end
end

function ObjectPlay:GetOID()
 if fID == 0 then
  fID = 1
  SendChatMessage('.go select')
 end
end

function ObjectPlay:DMUP()
 if cWorking == 0 then
  cWorking = 1
  incZ = ObjectHTxt:GetText()
  SendChatMessage(GPS)
 end
end

function ObjectPlay:DMDown()
 if cWorking == 0 then
  cWorking = 1
  incZ = 0 - ObjectHTxt:GetText()
  SendChatMessage(GPS)
 end
end

function ObjectPlay:DMLeft()
 if cWorking == 0 then
  cWorking = 1
  incY = ObjectWTxt:GetText()
  SendChatMessage(GPS)
 end
end

function ObjectPlay:DMRight()
 if cWorking == 0 then
  cWorking = 1
  incY = 0 - ObjectWTxt:GetText()
  SendChatMessage(GPS)
 end
end

function ObjectPlay:DMSS()
 if cWorking == 0 then
  cWorking = 1
  SendChatMessage(GPS)
 end
end

function ObjectPlay:DMSS2()
 isChecked = SaveSpawn:GetChecked()
 ObjectN = ObjectIDTxT:GetText()
 if isChecked == 1 then
  SendChatMessage('.go spawn '..ObjectN..' 1')
 else
  SendChatMessage('.go spawn '..ObjectN)
 end
end

function ObjectPlay:DMFront()
 if cWorking == 0 then
  cWorking = 1
  incX = ObjectLTxt:GetText()
  SendChatMessage(GPS)
 end
end

function ObjectPlay:DMBack()
 if cWorking == 0 then
  cWorking = 1
  incX = 0 - ObjectLTxt:GetText()
  SendChatMessage(GPS)
 end
end

function ObjectPlay:CustomMove()
 if cWorking == 0 then
  if XDirTxt:GetText() == '-' then
   incX = 0 - ObjectLTxt:GetText()
  elseif XDirTxt:GetText() == '+' then
   incX = ObjectLTxt:GetText()
  else
   incX = 0
  end
  if YDirTxt:GetText() == '-' then
   incY = 0 - ObjectWTxt:GetText()
  elseif YDirTxt:GetText() == '+' then
   incY = ObjectWTxt:GetText()
  else
   incY = 0
  end
  if ZDirTxt:GetText() == '-' then
   incZ = 0 - ObjectHTxt:GetText()
  elseif ZDirTxt:GetText() == '+' then
   incZ = ObjectHTxt:GetText()
  else
   incZ = 0
  end
  cWorking = 1
  SendChatMessage(GPS)
 end
end


