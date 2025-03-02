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
    main = {
      hiddenColumns = {},
      windowScale = 100,
      windowBackgroundColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1},
      windowBorder = true,
      checklistHelpTipClosed = false,
    },
    checklist = {
      open = false,
      hiddenColumns = {},
      windowScale = 100,
      windowBackgroundColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1},
      windowBorder = true,
      windowTitlebar = true,
      hideCompletedObjectives = false,
      hideInCombat = false,
      hideInDungeons = true,
      hideTable = false,
      hideTableHeader = false,
      hideUniqueObjectives = false,
      hideUniqueVendorObjectives = false,
      hideCatchUpObjectives = false,
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

---Get stored character by GUID
---@param GUID WOWGUID?
---@return WK_Character|nil
function Data:GetCharacter(GUID)
  if GUID == nil then
    GUID = UnitGUID("player")
  end

  if GUID == nil then
    return nil
  end

  if self.db.global.characters[GUID] == nil then
    self.db.global.characters[GUID] = Utils:TableCopy(self.defaultCharacter)
  end

  self.db.global.characters[GUID].GUID = GUID

  return self.db.global.characters[GUID]
end

function Data:ScanCharacter()
  local character = self:GetCharacter()
  if not character then return end

  -- Update character info
  local localizedRaceName, englishRaceName, raceID = UnitRace("player")
  local localizedClassName, classFile, classID = UnitClass("player")
  local englishFactionName, localizedFactionName = UnitFactionGroup("player")
  character.name = UnitName("player")
  character.realmName = GetRealmName()
  character.level = UnitLevel("player")
  character.factionEnglish = englishFactionName
  character.factionName = localizedFactionName
  character.raceID = raceID
  character.raceEnglish = englishRaceName
  character.raceName = localizedRaceName
  character.classID = classID
  character.classFile = classFile
  character.className = localizedClassName
  character.lastUpdate = GetServerTime()

  -- Let's not track a character without a TWW profession
  if Utils:TableCount(character.professions) < 1 then
    self.db.global.characters[character.GUID] = nil
  end
end

---Get characters
---@param unfiltered boolean?
---@return WK_Character[]
function Data:GetCharacters(unfiltered)
  local characters = Utils:TableFilter(self.db.global.characters, function(character)
    local include = true

    -- Ignore ghost characters (Bug: https://github.com/DennisRas/OctopalsVerifier/issues/47)
    if not character.name or character.name == "" then
      include = false
    end

    if not unfiltered then
      if not character.enabled then
        include = false
      end
    end

    return include
  end)

  table.sort(characters, function(a, b)
    if type(a.lastUpdate) == "number" and type(b.lastUpdate) == "number" then
      return a.lastUpdate > b.lastUpdate
    end
    return strcmputf8i(a.name, b.name) < 0
  end)

  return characters
end

---Analyze all objectives and their progress
---@return Octo_RaidMember[]
function Data:GetCharactersInRaid()
  ---@type Octo_RaidMember[]
  local raiders = {
    {
      name = GetUnitName("player", true),
      GUID = UnitGUID("player"),
      classID = select(3, UnitClass("player")),
      waVersion = Checks:WeakAurasVersion(),
      bwVersion = Checks:BigWigsVersion(),
      dbmVersion = Checks:DBMVersion(),
      mrtVersion = Checks:MRTVersion(),
      mrtNoteHash = Checks:HashedMRTNote(),
      ignoreList = Checks:IgnoredRaiders(),
      weakauras = Utils:TableMap(Data.WeakAurasToTrack, function(auraToTrack)
        return Checks:WeakAuraVersionByName(auraToTrack.auraName)
      end)
    }
  }
  for unit in Utils:IterateGroupMembers() do
    local playerName = GetUnitName(unit, true)
    local classID = select(3, UnitClass("player"))
    if playerName ~= GetUnitName("player", true) then
    end
  end

  return raiders
end
