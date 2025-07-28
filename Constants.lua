---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Constants
local Constants = {}
addon.Constants = Constants

Constants.TITLEBAR_HEIGHT = 30
Constants.TABLE_ROW_HEIGHT = 32
Constants.TABLE_HEADER_HEIGHT = 40
Constants.TABLE_CELL_PADDING = 10
Constants.MAX_WINDOW_HEIGHT = 900

Constants.MODULE_TYPE_ADDON = 'addon'
Constants.MODULE_TYPE_WEAKAURA = 'weakaura'
Constants.MODULE_TYPE_IGNORE_LIST = 'ignore-list'
Constants.MODULE_TYPE_MRT_NOTE_HASH = 'mrt-hash'
