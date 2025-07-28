---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

local Utils = addon.Utils

---@class Octo_NameModule
local NameModule = {
    name = 'Name',
    width = 120,
    align = "LEFT",
    description = {
        "People in your raid.",
    }
}
addon.Modules.Name = NameModule

function NameModule:new()
    return Utils:TableCopy(self)
end

function NameModule:GetCellContents(cellData, referenceRow)
    local name = cellData.name
    if cellData.classID then
        local _, classFile = GetClassInfo(cellData.classID)
        if classFile then
            local color = C_ClassColor.GetClassColor(classFile)
            if color then
                name = color:WrapTextInColorCode(name)
            end
        end
    end
    return {text = name}
end
