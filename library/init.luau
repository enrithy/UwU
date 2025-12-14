local UserInputService = cloneref(game:GetService('UserInputService'))
local HttpService = cloneref(game:GetService('HttpService'))
local Players = cloneref(game:GetService('Players'))

local Connections = {}
local Config, Fetcher = {}, {}

local Fluent = loadstring(game:HttpGet('https://raw.githubusercontent.com/enrithy/UwU/refs/heads/main/library/util/interface.luau'))()

local function save_config()
    if not isfolder(`UwU`) then
        makefolder(`UwU`)
    end

    if not isfolder(`UwU/configs`) then
        makefolder(`UwU/configs`)
    end

    if not isfile(`UwU/configs/{game.PlaceId}.json`) then
        writefile(`UwU/configs/{game.PlaceId}.json`, HttpService:JSONEncode({}))
    end

    for index, value in pairs(Connections) do
        Config[index] = type(value) == 'table' and HttpService:JSONDecode(HttpService:JSONEncode(value)) or value
    end

    pcall(function()
        writefile(`UwU/configs/{game.PlaceId}.json`, HttpService:JSONEncode(Config))
    end)
end

local function fetcher_config()
    if not isfolder(`UwU`) or not isfile(`UwU/configs/{game.PlaceId}.json`) then
        save_config()
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(`UwU/configs/{game.PlaceId}.json`))
    end)

    if success then
        Fetcher = data

        for index, value in pairs(Fetcher) do
            Connections[index] = value
        end
    else
        Fetcher = {}
    end

    return Fetcher
end

local Window = Fluent:CreateWindow({
    Title = 'UwU',
    SubTitle = '.gg/uwurbx',
    TabWidth = 107,
    Size = UDim2.fromOffset(467, 346),
    Acrylic = false,
    Theme = 'Darker',
    MinimizeKey = Enum.KeyCode.End
})

local mobile_button_ui = Instance.new('ImageButton')
local mobile_hidden_gui = Instance.new('ScreenGui')

mobile_hidden_gui.Enabled = UserInputService.TouchEnabled
mobile_hidden_gui.Parent = Players.LocalPlayer.PlayerGui
mobile_hidden_gui.ResetOnSpawn = false

mobile_button_ui.Position = UDim2.new(0, 50, 0, 50)
mobile_button_ui.Image = 'rbxassetid://10723346959'
mobile_button_ui.Size = UDim2.new(0, 44, 0, 44)
mobile_button_ui.Parent = mobile_hidden_gui
mobile_button_ui.BackgroundTransparency = 1
mobile_button_ui.Draggable = true

mobile_button_ui.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local function callback(property, callback)
    return function(value)
        Connections[property] = value
        save_config()

        task.spawn(callback, value)
    end
end

local function create_signal(signal)
    function signal:create_button(button)
        return signal:AddButton({
            Title = button.title or '',
            Description = button.description or '',
            Callback = button.callback or (function() end)
        })
    end

    function signal:create_paragraph(paragraph)
        return signal:AddParagraph({
            Title = paragraph.title or '',
            Content = paragraph.content or ''
        })
    end

    function signal:create_dialog(dialog)
        return Window:Dialog({
            Title = dialog.title or '',
            Content = dialog.content or '',
            Buttons = dialog.buttons or {}
        })
    end

    function signal:create_toggle(connection, toggle)
        toggle.flag = toggle.flag or connection

        toggle.default = toggle.default or false
        toggle.callback = toggle.callback or (function() end)

        if not fetcher_config()[toggle.flag] and not Connections[toggle.flag] then
            Connections[toggle.flag] = toggle.default
        end

        toggle.default = fetcher_config()[toggle.flag] or Connections[toggle.flag]
        toggle.callback = callback(toggle.flag, toggle.callback)

        return signal:AddToggle(connection, {
            Title = toggle.title or '',
            Description = toggle.description or '',
            Default = toggle.default,
            flag = toggle.flag,
            Callback = toggle.callback
        })
    end

    function signal:create_keybind(connection, keybind)
        keybind.flag = keybind.flag or connection

        keybind.default = keybind.default or 'E'
        keybind.callback = keybind.callback or (function() end)

        if not fetcher_config()[keybind.flag] and not Connections[keybind.flag] then
            Connections[keybind.flag] = keybind.default
        end

        keybind.default = fetcher_config()[keybind.flag] or Connections[keybind.flag]
        keybind.callback = callback(keybind.flag, keybind.callback)

        return signal:AddKeybind(connection, {
            Title = keybind.title or '',
            Description = keybind.description or '',
            Mode = keybind.mode or 'Toggle',
            Default = keybind.default,
            flag = keybind.flag,
            Callback = keybind.callback
        })
    end

    function signal:create_dropdown(connection, dropdown)
        dropdown.flag = dropdown.flag or connection

        dropdown.options = dropdown.options or {}
        dropdown.multi = dropdown.multi or false
        dropdown.default = dropdown.default or 1
        dropdown.callback = dropdown.callback or (function() end)

        if dropdown.multi and not fetcher_config()[dropdown.flag] and not Connections[dropdown.flag] then
            Connections[dropdown.flag] = {}

            for _, value in pairs(dropdown.options) do
                Connections[dropdown.flag][value] = false
            end
        elseif not fetcher_config()[dropdown.flag] and not Connections[dropdown.flag] then
            Connections[dropdown.flag] = dropdown.default
        end

        dropdown.default = fetcher_config()[dropdown.flag] or Connections[dropdown.flag]
        dropdown.callback = callback(dropdown.flag, dropdown.callback)

        return signal:AddDropdown(connection, {
            Title = dropdown.title or '',
            Description = dropdown.description or '',
            Values = dropdown.options,
            Multi = dropdown.multi,
            Default = dropdown.default,
            flag = dropdown.flag,
            Callback = dropdown.callback
        })
    end

    function signal:create_slider(connection, slider)
        slider.flag = slider.flag or connection

        slider.default = slider.default or 0
        slider.callback = slider.callback or (function() end)

        if not fetcher_config()[slider.flag] and not Connections[slider.flag] then
            Connections[slider.flag] = slider.default
        end

        slider.default = fetcher_config()[slider.flag] or Connections[slider.flag]
        slider.callback = callback(slider.flag, slider.callback)

        return signal:AddSlider(connection, {
            Title = slider.title or '',
            Description = slider.description or '',
            Min = slider.min or 0,
            Max = slider.max or 100,
            Default = slider.default,
            Rounding = slider.rounding or 1,
            flag = slider.flag,
            Callback = slider.callback
        })
    end

    function signal:create_input(connection, input)
        input.flag = input.flag or connection

        input.default = input.default or ''
        input.callback = input.callback or (function() end)

        if not fetcher_config()[input.flag] and not Connections[input.flag] then
            Connections[input.flag] = input.default
        end

        input.default = fetcher_config()[input.flag] or Connections[input.flag]
        input.callback = callback(input.flag, input.callback)

        return signal:AddInput(connection, {
            Title = input.title or '',
            Description = input.description or '',
            Default = input.default,
            Placeholder = input.place or '',
            Numeric = input.numeric or false,
            Finished = input.finished or false,
            flag = input.flag,
            Callback = input.callback
        })
    end

    return signal
end

function Window:create_tab(tab_name, icon)
    local tab = Window:AddTab({ Title = tab_name or '', Icon = icon or '' })
    create_signal(tab)

    function tab:create_section(name)
        local section = tab:AddSection(name or '')
        create_signal(section)

        return section
    end

    return tab
end

function Window:notify(index)
    Fluent:Notify({
        Title = index.title or '',
        Content = index.content or '',
        Duration = index.duration or 3
    })
end

function Window:select_tab(index)
    return Window:SelectTab(index)
end

return Window, Connections
