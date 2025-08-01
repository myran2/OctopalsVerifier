---@class WK_DefaultGlobal
---@field DBVersion integer?
---@field weeklyReset integer?
---@field minimap {minimapPos: number, hide: boolean, lock: boolean }
---@field main WK_DefaultGlobalMain
---@field settings WK_DefaultGlobalSettings

---@class WK_DefaultGlobalMain
---@field hiddenColumns table<string, boolean>
---@field windowScale integer
---@field windowBackgroundColor {r: number, g: number, b: number, a: number}
---@field windowBorder boolean Show the border?
---@field fontSize integer?

---@class WK_DefaultGlobalSettings
---@field open boolean
---@field weakAurasToTrack Octo_WeakAura[]

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
---@field icon string?
---@field editable boolean?
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
---@field nsVersion string?
---@field mrtVersion string?
---@field mrtNoteHash string?
---@field ignoreList table?
---@field weakauras table?
---@field receivedAt number
