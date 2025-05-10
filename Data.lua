---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Data
local Data = {
    ---@type Octo_RaidMember[]
    raidMembers = {}
}
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

Data.DBVersion = 1
Data.defaultDB = {
  ---@type WK_DefaultGlobal
  global = {
    minimap = {
      minimapPos = 235,
      hide = false,
      lock = false
    },
    main = {
      hiddenColumns = {},
      windowScale = 100,
      windowBackgroundColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1},
      windowBorder = true
    },
    settings = {
      open = false,
      weakAurasToTrack = {}
    }
  }
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

  if #self.db.global.settings.weakAurasToTrack == 0 then
    self.db.global.settings.weakAurasToTrack = Data:GetDefaultWeakAuras()
  end
end

--@type Octo_WeakAura[]
function Data:GetDefaultWeakAuras()
  return {
    {
      displayName = "Assignment Pack",
      wagoUrl = "https://wago.io/NSUndermine",
      auraName = "Northern Sky Liberation of Undermine",
      allowNested = false,
    },
    {
      displayName = "Raid Pack",
      wagoUrl = "https://wago.io/Undermine",
      auraName = "Liberation of Undermine",
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
      displayName = "Verifier Client",
      wagoUrl = "https://wago.io/exrYkN05u",
      auraName = "Octopals Verifier Client",
      allowNested = false,
    }
  }
end

function Data:GetTrackedWeakAuras()
  return Utils:TableFilter(self.db.global.settings.weakAurasToTrack, function(weakAura)
    return weakAura.auraName ~= "" and weakAura.displayName ~= ""
  end)
end

function Data:InitializeReferenceValue()
  Data.raidMembers[UnitGUID("player")] = {
    name = GetUnitName("player", true),
    GUID = UnitGUID("player") or "",
    classID = select(3, UnitClass("player")),
    waVersion = Checks:WeakAurasVersion(),
    bwVersion = Checks:BigWigsVersion(),
    dbmVersion = Checks:DBMVersion(),
    mrtVersion = Checks:MRTVersion(),
    mrtNoteHash = Checks:HashedMRTNote(),
    ignoreList = Checks:IgnoredRaiders(),
    weakauras = Utils:TableMap(Data:GetTrackedWeakAuras(), function(auraToTrack)
      return Checks:WeakAuraVersionByName(auraToTrack.auraName)
    end),
    receivedAt = GetServerTime()
  }
end

---@return Octo_RaidMember
function Data:GetReferenceValues()
  return self.raidMembers[UnitGUID("player")]
end

---Populate table with all characters currently in the group/raid.
function Data:InitializeRaidMembers()
  self.raidMembers = {}
  self:InitializeReferenceValue()

  for unit in Utils:IterateGroupMembers() do
    local raidMember = Utils:TableCopy(Data.defaultRaidMember)
    raidMember.name = GetUnitName(unit, true)
    raidMember.GUID = UnitGUID(unit)
    raidMember.classID = select(3, UnitClass(unit))

    if raidMember.GUID ~= UnitGUID("player") then
      Data.raidMembers[raidMember.GUID] = raidMember
    end
  end
end

-- Everyone in the raid that has sent a query response
function Data:GetLiveRaidMembers()
  local raidMembers = Utils:TableFilter(self.raidMembers, function(raidMember)
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

    if a.receivedAt == b.receivedAt then
      return a.GUID == UnitGUID('player')
    end
    return a.receivedAt < b.receivedAt
  end)

  return raidMembers
end

