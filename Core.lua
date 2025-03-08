---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

local Data = addon.Data
local Main = addon.Main
local Comms = addon.Comms
local Settings = addon.Settings
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

local Core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0")
addon.Core = Core

_G.OctopalsVerifier = addon

function Core:Render()
  Main:Render()
  Settings:Render()
end

function Core:OnInitialize()
  _G["BINDING_NAME_OCTOPALS_VERIFIER"] = "Show/Hide the window"
  self:RegisterChatCommand("octo", function() Main:ToggleWindow() end)
  self:RegisterChatCommand("waauditor", function() Main:ToggleWindow() end)

  Data:InitDB()

  local OVLDB = LibDataBroker:NewDataObject(addonName, {
    label = addonName,
    type = "launcher",
    icon = "Interface/AddOns/OctopalsVerifier/Media/Icon.blp",
    OnClick = function(...)
      Main:ToggleWindow()
    end,
    OnTooltipShow = function(tooltip)
      tooltip:SetText(addonName, 1, 1, 1)
      tooltip:AddLine("|cff00ff00Click|r to open OctopalsVerifier.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      local dragText = "|cff00ff00Drag|r to move this icon"
      if Data.db.global.minimap.lock then
        dragText = dragText .. " |cffff0000(locked)|r"
      end
      tooltip:AddLine(dragText .. ".", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end
  })
  LibDBIcon:Register(addonName, OVLDB, Data.db.global.minimap)
  LibDBIcon:AddButtonToCompartment(addonName)

  self:Render()
end

function Core:OnEnable()
  self:RegisterEvent("PLAYER_REGEN_DISABLED", function()
    Data.cache.inCombat = true
    self:Render()
  end)
  self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    Data.cache.inCombat = false
    self:Render()
  end)
  self:RegisterComm("OCTOPALS_REP", function(prefix, text, _, sender)
    Comms.processV1Message(sender, text)
    self:Render()
  end)
  self:RegisterComm("OCTOPALS_REP2", function(prefix, text, _, sender)
    Comms.processV2Message(sender, text)
    self:Render()
  end)
  self:RegisterComm("OCTOPALS_REP3", function(prefix, text, _, sender)
    Comms.processV3Message(sender, text)
    self:Render()
  end)

  self:Render()
end

function Core:OnDisable()
  self:UnregisterAllEvents()
  self:UnregisterAllBuckets()
end
