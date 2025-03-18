---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class Octo_Comms
local Comms = {}
addon.Comms = Comms

local Data = addon.Data
local Utils = addon.Utils

---@param sender string
---@param text string
function Comms.processV1Message(sender, text)
  if not UnitExists(sender) then
    return
  end

  local senderGUID = UnitGUID(sender)
  if senderGUID == nil then
    return
  end

  -- WA ver, BigWigs ver, mrt ver, mrt hash, WAs...
  local fields = Utils:ExplodeString(text, "\r\n")
  Data.raidMembers[senderGUID] = {
    name = sender,
    GUID = senderGUID,
    classID = select(3, UnitClass(sender)),
    waVersion = fields[1],
    bwVersion = fields[2],
    dbmVersion = nil,
    mrtVersion = fields[3],
    mrtNoteHash = fields[4],
    ignoreList = nil,
    weakauras = Utils:TableFilter(fields, function(field, index) 
      return index >= 5
    end),
    receivedAt = GetServerTime()
  }
end

---@param sender string
---@param text string
function Comms.processV2Message(sender, text)
  local fields = Utils:ExplodeString(text, "\r\n")
  local version = fields[1]
  if version == '1' then
    Comms.processV2d1Message(sender, text)
  else
    Comms.processV2d2Message(sender, text)
  end
end

---@param sender string
---@param text string
function Comms.processV2d1Message(sender, text)
  if not UnitExists(sender) then
    return
  end

  local senderGUID = UnitGUID(sender)
  if senderGUID == nil then
    return
  end

  -- client version, WA addon ver, bigwigs ver, mrt ver, mrt note hash, ignore list, WAs...
  local fields = Utils:ExplodeString(text, "\r\n")
  Data.raidMembers[senderGUID] = {
    name = sender,
    GUID = senderGUID,
    classID = select(3, UnitClass(sender)),
    waVersion = fields[2],
    bwVersion = fields[3],
    dbmVersion = nil,
    mrtVersion = fields[4],
    mrtNoteHash = fields[5],
    ignoreList = fields[6] == ":)" and {} or Utils:ExplodeString(fields[6], ", "),
    weakauras = Utils:TableFilter(fields, function(field, index) 
      return index >= 7
    end),
    receivedAt = GetServerTime()
  }
end

---@param sender string
---@param text string
function Comms.processV2d2Message(sender, text)
  if not UnitExists(sender) then
    return
  end

  local senderGUID = UnitGUID(sender)
  if senderGUID == nil then
    return
  end

  -- client version, WA addon ver, bigwigs ver, dbm ver, mrt ver, mrt note hash, ignore list, WAs...
  local fields = Utils:ExplodeString(text, "\r\n")
  Data.raidMembers[senderGUID] = {
    name = sender,
    GUID = senderGUID,
    classID = select(3, UnitClass(sender)),
    waVersion = fields[2],
    bwVersion = fields[3],
    dbmVersion = fields[4],
    mrtVersion = fields[5],
    mrtNoteHash = fields[6],
    ignoreList = fields[7] == ":)" and {} or Utils:ExplodeString(fields[7], ", "),
    weakauras = Utils:TableFilter(fields, function(field, index) 
      return index >= 8
    end),
    receivedAt = GetServerTime()
  }
end

---@param sender string
---@param text string
function Comms.processV3Message(sender, text)
  if not UnitExists(sender) then
    return
  end

  local senderGUID = UnitGUID(sender)
  if senderGUID == nil then
    return
  end

  Data.raidMembers[senderGUID] = {
    name = sender,
    GUID = senderGUID,
    classID = select(3, UnitClass(sender)),
    waVersion = "v3",
    bwVersion = "TODO",
    dbmVersion = "TODO",
    mrtVersion = "TODO",
    mrtNoteHash = "TODO",
    ignoreList = {},
    weakauras = {},
    receivedAt = GetServerTime()
  }
end
