local Controls   = require "necro.config.Controls"
local Entities   = require "system.game.Entities"
local Event      = require "necro.event.Event"
local Menu       = require "necro.menu.Menu"
local TextFormat = require "necro.config.i18n.TextFormat"
local UI         = require "necro.render.UI"
local Utilities  = require "system.utils.Utilities"

local MMHelper = require "MenuMod.Helper"

local NixLib = require "NixLib.NixLib"

local Text = require "DebugMenu.i18n.Text"

Event.menu.add("menuComponentList", "DebugMenu_componentList", function(ev)
  --[[ev.arg format:
  {
    components = nil or {} -- list of names
  }
  ]]

  local menu = {}
  local entries = {}
  local components = {}

  local search = ev.searchText or ""

  entries[#entries + 1] = {
    id = "_controlHint",
    label = string.format("%s: View component (if non-marker) | %s: Print component to log",
      Controls.getFriendlyMiscKeyBind(Controls.Misc.SELECT), Controls.getFriendlyMiscKeyBind(Controls.Misc.SELECT_2)),
    font = UI.Font.SMALL
  }

  if ev.arg.components then
    components = Utilities.map(ev.arg.components, NixLib.getComponent)
  else
    for k, v in Utilities.sortedPairs(NixLib.getComponents()) do
      components[#components + 1] = v
    end
  end

  for i, v in ipairs(components) do
    local name = v.name

    if name:lower():find(search:lower(), 1, true) then
      local entry = {
        id = "component_" .. name,
        label = name
      }

      if v.fields[1] then
        entry.action = function()
          Menu.open("DebugMenu_componentViewer", {
            component = v
          })
        end
        entry.specialAction = function()
          log.info(v)
        end
      end

      entries[#entries + 1] = entry
    end
  end

  entries[#entries + 1] = {
    height = 0,
    searchImmunity = true
  }

  entries[#entries + 1] = {
    id = "_done",
    label = Text.Menu.Close,
    action = Menu.close,
    searchImmunity = true
  }

  menu.entries = entries
  menu.label = Text.Menu.ComponentList.Title
  menu.escapeAction = Menu.close
  menu.searchable = true
  ev.menu = menu
end)
