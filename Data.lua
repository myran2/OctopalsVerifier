---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Data
local Data = {}
addon.Data = Data

local Utils = addon.Utils
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

---@type WK_Character
Data.defaultCharacter = {
  enabled = true,
  lastUpdate = 0,
  GUID = "",
  name = "",
  realmName = "",
  level = 0,
  factionEnglish = "",
  factionName = "",
  raceID = 0,
  raceEnglish = "",
  raceName = "",
  classID = 0,
  classFile = nil,
  className = "",
  professions = {},
  completed = {},
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

function Data:InitDB()
  ---@class AceDBObject-3.0
  ---@field global WK_DefaultGlobal
  self.db = AceDB:New(
    "OctopalsVerifierDB",
    self.defaultDB,
    true
  )
end

---Analyze all objectives and their progress
---@return Octo_RaidMember[]
function Data:GetCharactersInRaid()
  ---@type Octo_RaidMember[]
  local raiders = {}
  for unit in Utils:IterateGroupMembers() do
    local playerName = GetUnitName(unit, true)
    local classID = select(3, UnitClass("player"))
    if playerName ~= GetUnitName("player", true) then
    end
  end

  return raiders
end
