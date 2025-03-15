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
      weakAurasToTrack = {
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
        },
      }
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
end

function Data:GetTrackedWeakAuras()
  return Utils:TableFilter(self.db.global.settings.weakAurasToTrack, function(weakAura)
    return weakAura.auraName ~= "" and weakAura.displayName ~= ""
  end)
end
