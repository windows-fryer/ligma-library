local NO_DEBUG_OUTPUT = false
local THEMES = {
  Dark = {
    primary = "#6a1b9a",
    primary_light = "#9c4dcc",
    primary_dark = "#38006b",
    secondary = "#212121",
    secondary_light = "#484848",
    secondary_dark = "#000000"
  },
  Light = {
    primary = "#6a1b9a",
    primary_light = "#9c4dcc",
    primary_dark = "#38006b",
    secondary = "#fafafa",
    secondary_light = "#ffffff",
    secondary_dark = "#c7c7c7"
  }
}
local services = setmetatable({ }, {
  __index = function(self, key)
    if not (cache) then
      self.cache = { }
    end
    if not (self.cache[key]) then
      self.cache[key] = game:GetService(key)
    end
    assert(self.cache[key])
    return self.cache[key]
  end
})
local constants = {
  camera = services["Workspace"].CurrentCamera
}
local log
log = function(message, ...)
  if not (NO_DEBUG_OUTPUT) then
    return warn(message, ...)
  end
end
local window
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent, title, size, position)
      debug.profilebegin("window:new")
      assert(parent)
      self.library = parent
      self.objects = { }
    end,
    __base = _base_0,
    __name = "window"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  window = _class_0
end
local library
do
  local _class_0
  local _base_0 = {
    new_window = function(self, title, size, position)
      if title == nil then
        title = "Window"
      end
      if size == nil then
        size = Vector2.new(500, 600)
      end
      if position == nil then
        position = Vector2.new(0, 0)
      end
      debug.profilebegin("library:new_window")
      self.objects[#self.objects + 1] = window(self, title, size, position)
      debug.profileend()
      return self.objects[#self.objects]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      debug.setmemorycategory("library")
      debug.profilebegin("library:new")
      self.objects = { }
      return debug.profileend()
    end,
    __base = _base_0,
    __name = "library"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  library = _class_0
end
return library()
