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
  local senderGUID = UnitGUID(sender)
  if senderGUID == nil then
    return
  end

  Data.db.global.raidMembers[senderGUID] = {
    name = sender,
    GUID = senderGUID,
    classID = select(3, UnitClass(sender)),
    waVersion = "v1",
    bwVersion = "TODO",
    dbmVersion = "TODO",
    mrtVersion = "TODO",
    mrtNoteHash = "TODO",
    ignoreList = {},
    weakauras = {}
  }
end

---@param sender string
---@param text string
function Comms.processV2Message(sender, text)
  local senderGUID = UnitGUID(sender)
  if senderGUID == nil then
    return
  end

  Data.db.global.raidMembers[senderGUID] = {
    name = sender,
    GUID = senderGUID,
    classID = select(3, UnitClass(sender)),
    waVersion = "v2",
    bwVersion = "TODO",
    dbmVersion = "TODO",
    mrtVersion = "TODO",
    mrtNoteHash = "TODO",
    ignoreList = {},
    weakauras = {}
  }
end

---@param sender string
---@param text string
function Comms.processV3Message(sender, text)
  local senderGUID = UnitGUID(sender)
  if senderGUID == nil then
    return
  end

  Data.db.global.raidMembers[senderGUID] = {
    name = sender,
    GUID = senderGUID,
    classID = select(3, UnitClass(sender)),
    waVersion = "v3",
    bwVersion = "TODO",
    dbmVersion = "TODO",
    mrtVersion = "TODO",
    mrtNoteHash = "TODO",
    ignoreList = {},
    weakauras = {}
  }
end
