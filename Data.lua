---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Data
local Data = {}
addon.Data = Data

local Utils = addon.Utils
local Checks = addon.Checks
local AceDB = LibStub("AceDB-3.0")

---@type WK_DataCache
Data.cache = {
  isDarkmoonOpen = false,
  inCombat = false,
  items = {},
  mapInfo = {},
  weeklyProgress = {},
}

Data.DBVersion = 8
Data.defaultDB = {
  ---@type WK_DefaultGlobal
  global = {
    minimap = {
      minimapPos = 235,
      hide = false,
      lock = false
    },
    characters = {},
    raidMembers = {},
    main = {
      hiddenColumns = {},
      windowScale = 100,
      windowBackgroundColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1},
      windowBorder = true,
      checklistHelpTipClosed = false,
    },
  }
}

---@type Octo_WeakAura[]
Data.WeakAurasToTrack = {
  {
    displayName = "Assignment Pack",
    wagoUrl = "https://wago.io/NSNerubarPalace",
    auraName = "Northern Sky Nerub-ar Palace",
    allowNested = false,
  },
  {
    displayName = "NS DB",
    wagoUrl = "https://wago.io/NorthernSky",
    auraName = "Northern Sky Database & Functions",
    allowNested = false,
  },
  {
    displayName = "Interrupt",
    wagoUrl = "https://wago.io/InterruptAnchor",
    auraName = "Interrupt Anchor",
    allowNested = false,
  },
  {
    displayName = "Auditor",
    wagoUrl = "https://wago.io/exrYkN05u",
    auraName = "Octopals Verifier Client",
    allowNested = false,
  },
}

---@type Octo_RaidMember
Data.defaultRaidMember = {
  name = "",
  GUID = "",
  classID = 0,
  waVersion = nil,
  bwVersion = nil,
  dbmVersion = nil,
  mrtVersion = nil,
  mrtNoteHash = nil,
  ignoreList = nil,
  weakauras = nil,
  receivedAt = 0,
}

function Data:InitDB()
  ---@class AceDBObject-3.0
  ---@field global WK_DefaultGlobal
  self.db = AceDB:New(
    "OctopalsVerifierDB",
    self.defaultDB,
    true
  )
end

---@return Octo_RaidMember
function Data:InitializeReferenceValues()
  return {
    name = GetUnitName("player", true),
    GUID = UnitGUID("player"),
    classID = select(3, UnitClass("player")),
    waVersion = Checks:WeakAurasVersion(),
    bwVersion = Checks:BigWigsVersion(),
    dbmVersion = Checks:DBMVersion(),
    mrtVersion = Checks:MRTVersion(),
    mrtNoteHash = Checks:HashedMRTNote(),
    ignoreList = Checks:IgnoredRaiders(),
    weakauras = Utils:TableMap(self.WeakAurasToTrack, function(auraToTrack)
      return Checks:WeakAuraVersionByName(auraToTrack.auraName)
    end),
    receivedAt = GetServerTime()
  }
end

---@return Octo_RaidMember
function Data:GetReferenceValues()
  return self.db.global.raidMembers[UnitGUID("player")]
end

---Populate table with all characters currently in the group/raid.
function Data:InitializeRaidMembers()
  self.db.global.raidMembers[UnitGUID("player")] = self:InitializeReferenceValues()

  for unit in Utils:IterateGroupMembers() do
    local raidMember = Utils:TableCopy(self.defaultRaidMember)
    raidMember.name = GetUnitName(unit, true)
    raidMember.GUID = UnitGUID(unit)
    raidMember.classID = select(3, UnitClass(unit))

    if raidMember.GUID ~= UnitGUID("player") then
      self.db.global.raidMembers[raidMember.GUID] = raidMember
    end
  end
end

-- Everyone in the raid that has sent a query response
function Data:GetLiveRaidMembers()
  local raidMembers = Utils:TableFilter(self.db.global.raidMembers, function(raidMember)
    -- return raidMember.receivedAt > 0
    return true
  end)

  -- most recently recieved comes first, but 0 comes last.
  table.sort(raidMembers, function(a, b)
    if a.receivedAt == 0 then
      return false
    end
    if b.receivedAt == 0 then
      return true
    end
    return a.receivedAt > b.receivedAt
  end)

  return raidMembers
end
