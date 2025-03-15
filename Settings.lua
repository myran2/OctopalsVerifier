---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Settings
local Settings = {
  ---@type Octo_WeakAura[]
  weakAuras = {}
}
addon.Settings = Settings

local Constants = addon.Constants
local Utils = addon.Utils
local UI = addon.UI
local Data = addon.Data
local aceEvent = LibStub("AceEvent-3.0")

function Settings:ToggleWindow()
  if not self.window then return end
  if self.window:IsVisible() then
    self.window:Hide()
  else
    self.window:Show()
  end
  self.weakAuras = Utils:TableCopy(Data.db.global.settings.weakAurasToTrack)
  Data.db.global.settings.open = self.window:IsVisible()
  self:Render()
end

function Settings:Render()
  local dataColumns = self:GetColumns()
  local tableWidth = 0
  local tableHeight = 0

  ---@type WK_TableData
  local tableData = {
    columns = {},
    rows = {}
  }

  if not self.window then
    local frameName = addonName .. "SettingsWindow"
    self.window = CreateFrame("Frame", frameName, UIParent)
    self.window:SetSize(500, 500)
    self.window:SetFrameStrata("MEDIUM")
    self.window:SetFrameLevel(8100)
    self.window:SetToplevel(true)
    self.window:SetClampedToScreen(true)
    self.window:SetMovable(true)
    self.window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 8, -8)
    self.window:SetUserPlaced(true)
    self.window:RegisterForDrag("LeftButton")
    self.window:EnableMouse(true)
    self.window:SetScript("OnDragStart", function() self.window:StartMoving() end)
    self.window:SetScript("OnDragStop", function() self.window:StopMovingOrSizing() end)
    Utils:SetBackgroundColor(self.window, Data.db.global.main.windowBackgroundColor.r, Data.db.global.main.windowBackgroundColor.g, Data.db.global.main.windowBackgroundColor.b, Data.db.global.main.windowBackgroundColor.a)

    self.window.border = CreateFrame("Frame", "$parentBorder", self.window, "BackdropTemplate")
    self.window.border:SetPoint("TOPLEFT", self.window, "TOPLEFT", -3, 3)
    self.window.border:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT", 3, -3)
    self.window.border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    self.window.border:SetBackdropBorderColor(0, 0, 0, .5)
    self.window.border:Show()

    self.window.titlebar = CreateFrame("Frame", "$parentTitle", self.window)
    self.window.titlebar:SetPoint("TOPLEFT", self.window, "TOPLEFT")
    self.window.titlebar:SetPoint("TOPRIGHT", self.window, "TOPRIGHT")
    self.window.titlebar:SetHeight(Constants.TITLEBAR_HEIGHT)
    self.window.titlebar:RegisterForDrag("LeftButton")
    self.window.titlebar:EnableMouse(true)
    self.window.titlebar:SetScript("OnDragStart", function() self.window:StartMoving() end)
    self.window.titlebar:SetScript("OnDragStop", function() self.window:StopMovingOrSizing() end)
    Utils:SetBackgroundColor(self.window.titlebar, 0, 0, 0, 0.5)

    self.window.titlebar.icon = self.window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    self.window.titlebar.icon:SetPoint("LEFT", self.window.titlebar, "LEFT", 6, 0)
    self.window.titlebar.icon:SetSize(20, 20)
    self.window.titlebar.icon:SetTexture("Interface/AddOns/OctopalsVerifier/Media/Icon.blp")

    self.window.titlebar.title = self.window.titlebar:CreateFontString("$parentText", "OVERLAY")
    self.window.titlebar.title:SetFontObject("SystemFont_Med2")
    self.window.titlebar.title:SetPoint("LEFT", self.window.titlebar, 28, 0)
    self.window.titlebar.title:SetJustifyH("LEFT")
    self.window.titlebar.title:SetJustifyV("MIDDLE")
    self.window.titlebar.title:SetText("Settings")

    do -- Close Button
      self.window.titlebar.closeButton = CreateFrame("Button", "$parentCloseButton", self.window.titlebar)
      self.window.titlebar.closeButton:SetSize(Constants.TITLEBAR_HEIGHT, Constants.TITLEBAR_HEIGHT)
      self.window.titlebar.closeButton:SetPoint("RIGHT", self.window.titlebar, "RIGHT", 0, 0)
      self.window.titlebar.closeButton:SetScript("OnClick", function() self:ToggleWindow() end)
      self.window.titlebar.closeButton:SetScript("OnEnter", function()
        self.window.titlebar.closeButton.Icon:SetVertexColor(1, 1, 1, 1)
        Utils:SetBackgroundColor(self.window.titlebar.closeButton, 1, 0, 0, 0.2)
        GameTooltip:SetOwner(self.window.titlebar.closeButton, "ANCHOR_TOP")
        GameTooltip:SetText("Close the window", 1, 1, 1, 1, true);
        GameTooltip:Show()
      end)
      self.window.titlebar.closeButton:SetScript("OnLeave", function()
        self.window.titlebar.closeButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        Utils:SetBackgroundColor(self.window.titlebar.closeButton, 1, 1, 1, 0)
        GameTooltip:Hide()
      end)

      self.window.titlebar.closeButton.Icon = self.window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
      self.window.titlebar.closeButton.Icon:SetPoint("CENTER", self.window.titlebar.closeButton, "CENTER")
      self.window.titlebar.closeButton.Icon:SetSize(10, 10)
      self.window.titlebar.closeButton.Icon:SetTexture("Interface/AddOns/OctopalsVerifier/Media/Icon_Close.blp")
      self.window.titlebar.closeButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    end

    self.window.table = UI:CreateTableFrame({
      header = {
        enabled = true,
        sticky = true,
        height = Constants.TABLE_HEADER_HEIGHT,
      },
      rows = {
        height = Constants.TABLE_ROW_HEIGHT,
        highlight = false,
        striped = true
      },
      cells = {
        padding = Constants.TABLE_CELL_PADDING,
        highlight = true
      },
    })
    self.window.table:SetParent(self.window)
    self.window.table:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -Constants.TITLEBAR_HEIGHT)
    self.window.table:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT", 0, 0)

    self.window.addWeakauraButton = CreateFrame("Button", "addWeakauraButton", self.window)
    self.window.addWeakauraButton:SetPoint("BOTTOMLEFT", self.window.table, "BOTTOMLEFT", 0, self.window.table.config.rows.height / 2)
    self.window.addWeakauraButton:SetSize(128, 21)
    self.window.addWeakauraButton:SetNormalFontObject(GameFontNormal)
    self.window.addWeakauraButton:SetHighlightFontObject(GameFontHighlight)
    self.window.addWeakauraButton:SetNormalTexture(130763) -- "Interface\\Buttons\\UI-DialogBox-Button-Up"
    self.window.addWeakauraButton:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    self.window.addWeakauraButton:SetPushedTexture(130761) -- "Interface\\Buttons\\UI-DialogBox-Button-Down"
    self.window.addWeakauraButton:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    self.window.addWeakauraButton:SetHighlightTexture(130762) -- "Interface\\Buttons\\UI-DialogBox-Button-Highlight"
    self.window.addWeakauraButton:GetHighlightTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    self.window.addWeakauraButton:SetText("Add WeakAura")
    self.window.addWeakauraButton:SetScript("OnClick", function() self:HandleAddNewWeakaura() end)

    self.window.addWeakauraButton = CreateFrame("Button", "commitChangesButton", self.window)
    self.window.addWeakauraButton:SetPoint("BOTTOM", self.window, "BOTTOM", 0, 0)
    self.window.addWeakauraButton:SetSize(128, 21)
    self.window.addWeakauraButton:SetNormalFontObject(GameFontNormal)
    self.window.addWeakauraButton:SetHighlightFontObject(GameFontHighlight)
    self.window.addWeakauraButton:SetNormalTexture(130763) -- "Interface\\Buttons\\UI-DialogBox-Button-Up"
    self.window.addWeakauraButton:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    self.window.addWeakauraButton:SetPushedTexture(130761) -- "Interface\\Buttons\\UI-DialogBox-Button-Down"
    self.window.addWeakauraButton:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    self.window.addWeakauraButton:SetHighlightTexture(130762) -- "Interface\\Buttons\\UI-DialogBox-Button-Highlight"
    self.window.addWeakauraButton:GetHighlightTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    self.window.addWeakauraButton:SetText("Save")
    self.window.addWeakauraButton:SetScript("OnClick", function() self:CommitChanges() end)

    table.insert(UISpecialFrames, frameName)
  end

  -- Quick hotfix to avoid excessive rendering
  if (not self.window:IsVisible() and not Data.db.global.settings.open) then
    self.window:Hide()
    return
  end

  do -- Table Column config
    Utils:TableForEach(dataColumns, function(dataColumn)
      ---@type WK_TableDataColumn
      local column = {
        width = dataColumn.width,
        align = dataColumn.align or "LEFT",
      }
      table.insert(tableData.columns, column)
      tableWidth = tableWidth + dataColumn.width
    end)
  end

  do -- Table Header row
    ---@type WK_TableDataRow
    local row = {columns = {}}
    Utils:TableForEach(dataColumns, function(dataColumn)
      ---@type WK_TableDataCell
      local cell = {
        text = NORMAL_FONT_COLOR:WrapTextInColorCode(dataColumn.name),
        onEnter = dataColumn.onEnter,
        onLeave = dataColumn.onLeave,
      }
      table.insert(row.columns, cell)
    end)
    table.insert(tableData.rows, row)
    tableHeight = tableHeight + self.window.table.config.header.height
  end

  local rows = 0
  Utils:TableForEach(self.weakAuras, function(weakauraOption, index)
    ---@type WK_TableDataRow
    local row = {columns = {}}
    Utils:TableForEach(dataColumns, function(dataColumn)
      ---@type WK_TableDataCell
      local cell = dataColumn.cell(weakauraOption, index)
      table.insert(row.columns, cell)
    end)

    table.insert(tableData.rows, row)
    tableHeight = tableHeight + self.window.table.config.rows.height
    rows = rows + 1
  end)

  local windowWidth     = tableWidth
  local windowHeight    = Constants.TITLEBAR_HEIGHT
  local minWindowWidth  = 200
  local maxWindowHeight = 800

  if rows == 0 then
    windowHeight = 100
    self.window.table:Hide()
  else
    windowHeight = windowHeight + tableHeight + (2 * self.window.table.config.rows.height) + 2
    self.window.table:Show()
  end

  windowHeight = math.min(windowHeight, maxWindowHeight)
  windowWidth  = math.max(windowWidth, minWindowWidth)

  self.window:SetShown(Data.db.global.settings.open)
  self.window.border:SetShown(true)
  self.window.titlebar:SetShown(true)
  self.window.table:SetData(tableData)
  self.window:SetWidth(windowWidth)
  self.window:SetHeight(windowHeight)
  self.window:SetClampRectInsets(self.window:GetWidth() / 2, self.window:GetWidth() / -2, 0, self.window:GetHeight() / 2)
  self.window:SetScale(Data.db.global.main.windowScale / 100)
  if Data.cache.inCombat and Data.db.global.Settings.hideInCombat then
    self.window:Hide()
  end
end

function Settings:GetColumns()
  return {
    {
      name = "Aura Name",
      width = 300,
      onEnter = function(cellFrame)
        GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Aura Name", 1, 1, 1);
        GameTooltip:AddLine("The name of the WeakAura exactly as it appears in the WeakAuras list.")
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      cell = function(weakAura, index)
        return {
          text = weakAura.auraName,
        }
      end,
    },
    {
      name = "Display Name",
      width = 200,
      onEnter = function(cellFrame)
        GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Display Name", 1, 1, 1);
        GameTooltip:AddLine("How the WeakAura should be displayed in the verification table.")
        GameTooltip:AddLine("If this value is empty, the Aura Name will be used.")
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      cell = function(weakAura, index)
        return {
          text = weakAura.displayName,
        }
      end,
    },
    -- {
    --   name = "Wago URL",
    --   width = 250,
    --   cell = function(weakAura, index)
    --     return {
    --       text = weakAura.wagoUrl,
    --     }
    --   end,
    -- },
    {
      name = "Delete",
      width = 60,
      align = "CENTER",
      cell = function(weakAura, index)
        return {
          icon = "common-icon-redx",
          onClick = function()
            Settings:HandleRemoveWeakauraByIndex(index)
          end
        }
      end,
    },
  }
end

function Settings:HandleRemoveWeakauraByIndex(index)
  table.remove(self.weakAuras, index)
  self:Render()
end

function Settings:HandleAddNewWeakaura()
  local emptyRecords = Utils:TableFilter(self.weakAuras, function(weakaura) 
    return weakaura.auraName == "" or weakaura.displayName == ""
  end)

  if Utils:TableCount(emptyRecords) > 0 then
    return
  end

  table.insert(self.weakAuras, {
    displayName = "",
    auraName = "",
    wagoUrl = "",
    allowNested = false
  })

  self:Render()
end

function Settings:CommitChanges()
  Data.db.global.settings.weakAurasToTrack = Utils:TableCopy(self.weakAuras)
  aceEvent:SendMessage("OCTO_WA_SETTINGS_CHANGED")
  self:ToggleWindow()
end
