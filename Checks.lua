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
  if BigWigsAPI then
    return ("%d-%s"):format(BigWigsAPI.GetVersion(), BigWigsAPI.GetVersionHash())
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
      return -1
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
    if Utils:TableCount(row[field]) == 0 then
      return "*Empty*"
    end
    return tostring(Utils:TableCount(row[field]))
  end

  return tostring(row[field])
end

---@param field string
---@param row Octo_RaidMember
---@param referenceRow Octo_RaidMember
---@param index number?
function Checks:GetCellContents(field, row, referenceRow, index)
  local value = Checks:GetCheckValueAsString(field, index, row)
  local referenceValue = Checks:GetCheckValueAsString(field, index, referenceRow)

  -- this player has people in the raid on their ignore list!
  -- this is a problem even for the "reference"
  if field == 'ignoreList' and row[field] ~= nil and Utils:TableCount(row[field]) > 0 then
    return {
      icon = "common-icon-redx",
      tooltip = function()
        GameTooltip:SetText("Players Ignored:", 1, 1, 1);
        Utils:TableForEach(row[field], function(ignoredName)
          GameTooltip:AddLine(RED_FONT_COLOR:WrapTextInColorCode(ignoredName))
        end)
      end
    }
  end

  -- "reference" row should just show the values.
  if row.GUID == UnitGUID("player") then
    return {
      text = value == '-1' and "*Not Installed*" or value
    }

  end

  if row.receivedAt == 0 then
    return {
      text = "...",
      tooltip = function()
        GameTooltip:SetText("No Response", 1, 1, 1);
        GameTooltip:AddLine("This player doesn't have the verifier installed OR they were in combat at the time of the check.")
      end
    }
  end

  if value == nil then
    return {
      icon = "services-icon-warning",
      tooltip = function()
        GameTooltip:SetText("Not Supported", 1, 1, 1);
        GameTooltip:AddLine("This player's verifier WeakAura is too old to support this check.")
      end
    }
  end

  if value == referenceValue then
    return {
      icon = "common-icon-checkmark",
      tooltip = function()
        GameTooltip:SetText("Match", 1, 1, 1);
        GameTooltip:AddLine("This player's value for this check matches yours.")
      end
    }
  end

  return {
    icon = "common-icon-redx",
    tooltip = function()
      GameTooltip:SetText("Mismatch!", 1, 1, 1);
      if value == nil or value == '-1' or value == '0' then
        GameTooltip:AddDoubleLine(RED_FONT_COLOR:WrapTextInColorCode("Player doesn't have the Addon/WA enabled or installed."))
      else
        GameTooltip:AddDoubleLine(RED_FONT_COLOR:WrapTextInColorCode(value), "This value doesn't match yours.")
      end
    end
  }
end

---@param field string
---@param row Octo_RaidMember
---@param referenceRow Octo_RaidMember
---@param index number?
---@return WK_TableDataCell
function Checks:GetCellObject(field, row, referenceRow, index)
  local cellContents = self:GetCellContents(field, row, referenceRow, index)
  if cellContents.tooltip then
    cellContents.onEnter = function(cellFrame)
      GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
      cellContents.tooltip()
      GameTooltip:Show()
    end
    cellContents.onLeave = function()
      GameTooltip:Hide()
    end
  end
  return cellContents
end
