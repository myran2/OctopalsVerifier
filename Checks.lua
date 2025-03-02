---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class Octo_Checks
local Checks = {}
addon.Checks = Checks

local Utils = addon.Utils

--- Contents of MRT Note as a numeric hash.
---@return string?
function Checks:HashedMRTNote()
  if C_AddOns.IsAddOnLoaded("MRT") then
    if _G.VMRT.Note.Text1 then
      local text = _G.VMRT.Note.Text1
      local hashed = Utils:StringHash(text)
      return tostring(hashed)
    end
    return nil
  end
  return nil
end

--- Installed WeakAuras version
---@return string
function Checks:WeakAurasVersion()
  if WeakAuras then
    return WeakAuras.versionString
  end
  return "0"
end

--- Installed MRT version
---@return string
function Checks:MRTVersion()
  if _G.VMRT then
    return tostring(_G.VMRT.Addon.Version)
  end
  return "0"
end

--- Installed BigWigs version
---@return string
function Checks:BigWigsVersion()
  if BigWigsLoader then
    return BigWigsLoader.GetVersionString()
  end
  return "0"
end

--- Installed DBM version
---@return string
function Checks:DBMVersion()
  if DBM then
    return tostring(DBM.Revision)
  end
  return "0"
end

--- Raiders in the group that are on this player's ignore list.
---@return table
function Checks:IgnoredRaiders()
  local ignoredRaiders = {}
  for unit in Utils:IterateGroupMembers() do
    local playerName = UnitName(unit)
    if C_FriendList.IsOnIgnoredList(playerName) then
      table.insert(ignoredRaiders, playerName)
    end
  end

  return ignoredRaiders
end

function Checks:WeakAuraVersionByName(waName)
  local waData = WeakAuras.GetData(waName)
  if not waData then
      return nil
  end

  if not waData['url'] then
      -- local WA doesn't have a URL. not sure if this should be 0 or 1 yet
      return 0
  end

  local waURL = waData['url']
  local versionStr = waURL:match('.*/(%d+)$')
  if not versionStr then
      return 0
  end
  return tonumber(versionStr)
end


---@return string?
function Checks:GetCheckValueAsString(field, index, row)
  if row[field] == nil then
    return nil
  end

  if type(row[field]) == 'table' and index ~= nil then
    return tostring(row[field][index])
  end

  if field == 'ignoreList' then
    return tostring(Utils:TableCount(row[field]))
  end

  return tostring(row[field])
end

---@param field string
---@param row Octo_RaidMember
---@param referenceRow Octo_RaidMember
---@param index number?
---@return string
function Checks:GetCellContents(field, row, referenceRow, index)
  local value = Checks:GetCheckValueAsString(field, index, row)
  local referenceValue = Checks:GetCheckValueAsString(field, index, referenceRow)

  if row.GUID == UnitGUID("player") then
    return value or "? Shouldn't happen ?"
  end

  if row.receivedAt == 0 then
    return "..."
  end

  if value == nil then
    return YELLOW_FONT_COLOR:WrapTextInColorCode("Not Supported")
  end

  if value == referenceValue then
    return GREEN_FONT_COLOR:WrapTextInColorCode(value)
  end

  return RED_FONT_COLOR:WrapTextInColorCode(value)
end
