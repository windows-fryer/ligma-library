-- CONSTANTS --
NO_DEBUG_OUTPUT = false
THEMES = {
    Dark: {
        primary: "#6a1b9a",
        primary_light: "#9c4dcc",
        primary_dark: "#38006b",
        secondary: "#212121",
        secondary_light: "#484848",
        secondary_dark: "#000000"
    },
    Light: {
        primary: "#6a1b9a",
        primary_light: "#9c4dcc",
        primary_dark: "#38006b",
        secondary: "#fafafa",
        secondary_light: "#ffffff",
        secondary_dark: "#c7c7c7"
    },
    -- Append more themes here.
}

-- GLOBAL VARIABLES --
services = setmetatable({}, {
    __index: (key) =>
        @cache = {} unless cache
        @cache[key] = game\GetService(key) unless @cache[key]

        assert(@cache[key])

        return @cache[key]
})

constants = {
    camera: services["Workspace"].CurrentCamera
}

log = (message, ...) ->
    warn(message, ...) unless NO_DEBUG_OUTPUT

-- CLASSES --
class object
    new: (type, attributes = {}) =>
        


class window
    new: (parent, title, size, position) =>
        debug.profilebegin("window:new")

        assert(parent)

        @library = parent
        @objects = {}

class library
    new: () =>
        debug.setmemorycategory("library")
        debug.profilebegin("library:new")

        @objects = {}

        debug.profileend()

    new_window: (title = "Window", size = Vector2.new(500, 600), position = Vector2.new(0, 0)) =>
        debug.profilebegin("library:new_window")

        @objects[#@objects + 1] = window(@, title, size, position)

        debug.profileend()

        return @objects[#@objects]

-- MAIN ROUTINE --

return library!