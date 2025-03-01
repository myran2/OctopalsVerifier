---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Checks
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
---@return string?
function Checks:WeakAurasVersion()
  if WeakAuras then
    return WeakAuras.versionString
  end
  return nil
end

--- Installed MRT version
---@return string?
function Checks:MRTVersion()
  if _G.VMRT then
    return tostring(_G.VMRT.Addon.Version)
  end
  return nil
end

--- Installed BigWigs version
---@return string?
function Checks:BigWigsVersion()
  if BigWigsLoader then
    return BigWigsLoader.GetVersionString()
  end
  return nil
end

--- Installed DBM version
---@return string?
function Checks:DBMVersion()
  if DBM then
    return tostring(DBM.Revision)
  end
  return nil
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
