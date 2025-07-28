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
local Constants = addon.Constants
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
      checks = {}
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

  self.db.global.settings.checks = Data:GetDefaultChecks()
  if #self.db.global.settings.checks == 0 then
    self.db.global.settings.checks = Data:GetDefaultChecks()
  end
end

---@return Octo_Check[]
function Data:GetDefaultChecks()
  return {
    {
      moduleType = Constants.MODULE_TYPE_ADDON,
      enabled = true,
      displayName = "WA Addon",
      exactName = "WeakAuras",
      url = "https://www.curseforge.com/wow/addons/weakauras-2",
    },
    {
      moduleType = Constants.MODULE_TYPE_ADDON,
      enabled = true,
      displayName = "BW Addon",
      exactName = "BigWigs",
      url = "https://www.curseforge.com/wow/addons/big-wigs",
    },
    {
      moduleType = Constants.MODULE_TYPE_ADDON,
      enabled = true,
      displayName = "DBM Addon",
      exactName = "DBM-Core",
      url = "https://www.curseforge.com/wow/addons/deadly-boss-mods",
    },
    {
      moduleType = Constants.MODULE_TYPE_ADDON,
      enabled = true,
      displayName = "NS Addon",
      exactName = "NorthernSkyRaidTools",
      url = "https://www.curseforge.com/wow/addons/northern-sky-raid-tools",
    },
    {
      moduleType = Constants.MODULE_TYPE_ADDON,
      enabled = true,
      displayName = "MRT Addon",
      exactName = "MRT",
      url = "https://www.curseforge.com/wow/addons/method-raid-tools",
    },
    {
      moduleType = Constants.MODULE_TYPE_MRT_NOTE_HASH,
      enabled = true,
      displayName = "MRT Hash",
    },
    {
      moduleType = Constants.MODULE_TYPE_IGNORE_LIST,
      enabled = true,
      displayName = "Ignore List",
    },
    {
      moduleType = Constants.MODULE_TYPE_WEAKAURA,
      enabled = true,
      displayName = "Assignment Pack",
      exactName = "Northern Sky Liberation of Undermine",
      url = "https://wago.io/NSUndermine",
    },
    {
      moduleType = Constants.MODULE_TYPE_WEAKAURA,
      enabled = true,
      displayName = "Raid Pack",
      exactName = "Liberation of Undermine",
      url = "https://wago.io/Undermine",
    },
    {
      moduleType = Constants.MODULE_TYPE_WEAKAURA,
      enabled = true,
      displayName = "NS DB",
      exactName = "Northern Sky Database & Functions",
      url = "https://wago.io/NorthernSky",
    },
    {
      moduleType = Constants.MODULE_TYPE_WEAKAURA,
      enabled = true,
      displayName = "Interrupt",
      exactName = "Interrupt Anchor",
      url = "https://wago.io/InterruptAnchor",
    },
    {
      moduleType = Constants.MODULE_TYPE_WEAKAURA,
      enabled = true,
      displayName = "Verifier Client",
      exactName = "Octopals Verifier Client",
      url = "https://wago.io/exrYkN05u",
    }
  }
end

function Data:GetTrackedWeakAuras()
  return Utils:TableFilter(self.db.global.settings.weakAurasToTrack, function(weakAura)
    return weakAura.auraName ~= "" and weakAura.displayName ~= ""
  end)
end

---@return Octo_RaidMember
function Data:GetReferenceValues()
  return self.raidMembers[UnitGUID("player")]
end

---Populate table with all characters currently in the group/raid.
function Data:InitializeRaidMembers()
  self.raidMembers = {}

  for unit in Utils:IterateGroupMembers() do
    local raidMember = Utils:TableCopy(Data.defaultRaidMember)
    raidMember.name = GetUnitName(unit, true)
    raidMember.GUID = UnitGUID(unit)
    raidMember.classID = select(3, UnitClass(unit))

    if raidMember.GUID ~= UnitGUID("player") then
      table.insert(self.raidMembers, raidMember)
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

    return a.receivedAt < b.receivedAt
  end)

  return raidMembers
end

