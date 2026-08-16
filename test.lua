if getgenv().GamesenseLib and getgenv().GamesenseLib.Unload then
    getgenv().GamesenseLib:Unload()
end
--
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
local GamesenseLib = {}
GamesenseLib.__index = GamesenseLib
GamesenseLib.Sections = {}
GamesenseLib.Sections.__index = GamesenseLib.Sections

do -- Library Definition
    GamesenseLib.Connections = {}
    GamesenseLib.Errors = {}
    GamesenseLib.Tweens = {}
    GamesenseLib.Objects = {}
    GamesenseLib.Flags = {}
    GamesenseLib.UnnamedFlags = 0
    GamesenseLib.Build = "Beta"
    GamesenseLib.UID = "1"
    GamesenseLib.UnsafeMode = false
    GamesenseLib.InitTime = os.clock()
    GamesenseLib.Folder = "gamesense"
    GamesenseLib.ConfigFolder = "gamesense/Configs"
    GamesenseLib.UI = {
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
            [Enum.KeyCode.Backquote] = "`",
            [Enum.UserInputType.MouseButton1] = "M1",
            [Enum.UserInputType.MouseButton2] = "M2",
            [Enum.UserInputType.MouseButton3] = "M3"
        },
    }
    GamesenseLib.Theme = {
        Objects = {},
        Default = {
            Accent = Color3.fromRGB(153, 196, 39),
            SecondAccent = Color3.fromRGB(124, 158, 32),
            TextColor = Color3.fromRGB(205, 205, 205),
            Risky = Color3.fromRGB(165, 165, 120),
        }
    }

    function GamesenseLib:Validate(Defaults, Options)
        for Index, Value in Defaults do
            if Options[Index] == nil then
                Options[Index] = Value
            end
        end
        return Options
    end

    function GamesenseLib:Connection(Signal, Func, Name, Table)
        Name = Name or "Unknown"
        Table = Table or GamesenseLib.Connections
        local Connection; Connection = Signal:Connect(function(...)
            local Args = {...}
            local Success, Message = pcall(function() coroutine.wrap(Func)(unpack(Args)) end)
            if not Success and not GamesenseLib.Errors[Message] then
                if GamesenseLib.Notify then
                    GamesenseLib:Notify({Message = ("[ERROR] | An error has occurred:\n%s\nName: %s"):format(Message, Name), Delay = math.huge})
                else
                    warn(("[ERROR] | An error has occurred:\n%s\nName: %s"):format(Message, Name))
                end
                GamesenseLib.Errors[Message] = Message
                if Table[Connection] then
                    Table[Connection] = nil
                end
                return Connection and Connection:Disconnect()
            end
        end)
        if Connection and Table then
            table.insert(Table, Connection)
        end
        return Connection
    end

    function GamesenseLib:TweenObject(Object, Info, Goal, Callback)
        if not Object then return end
        local Tween = TweenService:Create(Object, Info, Goal)
        GamesenseLib:Connection(Tween.Completed, Callback or function() end)
        Tween:Play()
        GamesenseLib.Tweens[#GamesenseLib.Tweens + 1] = Tween
    end

    function GamesenseLib:NewFlag()
        GamesenseLib.UnnamedFlags += 1
        return ("UnknownFlag%s"):format(tostring(GamesenseLib.UnnamedFlags))
    end

    function GamesenseLib:ClampString(String, MaxWidth)
        local Clamped = String
        local TextLabel = GamesenseLib:CreateObject("TextLabel", {
            FontFace = GamesenseLib.UI.NewFont,
            TextStrokeTransparency = 0,
            Text = String,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextScaled = false,
            TextWrapped = false,
            Visible = false,
            TextSize = GamesenseLib.UI.FontSize,
            Parent = Client.PlayerGui
        })
        if TextLabel.TextBounds.X <= MaxWidth then
            TextLabel:Destroy()
            return String
        end
        while TextLabel.TextBounds.X > MaxWidth and #Clamped > 0 do
            Clamped = Clamped:sub(1, #Clamped - 1)
            TextLabel.Text = Clamped .. "..."
            task.wait()
        end
        TextLabel:Destroy()
        return Clamped .. "..."
    end

    function GamesenseLib:GetConfig()
        local Config = {}
        for Index, Value in GamesenseLib.Flags do
            if Value.Get and not string.find(Index, "_Status") then
                if typeof(Value:Get()) == "table" and Value:Get().Color and Value:Get().Transparency then
                    local Transparency = Value:Get().Transparency
                    local Hue, Saturation, ValueHSV = Value:Get().Color:ToHSV()
                    Config[Index] = {Hue, Saturation, ValueHSV, Transparency}
                else
                    Config[Index] = Value:Get()
                end
            end
        end
        return HttpService:JSONEncode(Config)
    end

    function GamesenseLib:LoadConfig(Config)
        local ConfigTable = HttpService:JSONDecode(Config)
        for Index, Value in ConfigTable do
            if GamesenseLib.Flags[Index] and GamesenseLib.Flags[Index].Set then
                GamesenseLib.Flags[Index]:Set(Value)
            end
        end
    end

    function GamesenseLib:SectionDragging(Frame)
        local MousePosition = UserInputService:GetMouseLocation()
        local Position = Frame.AbsolutePosition
        local Size = Frame.AbsoluteSize
        local InsideX = MousePosition.X >= Position.X and MousePosition.X <= Position.X + Size.X
        local InsideY = MousePosition.Y >= Position.Y and MousePosition.Y <= Position.Y + Size.Y
        return InsideX and InsideY
    end

    function GamesenseLib:CreateObject(Type, Properties, Hidden)
        local Hidden = Hidden or false
        local Object = Instance.new(Type)
        for Index, Value in Properties do
            if (not RunService:IsStudio()) and Index == "Name" and not string.match(Value, "%d") then
                Value = "\0"
            end
            if Index == "TextStrokeTransparency" and Value == 0 then
                local Stroke = Instance.new("UIStroke")
                Stroke.Parent = Object
                Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                GamesenseLib.Objects[Stroke] = {Stroke, {Parent = Object, LineJoinMode = Enum.LineJoinMode.Miter}, Hidden}
            else
                Object[Index] = Value
            end
        end
        GamesenseLib.Objects[Object] = {Object, Properties, Hidden}
        return Object
    end

    function GamesenseLib:AddTheme(Object, Properties)
        for Index, Value in Properties do
            GamesenseLib.Theme.Objects[Object] = GamesenseLib.Theme.Objects[Object] or {}
            GamesenseLib.Theme.Objects[Object][Index] = Value
        end
    end

    function GamesenseLib:GetTableIndexes(Table, Custom)
        local Table2 = {}
        for Index, Value in Table do
            Table2[Custom and Value[1] or #Table2 + 1] = Index 
        end
        return Table2
    end

    function GamesenseLib:UpdateConfigList(List, Type)
        for _, File in listfiles("gamesense/Configs") do
            local FileName = File:gsub("\\", "/"):gsub("gamesense/Configs/", ""):gsub(".cfg", "")
            if Type == "Remove" then
                List:RemoveValue(FileName)
            else
                List:AddValue(FileName)
            end
        end
    end

    function GamesenseLib:GetObjectsTable(MainUI, AddMain, Ignored)
        local AddMain = AddMain or false
        local Ignored = Ignored or {}
        local DescendantTable = {}
        local NewTable = {}
        for _, Descendant in MainUI:GetDescendants() do
            if table.find(Ignored, Descendant) then continue end
            DescendantTable[#DescendantTable + 1] = Descendant
        end
        if AddMain then
            DescendantTable[#DescendantTable + 1] = MainUI
        end
        for _, Descendant in DescendantTable do
            local Found = GamesenseLib.Objects[Descendant]
            if Found then
                local Properties = Found[2]
                local HiddenValue = Found[3]
                NewTable[#NewTable + 1] = {Descendant, Properties, HiddenValue}
            end
        end
        return NewTable
    end

    function GamesenseLib:SetTableVisible(Table, State, Ignored)
        local Ignored = Ignored or {}
        for _, Object in Table do
            if table.find(Ignored, Object) then continue end
            if typeof(Object) == "table" and Object.SetVisible then 
                Object:SetVisible(State)
            end
        end
    end

    function GamesenseLib:UpdateColor(ColorType, ColorValue)
        GamesenseLib.Theme.Default[ColorType] = ColorValue
        for Object, Properties in GamesenseLib.Theme.Objects do
            for Property, ThemeKeys in Properties do
                if typeof(ThemeKeys) == "table" then
                    if Object:IsA("UIGradient") and Property == "Color" then
                        if GamesenseLib.Theme.Default[ThemeKeys[1]] then
                            Object.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, GamesenseLib.Theme.Default[ThemeKeys[1]]), ColorSequenceKeypoint.new(1, GamesenseLib.Theme.Default[ThemeKeys[2]])}
                        end
                    end
                else
                    if ThemeKeys == ColorType then
                        Object[Property] = GamesenseLib.Theme.Default[ThemeKeys]
                    end
                end
            end
        end
    end

    function GamesenseLib:ViewPlayer(Player)
        if not GamesenseLib.UI.Viewing then
            Camera.CameraSubject = Player.Character.Humanoid
        else
            Camera.CameraSubject = Client.Character.Humanoid
        end
        GamesenseLib.UI.Viewing = not GamesenseLib.UI.Viewing
    end

    function GamesenseLib:GetTableLength(Table)
        local Length = 0
        for Index, Value in pairs(Table) do
            Length += 1
        end
        return Length
    end

    function GamesenseLib:ScrollingCheck(ScrollingFrame, Frame)
        if not ScrollingFrame:IsA("ScrollingFrame") then return true end
        local VisibleTopLeft = ScrollingFrame.CanvasPosition
        local VisibleBottomRight = VisibleTopLeft + ScrollingFrame.AbsoluteWindowSize
        local FrameTopLeft = Frame.AbsolutePosition - ScrollingFrame.AbsolutePosition + ScrollingFrame.CanvasPosition
        local FrameBottomRight = FrameTopLeft + Frame.AbsoluteSize
        return FrameBottomRight.X > VisibleTopLeft.X and FrameTopLeft.X < VisibleBottomRight.X and FrameBottomRight.Y > VisibleTopLeft.Y and FrameTopLeft.Y < VisibleBottomRight.Y
    end

    function GamesenseLib:ClampPosition(Object, Position, Offset)
        local ClampedX = math.clamp(Position.X.Offset, Offset, Viewport.X - Object.AbsoluteSize.X - Offset)
        local ClampedY = math.clamp(Position.Y.Offset, Offset, Viewport.Y - Object.AbsoluteSize.Y - Offset)
        return UDim2.new(Position.X.Scale, ClampedX, Position.Y.Scale, ClampedY)
    end

    function GamesenseLib:Fade(State, Table, MainUI, Speed)
        local IsMainUI = Table == GamesenseLib.Objects
        MainUI.Active = State
        if State then
            MainUI.Visible = true
        end
        if IsMainUI then
            GamesenseLib.UI.Faded = not State
        end
        if not State and IsMainUI then
            for _, obj in pairs(MainUI:GetDescendants()) do
                if obj.ClassName == "Frame" and obj.Name == "ToggleMain" then
                    obj.BackgroundTransparency = 1
                end
            end
        end
        for _, Object in Table do
            if not Object[3] then
                if Object[1].ClassName == "Frame" and (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                    Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                elseif Object[1].ClassName == "ImageLabel" or Object[1].ClassName == "ImageButton" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                        Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                    end
                    if (Object[2]["ImageTransparency"] or 0) ~= 1 then
                        Object[1].ImageTransparency = State and (Object[2]["ImageTransparency"] or 0) or 1
                    end
                elseif Object[1].ClassName == "TextLabel" or Object[1].ClassName == "TextButton" or Object[1].ClassName == "TextBox" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                        Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                    end
                    if (Object[2]["TextTransparency"] or 0) ~= 1 then
                        Object[1].TextTransparency = State and (Object[2]["TextTransparency"] or 0) or 1
                    end
                elseif Object[1].ClassName == "ScrollingFrame" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                        Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                    end
                    if (Object[2]["ScrollBarImageTransparency"] or 0) ~= 1 then
                        Object[1].ScrollBarImageTransparency = State and (Object[2]["ScrollBarImageTransparency"] or 0) or 1
                    end
                elseif Object[1].ClassName == "UIStroke" then
                    Object[1].Transparency = State and (Object[2]["Transparency"] or 0) or 1
                end
            end
        end
        if not State then
            task.delay(Speed, function()
                if not MainUI.Parent then return end
                MainUI.Visible = false
            end)
        end
    end

    function GamesenseLib:CheckFrameFirst(FrameA, FrameB)
        local Parent = FrameA.Parent
        local Frames = {}
        local IndexA, IndexB
        for _, Child in Parent:GetChildren() do
            if Child:IsA("Frame") then
                table.insert(Frames, Child)
            end
        end
        table.sort(Frames, function(a, b)
            if a.LayoutOrder == b.LayoutOrder then
                for _, Child in Parent:GetChildren() do
                    if Child == a then return true end
                    if Child == b then return false end
                end
            end
            return a.LayoutOrder < b.LayoutOrder
        end)
        for i, Frame in Frames do
            if Frame == FrameA then IndexA = i end
            if Frame == FrameB then IndexB = i end
        end
        return IndexA and IndexB and IndexA < IndexB
    end

    function GamesenseLib:Resizable(Object, DragFrame, MinResize, MaxResize, Increments, UseIcon, UseParent, Delay)
        local StartingSize, Dragging, MouseLocation, NewMouse, Hovering
        local function UpdateSize()
            if not MouseLocation then return end
            GamesenseLib.UI.Resizing = true
            local CurrentMousePosition = UserInputService:GetMouseLocation()
            local Delta = CurrentMousePosition - MouseLocation
            local NewSizeX = StartingSize.X.Offset + Delta.X
            local NewSizeY = StartingSize.Y.Offset + Delta.Y
            local Parent = Object.Parent
            local ParentSize = Parent.AbsoluteSize
            if UseParent then
                local OccupiedSpaceY = 0
                local FrameCount = 0
                for _, Child in Parent:GetChildren() do
                    if Child:IsA("Frame") and Child ~= Object then
                        FrameCount += 1
                        if GamesenseLib:CheckFrameFirst(Object, Child) then
                            if Child.AbsoluteSize.Y >= (ParentSize.Y - Object.AbsoluteSize.Y) - 57 then
                                Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (ParentSize.Y - Object.AbsoluteSize.Y) - 57))
                            end
                        else
                            OccupiedSpaceY += Child.AbsoluteSize.Y + 19
                        end
                    end
                end
                if OccupiedSpaceY == 0 then
                    MaxResize = UDim2.new(0, 0, 0, (ParentSize.Y - OccupiedSpaceY) - (FrameCount * (50 + 19)) - 38)
                else
                    MaxResize = UDim2.new(0, 0, 0, (ParentSize.Y - OccupiedSpaceY) - 38)
                end
            end
            if Increments then
                NewSizeY = math.clamp(math.round(NewSizeY / Increments) * Increments, MinResize.Y.Offset, MaxResize.Y.Offset)
            else
                NewSizeY = math.clamp(NewSizeY, MinResize.Y.Offset, MaxResize.Y.Offset)
                NewSizeX = math.clamp(NewSizeX, MinResize.X.Offset, MaxResize.X.Offset)
            end
            return UseParent and UDim2.new(1, 0, 0, NewSizeY) or UDim2.new(0, NewSizeX, 0, NewSizeY)
        end
        GamesenseLib:Connection(DragFrame.MouseEnter, function() Hovering = true end)
        GamesenseLib:Connection(DragFrame.MouseLeave, function()
            if NewMouse then NewMouse:Destroy() NewMouse = nil end
            UserInputService.MouseIconEnabled = true
            Hovering = false
        end)
        GamesenseLib:Connection(DragFrame.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                MouseLocation = UserInputService:GetMouseLocation()
                StartingSize = Object.Size
            end
        end)
        GamesenseLib:Connection(RunService.PreRender, function()
            if (Hovering or Dragging) and UseIcon then
                local MousePosition = UserInputService:GetMouseLocation()
                UserInputService.MouseIconEnabled = false
                if not NewMouse then
                    NewMouse = GamesenseLib:CreateObject("ImageLabel", {
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Image = "rbxassetid://87982048533100",
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Name = "Transparency",
                        Size = UDim2.new(0, 35, 0, 35),
                        ZIndex = 10000,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = GamesenseLib.UI.ScreenGUI
                    }, true)
                end
                NewMouse.Position = UDim2.new(0, MousePosition.X, 0, MousePosition.Y)
            end
            if Dragging then
                if Delay then
                    task.delay(Delay, function() Object.Size = UpdateSize() end)
                else
                    Object.Size = UpdateSize()
                end
            end
        end)
        GamesenseLib:Connection(UserInputService.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
                if NewMouse then NewMouse:Destroy() NewMouse = nil end
                if UseParent then
                    for _, Child in Object.Parent:GetChildren() do
                        if Child:IsA("Frame") and Child ~= Object then
                            if GamesenseLib:CheckFrameFirst(Object, Child) then
                                if Child.AbsoluteSize.Y >= (Object.Parent.AbsoluteSize.Y - Object.AbsoluteSize.Y) - 57 then
                                    Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (Object.Parent.AbsoluteSize.Y - Object.AbsoluteSize.Y) - 57))
                                end
                            end
                        end
                    end
                end
                UserInputService.MouseIconEnabled = true
                Dragging = false
                GamesenseLib.UI.Resizing = false
            end
        end)
    end

    function GamesenseLib:ColorPicker(Options)
        Options = GamesenseLib:Validate({
            Name = "Preview Color Picker",
            Default = GamesenseLib.Theme.Default.Accent,
            Alpha = 0,
            AlphaBar = true,
            Parent = nil,
            MainUI = nil,
            TabUI = nil,
            Count = 1,
            Keybind = false,
            Flag = GamesenseLib:NewFlag(),
            Callback = function() end,
        }, Options or {})
        local Hue, Saturation, Value = Options.Default:ToHSV()
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
            LastCopiedColor = {Options.Default, Options.Alpha},
            FrameOpened = false,
        }
        GamesenseLib.Flags[Options.Flag] = ColorPicker
        GamesenseLib.UI.TotalColorPickers += 1
        if Options.Keybind then
            Options.Count += 1
        end
        local ColorPickerOutline_1 = GamesenseLib:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            Name = "ColorPickerOutline" .. GamesenseLib.UI.TotalColorPickers,
            Position = UDim2.new(1, 0 - (Options.Count - 1) * 22, 0, 0),
            Size = UDim2.new(0, 17, 0, 9),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = Options.Parent
        })
        local ColorPickerChecker = GamesenseLib:CreateObject("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 4),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Visible = false,
            BorderSizePixel = 0,
            Parent = ColorPickerOutline_1
        })
        local Button_9 = GamesenseLib:CreateObject("TextButton", {
            FontFace = GamesenseLib.UI.NewFont,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_9",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = GamesenseLib.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ColorPickerOutline_1
        })
        local ColorPickerTransparency = GamesenseLib:CreateObject("ImageLabel", {
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
        local ColorPickerInline_1 = GamesenseLib:CreateObject("Frame", {
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
        local UIGradient_24 = GamesenseLib:CreateObject("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ColorPicker.Color),
                ColorSequenceKeypoint.new(1, ColorPicker.SecondColor)
            },
            Parent = ColorPickerInline_1
        })
        return ColorPicker
    end

    function GamesenseLib:Keybind(Options)
        Options = GamesenseLib:Validate({
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
            Flag = GamesenseLib.NewFlag(),
            Count = 1,
            ChangeToggle = false,
            Callback = function() end,
        }, Options or {})
        local Keybind = {
            State = false,
            Keybind = Options.Default,
        }
        GamesenseLib.Flags[Options.Flag] = Keybind
        return Keybind
    end

    function GamesenseLib:MultiBox(Options)
        Options = GamesenseLib:Validate({
            Default = "None",
            Name = "Preview MultiBox",
            Content = {},
            Parent = nil,
            MainUI = nil,
            Hiding = false,
            TabUI = nil,
            Risky = false,
            Flag = GamesenseLib.NewFlag(),
            Callback = function() end
        }, Options or {})
        local MultiBox = { Value = Options.Default }
        GamesenseLib.Flags[Options.Flag] = MultiBox
        return MultiBox
    end

    function GamesenseLib:Dropdown(Options)
        Options = GamesenseLib:Validate({
            Default = "None",
            Name = "Preview Dropdown",
            Content = {},
            Parent = nil,
            MainUI = nil,
            Hiding = false,
            TabUI = nil,
            Risky = false,
            Flag = GamesenseLib.NewFlag(),
            Callback = function() end
        }, Options or {})
        local Dropdown = { Value = Options.Default }
        GamesenseLib.Flags[Options.Flag] = Dropdown
        return Dropdown
    end

    function GamesenseLib:Slider(Options)
        Options = GamesenseLib:Validate({
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
            Flag = GamesenseLib.NewFlag(),
            Callback = function() end
        }, Options or {})
        local Slider = { CurrentValue = Options.Default }
        GamesenseLib.Flags[Options.Flag] = Slider
        return Slider
    end

    function GamesenseLib:Toggle(Options)
        Options = GamesenseLib:Validate({
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
            Flag = GamesenseLib:NewFlag(),
            Callback = function() end
        }, Options or {})
        local Toggle = { State = Options.Default }
        GamesenseLib.Flags[Options.Flag] = Toggle
        function Toggle:ColorPicker(opts) return GamesenseLib:ColorPicker(opts) end
        function Toggle:Keybind(opts) return GamesenseLib:Keybind(opts) end
        function Toggle:Set(val) Toggle.State = val Options.Callback(val) end
        function Toggle:Get() return Toggle.State end
        return Toggle
    end

    function GamesenseLib:Label(Options)
        Options = GamesenseLib:Validate({
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
        local Label = { State = true }
        function Label:ColorPicker(opts) return GamesenseLib:ColorPicker(opts) end
        function Label:Keybind(opts) return GamesenseLib:Keybind(opts) end
        return Label
    end

    function GamesenseLib:TextBox(Options)
        Options = GamesenseLib:Validate({
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
            Flag = GamesenseLib.NewFlag(),
            Callback = function() end
        }, Options or {})
        local TextBox = {}
        GamesenseLib.Flags[Options.Flag] = TextBox
        function TextBox:Get() return Options.Default end
        return TextBox
    end

    function GamesenseLib:List(Options)
        Options = GamesenseLib:Validate({
            Size = 100,
            Hidden = false,
            Flag = GamesenseLib.NewFlag(),
            Callback = function() end
        }, Options or {})
        local List = { CurrentValueName = nil }
        GamesenseLib.Flags[Options.Flag] = List
        function List:AddValue(val) end
        function List:RemoveValue(val) end
        return List
    end

    function GamesenseLib:Button(Options)
        Options = GamesenseLib:Validate({
            Name = "Preview Button",
            Confirmation = false,
            Parent = nil,
            Hidden = false,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, 0),
            Risky = false,
            Callback = function() end
        }, Options or {})
        return {}
    end

    function GamesenseLib:Window(Options)
        Options = GamesenseLib:Validate({
            Name = "gamesense",
            Size = UDim2.new(0, 700, 0, 612),
            MinResize = UDim2.new(0, 500, 0, 400),
            MaxResize = UDim2.new(0, 10000, 0, 10000),
            CloseBind = Enum.KeyCode.Insert,
        }, Options or {})
        local Window = { Visible = true, CurrentTab = nil, Tabs = {} }
        local MainUI = GamesenseLib:CreateObject("ScreenGui", {
            ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
            DisplayOrder = 1000,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            Name = "\0",
            Parent = gethui()
        })
        GamesenseLib.UI.ScreenGUI = MainUI
        GamesenseLib.UI.MainUI = MainUI

        function Window:SetTab(Number) end

        function Window:CreateTab(TabOptions)
            local Tab = {}
            function Tab:Section(SecOptions)
                local Section = { Elements = { ContentHolder = MainUI } }
                function Section:Toggle(opts) return GamesenseLib:Toggle(opts) end
                function Section:Slider(opts) return GamesenseLib:Slider(opts) end
                function Section:Dropdown(opts) return GamesenseLib:Dropdown(opts) end
                function Section:MultiBox(opts) return GamesenseLib:MultiBox(opts) end
                function Section:Button(opts) return GamesenseLib:Button(opts) end
                function Section:Label(opts) return GamesenseLib:Label(opts) end
                function Section:TextBox(opts) return GamesenseLib:TextBox(opts) end
                function Section:List(opts) return GamesenseLib:List(opts) end
                return Section
            end
            function Tab:SubSection(SubOptions)
                return Tab:Section(), Tab:Section()
            end
            function Tab:ImageDropdown(ImgOptions) end
            return Tab
        end

        return setmetatable(Window, GamesenseLib)
    end

    function GamesenseLib:CreateWatermark()
        local MainWatermark = GamesenseLib:CreateObject("Frame", {
            Name = "Watermark",
            Position = UDim2.new(0, 5, 0, 5),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(0, 200, 0, 20),
            BorderSizePixel = 0,
            ZIndex = 10000,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            Parent = GamesenseLib.UI.ScreenGUI
        }, true)
        local WatermarkText = GamesenseLib:CreateObject("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(208, 208, 208),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = "gamesense",
            Name = "Text",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            ZIndex = 10000,
            RichText = true,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = MainWatermark
        }, true)
    end

    function GamesenseLib:UpdateWatermark(Text)
        -- Updates watermark text safely
    end

    function GamesenseLib:Notify(Options)
        Options = GamesenseLib:Validate({
            Message = "Notification",
            Delay = 3,
            Position = "Top Left",
        }, Options or {})
        local Path = Options.Position == "Top Left" and GamesenseLib.UI.Notifications.TopLeft or GamesenseLib.UI.Notifications.Middle
        local NotificationFrameObject = GamesenseLib:CreateObject("Frame", {
            Name = "Notification",
            Position = UDim2.new(0, 5, 0, 80 + (#Path * 24)),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(0, 350, 0, 24),
            BorderSizePixel = 0,
            ZIndex = 10000,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Parent = GamesenseLib.UI.ScreenGUI
        }, true)
        local NotificationText = GamesenseLib:CreateObject("TextLabel", {
            FontFace = GamesenseLib.UI.NewFont,
            TextColor3 = Color3.fromRGB(208, 208, 208),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = Options.Message,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 10000,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true,
            TextSize = 13,
            Parent = NotificationFrameObject
        }, true)
        local NotificationFrame = { Object = NotificationFrameObject, Text = NotificationText }
        table.insert(Path, 1, NotificationFrame)
        task.delay(Options.Delay, function()
            if NotificationFrameObject and NotificationFrameObject.Parent then
                NotificationFrameObject:Destroy()
                local index = table.find(Path, NotificationFrame)
                if index then table.remove(Path, index) end
            end
        end)
    end

    function GamesenseLib:Init()
        GamesenseLib.UI.Initialized = true
        GamesenseLib:CreateWatermark()
    end

    function GamesenseLib:Unload()
        if GamesenseLib.UI.ScreenGUI then
            GamesenseLib.UI.ScreenGUI:Destroy()
        end
    end

    function GamesenseLib:Disable()
        for _, Value in GamesenseLib.Flags do
            if Value.Set then
                Value:Set(false)
            end
        end
    end
end

-- ==========================================
-- TEST SCRIPT & NOTIFICATIONS DEMO
-- ==========================================
local Window = GamesenseLib:Window({CloseBind = Enum.KeyCode.Insert})
local RageTab = Window:CreateTab({Icon = "rbxassetid://18248771514"})
Window:SetTab(1)

local RageSection = RageTab:Section({Name = "Aimbot Settings", Fill = true})

RageSection:Toggle({
    Name = "Enable Aimbot",
    Default = true,
    Callback = function(State)
        print("Aimbot:", State)
    end
})

RageSection:Slider({
    Name = "Field of View",
    Min = 0,
    Max = 180,
    Default = 90,
    Callback = function(Val)
        print("FOV:", Val)
    end
})

GamesenseLib:Init()

-- Test Notifications (Hit player/text alerts)
task.spawn(function()
    local Position = "Top Left"
    for i = 1, 3 do
        local R, G, B = GamesenseLib.Theme.Default.Accent.R * 255, GamesenseLib.Theme.Default.Accent.G * 255, GamesenseLib.Theme.Default.Accent.B * 255
        GamesenseLib:Notify({
            Message = ("hit <font color='rgb(%d, %d, %d)'>awesomegamer5</font> in the <font color='rgb(%d, %d, %d)'>head</font> for <font color='rgb(%d, %d, %d)'>100</font> damage"):format(R, G, B, R, G, B, R, G, B),
            Position = Position,
            Delay = 4
        })
        Position = Position == "Top Left" and "Middle" or "Top Left"
        task.wait(1)
    end
end)

return GamesenseLib
