---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

local Checks = addon.Checks
local Utils = addon.Utils

---@class Octo_AddonModule
local AddonModule = {
    width = 100,
    align = "CENTER",
    name = nil,
    referenceValue = nil,
}
addon.Modules.Addon = AddonModule

---@param check Octo_Check
function AddonModule:new(check)
    self.name = check.displayName
    self.referenceValue = self:GetReferenceValue(check)
    self.description = {
        "Exact Name: " .. check.exactName,
    }
    self.cell = self.GetCellContents

    return Utils:TableCopy(self)
end

function AddonModule:GetReferenceValue(check)
    local ver = Checks:GetAddonVersion(check.exactName)
    if ver == "Addon Missing" or ver == "Addon not enabled" then
        return "0"
    end
    return ver
end

function AddonModule:GetCellContents(cellData, referenceRow)
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
