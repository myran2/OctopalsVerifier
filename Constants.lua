---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Constants
local Constants = {}
addon.Constants = Constants

Constants.TITLEBAR_HEIGHT = 30
Constants.TABLE_ROW_HEIGHT = 24
Constants.TABLE_HEADER_HEIGHT = 32
Constants.TABLE_CELL_PADDING = 8
Constants.MAX_WINDOW_HEIGHT = 500
