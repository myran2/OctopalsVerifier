---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Interface
local UI = {}
addon.UI = UI

UI.TableCollection = {}
UI.ScrollCollection = {}

local Utils = addon.Utils
local Constants = addon.Constants

function UI:CreateScrollFrame(config)
  local frame = CreateFrame("ScrollFrame", "OctopalsVerifierScrollFrame" .. (Utils:TableCount(self.TableCollection) + 1))
  frame.config = CreateFromMixins(
    {
      scrollSpeedHorizontal = 20,
      scrollSpeedVertical = 20,
    },
    config or {}
  )

  frame.content = CreateFrame("Frame", "$parentContent", frame)
  frame.scrollbarH = CreateFrame("Slider", "$parentScrollbarH", frame, "UISliderTemplate")
  frame.scrollbarV = CreateFrame("Slider", "$parentScrollbarV", frame, "UISliderTemplate")

  frame:SetScript("OnMouseWheel", function(_, delta)
    if IsModifierKeyDown() or not frame.scrollbarV:IsVisible() then
      frame.scrollbarH:SetValue(frame.scrollbarH:GetValue() - delta * frame.config.scrollSpeedHorizontal)
    else
      frame.scrollbarV:SetValue(frame.scrollbarV:GetValue() - delta * frame.config.scrollSpeedVertical)
    end
  end)
  frame:SetScript("OnSizeChanged", function() frame:RenderScrollFrame() end)
  frame:SetScrollChild(frame.content)
  frame.content:SetScript("OnSizeChanged", function() frame:RenderScrollFrame() end)

  frame.scrollbarH:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  frame.scrollbarH:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  frame.scrollbarH:SetHeight(6)
  frame.scrollbarH:SetMinMaxValues(0, 100)
  frame.scrollbarH:SetValue(0)
  frame.scrollbarH:SetValueStep(1)
  frame.scrollbarH:SetOrientation("HORIZONTAL")
  frame.scrollbarH:SetObeyStepOnDrag(true)
  frame.scrollbarH.thumb = frame.scrollbarH:GetThumbTexture()
  frame.scrollbarH.thumb:SetPoint("CENTER")
  frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15)
  frame.scrollbarH.thumb:SetHeight(10)
  frame.scrollbarH:SetScript("OnValueChanged", function(_, value) frame:SetHorizontalScroll(value) end)
  frame.scrollbarH:SetScript("OnEnter", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.2) end)
  frame.scrollbarH:SetScript("OnLeave", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15) end)

  frame.scrollbarV:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  frame.scrollbarV:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  frame.scrollbarV:SetWidth(6)
  frame.scrollbarV:SetMinMaxValues(0, 100)
  frame.scrollbarV:SetValue(0)
  frame.scrollbarV:SetValueStep(1)
  frame.scrollbarV:SetOrientation("VERTICAL")
  frame.scrollbarV:SetObeyStepOnDrag(true)
  frame.scrollbarV.thumb = frame.scrollbarV:GetThumbTexture()
  frame.scrollbarV.thumb:SetPoint("CENTER")
  frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15)
  frame.scrollbarV.thumb:SetWidth(10)
  frame.scrollbarV:SetScript("OnValueChanged", function(_, value) frame:SetVerticalScroll(value) end)
  frame.scrollbarV:SetScript("OnEnter", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.2) end)
  frame.scrollbarV:SetScript("OnLeave", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15) end)

  if frame.scrollbarH.NineSlice then frame.scrollbarH.NineSlice:Hide() end
  if frame.scrollbarV.NineSlice then frame.scrollbarV.NineSlice:Hide() end

  function frame:RenderScrollFrame()
    local viewportWidth = frame:GetWidth()
    local viewportHeight = frame:GetHeight()
    local contentWidth = frame.content:GetWidth()
    local contentHeight = frame.content:GetHeight()
    local ratioWidth = viewportWidth / contentWidth
    local ratioHeight = viewportHeight / contentHeight
    -- Horizontal
    if ratioWidth < 1 then
      frame.scrollbarH:SetValueStep(frame.config.scrollSpeedHorizontal)
      frame.scrollbarH:SetMinMaxValues(0, contentWidth - viewportWidth)
      frame.scrollbarH.thumb:SetWidth(viewportWidth * ratioWidth)
      frame.scrollbarH.thumb:SetHeight(frame.scrollbarH:GetHeight())
      frame.scrollbarH:Show()
    else
      frame:SetHorizontalScroll(0)
      frame.scrollbarH:Hide()
    end
    -- Vertical
    if ratioHeight < 1 then
      frame.scrollbarV:SetValueStep(frame.config.scrollSpeedVertical)
      frame.scrollbarV:SetMinMaxValues(0, contentHeight - viewportHeight)
      frame.scrollbarV.thumb:SetHeight(math.min(viewportHeight * ratioHeight, viewportHeight / 3))
      frame.scrollbarV.thumb:SetWidth(frame.scrollbarV:GetWidth())
      frame.scrollbarV:Show()
    else
      frame:SetVerticalScroll(0)
      frame.scrollbarV:Hide()
    end
  end

  frame:RenderScrollFrame()
  return frame
end

function UI:CreateTableFrame(config)
  local tableFrame = CreateFrame("Frame", "OctopalsVerifierTable" .. (Utils:TableCount(self.TableCollection) + 1))
  tableFrame.config = CreateFromMixins(
    {
      header = {
        enabled = true,
        sticky = false,
        height = 30,
      },
      rows = {
        height = 22,
        highlight = true,
        striped = true
      },
      columns = {
        width = 100,
        highlight = false,
        striped = false
      },
      cells = {
        padding = Constants.TABLE_CELL_PADDING,
        highlight = false
      },
      ---@type WK_TableData
      data = {
        columns = {},
        rows = {},
      },
    },
    config or {}
  )
  tableFrame.rows = {}
  tableFrame.data = tableFrame.config.data
  tableFrame.scrollFrame = self:CreateScrollFrame({
    name = "$parentScrollFrame",
    scrollSpeedVertical = tableFrame.config.rows.height * 2
  })

  function tableFrame:SetData(data)
    self.data = data
    self:RenderTable()
  end

  function tableFrame:SetRowHeight(height)
    self.config.rows.height = height
    self:RenderTable()
  end

  function tableFrame:RenderTable()
    local offsetY = 0
    local offsetX = 0

    Utils:TableForEach(tableFrame.rows, function(rowFrame) rowFrame:Hide() end)
    Utils:TableForEach(tableFrame.data.rows, function(row, rowIndex)
      local rowFrame = tableFrame.rows[rowIndex]
      local rowHeight = tableFrame.config.rows.height
      local isStickyRow = false

      if not rowFrame then
        rowFrame = CreateFrame("Button", "$parentRow" .. rowIndex, tableFrame)
        rowFrame.columns = {}
        tableFrame.rows[rowIndex] = rowFrame
      end

      if rowIndex == 1 then
        if tableFrame.config.header.enabled then
          rowHeight = tableFrame.config.header.height
        end
        if tableFrame.config.header.sticky then
          isStickyRow = true
        end
      end

      -- Sticky header
      if isStickyRow then
        rowFrame:SetParent(tableFrame)
        rowFrame:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", 0, 0)
        rowFrame:SetPoint("TOPRIGHT", tableFrame, "TOPRIGHT", 0, 0)
        if not row.backgroundColor then
          Utils:SetBackgroundColor(rowFrame, 0, 0, 0, 0.3)
        end
      else
        rowFrame:SetParent(tableFrame.scrollFrame.content)
        rowFrame:SetPoint("TOPLEFT", tableFrame.scrollFrame.content, "TOPLEFT", 0, -offsetY)
        rowFrame:SetPoint("TOPRIGHT", tableFrame.scrollFrame.content, "TOPRIGHT", 0, -offsetY)
        if tableFrame.config.rows.striped and rowIndex % 2 == 1 then
          Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
        end
      end

      if row.backgroundColor then
        Utils:SetBackgroundColor(rowFrame, row.backgroundColor.r, row.backgroundColor.g, row.backgroundColor.b, row.backgroundColor.a)
      end

      rowFrame.data = row
      rowFrame:SetHeight(rowHeight)
      rowFrame:SetScript("OnEnter", function() rowFrame:onEnterHandler(rowFrame) end)
      rowFrame:SetScript("OnLeave", function() rowFrame:onLeaveHandler(rowFrame) end)
      rowFrame:SetScript("OnClick", function() rowFrame:onClickHandler(rowFrame) end)
      rowFrame:Show()

      function rowFrame:onEnterHandler(f)
        if rowIndex > 1 or not tableFrame.config.header.enabled then
          Utils:SetHighlightColor(rowFrame, 1, 1, 1, .03)
        end
        if row.onEnter then
          row:onEnter(f)
        end
      end

      function rowFrame:onLeaveHandler(f)
        if rowIndex > 1 or not tableFrame.config.header.enabled then
          Utils:SetHighlightColor(rowFrame, 1, 1, 1, 0)
        end
        if row.onLeave then
          row:onLeave(f)
        end
      end

      function rowFrame:onClickHandler(f)
        if row.onClick then
          row:onClick(f)
        end
      end

      offsetX = 0
      Utils:TableForEach(rowFrame.columns, function(columnFrame) columnFrame:Hide() end)
      Utils:TableForEach(row.columns, function(column, columnIndex)
        local columnFrame = rowFrame.columns[columnIndex]
        local columnConfig = tableFrame.data.columns[columnIndex]
        local columnWidth = columnConfig and columnConfig.width or tableFrame.config.columns.width
        local columnTextAlign = columnConfig and columnConfig.align or "LEFT"

        if not columnFrame then
          columnFrame = CreateFrame("Button", "$parentCol" .. columnIndex, rowFrame)
          columnFrame.text = columnFrame:CreateFontString("$parentText", "OVERLAY")
          columnFrame.text:SetFontObject("GameFontHighlightSmall")
          columnFrame.text:SetWordWrap(false)
          columnFrame.text:SetJustifyH(columnTextAlign)
          columnFrame.text:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", tableFrame.config.cells.padding, -tableFrame.config.cells.padding)
          columnFrame.text:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT", -tableFrame.config.cells.padding, tableFrame.config.cells.padding)

          columnFrame.editBox = CreateFrame("EditBox", nil, columnFrame, "BackdropTemplate")
          columnFrame.editBox:SetMaxLetters(64)
          columnFrame.editBox:SetAutoFocus(false)
          columnFrame.editBox:SetFontObject("GameFontHighlightSmall")
          columnFrame.editBox:SetWidth(columnWidth - 10)
          columnFrame.editBox:SetHeight(Constants.TABLE_ROW_HEIGHT - 4)
          columnFrame.editBox:SetJustifyV("BOTTOM")
          columnFrame.editBox:SetTextInsets(10, 10, 0, 0)
          columnFrame.editBox:SetPoint("LEFT", columnFrame, "LEFT", 3, 0)
          columnFrame.editBox:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8, insets = {left = 4, right = 4, top = 4, bottom = 4}})
          columnFrame.editBox:SetBackdropBorderColor(0, 0, 0, .5)
          columnFrame.editBox:SetScript("OnTextChanged", function()
            if columnFrame.editBox:GetText() ~= column.text then
              columnFrame.editBoxSave:Show()
            else
              columnFrame.editBoxSave:Hide()
            end
          end)
          columnFrame.editBoxSave = CreateFrame("Button", nil, columnFrame.editBox)
          columnFrame.editBoxSave:SetPoint("RIGHT", columnFrame.editBox, "RIGHT", -30)
          columnFrame.editBoxSave:SetWidth(20)
          columnFrame.editBoxSave:SetHeight(20)
          columnFrame.editBoxSave:SetNormalAtlas("common-icon-checkmark")
          columnFrame.editBoxSave:SetScript("OnClick", function()
            assert(column.onSave ~= nil, "Editable textfield save button clicked but no onSave function is defined!")
            column.text = columnFrame.editBox:GetText()
            column.onSave(columnFrame.editBox:GetText())
            columnFrame.editBoxSave:Hide()
            end)
          columnFrame.editBoxSave:Hide()

          columnFrame.tex = columnFrame:CreateTexture()
          columnFrame.tex:SetPoint("CENTER")
          columnFrame.tex:SetAtlas(column.icon, true)
          columnFrame.tex:SetScale(.5)

          rowFrame.columns[columnIndex] = columnFrame
        end

        columnFrame.data = column
        columnFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
        columnFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
        columnFrame:SetWidth(columnWidth)
        columnFrame:SetScript("OnEnter", function() columnFrame:onEnterHandler(columnFrame) end)
        columnFrame:SetScript("OnLeave", function() columnFrame:onLeaveHandler(columnFrame) end)
        columnFrame:SetScript("OnClick", function() columnFrame:onClickHandler(columnFrame) end)
        if column.icon then
          columnFrame.tex:Hide()
          columnFrame.tex:Show()
          columnFrame.text:SetText("")
          columnFrame.editBox:Hide()
        else
          columnFrame.tex:Hide()
          if column.editable == true then
            columnFrame.text:Hide()
            columnFrame.editBox:Show()
            columnFrame.editBox:SetText(column.text)
          else
            columnFrame.editBox:Hide()
            columnFrame.text:Show()
            columnFrame.text:SetText(column.text)
          end
        end
        columnFrame:Show()

        if column.backgroundColor then
          Utils:SetBackgroundColor(columnFrame, column.backgroundColor.r, column.backgroundColor.g, column.backgroundColor.b, column.backgroundColor.a)
        end

        function columnFrame:onEnterHandler(f)
          rowFrame:onEnterHandler(f)
          if column.onEnter then
            column.onEnter(f)
          end
        end

        function columnFrame:onLeaveHandler(f)
          rowFrame:onLeaveHandler(f)
          if column.onLeave then
            column.onLeave(f)
          end
        end

        function columnFrame:onClickHandler(f)
          rowFrame:onClickHandler(f)
          if column.onClick then
            column:onClick(f)
          end
        end

        offsetX = offsetX + columnWidth
      end)

      if not isStickyRow then
        offsetY = offsetY + rowHeight
      end
    end)

    tableFrame.scrollFrame:SetParent(tableFrame)
    tableFrame.scrollFrame:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", 0, tableFrame.config.header.sticky and -tableFrame.config.header.height or 0)
    tableFrame.scrollFrame:SetPoint("BOTTOMRIGHT", tableFrame, "BOTTOMRIGHT")
    tableFrame.scrollFrame.content:SetSize(offsetX, offsetY)
  end

  tableFrame.scrollFrame:HookScript("OnSizeChanged", function() tableFrame:RenderTable() end)
  tableFrame:RenderTable()
  table.insert(self.TableCollection, tableFrame)
  return tableFrame;
end
