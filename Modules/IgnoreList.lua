---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

local Checks = addon.Checks
local Utils = addon.Utils

---@class Octo_IgnoreListModule
local IgnoreListModule = {
    width = 100,
    align = "CENTER",
    referenceValue = nil,
}
addon.Modules.IgnoreList = IgnoreListModule

---@param check Octo_Check
function IgnoreListModule:new(check)
    self.name = check.displayName
    self.referenceValue = self:GetReferenceValue(check)
    self.description = {
        "Contents of this player's ignore list.",
    }
    self.cell = self.GetCellContents

    return Utils:TableCopy(self)
end

function IgnoreListModule:GetReferenceValue(check)
    local ignoredPlayers = Checks:IgnoredRaiders()
    if #ignoredPlayers == 0 then
        return "*Empty*"
    end

    return "Players ignored!"
end

function IgnoreListModule:GetCellContents(cellData, referenceRow)
    if referenceRow then
        return {
            text = self.referenceValue
        }
    end
    local value = ''
    if value == self.referenceValue then
        return {
        icon = "common-icon-checkmark",
        scale = 0.6,
        tooltip = function()
            GameTooltip:SetText("Match", 1, 1, 1);
            GameTooltip:AddLine("This player's value for this check matches yours.")
        end
        }
    end

    return {
        icon = "common-icon-redx",
        scale = 0.6,
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
