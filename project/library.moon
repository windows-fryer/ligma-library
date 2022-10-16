-- CONSTANTS --
NO_DEBUG_OUTPUT = true
NO_DEBUG_LOG = false
THEMES = {
    Dark: {
        primary: "#6a1b9a",
        primary_light: "#9c4dcc",
        primary_dark: "#38006b",
        secondary: "#141414",
        secondary_light: "#1e1e1e",
        secondary_dark: "#0c0c0c"
    },
    Light: {
        primary: "#6a1b9a",
        primary_light: "#9c4dcc",
        primary_dark: "#38006b",
        secondary: "#e6e6e6",
        secondary_light: "#ffffff",
        secondary_dark: "#c7c7c7"
    },
    -- Append more themes here.
}
(->
    for _, theme in next, THEMES do
        theme.primary = Color3.fromHex(theme.primary)
        theme.primary_light = Color3.fromHex(theme.primary_light)
        theme.primary_dark = Color3.fromHex(theme.primary_dark)
        theme.secondary = Color3.fromHex(theme.secondary)
        theme.secondary_light = Color3.fromHex(theme.secondary_light)
        theme.secondary_dark = Color3.fromHex(theme.secondary_dark)
)()
ZINDEX = {
    ["background"]: 100
}
CURSOR = Vector2.zero
EXECUTION_TIMESTAMP = os.time()
EXECUTION_DIRECTORY = "#{os.date("%Y", EXECUTION_TIMESTAMP)}/#{os.date("%B", EXECUTION_TIMESTAMP)}/#{os.date("%a%d", EXECUTION_TIMESTAMP)}.txt"

makefolder("#{os.date("%Y", EXECUTION_TIMESTAMP)}/")
makefolder("#{os.date("%Y", EXECUTION_TIMESTAMP)}/#{os.date("%B", EXECUTION_TIMESTAMP)}/")
writefile(EXECUTION_DIRECTORY, "Execution Log for #{os.date("%a %d %X", EXECUTION_TIMESTAMP)}\n")

-- GLOBAL VARIABLES --
services = setmetatable({}, {
    __index: (key) =>
        @cache = {} unless rawget(@, cache)
        @cache[key] = game\GetService(key) unless @cache[key]

        assert(@cache[key])

        return @cache[key]
})

constants = {
    camera: services["Workspace"].CurrentCamera
}

log = (message) ->
    debug.profilebegin("::log")

    services["TestService"]\Message(message) unless NO_DEBUG_OUTPUT
    appendfile(EXECUTION_DIRECTORY, "[#{os.date("%X", os.time())}] #{message}\n") unless NO_DEBUG_LOG

    debug.profileend()

offset = (offset) ->
    debug.profilebegin("::offset")

    CURSOR += offset

    debug.profileend()

    return CURSOR

guid = () ->
    debug.profilebegin("::guid")

    buffer_guid = services["HttpService"]\GenerateGUID(false)

    log("Generated GUID: #{buffer_guid}")

    debug.profileend()

    return buffer_guid

inside = (point, bounds, size, roblox = false) ->
    point = Vector2.new(point.X, point.Y) if typeof(point) == "Vector3"
    point += services["GuiService"]\GetGuiInset() if roblox

    return point.X >= bounds.X and point.X <= bounds.X + size.X and point.Y >= bounds.Y and point.Y <= bounds.Y + size.Y

-- CLASSES --
class drawing
    new: (parent, type, attributes = {}) =>
        debug.profilebegin("drawing:new")

        @id = guid()
        @parent = parent
        @object = Drawing.new(type) -- Not offically deprecated in synapse v3, but it most likely will be.
        @cursor_offset = CURSOR

        for attribute, value in next, attributes
            @object[attribute] = value

        @parent.library.objects[@id] = @

        debug.profileend()

    update: (attributes = {}) =>
        debug.profilebegin("drawing:update")

        @object["Position"] = @parent.position + @cursor_offset

        for attribute, value in next, attributes
            @object[attribute] = value

        debug.profileend()

    interactable: (callback = (-> assert(false)), state = true) =>
        debug.profilebegin("drawing:interactable")

        @parent.interactable[@id] = callback

        if (not state)
            @parent.interactable[@id] = nil
        
        debug.profileend()

    destroy: () =>
        debug.profilebegin("drawing:destroy")

        @object.Remove()
        @object = nil
        @ = nil

        debug.profileend()

class tab

class window
    new: (parent, title, size, position) =>
        debug.profilebegin("window:new")

        assert(parent)

        log("Creating new window: #{title}")

        @library = parent
        @window = @

        @title = title
        @size = size
        @position = position
        @theme = THEMES.Dark
        
        @dragging = false
        @dragging_offset = Vector2.zero
        @ignore_dragging = false
        
        @objects = {
            ["background"]: drawing(@, "Square", {
                ["Visible"]: true,
                ["ZIndex"]: ZINDEX.background,
                ["Transparency"]: 1,
                ["Color"]: @theme.secondary,
                ["Thickness"]: 0,
                ["Size"]: @size,
                ["Position"]: position + offset(Vector2.zero),
                ["Filled"]: true
            }),
            ["border"]: drawing(@, "Square", {
                ["Visible"]: true,
                ["ZIndex"]: ZINDEX.background,
                ["Transparency"]: 1,
                ["Color"]: @theme.secondary_light,
                ["Thickness"]: 0,
                ["Size"]: @size,
                ["Position"]: position + offset(Vector2.zero),
                ["Filled"]: false
            })
        }

        @tabs = {}

        input_began = (input) ->
            debug.profilebegin("window:input_began")

            if (input.UserInputType == Enum.UserInputType.MouseButton1)
                if (inside(input.Position, @objects["background"].object.Position, @objects["background"].object.Size, true) and not ignore_dragging)
                    @dragging = true
                    @dragging_offset = Vector2.new(input.Position.X, input.Position.Y)

            debug.profileend()

        input_changed = (input) ->
            debug.profilebegin("window:input_changed")

            if (input.UserInputType == Enum.UserInputType.MouseMovement)
                if (@dragging)
                    position = Vector2.new(input.Position.X, input.Position.Y)

                    @position += position - @dragging_offset
                    @dragging_offset = position

                    for _, object in next, @objects
                        object\update()

            debug.profileend()

        input_ended = (input) ->
            debug.profilebegin("window:input_ended")

            if (input.UserInputType == Enum.UserInputType.MouseButton1)
                @dragging = false
                @dragging_offset = Vector2.zero

            debug.profileend()

        @library.connections[guid()] = services["UserInputService"].InputBegan\Connect(input_began)
        @library.connections[guid()] = services["UserInputService"].InputChanged\Connect(input_changed)
        @library.connections[guid()] = services["UserInputService"].InputEnded\Connect(input_ended)

        debug.profileend()

class library
    new: () =>
        debug.setmemorycategory("library")
        debug.profilebegin("library:new")

        log("Initializing library...")

        @windows = {}
        @objects = {} -- Global list of all objects. Used for unloading.
        @connections = {} -- Global list of all connections. Used for unloading.

        debug.profileend()

    new_window: (title = "Window", size = Vector2.new(500, 600), position = Vector2.new(0, 0)) =>
        debug.profilebegin("library:new_window")

        log("Creating new window...")

        window_guid = guid()

        @windows[window_guid] = window(@, title, size, position)

        debug.profileend()

        return @windows[window_guid]

    unload: () =>
        debug.profilebegin("library:unload")

        log("Unloading library...")

        for _, connection in next, @connections
            connection\Disconnect()

        for _, object in next, @objects
            object\destroy()

        getgenv().library = nil

        debug.profileend()

-- MAIN ROUTINE --

getgenv().library\unload() if getgenv().library

current_library = library!

current_window = current_library\new_window("Test Window", Vector2.new(500, 600), (constants.camera.ViewportSize / 2) - Vector2.new(250, 300))

getgenv().library = current_library

return current_library