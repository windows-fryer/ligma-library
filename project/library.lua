local NO_DEBUG_OUTPUT = true
local NO_DEBUG_LOG = false
local THEMES = {
  Dark = {
    primary = "#6a1b9a",
    primary_light = "#9c4dcc",
    primary_dark = "#38006b",
    secondary = "#141414",
    secondary_light = "#1e1e1e",
    secondary_dark = "#0c0c0c"
  },
  Light = {
    primary = "#6a1b9a",
    primary_light = "#9c4dcc",
    primary_dark = "#38006b",
    secondary = "#e6e6e6",
    secondary_light = "#ffffff",
    secondary_dark = "#c7c7c7"
  }
}
(function()
  for _, theme in next,THEMES do
    theme.primary = Color3.fromHex(theme.primary)
    theme.primary_light = Color3.fromHex(theme.primary_light)
    theme.primary_dark = Color3.fromHex(theme.primary_dark)
    theme.secondary = Color3.fromHex(theme.secondary)
    theme.secondary_light = Color3.fromHex(theme.secondary_light)
    theme.secondary_dark = Color3.fromHex(theme.secondary_dark)
  end
end)()
local ZINDEX = {
  ["background"] = 100
}
local CURSOR = Vector2.zero
local EXECUTION_TIMESTAMP = os.time()
local EXECUTION_DIRECTORY = tostring(os.date("%Y", EXECUTION_TIMESTAMP)) .. "/" .. tostring(os.date("%B", EXECUTION_TIMESTAMP)) .. "/" .. tostring(os.date("%a%d", EXECUTION_TIMESTAMP)) .. ".txt"
makefolder(tostring(os.date("%Y", EXECUTION_TIMESTAMP)) .. "/")
makefolder(tostring(os.date("%Y", EXECUTION_TIMESTAMP)) .. "/" .. tostring(os.date("%B", EXECUTION_TIMESTAMP)) .. "/")
writefile(EXECUTION_DIRECTORY, "Execution Log for " .. tostring(os.date("%a %d %X", EXECUTION_TIMESTAMP)) .. "\n")
local services = setmetatable({ }, {
  __index = function(self, key)
    if not (rawget(self, cache)) then
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
log = function(message)
  debug.profilebegin("::log")
  if not (NO_DEBUG_OUTPUT) then
    services["TestService"]:Message(message)
  end
  if not (NO_DEBUG_LOG) then
    appendfile(EXECUTION_DIRECTORY, "[" .. tostring(os.date("%X", os.time())) .. "] " .. tostring(message) .. "\n")
  end
  return debug.profileend()
end
local offset
offset = function(offset)
  debug.profilebegin("::offset")
  CURSOR = CURSOR + offset
  debug.profileend()
  return CURSOR
end
local guid
guid = function()
  debug.profilebegin("::guid")
  local buffer_guid = services["HttpService"]:GenerateGUID(false)
  log("Generated GUID: " .. tostring(buffer_guid))
  debug.profileend()
  return buffer_guid
end
local inside
inside = function(point, bounds, size, roblox)
  if roblox == nil then
    roblox = false
  end
  if typeof(point) == "Vector3" then
    point = Vector2.new(point.X, point.Y)
  end
  if roblox then
    point = point + services["GuiService"]:GetGuiInset()
  end
  return point.X >= bounds.X and point.X <= bounds.X + size.X and point.Y >= bounds.Y and point.Y <= bounds.Y + size.Y
end
local drawing
do
  local _class_0
  local _base_0 = {
    update = function(self, attributes)
      if attributes == nil then
        attributes = { }
      end
      debug.profilebegin("drawing:update")
      self.object["Position"] = self.parent.position + self.cursor_offset
      for attribute, value in next,attributes do
        self.object[attribute] = value
      end
      return debug.profileend()
    end,
    interactable = function(self, callback, state)
      if callback == nil then
        callback = (function()
          return assert(false)
        end)
      end
      if state == nil then
        state = true
      end
      debug.profilebegin("drawing:interactable")
      self.parent.interactable[self.id] = callback
      if (not state) then
        self.parent.interactable[self.id] = nil
      end
      return debug.profileend()
    end,
    destroy = function(self)
      debug.profilebegin("drawing:destroy")
      self.object.Remove()
      self.object = nil
      self = nil
      return debug.profileend()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent, type, attributes)
      if attributes == nil then
        attributes = { }
      end
      debug.profilebegin("drawing:new")
      self.id = guid()
      self.parent = parent
      self.object = Drawing.new(type)
      self.cursor_offset = CURSOR
      for attribute, value in next,attributes do
        self.object[attribute] = value
      end
      self.parent.library.objects[self.id] = self
      return debug.profileend()
    end,
    __base = _base_0,
    __name = "drawing"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  drawing = _class_0
end
local tab
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "tab"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  tab = _class_0
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
      log("Creating new window: " .. tostring(title))
      self.library = parent
      self.window = self
      self.title = title
      self.size = size
      self.position = position
      self.theme = THEMES.Dark
      self.dragging = false
      self.dragging_offset = Vector2.zero
      self.ignore_dragging = false
      self.objects = {
        ["background"] = drawing(self, "Square", {
          ["Visible"] = true,
          ["ZIndex"] = ZINDEX.background,
          ["Transparency"] = 1,
          ["Color"] = self.theme.secondary,
          ["Thickness"] = 0,
          ["Size"] = self.size,
          ["Position"] = position + offset(Vector2.zero),
          ["Filled"] = true
        }),
        ["border"] = drawing(self, "Square", {
          ["Visible"] = true,
          ["ZIndex"] = ZINDEX.background,
          ["Transparency"] = 1,
          ["Color"] = self.theme.secondary_light,
          ["Thickness"] = 0,
          ["Size"] = self.size,
          ["Position"] = position + offset(Vector2.zero),
          ["Filled"] = false
        })
      }
      self.tabs = { }
      local input_began
      input_began = function(input)
        debug.profilebegin("window:input_began")
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
          if (inside(input.Position, self.objects["background"].object.Position, self.objects["background"].object.Size, true) and not ignore_dragging) then
            self.dragging = true
            self.dragging_offset = Vector2.new(input.Position.X, input.Position.Y)
          end
        end
        return debug.profileend()
      end
      local input_changed
      input_changed = function(input)
        debug.profilebegin("window:input_changed")
        if (input.UserInputType == Enum.UserInputType.MouseMovement) then
          if (self.dragging) then
            position = Vector2.new(input.Position.X, input.Position.Y)
            self.position = self.position + (position - self.dragging_offset)
            self.dragging_offset = position
            for _, object in next,self.objects do
              object:update()
            end
          end
        end
        return debug.profileend()
      end
      local input_ended
      input_ended = function(input)
        debug.profilebegin("window:input_ended")
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
          self.dragging = false
          self.dragging_offset = Vector2.zero
        end
        return debug.profileend()
      end
      self.library.connections[guid()] = services["UserInputService"].InputBegan:Connect(input_began)
      self.library.connections[guid()] = services["UserInputService"].InputChanged:Connect(input_changed)
      self.library.connections[guid()] = services["UserInputService"].InputEnded:Connect(input_ended)
      return debug.profileend()
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
      log("Creating new window...")
      local window_guid = guid()
      self.windows[window_guid] = window(self, title, size, position)
      debug.profileend()
      return self.windows[window_guid]
    end,
    unload = function(self)
      debug.profilebegin("library:unload")
      log("Unloading library...")
      for _, connection in next,self.connections do
        connection:Disconnect()
      end
      for _, object in next,self.objects do
        object:destroy()
      end
      getgenv().library = nil
      return debug.profileend()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      debug.setmemorycategory("library")
      debug.profilebegin("library:new")
      log("Initializing library...")
      self.windows = { }
      self.objects = { }
      self.connections = { }
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
if getgenv().library then
  getgenv().library:unload()
end
local current_library = library()
local current_window = current_library:new_window("Test Window", Vector2.new(500, 600), (constants.camera.ViewportSize / 2) - Vector2.new(250, 300))
getgenv().library = current_library
return current_library
