---@class WK_DefaultGlobal
---@field DBVersion integer?
---@field weeklyReset integer?
---@field minimap {minimapPos: number, hide: boolean, lock: boolean }
---@field characters table<string, WK_Character>
---@field main WK_DefaultGlobalMain

---@class WK_DefaultGlobalMain
---@field hiddenColumns table<string, boolean>
---@field windowScale integer
---@field windowBackgroundColor {r: number, g: number, b: number, a: number}
---@field windowBorder boolean Show the border?
---@field fontSize integer?
---@field checklistHelpTipClosed boolean?

---@class WK_Character
---@field GUID string|WOWGUID
---@field enabled boolean
---@field name string
---@field realmName string
---@field level integer
---@field factionEnglish string
---@field factionName string
---@field raceID integer
---@field raceEnglish string
---@field raceName string
---@field classID integer
---@field classFile ClassFile?
---@field className string
---@field lastUpdate number
---@field professions WK_CharacterProfession[]
---@field completed table<integer, boolean>

---@class WK_CharacterProfession
---@field enabled boolean
---@field skillLineID integer
---@field level integer
---@field maxLevel integer
---@field knowledgeLevel integer
---@field knowledgeMaxLevel integer
---@field knowledgeUnspent integer
---@field specializations table
---@field catchUpCurrencyInfo CurrencyInfo?

---@class WK_ObjectiveType
---@field id Enum.WK_Objectives
---@field name string
---@field description string
---@field type "item" | "quest"
---@field repeatable "No" | "Weekly" | "Monthly"

---@class WK_Profession
---@field name string
---@field skillLineID integer Profession ID
---@field skillLineVariantID integer Profession Expansion Variant ID
---@field spellID integer Learned Profession Spell ID
---@field catchUpCurrencyID integer
---@field catchUpWeeklyCap integer
---@field catchUpItemID integer

---@class WK_Objective
---@field professionID integer
---@field typeID Enum.WK_Objectives
---@field quests integer[]
---@field itemID integer?
---@field points integer
---@field limit integer?

---@class WK_DataCache
---@field isDarkmoonOpen boolean
---@field inCombat boolean
---@field items table<integer, ItemMixin>
---@field mapInfo table<integer, UiMapDetails>

---@class WK_DataColumn
---@field name string
---@field width integer
---@field align "LEFT" | "CENTER" | "RIGHT" | nil
---@field onEnter function?
---@field onLeave function?
---@field cell fun(character: Octo_RaidMember): WK_TableDataCell
---@field toggleHidden boolean

---@class WK_TableData
---@field columns WK_TableDataColumn[]?
---@field rows WK_TableDataRow[]

---@class WK_TableDataColumn
---@field width number
---@field align string?

---@class WK_TableDataRow
---@field columns WK_TableDataCell[]
---@field backgroundColor {r: number, g: number, b: number, a: number}?
---@field onEnter function?
---@field onLeave function?
---@field onClick function?

---@class WK_TableDataCell
---@field text string?
---@field backgroundColor {r: number, g: number, b: number, a: number}?
---@field onEnter function?
---@field onLeave function?
---@field onClick function?

---@class Octo_WeakAura
---@field displayName string
---@field wagoUrl string
---@field auraName string
---@field allowNested boolean

---@class Octo_InstalledWeakAura
---@field auraName string
---@field wagoUrl string
---@field version number?

---@class Octo_RaidMember
---@field GUID string|WOWGUID
---@field name string
---@field classID number
---@field waVersion string?
---@field bwVersion string?
---@field dbmVersion string?
---@field mrtVersion string?
---@field mrtNoteHash string?
---@field ignoreList table
---@field weakauras table

---@enum Enum.WK_Objectives
Enum.WK_Objectives = {
  Unique = "Unique",
  Treatise = "Treatise",
  ArtisanQuest = "ArtisanQuest",
  Treasure = "Treasure",
  Gathering = "Gathering",
  TrainerQuest = "TrainerQuest",
  DarkmoonQuest = "DarkmoonQuest",
  CatchUp = "CatchUp",
}
