-- Gamesense UI Library Framework
-- Extracted and modularized for building custom UIs.

local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Client = Players.LocalPlayer
local Camera = Workspace:FindFirstChildWhichIsA("Camera")
local Viewport = Camera.ViewportSize

do -- Folders
    if not isfolder("gamesense") then makefolder("gamesense") end
    if not isfolder("gamesense/Configs") then makefolder("gamesense/Configs") end
end

local Gamesense = {
    Connections = {}, Errors = {}, Tweens = {}, Objects = {},
    Sections = {}, ThemeSections = {}, Flags = {},
    UnnamedFlags = 0, Build = "Beta", UID = "1",
    UnsafeMode = false, InitTime = os.clock(),
    Folder = "gamesense", ConfigFolder = "gamesense/Configs",
    UI = {
        Name = "gamesense", CloseBind = Enum.KeyCode.Insert,
        SectionResizeIncrements = 1, WatermarkRefreshRate = 1,
        MainUI = nil, Initialized = false, Faded = false,
        LastCopiedColor = nil, TabIndex = 0, Viewing = false,
        CurrentSelectedColorPicker = nil, CurrentSelectedColorPickerExtra = nil,
        CurrentSelectedKeybindMode = nil, TotalColorPickers = 0, TotalKeybindModes = 0,
        WatermarkPosition = "Top Right", SectionZIndex = 100, Resizing = false,
        DropdownZIndex = 1, OpenColorFrames = 0, ScreenGUI = nil, TweenSpeed = 0.15,
        NewFont = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        FontSize = 13, DraggingGui = nil,
        Notifications = {TopLeft = {}, Middle = {}},
        Keys = {
            [Enum.KeyCode.LeftShift] = "LSHF", [Enum.KeyCode.RightShift] = "RSHF",
            [Enum.KeyCode.LeftControl] = "LCTR", [Enum.KeyCode.RightControl] = "RCTR",
            [Enum.KeyCode.LeftAlt] = "LALT", [Enum.KeyCode.RightAlt] = "RALT",
            [Enum.KeyCode.CapsLock] = "CAPS", [Enum.KeyCode.Space] = "SPCE",
            [Enum.KeyCode.One] = "ONE", [Enum.KeyCode.Two] = "TWO", [Enum.KeyCode.Three] = "THREE",
            [Enum.KeyCode.Four] = "FOUR", [Enum.KeyCode.Five] = "FIVE", [Enum.KeyCode.Six] = "SIX",
            [Enum.KeyCode.Seven] = "SEVEN", [Enum.KeyCode.Eight] = "EIGHT", [Enum.KeyCode.Nine] = "NINE",
            [Enum.KeyCode.Zero] = "ZERO", [Enum.KeyCode.Insert] = "INS", [Enum.UserInputType.MouseButton1] = "M1",
            [Enum.UserInputType.MouseButton2] = "M2", [Enum.UserInputType.MouseButton3] = "M3"
        },
    },
    Theme = {
        Objects = {},
        Default = {
            Accent = Color3.fromRGB(153, 196, 39), SecondAccent = Color3.fromRGB(124, 158, 32),
            TextColor = Color3.fromRGB(205, 205, 205), Risky = Color3.fromRGB(165, 165, 120),
        }
    }
}

function Gamesense:Validate(Defaults, Options)
    for Index, Value in Defaults do
        if Options[Index] == nil then Options[Index] = Value end
    end
    return Options
end

function Gamesense:Connection(Signal, Func, Name, Table)
    Name = Name or "Unknown" Table = Table or Gamesense.Connections
    local Connection; Connection = Signal:Connect(function(...)
        local Args = {...}
        local Success, Message = pcall(function() coroutine.wrap(Func)(unpack(Args)) end)
        if not Success and not Gamesense.Errors[Message] then
            if Gamesense.Notify then Gamesense:Notify({Message = ("[ERROR] | An error has occurred:\n%s\nName: %s"):format(Message, Name), Delay = math.huge}) else warn(Message) end
            Gamesense.Errors[Message] = Message
            if Table[Connection] then Table[Connection] = nil end
            return Connection and Connection:Disconnect()
        end
    end)
    if Connection and Table then table.insert(Table, Connection) end
    return Connection
end

function Gamesense:TweenObject(Object, Info, Goal, Callback)
    if not Object then return end
    local Tween = TweenService:Create(Object, Info, Goal)
    Gamesense:Connection(Tween.Completed, Callback or function() end)
    Tween:Play() Gamesense.Tweens[#Gamesense.Tweens + 1] = Tween
end

function Gamesense:NewFlag()
    Gamesense.UnnamedFlags += 1 return ("UnknownFlag%s"):format(tostring(Gamesense.UnnamedFlags))
end

function Gamesense:ClampString(String, MaxWidth)
    local Clamped = String
    local TextLabel = Gamesense:CreateObject("TextLabel", { FontFace = Gamesense.UI.NewFont, Text = String, Size = UDim2.new(1, 0, 1, 0), Visible = false, TextSize = Gamesense.UI.FontSize, Parent = Client.PlayerGui })
    if TextLabel.TextBounds.X <= MaxWidth then TextLabel:Destroy() return String end
    while TextLabel.TextBounds.X > MaxWidth and #Clamped > 0 do Clamped = Clamped:sub(1, #Clamped - 1) TextLabel.Text = Clamped .. "..." task.wait() end
    TextLabel:Destroy() return Clamped .. "..."
end

-- CONFIG SYSTEM
function Gamesense:GetConfig()
    local Config = {}
    for Index, Value in Gamesense.Flags do
        if Value.Get and not string.find(Index, "_Status") then
            if typeof(Value:Get()) == "table" and Value:Get().Color and Value:Get().Transparency then
                local Transparency = Value:Get().Transparency
                local Hue, Saturation, V = Value:Get().Color:ToHSV()
                Config[Index] = {Hue, Saturation, V, Transparency}
            else Config[Index] = Value:Get() end
        end
    end
    return HttpService:JSONEncode(Config)
end

function Gamesense:LoadConfig(Config)
    local Cfg = HttpService:JSONDecode(Config)
    for Index, Value in Cfg do
        if Gamesense.Flags[Index] and Gamesense.Flags[Index].Set then Gamesense.Flags[Index]:Set(Value) end
    end
end

function Gamesense:UpdateConfigList(List, Type)
    for _, File in listfiles("gamesense/Configs") do
        local FileName = File:gsub("\\", "/"):gsub("gamesense/Configs/", ""):gsub(".cfg", "")
        if Type == "Remove" then List:RemoveValue(FileName) else List:AddValue(FileName) end
    end
end

function Gamesense:SectionDragging(Frame)
    local MousePosition = UserInputService:GetMouseLocation()
    local Position = Frame.AbsolutePosition local Size = Frame.AbsoluteSize
    return MousePosition.X >= Position.X and MousePosition.X <= Position.X + Size.X and MousePosition.Y >= Position.Y and MousePosition.Y <= Position.Y + Size.Y
end

function Gamesense:CreateObject(Type, Properties, Hidden)
    local Object = Instance.new(Type)
    for Index, Value in Properties do
        if (not RunService:IsStudio()) and Index == "Name" and not string.match(Value, "%d") then Value = "\0" end
        if Index == "TextStrokeTransparency" and Value == 0 then
            local Stroke = Instance.new("UIStroke") Stroke.Parent = Object Stroke.LineJoinMode = Enum.LineJoinMode.Miter
            Gamesense.Objects[Stroke] = {Stroke, {Parent = Object, LineJoinMode = Enum.LineJoinMode.Miter}, Hidden or false}
        else Object[Index] = Value end
    end
    Gamesense.Objects[Object] = {Object, Properties, Hidden or false}
    return Object
end

function Gamesense:AddTheme(Object, Properties)
    for Index, Value in Properties do
        Gamesense.Theme.Objects[Object] = Gamesense.Theme.Objects[Object] or {}
        Gamesense.Theme.Objects[Object][Index] = Value
    end
end

function Gamesense:GetObjectsTable(MainUI, AddMain, Ignored)
    local DescendantTable = {} local NewTable = {}
    for _, Descendant in MainUI:GetDescendants() do if not table.find(Ignored or {}, Descendant) then DescendantTable[#DescendantTable + 1] = Descendant end end
    if AddMain then DescendantTable[#DescendantTable + 1] = MainUI end
    for _, Descendant in DescendantTable do
        local Found = Gamesense.Objects[Descendant]
        if Found then NewTable[#NewTable + 1] = {Descendant, Found[2], Found[3]} end
    end
    return NewTable
end

function Gamesense:UpdateColor(ColorType, ColorValue)
    Gamesense.Theme.Default[ColorType] = ColorValue
    for Object, Properties in Gamesense.Theme.Objects do
        for Property, ThemeKeys in Properties do
            if typeof(ThemeKeys) == "table" then
                if Object:IsA("UIGradient") and Property == "Color" and Gamesense.Theme.Default[ThemeKeys[1]] then
                    Object.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Gamesense.Theme.Default[ThemeKeys[1]]), ColorSequenceKeypoint.new(1, Gamesense.Theme.Default[ThemeKeys[2]])}
                end
            elseif ThemeKeys == ColorType then Object[Property] = Gamesense.Theme.Default[ThemeKeys] end
        end
    end
end

function Gamesense:ScrollingCheck(ScrollingFrame, Frame)
    if not ScrollingFrame:IsA("ScrollingFrame") then return true end
    local VisibleTopLeft = ScrollingFrame.CanvasPosition
    local VisibleBottomRight = VisibleTopLeft + ScrollingFrame.AbsoluteWindowSize
    local FrameTopLeft = Frame.AbsolutePosition - ScrollingFrame.AbsolutePosition + ScrollingFrame.CanvasPosition
    local FrameBottomRight = FrameTopLeft + Frame.AbsoluteSize
    return FrameBottomRight.X > VisibleTopLeft.X and FrameTopLeft.X < VisibleBottomRight.X and FrameBottomRight.Y > VisibleTopLeft.Y and FrameTopLeft.Y < VisibleBottomRight.Y
end

function Gamesense:Fade(State, Table, MainUI, Speed)
    MainUI.Active = State
    if State then MainUI.Visible = true end
    if Table == Gamesense.Objects then Gamesense.UI.Faded = not State end
    
    if not State and Table == Gamesense.Objects then
        for _, obj in pairs(MainUI:GetDescendants()) do
            if obj.ClassName == "Frame" and obj.Name == "ToggleMain" then obj.BackgroundTransparency = 1 end
        end
    end
    for _, Object in Table do
        if not Object[3] then
            if Object[1].ClassName == "Frame" or Object[1].ClassName == "ScrollingFrame" then Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
            elseif Object[1].ClassName == "ImageLabel" or Object[1].ClassName == "ImageButton" then
                Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                Object[1].ImageTransparency = State and (Object[2]["ImageTransparency"] or 0) or 1
            elseif Object[1].ClassName == "TextLabel" or Object[1].ClassName == "TextButton" or Object[1].ClassName == "TextBox" then
                Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                Object[1].TextTransparency = State and (Object[2]["TextTransparency"] or 0) or 1
            elseif Object[1].ClassName == "UIStroke" then
                Object[1].Transparency = State and (Object[2]["Transparency"] or 0) or 1
            end
        end
    end
    if not State then task.delay(Speed, function() if MainUI.Parent then MainUI.Visible = false end end) end
end

function Gamesense:CheckFrameFirst(FrameA, FrameB)
    local Frames = {}
    for _, Child in FrameA.Parent:GetChildren() do if Child:IsA("Frame") then table.insert(Frames, Child) end end
    table.sort(Frames, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
    local IndexA, IndexB
    for i, Frame in Frames do if Frame == FrameA then IndexA = i end if Frame == FrameB then IndexB = i end end
    return IndexA and IndexB and IndexA < IndexB
end

function Gamesense:Resizable(Object, DragFrame, MinResize, MaxResize, Increments, UseIcon, UseParent, Delay)
    local StartingSize, Dragging, MouseLocation, NewMouse, Hovering
    local function UpdateSize()
        if not MouseLocation then return end
        Gamesense.UI.Resizing = true
        local Delta = UserInputService:GetMouseLocation() - MouseLocation
        local NewSizeX = math.clamp(StartingSize.X.Offset + Delta.X, MinResize.X.Offset, MaxResize.X.Offset)
        local NewSizeY = math.clamp(StartingSize.Y.Offset + Delta.Y, MinResize.Y.Offset, MaxResize.Y.Offset)
        return UDim2.new(0, NewSizeX, 0, NewSizeY)
    end
    Gamesense:Connection(DragFrame.MouseEnter, function() Hovering = true end)
    Gamesense:Connection(DragFrame.MouseLeave, function() if NewMouse then NewMouse:Destroy() NewMouse=nil end UserInputService.MouseIconEnabled=true Hovering=false end)
    Gamesense:Connection(DragFrame.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true MouseLocation = UserInputService:GetMouseLocation() StartingSize = Object.Size end
    end)
    Gamesense:Connection(RunService.PreRender, function()
        if Dragging then Object.Size = UpdateSize() end
    end)
    Gamesense:Connection(UserInputService.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then Dragging = false Gamesense.UI.Resizing = false end
    end)
end

Gamesense.__index = Gamesense
Gamesense.Sections.__index = Gamesense.Sections
local Sections = Gamesense.Sections

-- [COLOR PICKER]
function Gamesense:ColorPicker(Options)
    Options = Gamesense:Validate({ Name="ColorPicker", Default=Gamesense.Theme.Default.Accent, Flag=Gamesense:NewFlag(), Callback=function() end }, Options or {})
    local ColorPicker = { Color = Options.Default, Alpha = 1 } Gamesense.Flags[Options.Flag] = ColorPicker
    -- Logic Omitted for brevity in this template, uses the exact structure of inside.
    -- (In standard Orion usage, users will use Tab:ColorPicker() or Section:ColorPicker())
    return ColorPicker
end

-- [KEYBIND]
function Gamesense:Keybind(Options)
    Options = Gamesense:Validate({ Default = Enum.KeyCode.Backspace, Mode = "Toggle", Flag = Gamesense:NewFlag(), Callback = function() end }, Options or {})
    local Keybind = { Keybind = Options.Default, State = false, Mode = Options.Mode } Gamesense.Flags[Options.Flag] = Keybind
    return Keybind
end

-- [MAIN WINDOW BUILDER]
function Gamesense:Window(Options)
    Options = Gamesense:Validate({
        Name = "gamesense", Size = UDim2.new(0, 700, 0, 612), MinResize = UDim2.new(0, 500, 0, 400), MaxResize = UDim2.new(0, 10000, 0, 10000), CloseBind = Enum.KeyCode.Insert,
    }, Options or {})
    
    local Window = { Visible = true, CurrentTab = nil, Tabs = {}, }
    local MainUI = Gamesense:CreateObject("ScreenGui", { ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder = 1000, ResetOnSpawn = false, IgnoreGuiInset = true, Name = "\0", Parent = gethui and gethui() or CoreGui })
    Gamesense.UI.ScreenGUI = MainUI

    local Outline = Gamesense:CreateObject("Frame", { Name = "Outline", Position = UDim2.new(0.5, -Options.Size.X.Offset/2, 0.5, -Options.Size.Y.Offset/2), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = Options.Size, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = MainUI, Active = true, Draggable = true })
    Gamesense.UI.MainUI = Outline

    local Inline = Gamesense:CreateObject("Frame", { Name = "Inline", Position = UDim2.new(0, 1, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(60, 60, 60), Parent = Outline })
    local Inner = Gamesense:CreateObject("Frame", { Name = "Inner", Position = UDim2.new(0, 1, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Inline })
    local Outline_1 = Gamesense:CreateObject("Frame", { Name = "Outline_1", Position = UDim2.new(0, 3, 0, 3), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -6, 1, -6), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(60, 60, 60), Parent = Inner })
    
    local PatternHolder = Gamesense:CreateObject("Frame", { Name = "PatternHolder", Position = UDim2.new(0, 1, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = Outline_1 })
    Gamesense:CreateObject("ImageLabel", { ImageColor3 = Color3.fromRGB(12, 12, 12), ScaleType = Enum.ScaleType.Tile, BorderColor3 = Color3.fromRGB(0, 0, 0), Image = "rbxassetid://8547666218", BackgroundTransparency = 1, Name = "Pattern", Size = UDim2.new(1, 0, 1, 0), TileSize = UDim2.new(0, 8, 0, 8), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = PatternHolder })
    
    local TopBarGradientHolder = Gamesense:CreateObject("Frame", { Name = "TopBarGradientHolder", Position = UDim2.new(0, 1, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -2, 0, 4), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = Outline_1 })
    Gamesense:CreateObject("UIGradient", { Rotation = 90, Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.55) }, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) }, Parent = TopBarGradientHolder })

    local SideBarMain = Gamesense:CreateObject("Frame", { Name = "SideBarMain", Position = UDim2.new(0, 1, 0, 5), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(0, 75, 1, -6), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(12, 12, 12), ClipsDescendants = true, Parent = Outline_1 })
    Gamesense:CreateObject("Frame", { AnchorPoint = Vector2.new(1, 0), Name = "Outline_2", Position = UDim2.new(1, 0, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = SideBarMain })
    local Holder = Gamesense:CreateObject("Frame", { BackgroundTransparency = 1, Name = "Holder", BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = SideBarMain })
    Gamesense:CreateObject("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Holder })
    Gamesense:CreateObject("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = Holder })

    Gamesense:Connection(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == Options.CloseBind then Window.Visible = not Window.Visible Gamesense:Fade(Window.Visible, Gamesense.Objects, Outline, 0.2) end
    end)

    -- [TABS SYSTEM]
    function Window:CreateTab(TabOptions)
        TabOptions = Gamesense:Validate({ Name = "Tab", Icon = "rbxassetid://8547236654" }, TabOptions or {})
        local Tab = { Hovering = false, Active = false, Index = Gamesense.UI.TabIndex + 1, Position = "Bottom", Sides = { Left = { Sections = {}, Sizes = 0 }, Right = { Sections = {}, Sizes = 0 } } }
        Gamesense.UI.TabIndex = Tab.Index

        local TabActive = Gamesense:CreateObject("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -2, 0, 64), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = Holder })
        local Outline_3 = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, 0, 1, 0), ZIndex = 2, BackgroundColor3 = Color3.fromRGB(0, 0, 0), Visible = false, Parent = TabActive })
        local Inline_1 = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, 1, 1, -2), Position = UDim2.new(0, 0, 0, 1), ZIndex = 2, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Outline_3 })
        local Main = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, 1, 1, -2), Position = UDim2.new(0, 0, 0, 1), ZIndex = 2, BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = Inline_1 })

        local Button = Gamesense:CreateObject("TextButton", { Text = TabOptions.Icon, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromRGB(90, 90, 90), TextTransparency = 1, Parent = TabActive })
        local Icon = Gamesense:CreateObject("ImageLabel", { Image = TabOptions.Icon, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ImageColor3 = Color3.fromRGB(109, 109, 109), ZIndex = 3, Parent = TabActive })
        
        local SectionsHolder = Gamesense:CreateObject("Frame", { BackgroundTransparency = 1, Visible = false, Position = UDim2.new(0, 76, 0, 5), Size = UDim2.new(1, -78, 1, -6), ClipsDescendants = true, Parent = Outline_1 })
        local Left = Gamesense:CreateObject("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), ClipsDescendants = true, Parent = SectionsHolder })
        Gamesense:CreateObject("UIPadding", { PaddingTop = UDim.new(0, 19), PaddingLeft = UDim.new(0, 21), PaddingRight = UDim.new(0, 8), Parent = Left })
        Gamesense:CreateObject("UIListLayout", { Padding = UDim.new(0, 19), Parent = Left })

        local Right = Gamesense:CreateObject("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 1, 0, 0), ClipsDescendants = true, Parent = SectionsHolder })
        Gamesense:CreateObject("UIPadding", { PaddingTop = UDim.new(0, 19), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 19), Parent = Right })
        Gamesense:CreateObject("UIListLayout", { Padding = UDim.new(0, 19), Parent = Right })

        function Tab:Activate()
            if Window.CurrentTab ~= nil then Window.CurrentTab:Deactivate() end
            Tab.Active = true SectionsHolder.Visible = true Outline_3.Visible = true
            Icon.ImageColor3 = Color3.fromRGB(210, 210, 210) Window.CurrentTab = Tab
        end
        function Tab:Deactivate() Tab.Active = false SectionsHolder.Visible = false Outline_3.Visible = false Icon.ImageColor3 = Color3.fromRGB(90, 90, 90) end
        
        Gamesense:Connection(Button.MouseButton1Click, function() Tab:Activate() end)
        Window.Tabs[#Window.Tabs + 1] = Tab
        if #Window.Tabs == 1 then Tab:Activate() end

        -- [SECTIONS & ELEMENTS]
        function Tab:Section(SecOptions)
            SecOptions = Gamesense:Validate({ Name = "Section", Side = "Left", Fill = false, Size = UDim2.new(1, 0, 0, 40) }, SecOptions or {})
            local ParentSide = SecOptions.Side == "Left" and Left or Right
            local SectionOutline = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, 0, 0, SecOptions.Size.Y.Offset), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = ParentSide })
            local SectionInline = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = SectionOutline })
            local SectionMain = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Color3.fromRGB(23, 23, 23), Parent = SectionInline })
            
            local Title = Gamesense:CreateObject("TextLabel", { Text = "<b>" .. SecOptions.Name .. "</b>", RichText = true, FontFace = Gamesense.UI.NewFont, TextSize = Gamesense.UI.FontSize, TextColor3 = Color3.fromRGB(198, 198, 198), BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, -8), Size = UDim2.new(1, 0, 0, 15), TextXAlignment = "Left", Parent = SectionOutline })
            Gamesense:CreateObject("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SectionMain })
            Gamesense:CreateObject("UIPadding", { PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), Parent = SectionMain })

            local SectionAPI = {}

            function SectionAPI:Toggle(TogOptions)
                TogOptions = Gamesense:Validate({ Name = "Toggle", Default = false, Flag = Gamesense:NewFlag(), Callback = function() end }, TogOptions or {})
                local State = TogOptions.Default Gamesense.Flags[TogOptions.Flag] = { Get = function() return State end, Set = function(self, val) State = val TogOptions.Callback(State) end }
                local TogFrame = Gamesense:CreateObject("TextButton", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = "", Parent = SectionMain })
                local TogBox = Gamesense:CreateObject("Frame", { Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, 0, 0.5, -4), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = TogFrame })
                local TogIn = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Color3.fromRGB(60, 60, 60), Parent = TogBox })
                local TogFill = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Gamesense.Theme.Default.Accent, BackgroundTransparency = State and 0 or 1, Parent = TogIn })
                Gamesense:CreateObject("TextLabel", { Text = TogOptions.Name, FontFace = Gamesense.UI.NewFont, TextSize = Gamesense.UI.FontSize, TextColor3 = Color3.fromRGB(198, 198, 198), BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0), TextXAlignment = "Left", Parent = TogFrame })
                Gamesense:Connection(TogFrame.MouseButton1Click, function() State = not State TogFill.BackgroundTransparency = State and 0 or 1 TogOptions.Callback(State) end)
                TogOptions.Callback(State)
                return { Set = function(self, v) State = v TogFill.BackgroundTransparency = State and 0 or 1 TogOptions.Callback(State) end }
            end

            function SectionAPI:Slider(SliOptions)
                SliOptions = Gamesense:Validate({ Name = "Slider", Min = 0, Max = 100, Default = 50, Flag = Gamesense:NewFlag(), Callback = function() end }, SliOptions or {})
                local SliFrame = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = SectionMain })
                Gamesense:CreateObject("TextLabel", { Text = SliOptions.Name, FontFace = Gamesense.UI.NewFont, TextSize = Gamesense.UI.FontSize, TextColor3 = Color3.fromRGB(198, 198, 198), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = "Left", Parent = SliFrame })
                local SliBox = Gamesense:CreateObject("TextButton", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Text = "", Parent = SliFrame })
                local SliIn = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Color3.fromRGB(60, 60, 60), Parent = SliBox })
                local SliFill = Gamesense:CreateObject("Frame", { Size = UDim2.new((SliOptions.Default - SliOptions.Min)/(SliOptions.Max - SliOptions.Min), 0, 1, 0), BackgroundColor3 = Gamesense.Theme.Default.Accent, Parent = SliIn })
                local ValueTxt = Gamesense:CreateObject("TextLabel", { Text = tostring(SliOptions.Default), FontFace = Gamesense.UI.NewFont, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = SliFill })
                
                local Dragging = false
                Gamesense:Connection(SliBox.InputBegan, function(inp) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
                Gamesense:Connection(UserInputService.InputEnded, function(inp) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                Gamesense:Connection(UserInputService.InputChanged, function(inp)
                    if Dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local scale = math.clamp((inp.Position.X - SliIn.AbsolutePosition.X) / SliIn.AbsoluteSize.X, 0, 1)
                        local val = math.floor(SliOptions.Min + ((SliOptions.Max - SliOptions.Min) * scale))
                        SliFill.Size = UDim2.new(scale, 0, 1, 0) ValueTxt.Text = tostring(val)
                        SliOptions.Callback(val)
                    end
                end)
                return { Set = function(self, v) local s = (v - SliOptions.Min)/(SliOptions.Max - SliOptions.Min) SliFill.Size = UDim2.new(s, 0, 1, 0) ValueTxt.Text = tostring(v) SliOptions.Callback(v) end }
            end

            function SectionAPI:Button(BtnOptions)
                BtnOptions = Gamesense:Validate({ Name = "Button", Callback = function() end }, BtnOptions or {})
                local BtnBox = Gamesense:CreateObject("TextButton", { Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Text = "", Parent = SectionMain })
                local BtnIn = Gamesense:CreateObject("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Parent = BtnBox })
                Gamesense:CreateObject("TextLabel", { Text = BtnOptions.Name, FontFace = Gamesense.UI.NewFont, TextSize = Gamesense.UI.FontSize, TextColor3 = Color3.fromRGB(198, 198, 198), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = BtnIn })
                Gamesense:Connection(BtnBox.MouseButton1Click, function() BtnOptions.Callback() end)
            end

            -- Additional elements like Dropdown, MultiBox, List map similarly to the internal structure.
            -- This exposes the builder methods just like Orion.
            
            return SectionAPI
        end

        return Tab
    end
    
    -- [WATERMARK SYSTEM]
    function Gamesense:CreateWatermark()
        local MainWatermark = Gamesense:CreateObject("Frame", { Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(0, 400, 0, 20), BorderSizePixel = 0, ZIndex = 10000, Parent = Gamesense.UI.ScreenGUI })
        local WatermarkText = Gamesense:CreateObject("TextLabel", { Text = "gamesense", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, RichText = true, TextSize = 14, TextColor3 = Color3.fromRGB(208, 208, 208), Parent = MainWatermark })
        Gamesense:CreateObject("UIPadding", { PaddingRight = UDim.new(0, 22), PaddingLeft = UDim.new(0, 22), Parent = WatermarkText })
        
        function Gamesense:ToggleWatermark(State) MainWatermark.Visible = State end
        function Gamesense:UpdateWatermark(Text) 
            WatermarkText.Text = tostring(Text) 
            MainWatermark.Size = UDim2.new(0, WatermarkText.TextBounds.X + 44, 0, 20) 
            MainWatermark.Position = UDim2.new(1, -(MainWatermark.Size.X.Offset) - 5, 0, 5) 
        end
    end

    -- [NOTIFICATION SYSTEM]
    function Gamesense:Notify(Options)
        Options = Gamesense:Validate({ Message = "Notification", Delay = 3, Position = "Top Left" }, Options or {})
        local NotifFrame = Gamesense:CreateObject("Frame", { BackgroundColor3 = Color3.fromRGB(12, 12, 12), Size = UDim2.new(0, 250, 0, 45), Position = UDim2.new(0, -300, 0, 20 + (#Gamesense.UI.Notifications.TopLeft * 50)), ZIndex = 10000, Parent = Gamesense.UI.ScreenGUI })
        local NotifText = Gamesense:CreateObject("TextLabel", { Text = Options.Message, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Color3.fromRGB(208, 208, 208), BackgroundTransparency = 1, RichText = true, TextSize = 14, TextXAlignment = "Left", Parent = NotifFrame })
        table.insert(Gamesense.UI.Notifications.TopLeft, NotifFrame)
        Gamesense:TweenObject(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 20, 0, 20 + ((#Gamesense.UI.Notifications.TopLeft - 1) * 50))})
        task.delay(Options.Delay, function()
            Gamesense:TweenObject(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, -300, 0, NotifFrame.Position.Y.Offset)})
            task.wait(0.5) NotifFrame:Destroy()
        end)
    end

    return Window
end

return Gamesense
