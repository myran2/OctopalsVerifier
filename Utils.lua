---@type string
local addonName = select(1, ...)
---@class WK_Addon
local addon = select(2, ...)

---@class WK_Utils
local Utils = {}
addon.Utils = Utils

---Set the background color for a parent frame
---@param parent any
---@param r number?
---@param g number?
---@param b number?
---@param a number?
function Utils:SetBackgroundColor(parent, r, g, b, a)
  if not parent.Background then
    parent.Background = parent:CreateTexture("Background", "BACKGROUND")
    parent.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
    parent.Background:SetAllPoints()
  end

  if type(r) == "table" then
    r, g, b, a = r.a, r.g, r.b, r.a
  end

  if type(r) == nil then
    r, g, b, a = 0, 0, 0, 0.1
  end

  parent.Background:SetVertexColor(r, g, b, a)
end

---Set the highlight color for a parent frame
---@param parent any
---@param r number?
---@param g number?
---@param b number?
---@param a number?
function Utils:SetHighlightColor(parent, r, g, b, a)
  if not parent.Highlight then
    parent.Highlight = parent:CreateTexture("Highlight", "OVERLAY")
    parent.Highlight:SetTexture("Interface/BUTTONS/WHITE8X8")
    parent.Highlight:SetAllPoints()
  end

  if type(r) == "table" then
    r, g, b, a = r.a, r.g, r.b, r.a
  end

  if type(r) == nil then
    r, g, b, a = 1, 1, 1, 0.1
  end

  parent.Highlight:SetVertexColor(r, g, b, a)
end

---Find a table item by callback
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): boolean
---@return T|nil, number|nil
function Utils:TableFind(tbl, callback)
  for i, v in pairs(tbl) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil, nil
end

---Find a table item by key and value
---@generic T
---@param tbl T[]
---@param key string
---@param val any
---@return T|nil
function Utils:TableGet(tbl, key, val)
  return self:TableFind(tbl, function(elm)
    return elm[key] and elm[key] == val
  end)
end

---Create a new table containing all elements that pass truth test
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): boolean
---@return T[]
function Utils:TableFilter(tbl, callback)
  local t = {}
  for i, v in pairs(tbl) do
    if callback(v, i) then
      table.insert(t, v)
    end
  end
  return t
end

---Count table items
---@param tbl table
---@return number
function Utils:TableCount(tbl)
  local n = 0
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
end

---Deep copy a table
---@generic T
---@param tbl T[]
---@param cache table?
---@return T[]
function Utils:TableCopy(tbl, cache)
  local t = {}
  cache = cache or {}
  cache[tbl] = t
  self:TableForEach(tbl, function(v, k)
    if type(v) == "table" then
      t[k] = cache[v] or self:TableCopy(v, cache)
    else
      t[k] = v
    end
  end)
  return t
end

---Map each item in a table
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): any
---@return T[]
function Utils:TableMap(tbl, callback)
  local t = {}
  self:TableForEach(tbl, function(v, k)
    local newv, newk = callback(v, k)
    t[newk and newk or k] = newv
  end)
  return t
end

---Run a callback on each table item
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number)
---@return T[]
function Utils:TableForEach(tbl, callback)
  assert(tbl, "Must be a table!")
  for ik, iv in pairs(tbl) do
    callback(iv, ik)
  end
  return tbl
end

--Swap provided indeces in the provided table
---@generic T
---@param tbl T[]
---@param index1 number
---@param index2 number
---@return T[]
function Utils:TableSwap(tbl, index1, index2)
  tbl[index1], tbl[index2] = tbl[index2], tbl[index1]
  return tbl
end

-- Split a string into a table by a seperator
---@param text string
---@param sep string
---@return table
function Utils:ExplodeString(text, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(text, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

--- from https://wowwiki-archive.fandom.com/wiki/USERAPI_StringHash
---@param text string the text to be hashed
---@return number numeric hash of the text
function Utils:StringHash(text)
  local counter = 1
  local len = string.len(text)
  for i = 1, len, 3 do
    counter = math.fmod(counter * 8161, 4294967279) + -- 2^32 - 17: Prime!
      (string.byte(text, i) * 16776193) +
      ((string.byte(text, i + 1) or (len - i + 256)) * 8372226) +
      ((string.byte(text, i + 2) or (len - i + 256)) * 3932164)
  end
  return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end

--- from https://github.com/WeakAuras/WeakAuras2/blob/main/WeakAuras/AuraEnvironment.lua#L52C1-L66C4
function Utils:IterateGroupMembers(reversed, forceParty)
  local unit = (not forceParty and IsInRaid()) and "raid" or "party"
  local numGroupMembers = unit == "party" and GetNumSubgroupMembers() or GetNumGroupMembers()
  local i = reversed and numGroupMembers or (unit == "party" and 0 or 1)
  return function()
    local ret
    if i == 0 and unit == "party" then
      ret = "player"
    elseif i <= numGroupMembers and i > 0 then
      ret = unit .. i
    end
    i = i + (reversed and -1 or 1)
    return ret
  end
end
