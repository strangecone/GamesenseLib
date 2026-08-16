-- Gamesense UI Library Framework[cite: 3]
-- Extracted and modularized for building custom UIs.

local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")
--
local Client = Players.LocalPlayer
local Camera = Workspace:FindFirstChildWhichIsA("Camera")
local Viewport = Camera.ViewportSize
--
do -- Folders
    if not isfolder("gamesense") then
        makefolder("gamesense")
    end
    --
    if not isfolder("gamesense/Configs") then
        makefolder("gamesense/Configs")
    end
end
--
local Gamesense = {
    Connections = {},
    Errors = {},
    Tweens = {},
    Objects = {},
    Sections = {},
    ThemeSections = {},
    Flags = {},
    UnnamedFlags = 0,
    Build = "Beta",
    UID = "1",
    UnsafeMode = false,
    InitTime = os.clock(),
    Folder = "gamesense",
    ConfigFolder = "gamesense/Configs",
    UI = {
        Name = "gamesense",
        CloseBind = Enum.KeyCode.Insert,
        SectionResizeIncrements = 1,
        WatermarkRefreshRate = 1,
        MainUI = nil,
        Initialized = false,
        Faded = false,
        LastCopiedColor = nil,
        TabIndex = 0,
        Viewing = false,
        CurrentSelectedColorPicker = nil,
        CurrentSelectedColorPickerExtra = nil,
        CurrentSelectedKeybindMode = nil,
        TotalColorPickers = 0,
        TotalKeybindModes = 0,
        WatermarkPosition = "Top Right",
        SectionZIndex = 100,
        Resizing = false,
        DropdownZIndex = 1,
        OpenColorFrames = 0,
        ScreenGUI = nil,
        TweenSpeed = 0.15,
        NewFont = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        FontSize = 13,
        DraggingGui = nil,
        Notifications = {TopLeft = {}, Middle = {}},
        Keys = {
            [Enum.KeyCode.LeftShift] = "LSHF",
            [Enum.KeyCode.RightShift] = "RSHF",
            [Enum.KeyCode.LeftControl] = "LCTR",
            [Enum.KeyCode.RightControl] = "RCTR",
            [Enum.KeyCode.LeftAlt] = "LALT",
            [Enum.KeyCode.RightAlt] = "RALT",
            [Enum.KeyCode.CapsLock] = "CAPS",
            [Enum.KeyCode.Space] = "SPCE",
            [Enum.KeyCode.One] = "ONE",
            [Enum.KeyCode.Two] = "TWO",
            [Enum.KeyCode.Three] = "THREE",
            [Enum.KeyCode.Four] = "FOUR",
            [Enum.KeyCode.Five] = "FIVE",
            [Enum.KeyCode.Six] = "SIX",
            [Enum.KeyCode.Seven] = "SEVEN",
            [Enum.KeyCode.Eight] = "EIGHT",
            [Enum.KeyCode.Nine] = "NINE",
            [Enum.KeyCode.Zero] = "ZERO",
            [Enum.KeyCode.KeypadOne] = "NUM1",
            [Enum.KeyCode.KeypadTwo] = "NUM2",
            [Enum.KeyCode.KeypadThree] = "NUM3",
            [Enum.KeyCode.KeypadFour] = "NUM4",
            [Enum.KeyCode.KeypadFive] = "NUM5",
            [Enum.KeyCode.KeypadSix] = "NUM6",
            [Enum.KeyCode.KeypadSeven] = "NUM7",
            [Enum.KeyCode.KeypadEight] = "NUM8",
            [Enum.KeyCode.KeypadNine] = "NUM9",
            [Enum.KeyCode.KeypadZero] = "NUM0",
            [Enum.KeyCode.Insert] = "INS",
            [Enum.KeyCode.Minus] = "-",
            [Enum.KeyCode.Equals] = "=",
            [Enum.KeyCode.Tilde] = "~",
            [Enum.KeyCode.LeftBracket] = "[",
            [Enum.KeyCode.RightBracket] = "]",
            [Enum.KeyCode.RightParenthesis] = ")",
            [Enum.KeyCode.LeftParenthesis] = "(",
            [Enum.KeyCode.Semicolon] = ",",
            [Enum.KeyCode.Quote] = "'",
            [Enum.KeyCode.BackSlash] = "\\",
            [Enum.KeyCode.Comma] = ",",
            [Enum.KeyCode.Period] = ".",
            [Enum.KeyCode.Slash] = "/",
            [Enum.KeyCode.Asterisk] = "*",
            [Enum.KeyCode.Plus] = "+",
            [Enum.KeyCode.Period] = ".",
            [Enum.KeyCode.Backquote] = "`",
            [Enum.UserInputType.MouseButton1] = "M1",
            [Enum.UserInputType.MouseButton2] = "M2",
            [Enum.UserInputType.MouseButton3] = "M3"
        },
    },
    Theme = {
        Objects = {},
        Default = {
            Accent = Color3.fromRGB(153, 196, 39),
            SecondAccent = Color3.fromRGB(124, 158, 32),
            TextColor = Color3.fromRGB(205, 205, 205),
            Risky = Color3.fromRGB(165, 165, 120),
        }
    }
}
--
function Gamesense:Validate(Defaults, Options)
    for Index, Value in Defaults do
        if Options[Index] == nil then
            Options[Index] = Value
        end
    end
    --
    return Options
end
--
function Gamesense:Connection(Signal, Func, Name, Table)
    Name = Name or "Unknown"
    Table = Table or Gamesense.Connections
    --
    local Connection; Connection = Signal:Connect(function(...)
        local Args = {...}
        --
        local Success, Message = pcall(function() coroutine.wrap(Func)(unpack(Args)) end)
        --
        if not Success and not Gamesense.Errors[Message] then
            if Gamesense.Notify then
                Gamesense:Notify({Message = ("[ERROR] | An error has occurred:\n%s\nName: %s"):format(Message, Name), Delay = math.huge})
            else
                warn(("[ERROR] | An error has occurred:\n%s\nName: %s"):format(Message, Name))
            end
            --
            Gamesense.Errors[Message] = Message
            --
            if Table[Connection] then
                Table[Connection] = nil
            end
            --
            return Connection and Connection:Disconnect()
        end
    end)
    --
    if Connection and Table then
        table.insert(Table, Connection)
    end
    --
    return Connection
end
--
function Gamesense:TweenObject(Object, Info, Goal, Callback)
    if not Object then return end
    --
    local Tween = TweenService:Create(Object, Info, Goal)
    --
    Gamesense:Connection(Tween.Completed, Callback or function() end)
    --
    Tween:Play()
    --
    Gamesense.Tweens[#Gamesense.Tweens + 1] = Tween
end
--
function Gamesense:NewFlag()
    Gamesense.UnnamedFlags += 1
    --
    return ("UnknownFlag%s"):format(tostring(Gamesense.UnnamedFlags))
end
--
function Gamesense:ClampString(String, MaxWidth)
    local Clamped = String
    --
    local TextLabel = Gamesense:CreateObject("TextLabel", {
        FontFace = Gamesense.UI.NewFont,
        TextStrokeTransparency = 0,
        Text = String,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextScaled = false,
        TextWrapped = false,
        Visible = false,
        TextSize = Gamesense.UI.FontSize,
        Parent = Client.PlayerGui
    })
    --
    if TextLabel.TextBounds.X <= MaxWidth then
        TextLabel:Destroy()
        --
        return String
    end
    --
    while TextLabel.TextBounds.X > MaxWidth and #Clamped > 0 do
        Clamped = Clamped:sub(1, #Clamped - 1)
        --
        TextLabel.Text = Clamped .. "..."
        --
        task.wait()
    end
    --
    TextLabel:Destroy()
    --
    return Clamped .. "..."
end
--
function Gamesense:GetConfig()
    local Config = {}
    --
    for Index, Value in Gamesense.Flags do
        if Value.Get and not string.find(Index, "_Status") then
            if typeof(Value:Get()) == "table" and Value:Get().Color and Value:Get().Transparency then
                local Transparency = Value:Get().Transparency
                local Hue, Saturation, V = Value:Get().Color:ToHSV()
                --
                Config[Index] = {Hue, Saturation, V, Transparency}
            else
                Config[Index] = Value:Get()
            end
        end
    end
    --
    return HttpService:JSONEncode(Config)
end
--
function Gamesense:LoadConfig(Config)
    local ConfigData = HttpService:JSONDecode(Config)
    --
    for Index, Value in ConfigData do
        if Gamesense.Flags[Index] and Gamesense.Flags[Index].Set then
            Gamesense.Flags[Index]:Set(Value)
        end
    end
end
--
function Gamesense:SectionDragging(Frame)
    local MousePosition = UserInputService:GetMouseLocation()
    local Position = Frame.AbsolutePosition
    local Size = Frame.AbsoluteSize
    --
    local InsideX = MousePosition.X >= Position.X and MousePosition.X <= Position.X + Size.X
    local InsideY = MousePosition.Y >= Position.Y and MousePosition.Y <= Position.Y + Size.Y
    --
    return InsideX and InsideY
end
--
function Gamesense:CreateObject(Type, Properties, Hidden)
    local Hidden = Hidden or false
    local Object = Instance.new(Type)
    --
    for Index, Value in Properties do
        if (not RunService:IsStudio()) and Index == "Name" and not string.match(Value, "%d") then
            Value = "\0"
        end
        --
        if Index == "TextStrokeTransparency" and Value == 0 then
            local Stroke = Instance.new("UIStroke")
            --
            Stroke.Parent = Object
            Stroke.LineJoinMode = Enum.LineJoinMode.Miter
            --
            Gamesense.Objects[Stroke] = {Stroke, {Parent = Object, LineJoinMode = Enum.LineJoinMode.Miter}, Hidden}
        else
            Object[Index] = Value
        end
    end
    --
    Gamesense.Objects[Object] = {Object, Properties, Hidden}
    --
    return Object
end
--
function Gamesense:AddTheme(Object, Properties)
    for Index, Value in Properties do
        Gamesense.Theme.Objects[Object] = Gamesense.Theme.Objects[Object] or {}
        Gamesense.Theme.Objects[Object][Index] = Value
    end
end
--
function Gamesense:GetTableIndexes(Table, Custom)
    local Table2 = {}
    --
    for Index, Value in Table do
        Table2[Custom and Value[1] or #Table2 + 1] = Index 
    end
    --
    return Table2
end
--
function Gamesense:UpdateConfigList(List, Type)
    for _, File in listfiles("gamesense/Configs") do
        local FileName = File:gsub("\\", "/"):gsub("gamesense/Configs/", ""):gsub(".cfg", "")
        --
        if Type == "Remove" then
            List:RemoveValue(FileName)
        else
            List:AddValue(FileName)
        end
    end
end
--
function Gamesense:GetObjectsTable(MainUI, AddMain, Ignored)
    local AddMain = AddMain or false
    local Ignored = Ignored or {}
    local DescendantTable = {}
    local NewTable = {}
    --
    for _, Descendant in MainUI:GetDescendants() do
        if table.find(Ignored, Descendant) then continue end
        --
        DescendantTable[#DescendantTable + 1] = Descendant
    end
    --
    if AddMain then
        DescendantTable[#DescendantTable + 1] = MainUI
    end
    --
    for _, Descendant in DescendantTable do
        local Found = Gamesense.Objects[Descendant]
        --
        if Found then
            local Properties = Found[2]
            local HiddenValue = Found[3]
            --
            NewTable[#NewTable + 1] = {Descendant, Properties, HiddenValue}
        end
    end
    --
    return NewTable
end
--
function Gamesense:SetTableVisible(Table, State, Ignored)
    local Ignored = Ignored or {}
    --
    for _, Object in Table do
        if table.find(Ignored, Object) then continue end
        --
        if typeof(Object) == "table" and Object.SetVisible then 
            Object:SetVisible(State)
        end
    end
end
--
function Gamesense:UpdateColor(ColorType, ColorValue)
    Gamesense.Theme.Default[ColorType] = ColorValue
    --
    for Object, Properties in Gamesense.Theme.Objects do
        for Property, ThemeKeys in Properties do
            if typeof(ThemeKeys) == "table" then
                if Object:IsA("UIGradient") and Property == "Color" then
                    if Gamesense.Theme.Default[ThemeKeys[1]] then
                        Object.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Gamesense.Theme.Default[ThemeKeys[1]]), ColorSequenceKeypoint.new(1, Gamesense.Theme.Default[ThemeKeys[2]])}
                    end
                end
            else
                if ThemeKeys == ColorType then
                    Object[Property] = Gamesense.Theme.Default[ThemeKeys]
                end
            end
        end
    end
end
--
function Gamesense:ViewPlayer(Player)
    if not Gamesense.UI.Viewing then
        Camera.CameraSubject = Player.Character.Humanoid
    else
        Camera.CameraSubject = Client.Character.Humanoid
    end
    --
    Gamesense.UI.Viewing = not Gamesense.UI.Viewing
end
--
function Gamesense:GetTableLength(Table)
    local Length = 0
    --
    for Index, Value in pairs(Table) do
        Length += 1
    end
    --
    return Length
end
--
function Gamesense:ScrollingCheck(ScrollingFrame, Frame)
    if not ScrollingFrame:IsA("ScrollingFrame") then return true end
    --
    local VisibleTopLeft = ScrollingFrame.CanvasPosition
    local VisibleBottomRight = VisibleTopLeft + ScrollingFrame.AbsoluteWindowSize
    --
    local FrameTopLeft = Frame.AbsolutePosition - ScrollingFrame.AbsolutePosition + ScrollingFrame.CanvasPosition
    local FrameBottomRight = FrameTopLeft + Frame.AbsoluteSize
    --
    return FrameBottomRight.X > VisibleTopLeft.X and FrameTopLeft.X < VisibleBottomRight.X and FrameBottomRight.Y > VisibleTopLeft.Y and FrameTopLeft.Y < VisibleBottomRight.Y
end
--
function Gamesense:ClampPosition(Object, Position, Offset)
    local ClampedX = math.clamp(Position.X.Offset, Offset, Viewport.X - Object.AbsoluteSize.X - Offset)
    local ClampedY = math.clamp(Position.Y.Offset, Offset, Viewport.Y - Object.AbsoluteSize.Y - Offset)
    --
    return UDim2.new(Position.X.Scale, ClampedX, Position.Y.Scale, ClampedY)
end
--
function Gamesense:Fade(State, Table, MainUI, Speed)
    local IsMainUI = Table == Gamesense.Objects
    --
    MainUI.Active = State
    --
    if State then
        MainUI.Visible = true
    end
    --
    if IsMainUI then
        Gamesense.UI.Faded = not State
    end
    --  handle toggle transparency when fading out since im not using fade out for now as it causes fps issues
    if not State and IsMainUI then
        -- find all toggle elements and force them transparent immediately instead of waiting since some things may not leave instantly
        for _, obj in pairs(MainUI:GetDescendants()) do
            if obj.ClassName == "Frame" then
                if obj.Name == "ToggleMain" then
                    obj.BackgroundTransparency = 1
                end
            end
        end
    end
    --
    for _, Object in Table do
        if not Object[3] then
            if Object[1].ClassName == "Frame" and (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
            elseif Object[1].ClassName == "ImageLabel" or Object[1].ClassName == "ImageButton" then
                if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                    Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                end
                --
                if (Object[2]["ImageTransparency"] or 0) ~= 1 then
                    Object[1].ImageTransparency = State and (Object[2]["ImageTransparency"] or 0) or 1
                end
            elseif Object[1].ClassName == "TextLabel" or Object[1].ClassName == "TextButton" or Object[1].ClassName == "TextBox" then
                if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                    Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                end
                --
                if (Object[2]["TextTransparency"] or 0) ~= 1 then
                    Object[1].TextTransparency = State and (Object[2]["TextTransparency"] or 0) or 1
                end
            elseif Object[1].ClassName == "ScrollingFrame" then
                if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                    Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                end
                --
                if (Object[2]["ScrollBarImageTransparency"] or 0) ~= 1 then
                    Object[1].ScrollBarImageTransparency = State and (Object[2]["ScrollBarImageTransparency"] or 0) or 1
                end
            elseif Object[1].ClassName == "UIStroke" then
                Object[1].Transparency = State and (Object[2]["Transparency"] or 0) or 1
            end
        end
    end
    --
    if not State then
        task.delay(Speed, function()
            if not MainUI.Parent then return end
            MainUI.Visible = false
        end)
    end
end
--
function Gamesense:CheckFrameFirst(FrameA, FrameB)
    local Parent = FrameA.Parent
    local Frames = {}
    local IndexA, IndexB
    --
    for _, Child in Parent:GetChildren() do
        if Child:IsA("Frame") then
            table.insert(Frames, Child)
        end
    end
    --
    table.sort(Frames, function(a, b)
        if a.LayoutOrder == b.LayoutOrder then
            for _, Child in Parent:GetChildren() do
                if Child == a then return true end
                if Child == b then return false end
            end
        end
        --
        return a.LayoutOrder < b.LayoutOrder
    end)
    --
    for i, Frame in Frames do
        if Frame == FrameA then IndexA = i end
        if Frame == FrameB then IndexB = i end
    end
    --
    return IndexA and IndexB and IndexA < IndexB
end
--
function Gamesense:Resizable(Object, DragFrame, MinResize, MaxResize, Increments, UseIcon, UseParent, Delay)
    local StartingSize, ObjectSize, Dragging, MouseLocation, PerformanceDragUI, NewMouse, Hovering
    --
    local function UpdateSize()
        if not MouseLocation then return end
        --
        Gamesense.UI.Resizing = true
        --
        local CurrentMousePosition = UserInputService:GetMouseLocation()
        local Delta = CurrentMousePosition - MouseLocation
        local NewSizeX = StartingSize.X.Offset + Delta.X
        local NewSizeY = StartingSize.Y.Offset + Delta.Y
        local Parent = Object.Parent
        local ParentSize = Parent.AbsoluteSize
        --
        if UseParent then
            local OccupiedSpaceY = 0
            local FrameCount = 0
            --
            for _, Child in Parent:GetChildren() do
                if Child:IsA("Frame") and Child ~= Object then
                    FrameCount += 1
                    --
                    if Gamesense:CheckFrameFirst(Object, Child) then
                        if Child.AbsoluteSize.Y >= (ParentSize.Y - Object.AbsoluteSize.Y) - 57 then
                            Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (ParentSize.Y - Object.AbsoluteSize.Y) - 57))
                        end
                    else
                        OccupiedSpaceY += Child.AbsoluteSize.Y + 19
                    end
                end
            end
            --
            if OccupiedSpaceY == 0 then
                MaxResize = UDim2.new(0, 0, 0, (ParentSize.Y - OccupiedSpaceY) - (FrameCount * (50 + 19)) - 38)
            else
                MaxResize = UDim2.new(0, 0, 0, (ParentSize.Y - OccupiedSpaceY) - 38)
            end
        end
        --
        if Increments then
            NewSizeY = math.clamp(math.round(NewSizeY / Increments) * Increments, MinResize.Y.Offset, MaxResize.Y.Offset)
        else
            NewSizeY = math.clamp(NewSizeY, MinResize.Y.Offset, MaxResize.Y.Offset)
            NewSizeX = math.clamp(NewSizeX, MinResize.X.Offset, MaxResize.X.Offset)
        end
        --
        return UseParent and UDim2.new(1, 0, 0, NewSizeY) or UDim2.new(0, NewSizeX, 0, NewSizeY)
    end
    
    --
    Gamesense:Connection(DragFrame.MouseEnter, function()
        Hovering = true
    end)
    --
    Gamesense:Connection(DragFrame.MouseLeave, function()
        if NewMouse then NewMouse:Destroy() NewMouse = nil end
        --
        UserInputService.MouseIconEnabled = true
        Hovering = false
    end)
    --
    Gamesense:Connection(DragFrame.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            MouseLocation = UserInputService:GetMouseLocation()
            StartingSize = Object.Size
        end
    end)
    --
    Gamesense:Connection(RunService.PreRender, function()
        if (Hovering or Dragging) and UseIcon then
            local MousePosition = UserInputService:GetMouseLocation()
            --
            UserInputService.MouseIconEnabled = false
            --
            if not NewMouse then
                NewMouse = Gamesense:CreateObject("ImageLabel", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Image = "rbxassetid://87982048533100",
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Name = "Transparency",
                    Size = UDim2.new(0, 35, 0, 35),
                    ZIndex = 10000,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = Gamesense.UI.ScreenGUI
                }, true)
            end
            --
            NewMouse.Position = UDim2.new(0, MousePosition.X, 0, MousePosition.Y)
        end
        --
        if Dragging then
            if Delay then task.delay(Delay, function()
                    Object.Size = UpdateSize()
                end)
            else
                Object.Size = UpdateSize()
            end
        end
    end)
    --
    Gamesense:Connection(UserInputService.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
            if NewMouse then NewMouse:Destroy() NewMouse = nil end
            --
            if UseParent then
                for _, Child in Object.Parent:GetChildren() do
                    if Child:IsA("Frame") and Child ~= Object then
                        if Gamesense:CheckFrameFirst(Object, Child) then
                            if Child.AbsoluteSize.Y >= (Object.Parent.AbsoluteSize.Y - Object.AbsoluteSize.Y) - 57 then
                                Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (Object.Parent.AbsoluteSize.Y - Object.AbsoluteSize.Y) - 57))
                            end
                        end
                    end
                end
            end
            --
            UserInputService.MouseIconEnabled = true
            Dragging = false
            Gamesense.UI.Resizing = false
        end
    end)
end
--
Gamesense.__index = Gamesense
Gamesense.Sections.__index = Gamesense.Sections
--
local Sections = Gamesense.Sections
--
function Gamesense:ColorPicker(Options)
    Options = Gamesense:Validate({
        Name = "Preview Color Picker",
        Default = Gamesense.Theme.Default.Accent,
        Alpha = 0,
        AlphaBar = true,
        Parent = nil,
        MainUI = nil,
        TabUI = nil,
        Count = 1,
        Keybind = false,
        Flag = Gamesense:NewFlag(),
        Callback = function() end,
    }, Options or {})
    --
    local Hue, Saturation, Value = Options.Default:ToHSV()
    --
    local ColorPicker = {
        Hover = false,
        Active = false,
        MouseDown = false,
        MainFrameHover = false,
        Color = Options.Default,
        SecondColor = Color3.fromRGB(math.max(math.floor(Options.Default.R * 255) - 14, 0), math.max(math.floor(Options.Default.G * 255) - 14, 0), math.max(math.floor(Options.Default.B * 255) - 14, 0)),
        Saturation = {Saturation, Value},
        Alpha = Options.Alpha,
        Hue = Hue,
        ActiveFrame = false,
        LastCopiedColor = {self.Color, self.Alpha},
        FrameOpened = false,
    }
    --
    Gamesense.Flags[Options.Flag] = ColorPicker
    --
    Gamesense.UI.TotalColorPickers += 1
    --
    if Options.Keybind then
        Options.Count += 1
    end
    --
    local ColorPickerOutline_1 = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        Name = "ColorPickerOutline" .. Gamesense.UI.TotalColorPickers,
        Position = UDim2.new(1, 0 - (Options.Count - 1) * 22, 0, 0),
        Size = UDim2.new(0, 17, 0, 9),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = Options.Parent
    })
    --
    local ColorPickerChecker = Gamesense:CreateObject("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 4),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Visible = false,
        BorderSizePixel = 0,
        Parent = ColorPickerOutline_1
    })
    --
    local Button_9 = Gamesense:CreateObject("TextButton", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button_9",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextTransparency = 1,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ColorPickerOutline_1
    })
    --
    local ColorPickerTransparency = Gamesense:CreateObject("ImageLabel", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Image = "rbxassetid://18249241978",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Name = "Transparency",
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BorderSizePixel = 0,
        ZIndex = 3,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ColorPickerOutline_1
    })
    --
    local ColorPickerInline_1 = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "ColorPickerInline_1",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ColorPickerOutline_1
    })
    --
    local UIGradient_24 = Gamesense:CreateObject("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ColorPicker.Color),
            ColorSequenceKeypoint.new(1, ColorPicker.SecondColor)
        },
        Parent = ColorPickerInline_1
    })
    --
    do -- Functions
        function ColorPicker:SetVisible(Bool)
            ColorPickerOutline_1.Visible = Bool
            --
            if Bool == false then
                ColorPicker:RemoveFrame()
            end
        end
        --
        function ColorPicker:AddFrame()
            Gamesense.UI.CurrentSelectedColorPicker = {ColorPicker = ColorPicker, ColorPickerOutline = ColorPickerOutline_1, Parent = Options.Parent}
            --
            Gamesense.UI.OpenColorFrames += 1
            --
            local ColorPickerOutline = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(0, 180, 0, 175),
                Name = "ColorPickerFrame" .. Gamesense.UI.TotalColorPickers,
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = Gamesense.UI.ScreenGUI
            })
            --
            ColorPickerOutline.BackgroundTransparency = 1
            --
            local ColorPickerInline = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "ColorPickerInline",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Parent = ColorPickerOutline
            })
            --
            ColorPickerInline.BackgroundTransparency = 1
            --
            local ColorPickerMain = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "ColorPickerMain",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = ColorPickerInline
            })
            --
            ColorPickerMain.BackgroundTransparency = 1
            --
            local MainPicker = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -24, 1, -19),
                Name = "MainPicker",
                Position = UDim2.new(0, 2, 0, 2),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = ColorPickerMain
            })
            --
            MainPicker.BackgroundTransparency = 1
            --
            local Button_91 = Gamesense:CreateObject("TextButton", {
                FontFace = Gamesense.UI.NewFont,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button_9",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextTransparency = 1,
                ZIndex = 250,
                TextSize = Gamesense.UI.FontSize,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = MainPicker
            })
            --
            local MainPickerColor = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "MainPickerColor",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = MainPicker
            })
            --
            MainPickerColor.BackgroundTransparency = 1
            --
            local UIGradient_20 = Gamesense:CreateObject("UIGradient", {
                Rotation = 180,
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                },
                Parent = MainPickerColor
            })
            --
            local BackImage = Gamesense:CreateObject("ImageLabel", {
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Image = "rbxassetid://13966897785",
                BackgroundTransparency = 1,
                Name = "BackImage",
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Parent = MainPickerColor
            })
            --
            BackImage.ImageTransparency = 1
            --
            local DraggingMainOutline = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(0, 4, 0, 4),
                Name = "DraggingMainOutline",
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 251,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = MainPicker
            })
            --
            DraggingMainOutline.BackgroundTransparency = 1
            --
            local DraggingMain = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "DraggingMain",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 251,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = DraggingMainOutline
            })
            --
            DraggingMain.BackgroundTransparency = 1
            --
            local SaturationSlider = Gamesense:CreateObject("Frame", {
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                AnchorPoint = Vector2.new(0, 1),
                Name = "SaturationSlider",
                Position = UDim2.new(0, 2, 1, -2),
                Size = UDim2.new(1, -24, 0, 12),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = ColorPickerMain
            })
            --
            SaturationSlider.BackgroundTransparency = 1
            --
            local Button_915241 = Gamesense:CreateObject("TextButton", {
                FontFace = Gamesense.UI.NewFont,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button_9",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextTransparency = 1,
                ZIndex = 250,
                TextSize = Gamesense.UI.FontSize,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SaturationSlider
            })
            --
            local SaturationColor = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "SaturationColor",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 251,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SaturationSlider
            })
            --
            SaturationColor.BackgroundTransparency = 1
            --
            local UIGradient_21 = Gamesense:CreateObject("UIGradient", {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                },
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0.10000000149011612),
                    NumberSequenceKeypoint.new(0.5, 0.800000011920929),
                    NumberSequenceKeypoint.new(1, 1)
                },
                Rotation = 180,
                Parent = SaturationColor
            })
            --
            local BackImage_1 = Gamesense:CreateObject("ImageLabel", {
                ScaleType = Enum.ScaleType.Tile,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "BackImage_1",
                TileSize = UDim2.new(0, 12, 0, 12),
                Image = "rbxassetid://18249241978",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Parent = SaturationSlider
            })
            --
            BackImage_1.ImageTransparency = 1
            --
            local DraggingSatOutline = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(0, 4, 1, 0),
                Name = "DraggingSatOutline",
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 251,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = SaturationSlider
            })
            --
            DraggingSatOutline.BackgroundTransparency = 1
            --
            local DraggingSatMain = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "DraggingSatMain",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 251,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = DraggingSatOutline
            })
            --
            DraggingSatMain.BackgroundTransparency = 1
            --
            local HueSlider = Gamesense:CreateObject("Frame", {
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                Name = "HueSlider",
                Position = UDim2.new(1, -2, 0, 2),
                Size = UDim2.new(0, 17, 1, -19),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = ColorPickerMain
            })
            --
            HueSlider.BackgroundTransparency = 1
            --
            local Button_9141 = Gamesense:CreateObject("TextButton", {
                FontFace = Gamesense.UI.NewFont,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button_9",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextTransparency = 1,
                ZIndex = 250,
                TextSize = Gamesense.UI.FontSize,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = HueSlider
            })
            --
            local BackImage_2 = Gamesense:CreateObject("ImageLabel", {
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "BackImage_2",
                TileSize = UDim2.new(0, 12, 0, 12),
                Image = "rbxassetid://8180989234",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 250,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Parent = HueSlider
            })
            --
            BackImage_2.ImageTransparency = 1
            --
            local DraggingHueOutline = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, 0, 0, 4),
                Name = "DraggingHueOutline",
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 251,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = HueSlider
            })
            --
            DraggingHueOutline.BackgroundTransparency = 1
            --
            local DraggingHueMain = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "DraggingHueMain",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 251,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = DraggingHueOutline
            })
            --
            DraggingHueMain.BackgroundTransparency = 1
            --
            do -- Functions
                function ColorPicker:UpdateSize()
                    ColorPickerOutline.Position = UDim2.new(0, ColorPickerOutline_1.AbsolutePosition.X, 0, (ColorPickerOutline_1.AbsolutePosition.Y + ColorPickerOutline_1.AbsoluteSize.Y + GuiService:GetGuiInset().Y + 2))
                end
                --
                ColorPicker:UpdateSize()
                --
                Gamesense:Connection(Options.MainUI:GetPropertyChangedSignal("AbsolutePosition"), ColorPicker.UpdateSize)
                --
                local StartingY = ColorPickerOutline_1.AbsolutePosition.Y
                local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
                local StartingCanvasPosition = Options.Parent.Parent.CanvasPosition
                --
                Gamesense:Connection(ColorPickerOutline_1:GetPropertyChangedSignal("AbsolutePosition"), function()
                    local CurrentY = ColorPickerOutline_1.AbsolutePosition.Y
                    local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                    local CurrentCanvasPosition = Options.Parent.Parent.CanvasPosition
                    --
                    if MainUICurrentY ~= MainUIStartingY then
                        MainUIStartingY = MainUICurrentY
                        StartingY = CurrentY
                        --
                        return
                    end
                    --
                    if CurrentCanvasPosition ~= StartingCanvasPosition then
                        StartingCanvasPosition = CurrentCanvasPosition
                        StartingY = CurrentY
                        --
                        return
                    end
                    --
                    if Gamesense.UI.Resizing then
                        return
                    end
                    --
                    if CurrentY ~= StartingY then
                        ColorPicker:RemoveFrame(true)
                    end
                    --
                    StartingY = CurrentY
                end)
                --
                Gamesense:Connection(Options.MainUI:GetPropertyChangedSignal("AbsoluteSize"), function()
                    if ColorPicker.Active then
                        ColorPickerOutline.Visible = Gamesense:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                    end
                    --
                    ColorPicker:UpdateSize()
                end)
                --
                if Options.Parent.Parent:IsA("ScrollingFrame") then
                    Gamesense:Connection(Options.Parent.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                        ColorPicker:UpdateSize()
                        --
                        if ColorPicker.Active then
                            ColorPickerOutline.Visible = Gamesense:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                        end
                    end)
                end
                --
                Gamesense:Connection(Options.MainUI:GetPropertyChangedSignal("Visible"), function()
                    if not Options.MainUI.Visible then
                        ColorPickerOutline.Visible = false
                    else
                        ColorPickerOutline.Visible = ColorPicker.Active
                    end
                end)
                --
                Gamesense:Connection(Options.Parent.Parent:GetPropertyChangedSignal("Visible"), function()
                    if not Options.Parent.Parent.Visible then
                        ColorPickerOutline.Visible = false
                    else
                        ColorPickerOutline.Visible = ColorPicker.Active
                    end
                end)
                --
                function ColorPicker:Update()
                    ColorPicker.Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2])
                    ColorPicker.SecondColor = Color3.fromRGB(math.max(math.floor(ColorPicker.Color.R * 255) - 23, 0), math.max(math.floor(ColorPicker.Color.G * 255) - 23, 0), math.max(math.floor(ColorPicker.Color.B * 255) - 23, 0))
                    --
                    UIGradient_24.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ColorPicker.Color), ColorSequenceKeypoint.new(1, ColorPicker.SecondColor)}
                    UIGradient_20.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ColorPicker.Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}
                    UIGradient_21.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ColorPicker.Color), ColorSequenceKeypoint.new(1, ColorPicker.Color)}
                    UIGradient_20.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromHSV(ColorPicker.Hue, 1, 1)), ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))}
                    --
                    local MaxSaturationX = math.max(0, MainPickerColor.AbsoluteSize.X - DraggingMainOutline.AbsoluteSize.X) / MainPickerColor.AbsoluteSize.X
                    local MaxSaturationY = math.max(0, MainPickerColor.AbsoluteSize.Y - DraggingMainOutline.AbsoluteSize.Y) / MainPickerColor.AbsoluteSize.Y
                    local MaxAlpha = math.max(0, SaturationColor.AbsoluteSize.X - DraggingSatOutline.AbsoluteSize.X) / SaturationColor.AbsoluteSize.X
                    local MaxHue = math.max(0, BackImage_2.AbsoluteSize.Y - DraggingHueOutline.AbsoluteSize.Y) / BackImage_2.AbsoluteSize.Y
                    --
                    Gamesense:TweenObject(DraggingMainOutline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromScale(math.clamp(ColorPicker.Saturation[1], 0, MaxSaturationX), math.clamp(1 - ColorPicker.Saturation[2], 0, MaxSaturationY))})
                    Gamesense:TweenObject(DraggingSatOutline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(math.clamp(1 - ColorPicker.Alpha, 0, MaxAlpha), 0, 0, 0)})
                    Gamesense:TweenObject(DraggingHueOutline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, math.clamp(ColorPicker.Hue, 0, MaxHue), 0)})
                    --
                    DraggingMain.BackgroundColor3 = ColorPicker.Color
                    DraggingSatMain.BackgroundColor3 = ColorPicker.Color
                    DraggingHueMain.BackgroundColor3 = ColorPicker.Color
                    ColorPickerInline_1.BackgroundTransparency = ColorPicker.Alpha
                    UIGradient_21.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.304 + (0.604 - 0.304) * ColorPicker.Alpha), NumberSequenceKeypoint.new(0.5, 0.7), NumberSequenceKeypoint.new(1, 1)}
                    --
                    Options.Callback(ColorPicker.Color, ColorPicker.Alpha)
                    Gamesense.Flags[Options.Flag] = ColorPicker
                end
                --
                function ColorPicker:Set(Color, Transparency)
                    if typeof(Color) == "table" then
                        ColorPicker.Color = Color3.fromHSV(Color[1], Color[2], Color[3])
                        ColorPicker.Alpha = Color[4]
                        ColorPicker.Hue = Color[1]
                        ColorPicker.Saturation[1] = Color[2]
                        ColorPicker.Saturation[2] = Color[3]
                        ColorPicker:Update()
                        Options.Callback(ColorPicker.Color, ColorPicker.Alpha)
                    elseif typeof(Color) == "Color3" then
                        local h, s, v = Color:ToHSV()
                        --
                        ColorPicker.Color = Color3.fromHSV(h, s, v)
                        ColorPicker.Alpha = Transparency or 1
                        ColorPicker.Hue = h
                        ColorPicker.Saturation[1] = s
                        ColorPicker.Saturation[2] = v
                        ColorPicker:Update()
                        Options.Callback(ColorPicker.Color, ColorPicker.Alpha)
                    end
                end
                --
                function ColorPicker:Get()
                    return {Color = ColorPicker.Color, Transparency = ColorPicker.Alpha}
                end
                --
                function ColorPicker:UpdateHue(Percentage)
                    local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
                    --
                    ColorPicker.Hue = Percentage
                    --
                    ColorPicker:Update()
                end
                --
                function ColorPicker:UpdateAlpha(Percentage)
                    local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
                    --
                    ColorPicker.Alpha = Percentage
                    --
                    ColorPicker:Update()
                end
                --
                function ColorPicker:UpdateSaturation(PercentageX, PercentageY)
                    local PercentageX = typeof(PercentageX == "number") and math.clamp(PercentageX, 0, 1) or 0
                    local PercentageY = typeof(PercentageY == "number") and math.clamp(PercentageY, 0, 1) or 0
                    --
                    ColorPicker.Saturation[1] = PercentageX
                    ColorPicker.Saturation[2] = 1 - PercentageY
                    --
                    ColorPicker:Update()
                end
            end
            --
            do -- Connections
                Gamesense:Connection(Button_91.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Gamesense.UI.DraggingGui = MainPickerColor
                        --
                        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                        local Percentage = (InputPosition - MainPickerColor.AbsolutePosition) / MainPickerColor.AbsoluteSize
                        --
                        ColorPicker:UpdateSaturation(Percentage.X, Percentage.Y)
                    end
                end)
                --
                Gamesense:Connection(Button_915241.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Gamesense.UI.DraggingGui = SaturationColor
                        --
                        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                        local GuiPosition = SaturationColor.AbsolutePosition.X
                        local GuiSize = SaturationColor.AbsoluteSize.X
                        local Percentage = ((GuiPosition + GuiSize - InputPosition.X) / GuiSize)
                        --
                        ColorPicker:UpdateAlpha(Percentage)
                    end
                end)
                --
                Gamesense:Connection(Button_9141.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Gamesense.UI.DraggingGui = BackImage_2
                        --
                        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                        local Percentage = (InputPosition - BackImage_2.AbsolutePosition) / BackImage_2.AbsoluteSize
                        --
                        ColorPicker:UpdateHue(Percentage.Y)
                    end
                end)
                --
                Gamesense:Connection(UserInputService.InputChanged, function(Input)
                    if (Gamesense.UI.DraggingGui ~= SaturationColor and Gamesense.UI.DraggingGui ~= MainPickerColor and Gamesense.UI.DraggingGui ~= BackImage_2) then return end
                    --
                    if not (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
                        Gamesense.UI.DraggingGui = nil
                        return
                    end
                    --
                    local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                    --
                    if (Input.UserInputType == Enum.UserInputType.MouseMovement) then
                        if Gamesense.UI.DraggingGui == MainPickerColor then
                            local Percentage = (InputPosition - MainPickerColor.AbsolutePosition) / MainPickerColor.AbsoluteSize
                            --
                            ColorPicker:UpdateSaturation(Percentage.X, Percentage.Y)
                        end
                        --
                        if Gamesense.UI.DraggingGui == SaturationColor then
                            local GuiPosition = SaturationColor.AbsolutePosition.X
                            local GuiSize = SaturationColor.AbsoluteSize.X
                            local Percentage = ((GuiPosition + GuiSize - InputPosition.X) / GuiSize)
                            --
                            ColorPicker:UpdateAlpha(Percentage)
                        end
                        --
                        if Gamesense.UI.DraggingGui == BackImage_2 then
                            local Percentage = (InputPosition - BackImage_2.AbsolutePosition) / BackImage_2.AbsoluteSize
                            --
                            ColorPicker:UpdateHue(Percentage.Y)
                        end
                    end
                end)
            end
            --
            ColorPicker:Update()
            Gamesense:Fade(true, Gamesense:GetObjectsTable(ColorPickerOutline, true), ColorPickerOutline, 0.1)
        end
        --
        function ColorPicker:RemoveFrame(Fast)
            local Fast = Fast or false
            --
            for Index, Value in Gamesense.UI.ScreenGUI:GetChildren() do
                if Value:IsA("Frame") and Value.Name == "ColorPickerFrame" .. Gamesense.UI.TotalColorPickers then
                    if Fast then
                        Value:Destroy()
                    else
                        Gamesense:Fade(false, Gamesense:GetObjectsTable(Value, true), Value, 0.1)
                        --
                        task.delay(Gamesense.UI.TweenSpeed, function()
                            Value:Destroy()
                        end)
                    end
                end
            end
        end
        --
        function ColorPicker:FindFrame()
            for Index, Value in Gamesense.UI.ScreenGUI:GetChildren() do
                if Value:IsA("Frame") and Value.Name == "ColorPickerFrame" .. Gamesense.UI.TotalColorPickers then
                    return true
                end
            end
            --
            return false
        end
        --
        function ColorPicker:Toggle()
            if Gamesense.UI.CurrentSelectedColorPicker and Gamesense.UI.CurrentSelectedColorPicker.ColorPickerOutline.Name ~= ColorPickerOutline_1.Name then
                Gamesense.UI.CurrentSelectedColorPicker.ColorPicker:RemoveFrame()
            end
            --
            if not ColorPicker:FindFrame() then
                ColorPicker.Active = true
                ColorPicker:AddFrame()
            else
                ColorPicker.Active = false
                ColorPicker:RemoveFrame()
            end
        end
        --
        function ColorPicker:AddOtherFrame()
            Gamesense.UI.CurrentSelectedColorPickerExtra = {ColorPicker = ColorPicker, ColorPickerObject = ColorPickerOutline_1, Parent = Options.Parent}
            --
            local KeybindModePickerOutline = Gamesense:CreateObject("Frame", {
                Name = "ColorPickerOutline" .. Gamesense.UI.TotalColorPickers,
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(0, 100, 0, 55),
                BorderSizePixel = 0,
                ZIndex = 25,
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = Gamesense.UI.ScreenGUI
            })
            --
            local KeybindModePickerMain = Gamesense:CreateObject("Frame", {
                Name = "KeybindModePickerMain",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex = 25,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Parent = KeybindModePickerOutline
            })
            --
            KeybindModePickerOutline.BackgroundTransparency = 1
            KeybindModePickerMain.BackgroundTransparency = 1
            --
            local UIListLayout_9 = Gamesense:CreateObject("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = KeybindModePickerMain
            })
            --
            function ColorPicker:UpdateSize()
                KeybindModePickerOutline.Position = UDim2.new(0, ColorPickerOutline_1.AbsolutePosition.X - 2, 0, ColorPickerOutline_1.AbsolutePosition.Y + ColorPickerOutline_1.AbsoluteSize.Y + KeybindModePickerOutline.AbsoluteSize.Y - 4)
            end
            --
            ColorPicker:UpdateSize()
            --
            Gamesense:Connection(Options.MainUI:GetPropertyChangedSignal("AbsolutePosition"), ColorPicker.UpdateSize)
            --
            local StartingY = ColorPickerOutline_1.AbsolutePosition.Y
            local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
            local StartingCanvasPosition = Options.Parent.Parent.CanvasPosition
            --
            Gamesense:Connection(ColorPickerOutline_1:GetPropertyChangedSignal("AbsolutePosition"), function()
                local CurrentY = ColorPickerOutline_1.AbsolutePosition.Y
                local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                local CurrentCanvasPosition = Options.Parent.Parent.CanvasPosition
                --
                if MainUICurrentY ~= MainUIStartingY then
                    MainUIStartingY = MainUICurrentY
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if CurrentCanvasPosition ~= StartingCanvasPosition then
                    StartingCanvasPosition = CurrentCanvasPosition
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if Gamesense.UI.Resizing then
                    return
                end
                --
                if CurrentY ~= StartingY then
                    ColorPicker:RemoveOtherFrame(true)
                end
                --
                StartingY = CurrentY
            end)
            --
            Gamesense:Connection(Options.MainUI:GetPropertyChangedSignal("AbsoluteSize"), function()
                if ColorPicker.ActiveFrame then
                    KeybindModePickerOutline.Visible = Gamesense:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                end
                --
                ColorPicker:UpdateSize()
            end)
            --
            if Options.Parent.Parent:IsA("ScrollingFrame") then
                Gamesense:Connection(Options.Parent.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                    ColorPicker:UpdateSize()
                    --
                    if ColorPicker.ActiveFrame then
                        KeybindModePickerOutline.Visible = Gamesense:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                    end
                end)
            end
            --
            for Index, Value in {"Copy", "Paste", "Reset"} do
                local ModeItem = {
                    Active = false,
                    Hovering = false,
                }
                --
                local Inactive = Gamesense:CreateObject("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(208, 208, 208),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = Value,
                    Text = Value,
                    RichText = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 17),
                    BorderSizePixel = 0,
                    TextSize = Gamesense.UI.FontSize,
                    ZIndex = 25,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = KeybindModePickerMain
                })
                --
                local Button_4 = Gamesense:CreateObject("TextButton", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_4",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    TextSize = Gamesense.UI.FontSize,
                    ZIndex = 25,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = Inactive
                })
                --
                local UIPadding_48 = Gamesense:CreateObject("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = Inactive
                })
                --
                Inactive.TextTransparency = 1
                --
                do -- Functions
                    function ModeItem:Activate()
                        if not ModeItem.Active then
                            ModeItem.Active = true
                            --
                            Inactive.Text = "<b>" .. Value .. "</b>"
                            Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Gamesense.Theme.Default.Accent})
                            --
                            if Value == "Copy" then
                                Gamesense.UI.LastCopiedColor = {Color = ColorPicker.Color, Alpha = ColorPicker.Alpha}
                            elseif Value == "Paste" then
                                if Gamesense.UI.LastCopiedColor then
                                    ColorPicker:Set(Gamesense.UI.LastCopiedColor.Color, Gamesense.UI.LastCopiedColor.Alpha)
                                end
                            elseif Value == "Reset" then
                                ColorPicker:Set(Options.Default, Options.Alpha)
                            end
                            --
                            ColorPicker:RemoveOtherFrame()
                        end
                    end
                    --
                    function ModeItem:Deactivate()
                        if ModeItem.Active then
                            ModeItem.Active = false
                            ModeItem.Hovering = false
                            Inactive.Text = Value
                            Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                        end
                    end
                end
                --
                do -- Connections
                    Gamesense:Connection(Button_4.MouseButton1Click, function()
                        ModeItem:Activate()
                    end)
                    --
                    Gamesense:Connection(Inactive.MouseEnter, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        --
                        if ModeItem.Active then return end
                        --
                        Inactive.Text = "<b>" .. Value .. "</b>"
                    end)
                    --
                    Gamesense:Connection(Inactive.MouseLeave, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        --
                        if ModeItem.Active then return end
                        --
                        Inactive.Text = Value
                        Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                    end)
                end
            end
            --
            Gamesense:Fade(true, Gamesense:GetObjectsTable(KeybindModePickerOutline, true), KeybindModePickerOutline, 0.1)
        end
        --
        function ColorPicker:RemoveOtherFrame(Fast)
            local Fast = Fast or false
            --
            for Index, Value in Gamesense.UI.ScreenGUI:GetChildren() do
                if Value:IsA("Frame") and Value.Name == "ColorPickerOutline" .. Gamesense.UI.TotalColorPickers then
                    if Fast then
                        Value:Destroy()
                    else
                        Gamesense:Fade(false, Gamesense:GetObjectsTable(Value, true), Value, 0.1)
                        --
                        task.delay(Gamesense.UI.TweenSpeed, function()
                            Value:Destroy()
                        end)
                    end
                end
            end
        end
        --
        function ColorPicker:FindOtherFrame()
            for Index, Value in Gamesense.UI.ScreenGUI:GetChildren() do
                if Value:IsA("Frame") and Value.Name == "ColorPickerOutline" .. Gamesense.UI.TotalColorPickers then
                    return true
                end
            end
            --
            return false
        end
        --
        function ColorPicker:ToggleOtherFrame()
            if Gamesense.UI.CurrentSelectedColorPickerExtra and Gamesense.UI.CurrentSelectedColorPickerExtra.ColorPickerObject.Name ~= ColorPickerOutline_1.Name then
                Gamesense.UI.CurrentSelectedColorPickerExtra.ColorPicker:RemoveFrame()
            end
            --
            if not ColorPicker:FindOtherFrame() then
                ColorPicker.ActiveFrame = true
                ColorPicker:AddOtherFrame()
            else
                ColorPicker.ActiveFrame = false
                ColorPicker:RemoveOtherFrame()
            end
        end
    end
    --
    do -- Connections
        Gamesense:Connection(Button_9.MouseButton2Click, function()
            ColorPicker:ToggleOtherFrame()
        end)
        --
        Gamesense:Connection(Button_9.MouseButton1Click, function()
            ColorPicker:Toggle()
        end)
    end
    --
    ColorPicker:AddFrame()
    ColorPicker:Update()
    ColorPicker:RemoveFrame()
    --
    return ColorPicker
end
--
function Gamesense:Keybind(Options)
    Options = Gamesense:Validate({
        Default = Enum.KeyCode.Backspace,
        Mode = "Toggle",
        UseMode = true,
        HideFromList = false,
        Blacklisted = {},
        Parent = nil,
        Toggle = nil,
        MainUI = nil,
        Hiding = false,
        ToggleState = false,
        Flag = Gamesense:NewFlag(),
        Count = 1,
        ChangeToggle = false,
        Callback = function() end,
    }, Options or {})
    --
    if Options.Toggle == nil then return end
    --
    local Keybind = {
        Hover = false,
        ActiveFrame = false,
        Keybind = Options.Default,
        RegKeybind = nil,
        State = false,
        SelectingKeybind = false,
        Toggle = false,
        Connection = nil,
        Mode = Options.Mode,
        ConfigKeybind = nil,
        Current = {},
        CurrentMode = nil,
        Hiding = false,
    }
    --
    Gamesense.Flags[Options.Flag] = Keybind
    Gamesense.UI.TotalKeybindModes += 1
    --
    local KeybindObject = Gamesense:CreateObject("TextLabel", {
        FontFace = Font.new("rbxassetid://12187371840", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(117, 117, 117),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = "[-]",
        Name = "KeybindOutline" .. Gamesense.UI.TotalKeybindModes,
        AnchorPoint = Vector2.new(1, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 7),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0 - (Options.Count - 1) * 22, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3,
        TextStrokeTransparency = 0,
        TextSize = 9,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local KeybindChecker = Gamesense:CreateObject("Frame", {
        Position = UDim2.new(0, 0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Visible = false,
        BorderSizePixel = 0,
        Parent = KeybindObject
    })
    --
    local Button_4 = Gamesense:CreateObject("TextButton", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button_4",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextTransparency = 1,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = KeybindObject
    })
    --
    local UserInputTypeBinds = {"MouseButton1", "MouseButton2", "MouseButton3"}
    --
    do -- Functions
        function Keybind:SetVisible(Bool)
            local OldValues = Gamesense.Objects[KeybindObject]
            --
            Keybind.Hiding = not Bool
            --
            if Bool then
                Gamesense.Objects[KeybindObject] = {KeybindObject, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(KeybindObject), KeybindObject, 0.075)
            Gamesense:TweenObject(KeybindObject, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and UDim2.new(1, 0, 0, 8) or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[KeybindObject] = {KeybindObject, OldValues[2], false}
                end
            end)
        end
        --
        function Keybind:Set(Key)
            if Keybind.Hiding then return end
            if typeof(Key) == "boolean" then return end
            --
            if typeof(Key) == "EnumItem" then
                Keybind.RegKeybind = Key
            elseif typeof(Key) == "string" then
                if table.find(UserInputTypeBinds, Key) then
                    Keybind.RegKeybind = Enum.UserInputType[Key]
                    Key = Enum.UserInputType[Key]
                else
                    Keybind.RegKeybind = Enum.KeyCode[Key]
                    Key = Enum.KeyCode[Key]
                end
            end
            --
            if typeof(Key) == "string" then
                if Key:find("KEY") then
                    Key = Enum.KeyCode[Key:gsub("KEY_", "")]
                elseif Key:find("Input") then
                    Key = Enum.UserInputType[Key:gsub("Input_", "")]
                end
            end
            --
            local ValidKey = false
            local KeyString = ""
            --
            if table.find(Options.Blacklisted, Key) then
                Key = nil
            end
            --
            if Key then
                if ((Key.EnumType == Enum.KeyCode and UserInputService:GetStringForKeyCode(Key) ~= "") or Gamesense.UI.Keys[Key]) then
                    ValidKey = true
                    KeyString = Gamesense.UI.Keys[Key] or UserInputService:GetStringForKeyCode(Key)
                end
            end
            --
            if ValidKey then
                Keybind.Keybind = KeyString
                KeybindObject.Text = "[" .. KeyString:upper() .. "]"
                --
                Options.Callback(Key)
                Gamesense.Flags[Options.Flag] = Keybind
            else
                Keybind.Keybind = "[-]"
                KeybindObject.Text = Keybind.Keybind
            end
            --
            Gamesense:TweenObject(KeybindObject, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(117, 117, 117)})
            KeybindObject.Size = UDim2.new(0, KeybindObject.TextBounds.X + 2, 0, 7)
        end
        --
        function Keybind:Toggle(Bool)
            if Keybind.Hiding then return end
            --
            if Bool == nil then
                Keybind.State = not Keybind.State
            else
                Keybind.State = Bool
            end
            --
            if not Options.HideFromList then
                if Keybind.State then
                    --Gamesense:AddKeybindFrame(Keybind.Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                else
                    --Gamesense:RemoveKeybindFrame(Options.Toggle:GetName(), Options.Toggle:GetSection())
                end
            end
            --
            if Options.Toggle.GetFlag then
                Gamesense.Flags[Options.Toggle:GetFlag()] = Keybind
            end
            --
            if Options.ChangeToggle then
                -- viuslaly toggle the UI element and update its state
                Options.Toggle:Set(Keybind.State)
            else
                Options.Toggle:GetCallback(Keybind.State)
            end
        end
        --
        task.delay(1, function()
            Keybind:Set(Options.Default)
        end)
        --
        function Keybind:Get()
            local KeyString = Keybind.RegKeybind.EnumType == Enum.KeyCode and tostring(Keybind.RegKeybind):match("^Enum%.KeyCode%.(.+)$") or tostring(Keybind.RegKeybind):match("^Enum%.UserInputType%.(.+)$")
            --
            return KeyString
        end
        --
        function Keybind:Active()
            return (Keybind.Keybind:lower() == "[-]" and true or Keybind.State)
        end
        --
        if Options.Mode == "Always on" then
            Keybind:Toggle(true)
        end
        --
        function Keybind:SetMode(Mode)
            Keybind.Mode = Mode
            --
            if Mode == "Always on" then
                if Mode == "Always on" then
                    Keybind:Toggle(true)
                end
                --
                if not Keybind.State then
                    Keybind.State = true
                    --
                    --Gamesense:AddKeybindFrame(Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                else
                    --Gamesense:UpdateKeybindFrame(Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                end
            elseif Mode == "Toggle" then
                if Keybind.State then
                    --Gamesense:UpdateKeybindFrame(Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                end
            elseif Mode == "On hotkey" then
                Keybind.State = false
                --
                --Gamesense:RemoveKeybindFrame(Options.Toggle:GetName(), Options.Toggle:GetSection())
            end
        end
        --
        function Keybind:AddFrame()
            Gamesense.UI.CurrentSelectedKeybindMode = {Keybind = Keybind, KeybindObject = KeybindObject, Parent = Options.Parent}
            --
            local KeybindModePickerOutline = Gamesense:CreateObject("Frame", {
                Name = "KeybindModePickerOutline" .. Gamesense.UI.TotalKeybindModes,
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(0, 100, 0, 55),
                BorderSizePixel = 0,
                ZIndex = 25,
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = Gamesense.UI.ScreenGUI
            })
            --
            local KeybindModePickerMain = Gamesense:CreateObject("Frame", {
                Name = "KeybindModePickerMain",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex = 25,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Parent = KeybindModePickerOutline
            })
            --
            KeybindModePickerOutline.BackgroundTransparency = 1
            KeybindModePickerMain.BackgroundTransparency = 1
            --
            local UIListLayout_9 = Gamesense:CreateObject("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = KeybindModePickerMain
            })
            --
            function Keybind:UpdateSize()
                KeybindModePickerOutline.Position = UDim2.new(0, KeybindObject.AbsolutePosition.X , 0, KeybindObject.AbsolutePosition.Y + KeybindObject.AbsoluteSize.Y + KeybindModePickerOutline.AbsoluteSize.Y - 2)
            end
            --
            Keybind:UpdateSize()
            --
            Gamesense:Connection(Options.MainUI:GetPropertyChangedSignal("AbsolutePosition"), Keybind.UpdateSize)
            --
            local StartingY = KeybindObject.AbsolutePosition.Y
            local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
            local StartingCanvasPosition = Options.Parent.Parent.CanvasPosition
            --
            Gamesense:Connection(KeybindObject:GetPropertyChangedSignal("AbsolutePosition"), function()
                local CurrentY = KeybindObject.AbsolutePosition.Y
                local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                local CurrentCanvasPosition = Options.Parent.Parent.CanvasPosition
                --
                if MainUICurrentY ~= MainUIStartingY then
                    MainUIStartingY = MainUICurrentY
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if CurrentCanvasPosition ~= StartingCanvasPosition then
                    StartingCanvasPosition = CurrentCanvasPosition
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if Gamesense.UI.Resizing then
                    return
                end
                --
                if CurrentY ~= StartingY then
                    Keybind:RemoveFrame(true)
                end
                --
                StartingY = CurrentY
            end)
            --
            Gamesense:Connection(Options.MainUI:GetPropertyChangedSignal("AbsoluteSize"), function()
                if Keybind.ActiveFrame then
                    KeybindModePickerOutline.Visible = Gamesense:ScrollingCheck(Options.Parent.Parent, KeybindChecker)
                end
                --
                Keybind:UpdateSize()
            end)
            --
            Gamesense:Connection(KeybindObject:GetPropertyChangedSignal("AbsoluteSize"), function()
                Keybind:UpdateSize()
            end)
            --
            if Options.Parent.Parent:IsA("ScrollingFrame") then
                Gamesense:Connection(Options.Parent.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                    Keybind:UpdateSize()
                    --
                    if Keybind.ActiveFrame then
                        KeybindModePickerOutline.Visible = Gamesense:ScrollingCheck(Options.Parent.Parent, KeybindChecker)
                    end
                end)
            end
            --
            for Index, Value in {"Always on", "On hotkey", "Toggle"} do
                local ModeItem = {
                    Active = false,
                    Hovering = false,
                }
                --
                local Inactive = Gamesense:CreateObject("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(208, 208, 208),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = Value,
                    Text = Value,
                    RichText = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 17),
                    BorderSizePixel = 0,
                    TextSize = Gamesense.UI.FontSize,
                    ZIndex = 25,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = KeybindModePickerMain
                })
                --
                local Button_4 = Gamesense:CreateObject("TextButton", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_4",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    TextSize = Gamesense.UI.FontSize,
                    ZIndex = 25,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = Inactive
                })
                --
                local UIPadding_48 = Gamesense:CreateObject("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = Inactive
                })
                --
                Inactive.TextTransparency = 1
                --
                do -- Functions
                    function ModeItem:Activate()
                        if not ModeItem.Active then
                            if Keybind.CurrentMode ~= nil then
                                Keybind.CurrentMode:Deactivate()
                            end
                            --
                            ModeItem.Active = true
                            --
                            Keybind.Mode = Value
                            Keybind.CurrentMode = ModeItem
                            --
                            Inactive.Text = "<b>" .. Value .. "</b>"
                            Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Gamesense.Theme.Default.Accent})
                            --
                            if Value == "Always on" then
                                if Keybind.Mode == "Always on" then
                                    Keybind:Toggle(true)
                                end
                                --
                                if not Keybind.State then
                                    Keybind.State = true
                                    --
                                    --Gamesense:AddKeybindFrame(Value, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                                else
                                    --Gamesense:UpdateKeybindFrame(Value, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                                end
                            elseif Value == "Toggle" then
                                if Keybind.State then
                                    --Gamesense:UpdateKeybindFrame(Value, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                                end
                            elseif Value == "On hotkey" then
                                Keybind.State = false
                                --
                                --Gamesense:RemoveKeybindFrame(Options.Toggle:GetName(), Options.Toggle:GetSection())
                            end
                        end
                    end
                    --
                    function ModeItem:Deactivate()
                        if ModeItem.Active then
                            ModeItem.Active = false
                            ModeItem.Hovering = false
                            Inactive.Text = Value
                            Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                        end
                    end
                end
                --
                do -- Connections
                    Gamesense:Connection(Button_4.MouseButton1Click, function()
                        ModeItem:Activate()
                    end)
                    --
                    Gamesense:Connection(Inactive.MouseEnter, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        --
                        if ModeItem.Active then return end
                        --
                        Inactive.Text = "<b>" .. Value .. "</b>"
                    end)
                    --
                    Gamesense:Connection(Inactive.MouseLeave, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        --
                        if ModeItem.Active then return end
                        --
                        Inactive.Text = Value
                        Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                    end)
                end
                --
                if Value == Keybind.Mode then
                    ModeItem:Activate()
                end
            end
            --
            Gamesense:Fade(true, Gamesense:GetObjectsTable(KeybindModePickerOutline, true), KeybindModePickerOutline, 0.1)
        end
        --
        function Keybind:RemoveFrame(Fast)
            local Fast = Fast or false
            --
            for Index, Value in Gamesense.UI.ScreenGUI:GetChildren() do
                if Value:IsA("Frame") and Value.Name == "KeybindModePickerOutline" .. Gamesense.UI.TotalKeybindModes then
                    if Fast then
                        Value:Destroy()
                    else
                        Gamesense:Fade(false, Gamesense:GetObjectsTable(Value, true), Value, 0.1)
                        --
                        task.delay(Gamesense.UI.TweenSpeed, function()
                            Value:Destroy()
                        end)
                    end
                end
            end
        end
        --
        function Keybind:FindFrame()
            for Index, Value in Gamesense.UI.ScreenGUI:GetChildren() do
                if Value:IsA("Frame") and Value.Name == "KeybindModePickerOutline" .. Gamesense.UI.TotalKeybindModes then
                    return true
                end
            end
            --
            return false
        end
        --
        function Keybind:ToggleFrame()
            Gamesense:TweenObject(KeybindObject, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(176, 176, 176)})
            --
            if Gamesense.UI.CurrentSelectedKeybindMode and Gamesense.UI.CurrentSelectedKeybindMode.KeybindObject.Name ~= KeybindObject.Name then
                Gamesense.UI.CurrentSelectedKeybindMode.Keybind:RemoveFrame()
                --
                Gamesense:TweenObject(Gamesense.UI.CurrentSelectedKeybindMode.KeybindObject, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(117, 117, 117)})
            end
            --
            if not Keybind:FindFrame() then
                Keybind.ActiveFrame = true
                Keybind:AddFrame()
            else
                Keybind.ActiveFrame = false
                Keybind:RemoveFrame()
            end
        end
    end
    --
    do -- Connections
        Gamesense:Connection(KeybindObject.MouseEnter, function()
            if Keybind.SelectingKeybind then return end
            --
            Gamesense:TweenObject(KeybindObject, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(176, 176, 176)})
        end)
        --
        Gamesense:Connection(KeybindObject.MouseLeave, function()
            if Keybind.SelectingKeybind then return end
            --
            Gamesense:TweenObject(KeybindObject, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(117, 117, 117)})
        end)
        --
        Gamesense:Connection(Button_4.MouseButton2Click, function()
            if not Options.UseMode then return end
            --
            Keybind:ToggleFrame()
        end)
        --
        Gamesense:Connection(Button_4.MouseButton1Click, function()
            if Keybind.Connection then
                Keybind.Connection:Disconnect()
            end
            --
            Keybind.SelectingKeybind = true
            --
            Gamesense:TweenObject(KeybindObject, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 0, 0)})
            --
            Keybind.Connection = Gamesense:Connection(UserInputService.InputBegan, function(Input)
                Keybind:Set(Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode or Input.UserInputType)
                --
                if Keybind.Connection then
                    Keybind.Connection:Disconnect()
                    --
                    task.delay(0.1, function()
                        Keybind.Connection = nil
                        Keybind.SelectingKeybind = false
                    end)
                end
            end)
        end)
        --
        Gamesense:Connection(UserInputService.InputBegan, function(Input, Proccessed)
            if Proccessed then return end
            --
            if (Input.UserInputType == Enum.UserInputType.Keyboard and Keybind.Keybind ~= "[-]" and Input.KeyCode == Keybind.RegKeybind) or (Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Keybind == "MB1") or (Input.UserInputType == Enum.UserInputType.MouseButton2 and Keybind.Keybind == "MB2") or (Input.UserInputType == Enum.UserInputType.MouseButton3 and Keybind.Keybind == "MMB") then
                if Keybind.Mode == "Always on" then
                    Keybind:Toggle(true)
                else
                    Keybind:Toggle()
                end
            end
        end)
        --
        Gamesense:Connection(UserInputService.InputEnded, function(Input, Proccessed)
            if Proccessed then return end
            --
            if Keybind.Mode == "On hotkey" then
                if (Input.UserInputType == Enum.UserInputType.Keyboard and Keybind.Keybind ~= "[-]" and Input.KeyCode == Keybind.RegKeybind) or (Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Keybind == "MB1") or (Input.UserInputType == Enum.UserInputType.MouseButton2 and Keybind.Keybind == "MB2") or (Input.UserInputType == Enum.UserInputType.MouseButton3 and Keybind.Keybind == "MMB") then
                    Keybind:Toggle()
                end
            end
        end)
    end
    --
    if Options.Hiding then
        Keybind:SetVisible(false)
    end
    --
    return Keybind
end
--
function Gamesense:MultiBox(Options)
    Options = Gamesense:Validate({
        Default = "None",
        Name = "Preview MultiBox",
        Content = {},
        Parent = nil,
        MainUI = nil,
        Hiding = false,
        TabUI = nil,
        Risky = false,
        Flag = Gamesense:NewFlag(),
        Callback = function() end
    }, Options or {})
    --
    local MultiBox = {
        Open = false,
        Hover = false,
        Items = Options.Content,
        Scrollable = false,
        Value = {},
        SelectedOrder = {},
        AllItems = {},
    }
    --
    Gamesense.Flags[Options.Flag] = MultiBox
    Options.Callback(Options.Default)
    --
    local PreviewMultiBox_5 = Gamesense:CreateObject("Frame", {
        Name = "PreviewMultiBox_5",
        BackgroundTransparency = 1,
        Size = Options.Name == "" and UDim2.new(1, 0, 0, 20) or UDim2.new(1, 0, 0, 31),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local MultiBoxOutline_5 = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0, 1),
        Name = "MultiBoxOutline_5",
        Position = UDim2.new(0, -1, 1, 0),
        Size = UDim2.new(1, -19, 0, 20),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = PreviewMultiBox_5
    })
    --
    local MultiBoxChecker = Gamesense:CreateObject("Frame", {
        Name = "MultiBoxChecker",
        Position = UDim2.new(0, 0, 1, 0),
        Visible = false,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        Parent = MultiBoxOutline_5
    })
    --
    local MultiBoxBack_5 = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "MultiBoxBack_5",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        Parent = MultiBoxOutline_5
    })
    --
    local MultiBoxArrow = Gamesense:CreateObject("ImageLabel", {
        ImageColor3 = Color3.fromRGB(151, 151, 151),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "MultiBoxArrow",
        Image = "rbxassetid://15556784588",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -11, 0, 6),
        Size = UDim2.new(0, 5, 0, 4),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = MultiBoxBack_5
    })
    --
    local UIGradient_34 = Gamesense:CreateObject("UIGradient", {
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
        },
        Parent = MultiBoxBack_5
    })
    --
    local MultiBoxValue_5 = Gamesense:CreateObject("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(152, 152, 152),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = "None",
        Name = "MultiBoxValue_5",
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = MultiBoxBack_5
    })
    --
    local UIPadding_87 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        Parent = MultiBoxValue_5
    })
    --
    local Button_44 = Gamesense:CreateObject("TextButton", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button_44",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextTransparency = 1,
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = MultiBoxOutline_5
    })
    --
    local MultiBoxName_5 = Gamesense:CreateObject("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Gamesense.Theme.Default.TextColor,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = Options.Name,
        Name = "MultiBoxName_5",
        ZIndex = 3,
        Size = UDim2.new(1, -19, 1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, -4),
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewMultiBox_5
    })
    --
    local UIPadding_88 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        Parent = PreviewMultiBox_5
    })
    --
    local MultiBoxMainOutline = Gamesense:CreateObject("Frame", {
        Name = "MultiBoxMainOutline",
        Position = UDim2.new(0, 0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 10,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = Gamesense.UI.ScreenGUI
    })
    --
    local MultiBoxMain = Gamesense:CreateObject("Frame", {
        Name = "MultiBoxMain",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 10,
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Parent = MultiBoxMainOutline
    })
    --
    MultiBoxMainOutline.BackgroundTransparency = 1
    MultiBoxMain.BackgroundTransparency = 1
    --
    local UIListLayout_9 = Gamesense:CreateObject("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = MultiBoxMain
    })
    --
    do -- Functions
        function MultiBox:Set(Values)
            for Index, Item in MultiBox.AllItems do
                if not table.find(Values, Index) then
                    MultiBox.Items[Index] = false
                else
                    MultiBox.Items[Index] = true
                end
                --
                Item:Toggle()
            end
        end
        --
        function MultiBox:Get()
            return MultiBox.Value
        end
        --
        function MultiBox:SetVisible(Bool)
            local OldValues = Gamesense.Objects[PreviewMultiBox_5]
            --
            MultiBox.Hiding = not Bool
            --
            if Bool then
                Gamesense.Objects[PreviewMultiBox_5] = {PreviewMultiBox_5, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewMultiBox_5), PreviewMultiBox_5, 0.075)
            Gamesense:TweenObject(PreviewMultiBox_5, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and (Options.Name == "" and UDim2.new(1, 0, 0, 20) or UDim2.new(1, 0, 0, 31)) or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[PreviewMultiBox_5] = {PreviewMultiBox_5, OldValues[2], false}
                end
            end)
        end
        --
        function MultiBox:AddValue(Value)
            local Item = {
                Active = false,
                Hovering = false,
            }
            --
            MultiBox.Items[Value] = Item
            --
            local Inactive = Gamesense:CreateObject("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(208, 208, 208),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = Value,
                Text = Value,
                RichText = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 20),
                BorderSizePixel = 0,
                TextSize = Gamesense.UI.FontSize,
                ZIndex = 10,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Parent = MultiBoxMain
            })
            --
            local Button_4 = Gamesense:CreateObject("TextButton", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button_4",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextTransparency = 1,
                TextSize = Gamesense.UI.FontSize,
                ZIndex = 11,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = Inactive
            })
            --
            local UIPadding_48 = Gamesense:CreateObject("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = Inactive
            })
            --
            Inactive.TextTransparency = 1
            --
            do -- Functions
                function Item:GetSelectedItems()
                    local SelectedItems = {}
                    --
                    for _, Item in MultiBox.SelectedOrder do
                        if MultiBox.Items[Item] then
                            table.insert(SelectedItems, Item)
                        end
                    end
                    --
                    return SelectedItems
                end
                --
                function MultiBox:UpdateValue()
                    MultiBox.Value = Item:GetSelectedItems()
                    --
                    MultiBoxValue_5.Text = Gamesense:ClampString(table.concat(MultiBox.Value, ", "), MultiBoxMain.AbsoluteSize.X - MultiBoxArrow.AbsoluteSize.X - 4)
                end
                --
                function Item:SelectItem(Item)
                    if not table.find(MultiBox.SelectedOrder, Item) then
                        table.insert(MultiBox.SelectedOrder, Item)
                    end
                    --
                    MultiBox:UpdateValue()
                end

                function Item:DeselectItem(Item)
                    for Index, Value in MultiBox.SelectedOrder do
                        if Value == Item then
                            table.remove(MultiBox.SelectedOrder, Index)
                            --
                            break
                        end
                    end
                    --
                    MultiBox:UpdateValue()
                end
                --
                function Item:Activate()
                    if not Item.Active then
                        Item.Active = true
                        MultiBox.CurrentItem = Item
                        MultiBox.Items[Value] = true
                        Gamesense.Flags[Options.Flag] = MultiBox
                        Item:SelectItem(Value)
                        Options.Callback(MultiBox.Value)
                        --
                        Inactive.Text = "<b>" .. Value .. "</b>"
                        Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Gamesense.Theme.Default.Accent})
                        Gamesense:AddTheme(Inactive, {
                            TextColor3 = "Accent",
                        })
                    end
                end
                --
                function Item:Deactivate()
                    if Item.Active then
                        Item.Active = false
                        Item.Hovering = false
                        MultiBox.CurrentItem = nil
                        Gamesense.Flags[Options.Flag] = MultiBox
                        MultiBox.Items[Value] = false
                        Item:DeselectItem(Value)
                        Options.Callback(MultiBox.Value)
                        --
                        Inactive.Text = Value
                        Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                        Gamesense:AddTheme(Inactive, {
                            TextColor3 = "TextColor",
                        })
                    end
                end
                --
                function Item:Toggle()
                    MultiBox.Items[Value] = not MultiBox.Items[Value]
                    --
                    if MultiBox.Items[Value] then
                        Item:Activate()
                    else
                        Item:Deactivate()
                    end
                end
            end
            --
            do -- Connections
                Gamesense:Connection(Button_4.MouseButton1Click, function()
                    if MultiBox.Hiding then return end
                    --
                    Item:Toggle()
                end)
                --
                Gamesense:Connection(Inactive.MouseEnter, function()
                    Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    --
                    if Item.Active then return end
                    --
                    Inactive.Text = "<b>" .. Value .. "</b>"
                end)
                --
                Gamesense:Connection(Inactive.MouseLeave, function()
                    Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    --
                    if Item.Active then return end
                    --
                    Inactive.Text = Value
                    Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                end)
            end
            --
            if typeof(Options.Default) == "table" and table.find(Options.Default, Value) then
                Item:Activate()
                Item:SelectItem(Value)
            else
                MultiBox.Items[Value] = false
            end
        end
        --
        function MultiBox:Toggle(Fast)
            local Fast = Fast or false
            local OldValues = Gamesense.Objects[MultiBoxMainOutline]
            --
            if MultiBox.Open then
                if Fast then
                    Gamesense:Fade(false, Gamesense:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0)
                    MultiBoxMainOutline.Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, 0)
                    Gamesense.Objects[MultiBoxMainOutline] = {MultiBoxMainOutline, OldValues[2], true}
                else
                    Gamesense:Fade(false, Gamesense:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0.1)
                    Gamesense:TweenObject(MultiBoxMainOutline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, 0)}, function()
                        Gamesense.Objects[MultiBoxMainOutline] = {MultiBoxMainOutline, OldValues[2], true}
                    end)
                end
            else
                Gamesense.Objects[MultiBoxMainOutline] = {MultiBoxMainOutline, OldValues[2], false}
                --
                if Fast then
                    Gamesense:Fade(true, Gamesense:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0)
                    MultiBoxMainOutline.Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, (#Options.Content * 20) + 2)
                else
                    Gamesense:Fade(true, Gamesense:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0.1)
                    Gamesense:TweenObject(MultiBoxMainOutline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, (#Options.Content * 20) + 2)})
                end	
            end
            --
            MultiBox.Open = not MultiBox.Open
        end
        --
        function MultiBox:Update()
            MultiBoxMainOutline.Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, MultiBoxMainOutline.AbsoluteSize.Y)
            MultiBoxMainOutline.Position = UDim2.new(0, MultiBoxOutline_5.AbsolutePosition.X, 0, ((MultiBoxOutline_5.AbsolutePosition.Y + MultiBoxOutline_5.AbsoluteSize.Y) + GuiService:GetGuiInset().Y + 2))
            --
            if MultiBox.Open then
                MultiBoxMainOutline.Visible = Gamesense:ScrollingCheck(Options.Parent, MultiBoxChecker)
            end
        end
        --
        MultiBox:Update()
        --
        Gamesense:Connection(MultiBoxOutline_5:GetPropertyChangedSignal("AbsolutePosition"), MultiBox.Update)
        Gamesense:Connection(MultiBoxOutline_5:GetPropertyChangedSignal("AbsoluteSize"), MultiBox.Update)
        --
        local StartingX = PreviewMultiBox_5.AbsolutePosition.X
        local StartingY = PreviewMultiBox_5.AbsolutePosition.Y
        local MainUIStartingX = Options.MainUI.AbsolutePosition.X
        local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
        local StartingCanvasPosition = Options.Parent.CanvasPosition
        --
        Gamesense:Connection(PreviewMultiBox_5:GetPropertyChangedSignal("AbsolutePosition"), function()
            if not MultiBox.Open then return end
            --
            local CurrentX = PreviewMultiBox_5.AbsolutePosition.X
            local CurrentY = PreviewMultiBox_5.AbsolutePosition.Y
            local MainUICurrentX = Options.MainUI.AbsolutePosition.X
            local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
            local CurrentCanvasPosition = Options.Parent.CanvasPosition
            --
            if MainUICurrentX ~= MainUIStartingX or MainUICurrentY ~= MainUIStartingY then
                MainUIStartingX = MainUICurrentX
                MainUIStartingY = MainUICurrentY
                StartingX = CurrentX
                StartingY = CurrentY
                --
                return
            end
            --
            if CurrentCanvasPosition ~= StartingCanvasPosition then
                StartingCanvasPosition = CurrentCanvasPosition
                StartingX = CurrentX
                StartingY = CurrentY
                --
                return
            end
            --
            if Gamesense.UI.Resizing then
                return
            end
            --
            if CurrentX ~= StartingX or CurrentY ~= StartingY then
                MultiBox:Toggle(true)
            end
            --
            StartingX = CurrentX
            StartingY = CurrentY
        end)
        --
        if Options.Parent:IsA("ScrollingFrame") then
            Gamesense:Connection(Options.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                MultiBox:Update()
            end)
        end
    end
    --
    do -- Connections
        Gamesense:Connection(Button_44.MouseButton1Click, function()
            if MultiBox.Hiding then return end
            --
            MultiBox:Toggle()
        end)
        --
        Gamesense:Connection(MultiBoxOutline_5.MouseEnter, function()
            if Gamesense.UI.Faded then return end
            --
            if not MultiBox.Open then
                MultiBox.Hovering = true
                Gamesense:TweenObject(MultiBoxBack_5, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            end	
        end)
        --
        Gamesense:Connection(MultiBoxOutline_5.MouseLeave, function()
            if Gamesense.UI.Faded then return end
            --
            if not MultiBox.Open then
                MultiBox.Hovering = false
                Gamesense:TweenObject(MultiBoxBack_5, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
            end	
        end)
    end
    --
    for Index, Value in Options.Content do
        if typeof(Value) == "boolean" or typeof(Value) == "table" then continue end
        --
        MultiBox:AddValue(Value)
    end
    --
    Gamesense:Fade(false, Gamesense:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0.1)
    --
    if Options.Hiding then
        MultiBox:SetVisible(false)
    end
    --
    MultiBox:Toggle(true)
    --
    return MultiBox
end
--
function Gamesense:Dropdown(Options)
    Options = Gamesense:Validate({
        Default = "None",
        Name = "Preview Dropdown",
        Content = {},
        Parent = nil,
        MainUI = nil,
        Hiding = false,
        TabUI = nil,
        Risky = false,
        Flag = Gamesense:NewFlag(),
        Callback = function() end
    }, Options or {})
    --
    local Dropdown = {
        Open = false,
        Active = false,
        Hovering = false,
        CurrentItem = nil,
        Scrollable = false,
        Hiding = false,
        Items = {},
        Value = Options.Default,
    }
    --
    Gamesense.Flags[Options.Flag] = Dropdown
    --
    local PreviewDropdown_5 = Gamesense:CreateObject("Frame", {
        Name = "PreviewDropdown_5",
        BackgroundTransparency = 1,
        Size = Options.Name == "" and UDim2.new(1, 0, 0, 20) or UDim2.new(1, 0, 0, 31),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local DropdownOutline_5 = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0, 1),
        Name = "DropdownOutline_5",
        Position = UDim2.new(0, -1, 1, 0),
        Size = UDim2.new(1, -19, 0, 20),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = PreviewDropdown_5
    })
    --
    local DropdownChecker = Gamesense:CreateObject("Frame", {
        Name = "DropdownChecker",
        Position = UDim2.new(0, 0, 1, 0),
        Visible = false,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        Parent = DropdownOutline_5
    })
    --
    local DropdownBack_5 = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "DropdownBack_5",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        Parent = DropdownOutline_5
    })
    --
    local DropdownArrow = Gamesense:CreateObject("ImageLabel", {
        ImageColor3 = Color3.fromRGB(151, 151, 151),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "DropdownArrow",
        Image = "rbxassetid://15556784588",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -11, 0, 6),
        Size = UDim2.new(0, 5, 0, 4),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = DropdownBack_5
    })
    --
    local UIGradient_34 = Gamesense:CreateObject("UIGradient", {
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
        },
        Parent = DropdownBack_5
    })
    --
    local DropdownValue_5 = Gamesense:CreateObject("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(152, 152, 152),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = Options.Default ~= "None" and table.find(Options.Content, Options.Default) and Options.Default or "None",
        Name = "DropdownValue_5",
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = DropdownBack_5
    })
    --
    local UIPadding_87 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        Parent = DropdownValue_5
    })
    --
    local Button_44 = Gamesense:CreateObject("TextButton", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button_44",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextTransparency = 1,
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = DropdownOutline_5
    })
    --
    local DropdownName_5 = Gamesense:CreateObject("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Gamesense.Theme.Default.TextColor,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = Options.Name,
        Name = "DropdownName_5",
        ZIndex = 3,
        Position = UDim2.new(0, 0, 0, -4),
        Size = UDim2.new(1, -19, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewDropdown_5
    })
    --
    local UIPadding_88 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        Parent = PreviewDropdown_5
    })
    --
    local DropdownMainOutline = Gamesense:CreateObject("Frame", {
        Name = "DropdownMainOutline",
        Position = UDim2.new(0, 0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 10,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = Gamesense.UI.ScreenGUI
    })
    --
    local DropdownMain = Gamesense:CreateObject("Frame", {
        Name = "DropdownMain",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 10,
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Parent = DropdownMainOutline
    })
    --
    DropdownMainOutline.BackgroundTransparency = 1
    DropdownMain.BackgroundTransparency = 1
    --
    local UIListLayout_9 = Gamesense:CreateObject("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = DropdownMain
    })
    --
    do -- Functions
        function Dropdown:Set(State)
            for Index, Value in Dropdown.Items do
                if Index == State then
                    Value:Activate()
                else
                    Value:Deactivate()
                end
            end
        end
        --
        function Dropdown:Get()
            return Dropdown.Value
        end
        --
        function Dropdown:SetVisible(Bool)
            local OldValues = Gamesense.Objects[PreviewDropdown_5]
            --
            Dropdown.Hiding = not Bool
            --
            if Bool then
                Gamesense.Objects[PreviewDropdown_5] = {PreviewDropdown_5, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewDropdown_5), PreviewDropdown_5, 0.075)
            Gamesense:TweenObject(PreviewDropdown_5, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and (Options.Name == "" and UDim2.new(1, 0, 0, 20) or UDim2.new(1, 0, 0, 31)) or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[PreviewDropdown_5] = {PreviewDropdown_5, OldValues[2], false}
                end
            end)
        end
        --
        function Dropdown:AddValue(Value)
            local Item = {
                Active = false,
                Hovering = false,
            }
            --
            Dropdown.Items[Value] = Item
            --
            local Inactive = Gamesense:CreateObject("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(208, 208, 208),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = Value,
                Text = Value,
                RichText = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 20),
                BorderSizePixel = 0,
                TextSize = Gamesense.UI.FontSize,
                ZIndex = 10,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Parent = DropdownMain
            })
            --
            local Button_4 = Gamesense:CreateObject("TextButton", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button_4",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextTransparency = 1,
                TextSize = Gamesense.UI.FontSize,
                ZIndex = 10,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = Inactive
            })
            --
            local UIPadding_48 = Gamesense:CreateObject("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = Inactive
            })
            --
            Inactive.TextTransparency = 1
            --
            do -- Functions
                function Item:Activate()
                    if not Item.Active then
                        if Dropdown.CurrentItem ~= nil then
                            Dropdown.CurrentItem:Deactivate()
                        end
                        --
                        Item.Active = true
                        Dropdown.CurrentItem = Item
                        Dropdown.Value = Value
                        Gamesense.Flags[Options.Flag] = Dropdown
                        Options.Callback(Value)
                        DropdownValue_5.Text = Value
                        --
                        Inactive.Text = "<b>" .. Value .. "</b>"
                        Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Gamesense.Theme.Default.Accent})
                        Gamesense:AddTheme(Inactive, {
                            TextColor3 = "Accent",
                        })
                    end
                end
                --
                function Item:Deactivate()
                    if Item.Active then
                        Item.Active = false
                        Item.Hovering = false
                        Inactive.Text = Value
                        Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                        Gamesense:AddTheme(Inactive, {
                            TextColor3 = "TextColor",
                        })
                    end
                end
            end
            --
            do -- Connections
                Gamesense:Connection(Button_4.MouseButton1Click, function()
                    if Dropdown.Hiding then return end
                    --
                    Item:Activate()
                    Dropdown:Toggle()
                end)
                --
                Gamesense:Connection(Inactive.MouseEnter, function()
                    Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    --
                    if Item.Active then return end
                    --
                    Inactive.Text = "<b>" .. Value .. "</b>"
                end)
                --
                Gamesense:Connection(Inactive.MouseLeave, function()
                    Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    --
                    if Item.Active then return end
                    --
                    Inactive.Text = Value
                    Gamesense:TweenObject(Inactive, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                end)
            end
            --
            if Value == Options.Default then
                Item:Activate()
            end
        end
        --
        function Dropdown:Toggle(Fast)
            local Fast = Fast or false
            local OldValues = Gamesense.Objects[DropdownMainOutline]
            --
            if Dropdown.Open then
                if Fast then
                    Gamesense:Fade(false, Gamesense:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0)
                    DropdownMainOutline.Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, 0)
                    Gamesense.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], true}
                else
                    Gamesense:Fade(false, Gamesense:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
                    Gamesense:TweenObject(DropdownMainOutline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, 0)}, function()
                        Gamesense.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], true}
                    end)
                end
            else
                Gamesense.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], false}
                --
                if Fast then
                    Gamesense:Fade(true, Gamesense:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0)
                    DropdownMainOutline.Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, (#Options.Content * 20) + 2)
                else
                    Gamesense:Fade(true, Gamesense:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
                    Gamesense:TweenObject(DropdownMainOutline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, (#Options.Content * 20) + 2)})
                end	
            end
            --
            Dropdown.Open = not Dropdown.Open
        end
        --
        function Dropdown:Update()
            DropdownMainOutline.Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, DropdownMainOutline.AbsoluteSize.Y)
            DropdownMainOutline.Position = UDim2.new(0, DropdownOutline_5.AbsolutePosition.X, 0, ((DropdownOutline_5.AbsolutePosition.Y + DropdownOutline_5.AbsoluteSize.Y) + GuiService:GetGuiInset().Y + 2))
            --
            if Dropdown.Open then
                DropdownMainOutline.Visible = Gamesense:ScrollingCheck(Options.Parent, DropdownChecker)
            end
        end
        --
        Dropdown:Update()
        --
        Gamesense:Connection(DropdownOutline_5:GetPropertyChangedSignal("AbsolutePosition"), Dropdown.Update)
        Gamesense:Connection(DropdownOutline_5:GetPropertyChangedSignal("AbsoluteSize"), Dropdown.Update)
        --
        local StartingX = PreviewDropdown_5.AbsolutePosition.X
        local StartingY = PreviewDropdown_5.AbsolutePosition.Y
        local MainUIStartingX = Options.MainUI.AbsolutePosition.X
        local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
        local StartingCanvasPosition = Options.Parent.CanvasPosition
        --
        Gamesense:Connection(PreviewDropdown_5:GetPropertyChangedSignal("AbsolutePosition"), function()
            if not Dropdown.Open then return end
            --
            local CurrentX = PreviewDropdown_5.AbsolutePosition.X
            local CurrentY = PreviewDropdown_5.AbsolutePosition.Y
            local MainUICurrentX = Options.MainUI.AbsolutePosition.X
            local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
            local CurrentCanvasPosition = Options.Parent.CanvasPosition
            --
            if MainUICurrentX ~= MainUIStartingX or MainUICurrentY ~= MainUIStartingY then
                MainUIStartingX = MainUICurrentX
                MainUIStartingY = MainUICurrentY
                StartingX = CurrentX
                StartingY = CurrentY
                --
                return
            end
            --
            if CurrentCanvasPosition ~= StartingCanvasPosition then
                StartingCanvasPosition = CurrentCanvasPosition
                StartingX = CurrentX
                StartingY = CurrentY
                --
                return
            end
            --
            if Gamesense.UI.Resizing then
                return
            end
            --
            if CurrentX ~= StartingX or CurrentY ~= StartingY then
                Dropdown:Toggle(true)
            end
            --
            StartingX = CurrentX
            StartingY = CurrentY
        end)
        --
        if Options.Parent:IsA("ScrollingFrame") then
            Gamesense:Connection(Options.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                Dropdown:Update()
            end)
        end
    end
    --
    do -- Connections
        Gamesense:Connection(Button_44.MouseButton1Click, function()
            if Dropdown.Hiding then return end
            --
            Dropdown:Toggle()
        end)
        --
        Gamesense:Connection(DropdownOutline_5.MouseEnter, function()
            if Gamesense.UI.Faded then return end
            --
            if not Dropdown.Open then
                Dropdown.Hovering = true
                Gamesense:TweenObject(DropdownBack_5, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            end	
        end)
        --
        Gamesense:Connection(DropdownOutline_5.MouseLeave, function()
            if Gamesense.UI.Faded then return end
            --
            if not Dropdown.Open then
                Dropdown.Hovering = false
                Gamesense:TweenObject(DropdownBack_5, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
            end	
        end)
    end
    --
    for _, Value in Options.Content do
        Dropdown:AddValue(Value)
    end
    --
    Gamesense:Fade(false, Gamesense:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
    --
    if Options.Hiding then
        Dropdown:SetVisible(false)
    end
    --
    Dropdown:Toggle(true)
    --
    return Dropdown
end
--
function Gamesense:Slider(Options)
    Options = Gamesense:Validate({
        Name = "Preview Slider",
        Min = 0,
        Max = 100,
        Default = 1,
        Decimal = 1,
        UseIcons = true,
        Ending = "",
        Disable = {},
        Hidden = false,
        Risky = false,
        Parent = nil,
        OverrideLimit = false,
        Flag = Gamesense:NewFlag(),
        Callback = function() end
    }, Options or {})
    --
    local Slider = {
        MouseDown = false,
        Hiding = false,
        Hovering = false,
        Connection = nil,
        CurrentValue = -9999,
        LeftControlDown = false,
    }
    --
    Gamesense.Flags[Options.Flag] = Slider
    --
    local PreviewSlider = Gamesense:CreateObject("Frame", {
        Name = "PreviewSlider",
        BackgroundTransparency = 1,
        Size = Options.Name == "" and UDim2.new(1, 0, 0, 7) or UDim2.new(1, 0, 0, 20),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local SliderOutline = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0, 1),
        Name = "SliderOutline",
        Position = UDim2.new(0, -1, 1, 0),
        Size = UDim2.new(1, -19, 0, 7),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = PreviewSlider
    })
    --
    local SliderBack = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "SliderBack",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(205, 205, 205),
        Parent = SliderOutline
    })
    --
    local UIGradient_2 = Gamesense:CreateObject("UIGradient", {
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(81, 81, 81)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(68, 68, 68))
        },
        Parent = SliderBack
    })
    --
    local SliderDrag = Gamesense:CreateObject("Frame", {
        Name = "Slider",
        Size = UDim2.new(0.5, 0, 1, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = SliderBack
    })
    --
    local UIGradient_3 = Gamesense:CreateObject("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Gamesense.Theme.Default.Accent),
            ColorSequenceKeypoint.new(1, Gamesense.Theme.Default.SecondAccent)
        },
        Parent = SliderDrag
    })
    --
    Gamesense:AddTheme(UIGradient_3, {
        Color = {"Accent", "SecondAccent"},
    })
    --
    local Button_4 = Gamesense:CreateObject("TextButton", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button_4",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextTransparency = 1,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = SliderOutline
    })
    --
    local SliderName = Gamesense:CreateObject("TextLabel", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Options.Risky and Gamesense.Theme.Default.Risky or Gamesense.Theme.Default.TextColor,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = Options.Name,
        Name = "SliderName",
        ZIndex = 3,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewSlider
    })
    --
    if Options.Risky then
        Gamesense:AddTheme(SliderName, {
            TextColor3 = "Risky",
        })
    end
    --
    local UIPadding_3 = Gamesense:CreateObject("UIPadding", {
        PaddingTop = UDim.new(0, -4),
        PaddingLeft = UDim.new(0, 20),
        Parent = PreviewSlider
    })
    --
    local SliderValue = Gamesense:CreateObject("TextBox", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Color3.fromRGB(198, 198, 198),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = Options.Default,
        Name = "SliderValue",
        ZIndex = 3,
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 100, 0, 0),
        BackgroundTransparency = 1,
        RichText = true,
        BorderSizePixel = 0,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = Gamesense.UI.FontSize,
        TextStrokeTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = SliderDrag
    })
    --
    local AddButton = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(1, 1),
        Name = "AddButton",
        Position = UDim2.new(1, -13, 1, -3),
        Size = UDim2.new(0, 3, 0, 1),
        ZIndex = 3,
        BorderSizePixel = 0,
        Visible = Options.UseIcons,
        BackgroundColor3 = Color3.fromRGB(100, 100, 100),
        Parent = PreviewSlider
    })
    --
    local AddButton2 = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(0, 1, 0, 3),
        Name = "AddButton2",
        Position = UDim2.new(0, 1, 0, -1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        Visible = Options.UseIcons,
        BackgroundColor3 = Color3.fromRGB(100, 100, 100),
        Parent = AddButton
    })
    --
    local AddActualButton = Gamesense:CreateObject("TextButton", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "AddActualButton",
        TextTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 11, 0, 7),
        Visible = Options.UseIcons,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -9, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 3,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewSlider
    })
    --
    local MinusActualButton = Gamesense:CreateObject("TextButton", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "MinusActualButton",
        TextTransparency = 1,
        Visible = Options.UseIcons,
        AnchorPoint = Vector2.new(0, 1),
        Size = UDim2.new(0, 11, 0, 7),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -12, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 3,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewSlider
    })
    --
    local MinusButton = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0, 1),
        Name = "MinusButton",
        Visible = Options.UseIcons,
        Position = UDim2.new(0, -8, 1, -3),
        Size = UDim2.new(0, 3, 0, 1),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(100, 100, 100),
        Parent = PreviewSlider
    })
    --
    local function GetValue(Value)
        return typeof(Value) == "string" and Value or ("%.14g"):format(Value)
    end
    --
    local function SetValue(Value, IgnoreLimit)
        if (not Value) or Slider.Hiding then return end
        --
        local OriginalValue = Value
        -- check if we should allow values beyond the max
        if Options.OverrideLimit and IgnoreLimit then
            -- allow any value (still enforce min and decimal rounding)
            Value = Value and math.max(Options.Decimal * math.round(tonumber(Value) / Options.Decimal), Options.Min) or 0
        else
            -- default behavior: clamp between min and max
            Value = Value and math.clamp(Options.Decimal * math.round(tonumber(Value) / Options.Decimal), Options.Min, Options.Max) or 0
        end
        
        local ValueText = Options.Disable[1] and ((Value <= Options.Disable[2] or Value >= Options.Disable[3]) and Options.Disable[1]) or tostring(GetValue(Value)) .. Options.Ending
        --
        SliderValue.Text = "<b>" .. ValueText .. "</b>"
        --
        if Value ~= Slider.CurrentValue then
            Slider.CurrentValue = Value
            --
            -- always display the slider within bounds, even if the value is beyond max
            local DisplayValue = math.min(Value, Options.Max)
            Gamesense:TweenObject(SliderDrag, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new((DisplayValue - Options.Min) / (Options.Max - Options.Min), 0, 1, 0)})
            --
            SliderValue.Size = UDim2.fromOffset(SliderValue.TextBounds.X, SliderValue.TextBounds.Y)
            SliderValue.Position = UDim2.new(1, SliderValue.TextBounds.X / 2, 0, -4)
        end
        --
        Gamesense.Flags[Options.Flag] = Slider
        Options.Callback(tonumber(GetValue(Value)))
    end
    --
    SetValue(Options.Default)
    --
    function Slider:Get()
        return tonumber(GetValue(Slider.CurrentValue))
    end
    --
    function Slider:Max()
        return Options.Max
    end
    --
    function Slider:Min()
        return Options.Min
    end
    --
    function Slider:Set(Value)
        if not Value then return end
        --
        SetValue(Value, Options.OverrideLimit) -- allow overriding limits for api calls too
    end
    --
    function Slider:GetName()
        return Options.Name
    end
    --
    function Slider:SetVisible(Bool)
        local OldValues = Gamesense.Objects[PreviewSlider]
        --
        Slider.Hiding = not Bool
        SliderValue.Visible = Bool
        --
        if Bool then
            Gamesense.Objects[PreviewSlider] = {PreviewSlider, OldValues[2], true}
        end
        --
        Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewSlider), PreviewSlider, 0.075)
        Gamesense:TweenObject(PreviewSlider, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and (Options.Name == "" and UDim2.new(1, 0, 0, 7) or UDim2.new(1, 0, 0, 20)) or UDim2.new(1, 0, 0, -10)}, function()
            if not Bool then
                Gamesense.Objects[PreviewSlider] = {PreviewSlider, OldValues[2], false}
            end
        end)
    end
    --
    local function SlideBar(Input)
        local SizeX = (Input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
        local Value = math.clamp((Options.Max - Options.Min) * SizeX + Options.Min, Options.Min, Options.Max)
        --
        SetValue(Value)
    end
    --
    do -- Connections
        Gamesense:Connection(SliderOutline.MouseEnter, function()
            if Gamesense.UI.Faded then return end
            --
            Gamesense:TweenObject(SliderBack, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        end)
        --
        Gamesense:Connection(SliderOutline.MouseLeave, function()
            if Gamesense.UI.Faded then return end
            --
            Gamesense:TweenObject(SliderBack, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(205, 205, 205)})
        end)
        --
        Gamesense:Connection(MinusActualButton.MouseButton1Click, function()
            if Gamesense.UI.Faded then return end
            --
            Slider:Set(Slider.CurrentValue - Options.Decimal)
        end)
        --
        Gamesense:Connection(AddActualButton.MouseButton1Click, function()
            if Gamesense.UI.Faded then return end
            --
            Slider:Set(Slider.CurrentValue + Options.Decimal)
        end)
        --
        Gamesense:Connection(Button_4.MouseButton1Down, function()
            if Gamesense.UI.Faded then return end
            --
            Gamesense.UI.DraggingGui = SliderDrag
            Slider.MouseDown = true
            SlideBar({Position = UserInputService:GetMouseLocation()})
        end)
        --
        Gamesense:Connection(SliderValue.FocusLost, function()
            local NewValue = tonumber(SliderValue.Text)
            --
            if NewValue then
                SetValue(NewValue, Options.OverrideLimit) -- pass true to allow exceeding max
            else
                SetValue(Options.Min)
            end
        end)
        --
        Gamesense:Connection(UserInputService.InputChanged, function(Input)
            if Gamesense.UI.Faded then return end
            --
            if Gamesense.UI.DraggingGui ~= SliderDrag and not (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
                return
            end
            --
            if Slider.MouseDown and Input.UserInputType == Enum.UserInputType.MouseMovement then
                SlideBar(Input)
            end
        end)
        --
        Gamesense:Connection(UserInputService.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Slider.MouseDown = false
            end
        end)
    end
    --
    if Options.Hidden then
        Slider:SetVisible(false)
    end
    --
    return Slider
end
--
function Gamesense:Toggle(Options)
    Options = Gamesense:Validate({
        Default = false,
        Name = "Preview Toggle",
        Risky = false,
        SectionName = nil,
        Parent = nil,
        Hidden = false,
        AnchorPoint = Vector2.new(0, 0),
        MainUI = nil,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 0),
        UseToggleOutline = false,
        ZIndex = 2,
        Flag = Gamesense:NewFlag(),
        Callback = function() end
    }, Options or {})
    --
    local Toggle = {
        Active = false,
        Hovering = false,
        State = false,
        Hiding = false,
        MainUI = Options.MainUI,
        TabUI = Options.TabUI,
        ColorPickers = {},
        KeybindState = false,
    }
    --
    Gamesense.Flags[Options.Flag] = Toggle
    --
    local PreviewToggle = Gamesense:CreateObject("Frame", {
        Name = "PreviewToggle",
        BackgroundTransparency = 1,
        Size = Options.Size,
        Position = Options.Position,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Options.AnchorPoint,
        ZIndex = Options.ZIndex or 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local ToggleOutline = Gamesense:CreateObject("Frame", {
        Name = "ToggleOutline",
        Size = UDim2.new(0, 8, 0, 8),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = Options.ZIndex or 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = PreviewToggle
    })
    --
    if Options.UseToggleOutline then
        ToggleOutline.AnchorPoint = Options.AnchorPoint
        ToggleOutline.Position = Options.Position
    end
    --
    local ToggleInline = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "ToggleInline",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = Options.ZIndex or 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(227, 227, 227),
        Parent = ToggleOutline
    })
    --
    local UIGradient_3 = Gamesense:CreateObject("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(84, 84, 84)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(74, 74, 74))
        },
        Parent = ToggleInline
    })
    --
    local ToggleMain = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "ToggleInline",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = Options.ZIndex or 2,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ToggleOutline
    })
    --
    Gamesense.Objects[ToggleMain] = {ToggleMain, {BackgroundTransparency = ToggleMain.BackgroundTransparency}, false}
    --
    local UIGradient_32 = Gamesense:CreateObject("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Gamesense.Theme.Default.Accent),
            ColorSequenceKeypoint.new(1, Gamesense.Theme.Default.SecondAccent)
        },
        Parent = ToggleMain
    })
    --
    Gamesense:AddTheme(UIGradient_32, {
        Color = {"Accent", "SecondAccent"},
    })
    --
    local ToggleName = Gamesense:CreateObject("TextLabel", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "ToggleName",
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = Options.ZIndex or 2,
        FontFace = Gamesense.UI.NewFont,
        RichText = true,
        Text = Options.Name,
        TextColor3 = Options.Risky and Gamesense.Theme.Default.Risky or Gamesense.Theme.Default.TextColor,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewToggle
    })
    --
    if Options.Risky then
        Gamesense:AddTheme(ToggleName, {
            TextColor3 = "Risky",
        })
    end
    --
    local UIPadding_7 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        Parent = ToggleName
    })
    --
    local Button_9 = Gamesense:CreateObject("TextButton", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button_9",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextTransparency = 1,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewToggle
    })
    --
    do -- Functions
        function Toggle:ToggleGUI(Bool)
            if Bool == nil then
                Toggle.State = not Toggle.State
            else
                Toggle.State = Bool
            end
            --
            Gamesense:TweenObject(ToggleMain, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = Toggle.State and 0 or 1})
            
            -- update the stored transparency value in the objects table, this is for the temp fix for the toggle out and toggle in 
            -- since this uses instant out and instant in instead of the normal fade in and fade out
            if Gamesense.Objects[ToggleMain] then
                Gamesense.Objects[ToggleMain][2].BackgroundTransparency = Toggle.State and 0 or 1
            end
            
            --
            Gamesense.Flags[Options.Flag] = Toggle
            Options.Callback(Toggle.State)
        end
        --
        function Toggle:GetName()
            return Options.Name
        end
        --
        function Toggle:GetFlag()
            return Options.Flag
        end
        --
        function Toggle:GetSection()
            return Options.SectionName
        end
        --
        function Toggle:GetState()
            return Toggle.State
        end
        --
        function Toggle:GetCallback(b)
            Options.Callback(b)
        end
        --
        function Toggle:Set(Value)
            Toggle:ToggleGUI(Value)
        end
        --
        function Toggle:SetName(Name)
            Options.Name = Name
            ToggleName.Text = Name
        end
        --
        function Toggle:Get()
            return Toggle.State
        end
        --
        function Toggle:SetVisible(Bool)
            local OldValues = Gamesense.Objects[PreviewToggle]
            --
            Toggle.Hiding = not Bool
            --
            if Bool then
                Gamesense.Objects[PreviewToggle] = {PreviewToggle, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewToggle), PreviewToggle, 0.075)
            Gamesense:TweenObject(PreviewToggle, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and UDim2.new(1, 0, 0, 8) or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[PreviewToggle] = {PreviewToggle, OldValues[2], false}
                end
            end)
        end
        --
        function Toggle:ColorPicker(Opt)
            Opt = Gamesense:Validate({
                Name = "Preview Color Picker",
                Default = Gamesense.Theme.Default.Accent,
                Flag = Gamesense.NewFlag(),
                Alpha = 0,
                AlphaBar = true,
                Callback = function() end,
            }, Opt or {})
            --
            local ColorPicker = {}
            --
            Toggle.ColorPickers[#Toggle.ColorPickers + 1] = ColorPicker
            --
            local ColorPickerFrame = Gamesense:ColorPicker({
                Name = Opt.Name,
                Default = Opt.Default,
                Flag = Opt.Flag,
                Alpha = Opt.Alpha,
                AlphaBar = Opt.AlphaBar,
                MainUI = Toggle.MainUI,
                TabUI = Toggle.TabUI,
                Callback = Opt.Callback,
                Parent = PreviewToggle,
                Keybind = Toggle.KeybindState,
                Count = #Toggle.ColorPickers,
            })
            --
            return ColorPickerFrame
        end
        --
        function Toggle:Keybind(Opt)
            Opt = Gamesense:Validate({
                Default = Enum.KeyCode.Backspace,
                Mode = "Toggle",
                UseMode = true,
                HideFromList = false,
                Blacklisted = {},
                Hiding = false,
                ChangeToggle = false,
                Flag = Gamesense.NewFlag(),
                Callback = function() end,
            }, Opt or {})
            --
            local Keybind = {}
            --
            Toggle.KeybindState = true
            --
            Gamesense:Keybind({
                Default = Opt.Default,
                Mode = Opt.Mode,
                HideFromList = Opt.HideFromList,
                Blacklisted = Opt.Blacklisted,
                Parent = PreviewToggle,
                UseMode = Opt.UseMode,
                Toggle = Toggle,
                MainUI = Toggle.MainUI,
                TabUI = Toggle.TabUI,
                Hiding = Opt.Hiding,
                ToggleState = Toggle.State,
                ChangeToggle = Opt.ChangeToggle,
                Flag = Opt.Flag,
                Callback = Opt.Callback,
                Count = #Toggle.ColorPickers + 1,
            })
            --
            return Keybind
        end
    end
    --
    do -- Connections
        Gamesense:Connection(PreviewToggle.MouseEnter, function()
            if Gamesense.UI.Faded then return end
            --
            Gamesense:TweenObject(ToggleInline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        end)
        --
        Gamesense:Connection(PreviewToggle.MouseLeave, function()
            if Gamesense.UI.Faded then return end
            --
            Gamesense:TweenObject(ToggleInline, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(227, 227, 227)})
        end)
        --
        Gamesense:Connection(Button_9.MouseButton1Click, function()
            if Gamesense.UI.Faded then return end
            --
            if Toggle.Hiding then return end
            --
            Toggle:ToggleGUI()
        end)
    end
    --
    Toggle:ToggleGUI(Options.Default)
    --
    if Options.Hidden then
        Toggle:SetVisible(false)
    end
    --
    return Toggle
end
--
function Gamesense:Label(Options)
    Options = Gamesense:Validate({
        Message = "Preview Label",
        Side = "Left",
        Risky = false,
        Parent = nil,
        MainUI = nil,
        SectionName = nil,
        Hidden = false,
        TabUI = nil,
        Callback = function() end
    }, Options or {})
    --
    local Label = {
        ColorPickers = {},
        KeybindState = false,
        Hiding = false,
        MainUI = Options.MainUI,
        TabUI = Options.TabUI,
        State = true,
    }
    --
    local PreviewLabel = Gamesense:CreateObject("Frame", {
        Name = "PreviewLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local LabelText = Gamesense:CreateObject("TextLabel", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "ToggleName",
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment[Options.Side],
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, -1),
        ZIndex = 2,
        FontFace = Gamesense.UI.NewFont,
        RichText = true,
        Text = Options.Message,
        TextColor3 = Color3.fromRGB(198, 198, 198),
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PreviewLabel
    })
    --
    local UIPadding_7 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        Parent = LabelText
    })
    --
    do -- Functions
        function Label:GetName()
            return Options.Message
        end
        --
        function Label:GetState()
            return Label.State
        end
        --
        function Label:GetSection()
            return Options.SectionName
        end
        --
        function Label:GetCallback(Bool)
            Options.Callback(Bool)
        end
        --
        function Label:SetVisible(Bool)
            local OldValues = Gamesense.Objects[PreviewLabel]
            --
            Label.Hiding = not Bool
            --
            if Bool then
                Gamesense.Objects[PreviewLabel] = {PreviewLabel, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewLabel), PreviewLabel, 0.075)
            Gamesense:TweenObject(PreviewLabel, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and UDim2.new(1, 0, 0, 8) or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[PreviewLabel] = {PreviewLabel, OldValues[2], false}
                end
            end)
        end
        --
        function Label:ColorPicker(Opt)
            Opt = Gamesense:Validate({
                Name = "Preview Color Picker",
                Default = Gamesense.Theme.Default.Accent,
                Flag = Gamesense.NewFlag(),
                Alpha = 0,
                AlphaBar = true,
                MainUI = nil,
                Callback = function() end,
            }, Opt or {})
            --
            local ColorPicker = {}
            --
            Label.ColorPickers[#Label.ColorPickers + 1] = ColorPicker
            --
            local ColorPickerFrame = Gamesense:ColorPicker({
                Name = Opt.Name,
                Default = Opt.Default,
                Flag = Opt.Flag,
                Alpha = Opt.Alpha,
                AlphaBar = Opt.AlphaBar,
                MainUI = Label.MainUI,
                TabUI = Label.TabUI,
                Callback = Opt.Callback,
                Parent = PreviewLabel,
                Keybind = Label.KeybindState,
                Count = #Label.ColorPickers,
            })
            --
            return ColorPickerFrame
        end
        --
        function Label:Keybind(Opt)
            Opt = Gamesense:Validate({
                Default = Enum.KeyCode.Backspace,
                Mode = "Toggle",
                UseMode = true,
                HideFromList = false,
                Blacklisted = {},
                Hiding = false,
                Flag = Gamesense.NewFlag(),
                Callback = function() end,
            }, Opt or {})
            --
            local Keybind = {}
            --
            Label.KeybindState = true
            --
            Gamesense:Keybind({
                Default = Opt.Default,
                Mode = Opt.Mode,
                HideFromList = Opt.HideFromList,
                Blacklisted = Opt.Blacklisted,
                Parent = PreviewLabel,
                Toggle = Label,
                UseMode = Opt.UseMode,
                MainUI = Label.MainUI,
                TabUI = Label.TabUI,
                Hiding = Opt.Hiding,
                ToggleState = Label.State,
                Flag = Opt.Flag,
                Callback = Opt.Callback,
                Count = #Label.ColorPickers + 1,
            })
            --
            return Keybind
        end
    end
    --
    if Options.Hidden then
        Label:SetVisible(false)
    end
    --
    return Label
end
--
function Gamesense:TextBox(Options)
    Options = Gamesense:Validate({
        Default = "",
        Name = "Preview TextBox",
        Max = 32,
        Parent = nil,
        Size = UDim2.new(1, 0, 0, 19),
        Position = UDim2.new(0, 0, 0, 0),
        NumbersOnly = false,
        ClearOnFocus = false,
        Hidden = false,
        TypedCheck = false,
        CheckIfPressedEnter = false,
        Risky = false,
        Flag = Gamesense.NewFlag(),
        Callback = function() end
    }, Options or {})
    --
    local TextBox = {
        Focused = false,
        Hovering = false,
        Hiding = false,
    }
    --
    Gamesense.Flags[Options.Flag] = TextBox
    --
    local PreviewTextBox = Gamesense:CreateObject("Frame", {
        Name = "PreviewTextBox",
        BackgroundTransparency = 1,
        Size = Options.Size,
        Position = Options.Position,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local TextBoxOutline = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "TextBoxOutline",
        Position = UDim2.new(0, -1, 0, 0),
        Size = UDim2.new(1, -19, 0, 19),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = PreviewTextBox
    })
    --
    local TextBoxInline = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "TextBoxInline",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Parent = TextBoxOutline
    })
    --
    local TextBoxMain = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "TextBoxMain",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        Parent = TextBoxInline
    })
    --
    local TextBoxObject = Gamesense:CreateObject("TextBox", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Gamesense.Theme.Default.TextColor,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = "",
        ZIndex = 3,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        SelectionStart = 1,
        ClearTextOnFocus = Options.ClearOnFocus,
        PlaceholderColor3 = Gamesense.Theme.Default.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = "_",
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = TextBoxMain
    })
    --
    TextBox.Object = TextBoxObject
    --
    local UIPadding_6 = Gamesense:CreateObject("UIPadding", {
        PaddingBottom = UDim.new(0, 2),
        PaddingLeft = UDim.new(0, 5),
        Parent = TextBoxObject
    })
    --
    local UIPadding_7 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        Parent = PreviewTextBox
    })
    --
    do -- Functions
        function TextBox:SetVisible(Bool)
            local OldValues = Gamesense.Objects[PreviewTextBox]
            --
            TextBox.Hiding = not Bool
            TextBoxObject.Visible = Bool
            --
            if Bool then
                Gamesense.Objects[PreviewTextBox] = {PreviewTextBox, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewTextBox), PreviewTextBox, 0.075)
            Gamesense:TweenObject(PreviewTextBox, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and Options.Size or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[PreviewTextBox] = {PreviewTextBox, OldValues[2], false}
                end
            end)
        end
        --
        function TextBox:Get()
            return TextBoxObject.Text
        end
    end
    --
    do -- Connections
        Gamesense:Connection(TextBoxObject:GetPropertyChangedSignal("Text"), function()
            TextBoxObject.Text = TextBoxObject.Text:sub(1, Options.Max)
            --
            if Options.NumbersOnly then
                TextBoxObject.Text = TextBoxObject.Text:gsub('[^%d%.%-]+', '')
            end
            --
            if Options.TypedCheck then
                Gamesense.Flags[Options.Flag] = TextBox
                Options.Callback(TextBoxObject.Text)
            end
            --
            TextBox.Focused = true
        end)
        --
        Gamesense:Connection(TextBoxObject.Focused, function()
            if Gamesense.UI.Faded then return end
            --
            if TextBox.Hiding then
                TextBoxObject:ReleaseFocus()
                --
                return
            end
            --
            TextBox.Focused = true
            --
            TextBoxObject.TextColor3 = Gamesense.Theme.Default.Accent
            --
            Gamesense:AddTheme(TextBoxObject, {
                TextColor3 = "Accent",
            })
            --
            TextBoxObject.PlaceholderText = ""
        end)
        --
        Gamesense:Connection(TextBoxObject.FocusLost, function(EnterPressed)
            if Options.CheckIfPressedEnter and not EnterPressed then return end
            --
            TextBox.Focused = false
            TextBoxObject.PlaceholderText = "_"
            --
            TextBoxObject.TextColor3 = Gamesense.Theme.Default.TextColor
            --
            Gamesense:AddTheme(TextBoxObject, {
                TextColor3 = "TextColor",
            })
            --
            Gamesense.Flags[Options.Flag] = TextBox
            Options.Callback(TextBoxObject.Text)
        end)
    end
    --
    if Options.Hidden then
        TextBox:SetVisible(false)
    end
    --
    return TextBox
end
--
function Gamesense:List(Options)
    Options = Gamesense:Validate({
        Size = 100,
        Hidden = false,
        Flag = Gamesense.NewFlag(),
        Callback = function() end
    }, Options or {})
    --
    local List = {
        CurrentValue = nil,
        CurrentValueName = nil,
    }
    --
    Gamesense.Flags[Options.Flag] = List
    --
    local PreviewList = Gamesense:CreateObject("Frame", {
        Name = "PreviewList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, Options.Size),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local UIPadding_11 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        Parent = PreviewList
    })
    --
    local ListOutline = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -19, 1, -18),
        Name = "ListOutline",
        Position = UDim2.new(0, -1, 0, 18),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = PreviewList
    })
    --
    local ListMain = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "ListMain",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 4,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Parent = ListOutline
    })
    --
    local DownArrow = Gamesense:CreateObject("ImageButton", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "DownArrow",
        Image = "rbxassetid://15540867448",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 1, -9),
        Size = UDim2.new(0, 5, 0, 4),
        ZIndex = 7,
        Visible = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ListMain
    })
    --
    local UpArrow = Gamesense:CreateObject("ImageButton", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "UpArrow",
        Image = "rbxassetid://15540851994",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0, 5),
        Size = UDim2.new(0, 5, 0, 4),
        ZIndex = 7,
        Visible = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ListMain
    })
    --
    local ListScrolling = Gamesense:CreateObject("ScrollingFrame", {
        ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
        MidImage = "rbxassetid://158362264",
        Active = true,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ScrollBarThickness = 5,
        Name = "ListScrolling",
        ZIndex = 3,
        TopImage = "rbxassetid://158362264",
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BottomImage = "rbxassetid://158362264",
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        CanvasPosition = Vector2.new(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Parent = ListOutline
    })
    --
    local UIListLayout_2 = Gamesense:CreateObject("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ListScrolling
    })
    --
    local TextBox = Gamesense:TextBox({Parent = PreviewList, TypedCheck = true, Size = UDim2.new(1, 20, 0, 19), Position = UDim2.new(0, -20, 0, 0), Callback = function(Text)
        List:UpdateSection()
        --
        for _, Frame in ListScrolling:GetChildren() do
            if Frame:IsA("Frame") then
                Frame.Visible = string.find(Frame.Name:lower(), Text:lower()) and true or false
            end
        end
    end})
    --
    do -- Functions
        function List:Get()
            return List.CurrentValueName
        end
        --
        function List:SetVisible(Bool)
            local OldValues = Gamesense.Objects[PreviewList]
            --
            TextBox.Object.Visible = Bool
            --
            if Bool then
                Gamesense.Objects[PreviewList] = {PreviewList, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewList, false), PreviewList, 0.075)
            Gamesense:TweenObject(PreviewList, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and UDim2.new(1, 0, 0, Options.Size) or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[PreviewList] = {PreviewList, OldValues[2], false}
                end
            end)
        end
        --
        function List:AddValue(Value, Icon)
            if ListScrolling:FindFirstChild(Value) then return end
            --
            local ListValue = {
                Active = false,
                Hovering = false,
            }
            --
            local InactiveValue = Gamesense:CreateObject("Frame", {
                Name = Value .. "1",
                Size = UDim2.new(1, 0, 0, 20),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 5,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Parent = ListScrolling
            })
            --
            local Button_912 = Gamesense:CreateObject("TextButton", {
                FontFace = Gamesense.UI.NewFont,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button_9",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextTransparency = 1,
                TextSize = Gamesense.UI.FontSize,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = InactiveValue
            })
            --
            local ValueName_1 = Gamesense:CreateObject("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(208, 208, 208),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "ValueName_1",
                BorderSizePixel = 0,
                Text = Value,
                RichText = true,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 5,
                TextSize = Gamesense.UI.FontSize,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = InactiveValue
            })
            --
            if Icon then
                local Color = Icon.Color or Color3.fromRGB(255, 255, 255)
                --
                local IconImage = Gamesense:CreateObject("ImageLabel", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Image = Icon.Image,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = Icon.Position or UDim2.new(0, 7, 0.5, 0),
                    BackgroundTransparency = 1,
                    Name = "BackImage",
                    Size = Icon.Size or UDim2.new(0, 13, 0, 13),
                    ZIndex = 5,
                    BorderSizePixel = 0,
                    ImageColor3 = Color,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Parent = InactiveValue
                })
                --
                local UIPadding_135 = Gamesense:CreateObject("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    Parent = IconImage
                })
            end
            --
            ValueName_1.Text = Gamesense:ClampString(Value, ValueName_1.AbsoluteSize.X - 25)
            --
            local UIPadding_13 = Gamesense:CreateObject("UIPadding", {
                PaddingLeft = UDim.new(0, (Icon and 25 or 10)),
                Parent = ValueName_1
            })
            --
            do -- Functions
                function ListValue:Activate()
                    if not ListValue.Active then
                        --
                        if List.CurrentValue then
                            List.CurrentValue:Deactivate()
                        end
                        --
                        ListValue.Active = true
                        --
                        ValueName_1.TextColor3 = Gamesense.Theme.Default.Accent
                        ValueName_1.Text = "<b>" .. Value .. "</b>"
                        --
                        Gamesense:AddTheme(ValueName_1, {
                            TextColor3 = "Accent",
                        })
                        --
                        List.CurrentValue = ListValue
                        List.CurrentValueName = Value
                        Gamesense.Flags[Options.Flag] = List
                        Options.Callback(Value)
                    end
                end
                --
                function ListValue:Deactivate()
                    if ListValue.Active then
                        ListValue.Active = false
                        ListValue.Hovering = false
                        ValueName_1.TextColor3 = Gamesense.Theme.Default.TextColor
                        --
                        Gamesense:AddTheme(ValueName_1, {
                            TextColor3 = "TextColor",
                        })
                    end
                end
            end
            --
            do -- Connections
                local OldText = ValueName_1.Text
                --
                Gamesense:Connection(PreviewList:GetPropertyChangedSignal("AbsoluteSize"), function()
                    ValueName_1.Text = Gamesense:ClampString(Value, ValueName_1.AbsoluteSize.X - 25)
                end)
                --
                Gamesense:Connection(InactiveValue.MouseEnter, function()
                    if Gamesense.UI.Faded then return end
                    --
                    InactiveValue.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    OldText = ValueName_1.Text
                    --
                    if not ListValue.Active then
                        ValueName_1.Text = "<b>" .. OldText .. "</b>"
                    end
                end)
                --
                Gamesense:Connection(InactiveValue.MouseLeave, function()
                    if Gamesense.UI.Faded then return end
                    --
                    InactiveValue.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    --
                    if not ListValue.Active then
                        ValueName_1.Text = OldText
                    end
                end)
                --
                Gamesense:Connection(Button_912.MouseButton1Click, function()
                    if Gamesense.UI.Faded then return end
                    --
                    ListValue:Activate()
                end)
            end
        end
        --
        function List:RemoveValue(Value)
            for _, Object in ListScrolling:GetChildren() do
                if Object.Name == Value .. "1" then
                    Object:Destroy()
                end
            end
        end
        --
        function List:UpdateSection()
            local CanvasSize = ListScrolling.AbsoluteCanvasSize.Y
            local AbsoluteSize = ListMain.AbsoluteSize.Y
            --
            if CanvasSize > AbsoluteSize then
                ListMain.Size = UDim2.new(1, -8, 1, -2)
                UpArrow.Visible = not List:CheckArrows("Up")
                DownArrow.Visible = not List:CheckArrows("Down")
            elseif CanvasSize == AbsoluteSize then
                ListMain.Size = UDim2.new(1, -2, 1, -2)
                UpArrow.Visible = false
                DownArrow.Visible = false
            end
        end
        --
        function List:CheckArrows(Type)
            if Type == "Up" then
                return ListScrolling.CanvasPosition == Vector2.new(0, 0)
            elseif Type == "Down" then
                return ListScrolling.CanvasPosition == Vector2.new(0, ListScrolling.AbsoluteCanvasSize.Y - ListScrolling.AbsoluteSize.Y)
            else
                return false
            end
        end
    end
    --
    List:UpdateSection()
    --
    do -- Connections
        Gamesense:Connection(ListScrolling.ChildAdded, function()
            List:UpdateSection()
        end)
        --
        Gamesense:Connection(ListScrolling.ChildRemoved, function()
            List:UpdateSection()
        end)
        --
        Gamesense:Connection(ListOutline:GetPropertyChangedSignal("AbsoluteSize"), function()
            List:UpdateSection()
        end)
        --
        Gamesense:Connection(ListScrolling:GetPropertyChangedSignal("AbsoluteSize"), function()
            List:UpdateSection()
        end)
        --
        Gamesense:Connection(ListScrolling:GetPropertyChangedSignal("CanvasPosition"), function()
            List:UpdateSection()
        end)
        --
        Gamesense:Connection(UpArrow.MouseButton1Click, function()
            if Gamesense.UI.Faded then return end
            --
            if not UpArrow.Visible then return end
            --
            Gamesense:TweenObject(ListScrolling, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, 0)})
        end)
        --
        Gamesense:Connection(DownArrow.MouseButton1Click, function()
            if Gamesense.UI.Faded then return end
            --
            if not DownArrow.Visible then return end
            --
            Gamesense:TweenObject(ListScrolling, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, ListScrolling.AbsoluteCanvasSize.Y - ListScrolling.AbsoluteSize.Y)})
        end)
    end
    --
    if Options.Hidden then
        List:SetVisible(false)
    end
    --
    return List
end
--
function Gamesense:Button(Options)
    Options = Gamesense:Validate({
        Name = "Preview Button",
        Confirmation = false,
        Parent = nil,
        Hidden = false,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 0),
        Risky = false,
        Callback = function() end
    }, Options or {})
    --
    local Button = {
        MouseDown = false,
        Hovering = false,
        WaitingForConfirm = false,
        Hiding = false,
        ConfirmationTime = 0,
        ConfirmationConnection = nil,
    }
    --
    local PreviewButton = Gamesense:CreateObject("Frame", {
        Name = "PreviewButton",
        BackgroundTransparency = 1,
        Size = Options.Size,
        Position = Options.Position,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Options.Parent
    })
    --
    local ButtonOutline = Gamesense:CreateObject("Frame", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "ButtonOutline",
        Position = UDim2.new(0, -1, 0, 0),
        Size = UDim2.new(1, -19, 0, 25),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = PreviewButton
    })
    --
    local ButtonInline = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "ButtonInline",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Parent = ButtonOutline
    })
    --
    local ButtonMain_1 = Gamesense:CreateObject("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Name = "ButtonMain_1",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        Parent = ButtonInline
    })
    --
    local UIGradient_4 = Gamesense:CreateObject("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
        },
        Parent = ButtonMain_1
    })
    --
    local Button_6 = Gamesense:CreateObject("TextButton", {
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Options.Risky and Gamesense.Theme.Default.Risky or Gamesense.Theme.Default.TextColor,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button_6",
        RichText = true,
        Text = "<b>" .. Options.Name .. "</b>",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        TextSize = Gamesense.UI.FontSize,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ButtonOutline
    })
    --
    if Options.Risky then
        Gamesense:AddTheme(Button_6, {
            TextColor3 = "Risky",
        })
    end
    --
    local UIPadding_8 = Gamesense:CreateObject("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        Parent = PreviewButton
    })
    --
    do -- Functions
        function Button:UpdateSize(Size)
            ButtonOutline.Size = Size
        end
        --
        function Button:UpdatePosition(Position)
            PreviewButton.Position = Position
        end
        --
        function Button:SetVisible(Bool)
            local OldValues = Gamesense.Objects[PreviewButton]
            --
            Button.Hiding = not Bool
            --
            if Bool then
                Gamesense.Objects[PreviewButton] = {PreviewButton, OldValues[2], true}
            end
            --
            Gamesense:Fade(Bool, Gamesense:GetObjectsTable(PreviewButton), PreviewButton, 0.075)
            Gamesense:TweenObject(PreviewButton, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = Bool and Options.Size or UDim2.new(1, 0, 0, -10)}, function()
                if not Bool then
                    Gamesense.Objects[PreviewButton] = {PreviewButton, OldValues[2], false}
                end
            end)
        end
        --
        function Button:ConfirmationStart()
            Button.MouseDown = true
            Button.WaitingForConfirm = true
            Button.ConfirmationTime = 3
            Button_6.Text = "<b>Are you sure?</b>"
            --
            if Button.ConfirmationConnection then
                coroutine.close(Button.ConfirmationConnection)
                Button.ConfirmationConnection = nil
            end
            --
            Button.ConfirmationConnection = coroutine.create(function()
                for i = 1, 3 do 
                    task.wait(1)
                    --
                    Button.ConfirmationTime = Button.ConfirmationTime - 1
                    --
                    if Button.ConfirmationTime <= 0 then
                        Button_6.Text = "<b>" .. Options.Name .. "</b>"
                        --
                        if Button.MouseDown then
                            Gamesense:TweenObject(Button_6, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Gamesense.Theme.Default.TextColor})
                            --
                            Button.MouseDown = false
                            Button.WaitingForConfirm = false
                        end
                        --
                        break
                    end
                end
            end)
            --
            coroutine.resume(Button.ConfirmationConnection)
        end
    end
    --
    do -- Connections
        Gamesense:Connection(Button_6.MouseButton1Down, function()
            if Gamesense.UI.Faded then return end
            --
            if Button.Hiding then return end
            --
            Gamesense:TweenObject(ButtonMain_1, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(180, 180, 180)})
            --
            if Options.Confirmation then
                if not Button.WaitingForConfirm then
                    Button:ConfirmationStart()
                else
                    if Button.ConfirmationConnection then
                        coroutine.close(Button.ConfirmationConnection)
                        Button.ConfirmationConnection = nil
                    end
                    --
                    Options.Callback()
                    Button.MouseDown = true
                    Button.Hovering = false
                    Button.WaitingForConfirm = false
                    --
                    Gamesense:TweenObject(ButtonMain_1, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(180, 180, 180)})
                    --
                    Button_6.Text = "<b>" .. Options.Name .. "</b>"
                end
            else
                Options.Callback()
                Button.MouseDown = true
            end
        end)
        --
        Gamesense:Connection(UserInputService.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and Button.MouseDown and not Button.WaitingForConfirm then
                Button.Hovering = false
                Button.MouseDown = false
            end
            --
            Gamesense:TweenObject(ButtonMain_1, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
        end)
        --
        Gamesense:Connection(ButtonOutline.MouseEnter, function()
            if Gamesense.UI.Faded then return end
            --
            if not Button.MouseDown then
                Button.Hovering = true
                Gamesense:TweenObject(ButtonMain_1, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            end	
        end)
        --
        Gamesense:Connection(ButtonOutline.MouseLeave, function()
            if Gamesense.UI.Faded then return end
            --
            if not Button.MouseDown then
                Button.Hovering = false
                Gamesense:TweenObject(ButtonMain_1, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
            end	
        end)
    end
    --
    if Options.Hidden then
        Button:SetVisible(false)
    end
    --
    return Button
end
--
function Gamesense:Window(Options)
    Options = Gamesense:Validate({
        Name = "gamesense",
        Size = UDim2.new(0, 700, 0, 612),
        MinResize = UDim2.new(0, 500, 0, 400),
        MaxResize = UDim2.new(0, 10000, 0, 10000),
        CloseBind = Enum.KeyCode.Insert,
    }, Options or {})
    --
    local Window = {
        Visible = true,
        CurrentTab = nil,
        Tabs = {},
    }
    --
    local MainUI = Gamesense:CreateObject("ScreenGui", {
        ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Name = "\0",
        Parent = gethui and gethui() or CoreGui
    })
    --
    Gamesense.UI.ScreenGUI = MainUI
    --
    local Outline = Gamesense:CreateObject("Frame", {
        Name = "Outline",
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = Options.Size,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Parent = MainUI
    })
    --
    Outline:SetAttribute("g", Window.CurrentTab)
    Gamesense.UI.MainUI = Outline
    --
    Outline.Position = UDim2.fromOffset((Viewport.X / 2) - (Outline.Size.X.Offset / 2), (Viewport.Y / 2) - (Outline.Size.Y.Offset / 2))
    Outline.Active = true
    Outline.Draggable = true
    --
    local Inline = Gamesense:CreateObject("Frame", {
        Name = "Inline",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Parent = Outline
    })
    --
    local Inner = Gamesense:CreateObject("Frame", {
        Name = "Inner",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Parent = Inline
    })
    --
    local Outline_1 = Gamesense:CreateObject("Frame", {
        Name = "Outline_1",
        Position = UDim2.new(0, 3, 0, 3),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, -6, 1, -6),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Parent = Inner
    })
    --
    local PatternHolder = Gamesense:CreateObject("Frame", {
        Name = "PatternHolder",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Parent = Outline_1
    })
    --
    local Pattern = Gamesense:CreateObject("ImageLabel", {
        ImageColor3 = Color3.fromRGB(12, 12, 12),
        ScaleType = Enum.ScaleType.Tile,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Image = "rbxassetid://8547666218",
        BackgroundTransparency = 1,
        Name = "Pattern",
        Size = UDim2.new(1, 0, 1, 0),
        TileSize = UDim2.new(0, 8, 0, 8),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = PatternHolder
    })
    --
    local TopBarGradientHolder = Gamesense:CreateObject("Frame", {
        Name = "TopBarGradientHolder",
        Position = UDim2.new(0, 1, 0, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, -2, 0, 4),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Outline_1
    })
    --
    local GradientBar = Gamesense:CreateObject("ImageLabel", {
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Image = "rbxassetid://8508019876",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 1, 0, 1),
        Name = "GradientBar",
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = TopBarGradientHolder
    })
    --
    local UIGradient = Gamesense:CreateObject("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0.550000011920929)
        },
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        },
        Parent = TopBarGradientHolder
    })
    --
    local SideBarMain = Gamesense:CreateObject("Frame", {
        Name = "SideBarMain",
        Position = UDim2.new(0, 1, 0, 5),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(0, 75, 1, -6),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        ClipsDescendants = true,
        Parent = Outline_1
    })
    --
    local Outline_2 = Gamesense:CreateObject("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Name = "Outline_2",
        Position = UDim2.new(1, 0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Parent = SideBarMain
    })
    --
    local Holder = Gamesense:CreateObject("Frame", {
        BackgroundTransparency = 1,
        Name = "Holder",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = SideBarMain
    })
    --
    local UIListLayout = Gamesense:CreateObject("UIListLayout", {
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Holder
    })
    --
    local UIPadding = Gamesense:CreateObject("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        Parent = Holder
    })
    --
    local Inline_4 = Gamesense:CreateObject("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Name = "Inline_4",
        Position = UDim2.new(1, -1, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Parent = SideBarMain
    })
    --
    local ResizeButton = Gamesense:CreateObject("TextButton", {
        FontFace = Gamesense.UI.NewFont,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Name = "Button",
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextTransparency = 1,
        TextSize = Gamesense.UI.FontSize,
        ZIndex = 5,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Outline
    })
    --
    do -- Functions
        function Window:SetTab(Number)
            for Index, Tab in Window.Tabs do
                if Index == Number then
                    if Window.CurrentTab ~= nil then
                        Window.CurrentTab:Deactivate()
                    end
                    --
                    Tab:Activate()
                end
            end
        end
    end
    --
    do -- Connections
        Gamesense:Connection(UserInputService.InputBegan, function(Input)
            if Input.KeyCode == Options.CloseBind then
                Window.Visible = not Window.Visible
                --
                Gamesense:Fade(Window.Visible, Gamesense.Objects, Outline, 0.2)
            end
        end)
        --
        Gamesense:Resizable(Outline, ResizeButton, Options.MinResize, Options.MaxResize)
    end
    --
    function Window:CreateTab(Options)
        Options = Gamesense:Validate({
            Icon = "rbxassetid://8547236654",
        }, Options or {})
        --
        local Tab = {
            Hovering = false,
            Active = false,
            Index = Gamesense.UI.TabIndex + 1,
            SubSectionEnabled = false,
            DropdownSectionEnabled = false,
            Position = "Bottom",
            Sides = {
                Left = {
                    Sections = {},
                    Sizes = 0,
                },
                Right = {
                    Sections = {},
                    Sizes = 0,
                }
            }
        }
        --
        Gamesense.UI.TabIndex = Tab.Index
        --
        local TabActive = Gamesense:CreateObject("Frame", {
            BackgroundTransparency = 1,
            Name = "TabActive",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -2, 0, 64),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Holder
        })
        --
        local Outline_3 = Gamesense:CreateObject("Frame", {
            Name = "Outline_3",
            Size = UDim2.new(1, 0, 1, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            Visible = false,
            Parent = TabActive
        })
        --
        local Inline_1 = Gamesense:CreateObject("Frame", {
            Size = UDim2.new(1, 1, 1, -2),
            Name = "Inline_1",
            Position = UDim2.new(0, 0, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Parent = Outline_3
        })
        --
        local Main = Gamesense:CreateObject("Frame", {
            Size = UDim2.new(1, 1, 1, -2),
            Name = "Main",
            Position = UDim2.new(0, 0, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Parent = Inline_1
        })
        --
        local Pattern_1 = Gamesense:CreateObject("ImageLabel", {
            ImageColor3 = Color3.fromRGB(12, 12, 12),
            ScaleType = Enum.ScaleType.Tile,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Pattern_1",
            Image = "rbxassetid://8547666218",
            BackgroundTransparency = 1,
            TileSize = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            Parent = Main
        })
        --
        local Button = Gamesense:CreateObject("TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/Zekton.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button",
            Text = Options.Icon,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            TextColor3 = Color3.fromRGB(90, 90, 90),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = Gamesense.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = TabActive
        })
        --
        local Icon = Gamesense:CreateObject("ImageLabel", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button",
            Image = Options.Icon,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = Color3.fromRGB(109, 109, 109),
            BorderSizePixel = 0,
            ZIndex = 3,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = TabActive
        })
        --
        local SectionsHolder = Gamesense:CreateObject("Frame", {
            Name = "SectionsHolder",
            BackgroundTransparency = 1,
            Visible = true,
            Position = UDim2.new(0, 76, 0, 5),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -78, 1, -6),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ClipsDescendants = true,
            Parent = Outline_1
        })
        --
        local Left = Gamesense:CreateObject("Frame", {
            BackgroundTransparency = 1,
            Name = "Left",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0, 1, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ClipsDescendants = true,
            Parent = SectionsHolder
        })
        --
        local UIPadding_1 = Gamesense:CreateObject("UIPadding", {
            PaddingTop = UDim.new(0, 19),
            PaddingBottom = UDim.new(0, 19),
            PaddingRight = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 21),
            Parent = Left
        })
        --
        local UIListLayout12 = Gamesense:CreateObject("UIListLayout", {
            Padding = UDim.new(0, 19),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Left
        })
        --
        local Right = Gamesense:CreateObject("Frame", {
            Name = "Right",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 1, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ClipsDescendants = true,
            Parent = SectionsHolder
        })
        --
        local UIPadding_2 = Gamesense:CreateObject("UIPadding", {
            PaddingTop = UDim.new(0, 19),
            PaddingBottom = UDim.new(0, 19),
            PaddingRight = UDim.new(0, 19),
            PaddingLeft = UDim.new(0, 10),
            Parent = Right
        })
        --
        local UIListLayout52 = Gamesense:CreateObject("UIListLayout", {
            Padding = UDim.new(0, 19),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Right
        })
        --
        local SectionsHolder2 = Gamesense:CreateObject("Frame", {
            Name = "SectionsHolder",
            BackgroundTransparency = 1,
            Visible = true,
            Position = UDim2.new(0, 76, 0, 5),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -78, 1, -6),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ClipsDescendants = true,
            Parent = Outline_1
        })
        --
        local SubSectionHolder = Gamesense:CreateObject("Frame", {
            Name = "SubSectionHolder",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -39, 0, 61),
            BorderSizePixel = 0,
            ZIndex = 1,
            Visible = false,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = SectionsHolder2
        })
        --
        Left.Position = UDim2.new(0, 0, 0, Left.AbsoluteSize.Y)
        Right.Position = UDim2.new(0.5, 1, 0, Right.AbsoluteSize.Y)
        SubSectionHolder.Position = UDim2.new(0, 21, 0, SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y)
        --
        do -- Functions
            function Tab:MoveSides(State)
                task.spawn(function()
                    if State then
                        if Tab.Position == "Bottom" then
                            Left.Position = UDim2.new(0, 0, 0, Left.AbsoluteSize.Y)
                            Right.Position = UDim2.new(0.5, 1, 0, Right.AbsoluteSize.Y)
                            SubSectionHolder.Position = UDim2.new(0, 21, 0, SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y)
                        else
                            Left.Position = UDim2.new(0, 0, 0, -Left.AbsoluteSize.Y)
                            Right.Position = UDim2.new(0.5, 1, 0, -Right.AbsoluteSize.Y)
                            SubSectionHolder.Position = UDim2.new(0, 21, 0, -(SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y))
                        end
                        --
                        Gamesense:TweenObject(SubSectionHolder, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 21, 0, 19)})
                        Gamesense:TweenObject(Left, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
                        Gamesense:TweenObject(Right, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 1, 0, 0)})
                    else
                        task.wait(0.001)
                        --
                        local SubSectionPosition = Tab.Position == "Bottom" and SectionsHolder2.AbsoluteSize.Y + 10 or -SectionsHolder2.AbsoluteSize.Y
                        local LeftPosition = Tab.Position == "Bottom" and Left.AbsoluteSize.Y + 10 or -Left.AbsoluteSize.Y
                        local RightPosition = Tab.Position == "Bottom" and Right.AbsoluteSize.Y + 10 or -Right.AbsoluteSize.Y
                        --
                        Gamesense:TweenObject(SubSectionHolder, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 21, 0, SubSectionPosition)})
                        Gamesense:TweenObject(Left, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, LeftPosition)})
                        Gamesense:TweenObject(Right, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 1, 0, RightPosition)})
                    end
                end)
            end
            --
            function Tab:Activate()
                if not Tab.Active then
                    --
                    if Window.CurrentTab ~= nil then
                        Window.CurrentTab:Deactivate()
                    end
                    --
                    Tab.Active = true
                    Tab:MoveSides(true)
                    --
                    Gamesense:TweenObject(Icon, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(210, 210, 210)})
                    Outline_3.Visible = true
                    --
                    Window.CurrentTab = Tab
                    Outline:SetAttribute("g", table.find(Window.Tabs, Tab))
                end
            end
            --
            function Tab:Deactivate()
                if Tab.Active then
                    Tab.Active = false
                    Tab.Hovering = false
                    Outline_3.Visible = false
                    Gamesense:TweenObject(Icon, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(90, 90, 90)})
                    --
                    Tab:MoveSides(false)
                end
            end
        end
        --
        do -- Connections
            Gamesense:Connection(Outline:GetAttributeChangedSignal("g"), function()
                if Outline:GetAttribute("g") > Tab.Index then
                    Tab.Position = "Top"
                elseif Outline:GetAttribute("g") < Tab.Index then
                    Tab.Position = "Bottom"
                end
            end)
            --
            Gamesense:Connection(Outline:GetPropertyChangedSignal("AbsoluteSize"), function()
                if not Tab.Active then
                    SubSectionHolder.Position = UDim2.new(0, 21, 0, SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y)
                    Left.Position = UDim2.new(0, 0, 0, Left.AbsoluteSize.Y)
                    Right.Position = UDim2.new(0.5, 1, 0, Right.AbsoluteSize.Y)
                else
                    Left.Position = UDim2.new(0, 0, 0, 0)
                    Right.Position = UDim2.new(0.5, 1, 0, 0)
                end
            end)
            --
            Gamesense:Connection(Button.MouseButton1Click, function()
                Tab:Activate()
            end)
            --
            Gamesense:Connection(TabActive.MouseEnter, function()
                if not Tab.Active then
                    Tab.Hovering = true
                    Gamesense:TweenObject(Icon, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(168, 168, 168)})
                end
            end)
            --
            Gamesense:Connection(TabActive.MouseLeave, function()
                if not Tab.Active then
                    Tab.Hovering = false
                    Gamesense:TweenObject(Icon, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(90, 90, 90)})
                end
            end)
        end
        --
        Window.Tabs[#Window.Tabs + 1] = Tab
        --
        function Tab:Section(Options)
            Options = Gamesense:Validate({
                Name = "Preview Section",
                Side = "Left",
                Fill = false,
                Size = UDim2.new(1, 0, 0, 40),
                ParentOptions = {},
                Icon = nil,
                Parent = nil,
            }, Options or {})
            --
            local Section = {
                Elements = {},
                SizeButton = nil,
                Hovering = false,
                DragConnection = nil,
                Left = {
                    Order = 1,
                },
                Right = {
                    Order = 1,
                },
            }
            --
            local Parent = Options.Side == "Left" and Left or Right
            --
            local SectionOutline = Gamesense:CreateObject("Frame", {
                Name = "SectionOutline",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, 0, 0, Options.Size),
                AutomaticSize = Options.Fill and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                ZIndex = 1,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = Options.Parent or Parent
            })
            --
            table.insert(Tab.Sides[Options.Side].Sections, SectionOutline)
            --
            task.delay(0.01, function()
                if Options.Fill == false then
                    Tab.Sides[Options.Side].Sizes += SectionOutline.AbsoluteSize.Y + 19
                end
                --
                if Options.Fill then
                    SectionOutline.Size = UDim2.new(1, 0, 1, -(Tab.Sides[Options.Side].Sizes))
                else
                    SectionOutline.Size = UDim2.new(1, 0, 0, Options.Size)
                end
            end)
            --
            local SectionInline = Gamesense:CreateObject("Frame", {
                Name = "SectionInline",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = SectionOutline
            })
            --
            local SectionScrolling = Gamesense:CreateObject("ScrollingFrame", {
                ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
                MidImage = "rbxassetid://158362264",
                Active = true,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ScrollBarThickness = 5,
                Size = UDim2.new(1, -2, 1, -2),
                TopImage = "rbxassetid://158362264",
                Position = UDim2.new(0, 1, 0, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                CanvasPosition = Vector2.new(0, 0),
                BottomImage = "rbxassetid://158362264",
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = SectionInline
            })
            --
            local UIListLayout_3 = Gamesense:CreateObject("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionScrolling
            })
            --
            local UIPadding_8 = Gamesense:CreateObject("UIPadding", {
                PaddingTop = UDim.new(0, 19),
                PaddingBottom = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 18),
                PaddingLeft = UDim.new(0, 18),
                Parent = SectionScrolling
            })
            --
            local SectionMain = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, -2, 1, -2),
                Name = "SectionMain_1",
                Position = UDim2.new(0, 1, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 1,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                Parent = SectionInline
            })
            --
            local SectionFader = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                AnchorPoint = Vector2.new(0, 1),
                Name = "SectionFader",
                Position = UDim2.new(0, 0, 1, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 3,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                Parent = SectionMain
            })
            --
            local DownArrow = Gamesense:CreateObject("ImageButton", {
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "DownArrow",
                Image = "rbxassetid://15540867448",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -10, 1, -9),
                Size = UDim2.new(0, 5, 0, 4),
                ZIndex = 4,
                BorderSizePixel = 0,
                Visible = false,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SectionMain
            })
            --
            local UpArrow = Gamesense:CreateObject("ImageButton", {
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "UpArrow",
                Image = "rbxassetid://15540851994",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -10, 0, 5),
                Size = UDim2.new(0, 5, 0, 4),
                ZIndex = 4,
                BorderSizePixel = 0,
                Visible = false,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SectionMain
            })
            --
            local UIGradient = Gamesense:CreateObject("UIGradient", {
                Rotation = -90,
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                },
                Parent = SectionFader
            })
            --
            local SectionFader2 = Gamesense:CreateObject("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                Name = "SectionFader",
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 3,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                Parent = SectionMain
            })
            --
            local UIGradient = Gamesense:CreateObject("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                },
                Parent = SectionFader2
            })
            --
            local TitleInline = Gamesense:CreateObject("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "TitleInline",
                BorderSizePixel = 0,
                Parent = SectionOutline,
                Position = UDim2.new(0, 9, 0, 0),
                Size = UDim2.new(0, 0, 0, 2),
                ZIndex = 5
            })
            --
            local UIGradient2 = Gamesense:CreateObject("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 19, 19)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24))
                },
                Parent = TitleInline
            })
            --
            local Title = Gamesense:CreateObject("TextButton", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Parent = SectionOutline,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -26, 0, 15),
                ZIndex = 5,
                FontFace = Gamesense.UI.NewFont,
                RichText = true,
                Text = "<b>" .. Options.Name .. "</b>",
                TextColor3 = Color3.fromRGB(198, 198, 198),
                TextSize = Gamesense.UI.FontSize,
                TextStrokeTransparency = 1,
                TextXAlignment = "Left"
            })
            --
            local ResizableButton_6 = Gamesense:CreateObject("ImageButton", {
                ImageColor3 = Color3.fromRGB(40, 40, 40),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                AnchorPoint = Vector2.new(1, 1),
                Image = "http://www.roblox.com/asset/?id=127012144286347",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -2, 1, -2),
                Name = "ResizableButton_6",
                Size = UDim2.new(0, 6, 0, 6),
                BorderSizePixel = 0,
                ZIndex = 5,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SectionOutline
            })
            --
            Section.Elements = {
                Name = Title,
                ContentHolder = SectionScrolling,
            }
            --
            Title.Size = UDim2.fromOffset(Title.TextBounds.X, 15)
            TitleInline.Size = UDim2.new(0, Title.TextBounds.X + 6, 0, 2)
            --
            do -- Functions
                function Section:UpdateSection()
                    local CanvasSizeFloored = math.floor(SectionScrolling.AbsoluteCanvasSize.Y)
                    local AbsoluteSizeFloored = math.floor(SectionMain.AbsoluteSize.Y)
                    --
                    if CanvasSizeFloored > AbsoluteSizeFloored then
                        SectionMain.Size = UDim2.new(1, -8, 1, -2)
                        UpArrow.Visible = not Section:CheckArrows("Up")
                        DownArrow.Visible = not Section:CheckArrows("Down")
                    elseif CanvasSizeFloored == AbsoluteSizeFloored then
                        SectionMain.Size = UDim2.new(1, -2, 1, -2)
                        UpArrow.Visible = false
                        DownArrow.Visible = false
                    end
                end
                --
                function Section:CheckArrows(Type)
                    if Type == "Up" then
                        return SectionScrolling.CanvasPosition == Vector2.new(0, 0)
                    elseif Type == "Down" then
                        return SectionScrolling.CanvasPosition == Vector2.new(0, SectionScrolling.AbsoluteCanvasSize.Y - SectionScrolling.AbsoluteSize.Y)
                    else
                        return false
                    end
                end
                --
                function Section:CalculateHeight(SectionArg, Container)
                    local Padding = 10
                    local Height = 0
                    --
                    for _, Child in Container:GetChildren() do
                        if Child:IsA("GuiObject") and Child.Visible then
                            Height = Height + Child.AbsoluteSize.Y + Padding
                        end
                    end
                    --
                    SectionArg.Size = UDim2.new(SectionArg.Size.X.Scale, SectionArg.Size.X.Offset, 0, math.clamp(Height + 31, 50, SectionOutline.Parent.AbsoluteSize.Y))
                end
                --
                function Section:CalculateButton(Position)
                    if Section.SizeButton then return end
                    --
                    local ButtonOutline = Gamesense:CreateObject("Frame", {
                        Name = "SectionOutline",
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(0, 30, 0, 25),
                        BorderSizePixel = 0,
                        Position = Position,
                        ZIndex = 5,
                        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                        Parent = Gamesense.UI.ScreenGUI
                    })
                    --
                    local ButtonMain = Gamesense:CreateObject("Frame", {
                        Size = UDim2.new(1, -2, 1, -2),
                        Name = "SectionMain_1",
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        ZIndex = 5,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                        Parent = ButtonOutline
                    })
                    --
                    local ButtonText = Gamesense:CreateObject("TextLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Parent = ButtonOutline,
                        Position = UDim2.new(0, 0, 0.5, -1),
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 5,
                        FontFace = Gamesense.UI.NewFont,
                        RichText = true,
                        Text = "Calculate height",
                        TextColor3 = Color3.fromRGB(198, 198, 198),
                        TextSize = Gamesense.UI.FontSize,
                        TextStrokeTransparency = 1,
                        TextXAlignment = "Left"
                    })
                    --
                    local UIPadding_82 = Gamesense:CreateObject("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        Parent = ButtonText
                    })
                    --
                    local Button_945 = Gamesense:CreateObject("TextButton", {
                        FontFace = Gamesense.UI.NewFont,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = "Button_9",
                        BackgroundTransparency = 1,
                        ZIndex = 5,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        TextTransparency = 1,
                        TextSize = Gamesense.UI.FontSize,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = ButtonOutline
                    })
                    --
                    Section.SizeButton = ButtonOutline
                    ButtonOutline.Size = UDim2.fromOffset(ButtonText.TextBounds.X + 16, 25)
                    ButtonOutline.BackgroundTransparency = 1
                    ButtonMain.BackgroundTransparency = 1
                    ButtonText.TextTransparency = 1
                    Button_945.TextTransparency = 1
                    --
                    do -- Connections
                        Gamesense:Connection(Button_945.MouseEnter, function()
                            Section.Hovering = true
                        end)
                        --
                        Gamesense:Connection(Button_945.MouseLeave, function()
                            Section.Hovering = false
                        end)
                        --
                        Gamesense:Connection(Button_945.MouseButton1Click, function()
                            Section:CalculateHeight(SectionOutline, SectionScrolling)
                            Gamesense:Fade(false, Gamesense:GetObjectsTable(ButtonOutline, true), ButtonOutline, 0.1)
                            --
                            task.delay(Gamesense.UI.TweenSpeed, function()
                                for _, Value in ButtonOutline:GetDescendants() do
                                    Value:Destroy()
                                end
                                --
                                ButtonOutline:Destroy()
                                Section.SizeButton = nil
                            end)
                        end)
                    end
                    --
                    Gamesense:Fade(true, Gamesense:GetObjectsTable(ButtonOutline, true), ButtonOutline, 0.1)
                end
            end
            --
            do -- Connections
                Gamesense:Connection(SectionScrolling.ChildAdded, function()
                    Section:UpdateSection()
                end)
                --
                Gamesense:Connection(SectionScrolling.ChildRemoved, function()
                    Section:UpdateSection()
                end)
                --
                Gamesense:Connection(SectionOutline:GetPropertyChangedSignal("AbsoluteSize"), function()
                    Section:UpdateSection()
                end)
                --
                Gamesense:Connection(RunService.PreRender, function() -- fastest option
                    if SectionOutline.AbsoluteSize.Y >= ((SectionOutline.Parent.AbsoluteSize.Y - Tab.Sides[Options.Side].Sizes) - 38) then
                        if Tab.SubSectionEnabled then
                            if #Tab.Sides[Options.Side].Sections <= 3 then
                                SectionOutline.Size = UDim2.new(1, 0, 1, -Tab.Sides[Options.Side].Sizes)
                            end
                        else
                            SectionOutline.Size = UDim2.new(1, 0, 1, -Tab.Sides[Options.Side].Sizes)
                        end
                    end
                    --
                    for _, Child in SectionOutline.Parent:GetChildren() do
                        if Child:IsA("Frame") and Child ~= SectionOutline then
                            if Gamesense:CheckFrameFirst(SectionOutline, Child) then
                                if Child.AbsoluteSize.Y >= ((Child.Parent.AbsoluteSize.Y - Tab.Sides[Options.Side].Sizes) - 38) then
                                    Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (SectionOutline.Parent.AbsoluteSize.Y - SectionOutline.AbsoluteSize.Y) - 57))
                                end
                                --
                                if Child.AbsoluteSize.Y == 50 and (SectionOutline.AbsoluteSize.Y == SectionOutline.Parent.AbsoluteSize.Y - 107) then
                                    SectionOutline.Size = UDim2.new(SectionOutline.Size.X.Scale, SectionOutline.Size.X.Offset, 0, SectionOutline.Parent.AbsoluteSize.Y - 107)
                                end
                            end
                        end
                    end
                end)
                --
                Gamesense:Connection(SectionScrolling:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
                    Section:UpdateSection()
                end)
                --
                Gamesense:Connection(SectionScrolling:GetPropertyChangedSignal("CanvasPosition"), function()
                    UpArrow.Visible = not Section:CheckArrows("Up")
                    DownArrow.Visible = not Section:CheckArrows("Down")
                end)
                --
                Gamesense:Connection(UpArrow.MouseButton1Click, function()
                    if not UpArrow.Visible then return end
                    --
                    Gamesense:TweenObject(SectionScrolling, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, 0)})
                end)
                --
                Gamesense:Connection(DownArrow.MouseButton1Click, function()
                    if not DownArrow.Visible then return end
                    --
                    Gamesense:TweenObject(SectionScrolling, TweenInfo.new(Gamesense.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, SectionScrolling.AbsoluteCanvasSize.Y - SectionScrolling.AbsoluteSize.Y)})
                end)
                --
                do -- Dragging
                    Gamesense:Connection(Title.MouseButton1Down, function()
                        Title.TextColor3 = Gamesense.Theme.Default.Accent
                        --
                        Section.DragConnection = Gamesense:Connection(UserInputService.InputChanged, function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                                local SelectedOptions = {["SubSection"] = Options.ParentOptions, ["Other"] = {Left, Right}}
                                local Selected = Tab.SubSectionEnabled and "SubSection" or "Other"
                                local NewLeft, NewRight = SelectedOptions[Selected][1], SelectedOptions[Selected][2]
                                local Parent2 = Gamesense:SectionDragging(NewLeft) and NewLeft or Gamesense:SectionDragging(NewRight) and NewRight
                                local ParentName = Parent2 == NewLeft and "Left" or "Right"
                                local TopHalf = Parent2 and Input.Position.Y < Parent2.AbsoluteSize.Y / 2
                                --
                                if not Parent2 then return end
                                --
                                SectionOutline.Parent = Parent2
                                --
                                for _, SectionChild in Parent2:GetChildren() do
                                    if SectionChild:IsA("Frame") and SectionChild.Visible then
                                        if SectionChild == SectionOutline then
                                            if TopHalf then
                                                SectionChild.LayoutOrder = (Tab.DropdownSectionEnabled and Parent2 == NewLeft and 2) or 1
                                            else
                                                SectionChild.LayoutOrder = Section[ParentName].Order + 1
                                            endI encountered an error doing what you asked. Could you try again?
