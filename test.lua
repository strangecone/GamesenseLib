if Library and Library.Unload then
    Library:Unload()
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
    if not isfolder("gamesense/Configs") then
        makefolder("gamesense/Configs")
    end
end
--
local Library = {}

do -- Library Core Engine
    Library = {
        Connections = {}, Errors = {}, Tweens = {}, Objects = {},
        Sections = {}, ThemeSections = {}, Flags = {}, UnnamedFlags = 0,
        Build = "Beta", UID = "1", UnsafeMode = false, InitTime = os.clock(),
        Folder = "gamesense", ConfigFolder = "gamesense/Configs",
        UI = {
            Name = "gamesense", CloseBind = Enum.KeyCode.Insert,
            SectionResizeIncrements = 1, WatermarkRefreshRate = 1,
            MainUI = nil, Initialized = false, Faded = false, LastCopiedColor = nil,
            TabIndex = 0, Viewing = false, CurrentSelectedColorPicker = nil,
            CurrentSelectedColorPickerExtra = nil, CurrentSelectedKeybindMode = nil,
            TotalColorPickers = 0, TotalKeybindModes = 0, WatermarkPosition = "Top Right",
            SectionZIndex = 100, Resizing = false, DropdownZIndex = 1,
            OpenColorFrames = 0, ScreenGUI = nil, TweenSpeed = 0.15,
            NewFont = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            FontSize = 13, DraggingGui = nil, Notifications = {TopLeft = {}, Middle = {}},
            Keys = {
                [Enum.KeyCode.LeftShift] = "LSHF", [Enum.KeyCode.RightShift] = "RSHF", [Enum.KeyCode.LeftControl] = "LCTR",
                [Enum.KeyCode.RightControl] = "RCTR", [Enum.KeyCode.LeftAlt] = "LALT", [Enum.KeyCode.RightAlt] = "RALT",
                [Enum.KeyCode.Insert] = "INS", [Enum.UserInputType.MouseButton1] = "M1", [Enum.UserInputType.MouseButton2] = "M2"
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
    
    function Library:Validate(Defaults, Options)
        for Index, Value in pairs(Defaults) do
            if Options[Index] == nil then Options[Index] = Value end
        end
        return Options
    end

    function Library:Connection(Signal, Func, Name, Table)
        Name = Name or "Unknown"
        Table = Table or Library.Connections
        local Connection; Connection = Signal:Connect(function(...)
            local Args = {...}
            local Success, Message = pcall(function() coroutine.wrap(Func)(unpack(Args)) end)
            if not Success and not Library.Errors[Message] then
                Library.Errors[Message] = Message
                if Table[Connection] then Table[Connection] = nil end
                return Connection and Connection:Disconnect()
            end
        end)
        if Connection and Table then table.insert(Table, Connection) end
        return Connection
    end

    function Library:TweenObject(Object, Info, Goal, Callback)
        if not Object then return end
        local Tween = TweenService:Create(Object, Info, Goal)
        Library:Connection(Tween.Completed, Callback or function() end)
        Tween:Play()
        Library.Tweens[#Library.Tweens + 1] = Tween
    end

    function Library:NewFlag()
        Library.UnnamedFlags += 1
        return ("UnknownFlag%s"):format(tostring(Library.UnnamedFlags))
    end

    function Library:ClampString(String, MaxWidth)
        local Clamped = String
        local TextLabel = Library:CreateObject("TextLabel", {FontFace = Library.UI.NewFont, TextStrokeTransparency = 0, Text = String, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, TextScaled = false, TextWrapped = false, Visible = false, TextSize = Library.UI.FontSize, Parent = Client.PlayerGui})
        if TextLabel.TextBounds.X <= MaxWidth then TextLabel:Destroy() return String end
        while TextLabel.TextBounds.X > MaxWidth and #Clamped > 0 do
            Clamped = Clamped:sub(1, #Clamped - 1)
            TextLabel.Text = Clamped .. "..."
            task.wait()
        end
        TextLabel:Destroy()
        return Clamped .. "..."
    end

    function Library:GetConfig()
        local Config = {}
        for Index, Value in pairs(Library.Flags) do
            if Value.Get and not string.find(Index, "_Status") then
                if typeof(Value:Get()) == "table" and Value:Get().Color and Value:Get().Transparency then
                    local Transparency = Value:Get().Transparency
                    local Hue, Saturation, V = Value:Get().Color:ToHSV()
                    Config[Index] = {Hue, Saturation, V, Transparency}
                else
                    Config[Index] = Value:Get()
                end
            end
        end
        return HttpService:JSONEncode(Config)
    end

    function Library:LoadConfig(Config)
        local Cfg = HttpService:JSONDecode(Config)
        for Index, Value in pairs(Cfg) do
            if Library.Flags[Index] and Library.Flags[Index].Set then
                Library.Flags[Index]:Set(Value)
            end
        end
    end

    function Library:SectionDragging(Frame)
        local MousePosition = UserInputService:GetMouseLocation()
        local Position = Frame.AbsolutePosition
        local Size = Frame.AbsoluteSize
        return MousePosition.X >= Position.X and MousePosition.X <= Position.X + Size.X and MousePosition.Y >= Position.Y and MousePosition.Y <= Position.Y + Size.Y
    end

    function Library:CreateObject(Type, Properties, Hidden)
        Hidden = Hidden or false
        local Object = Instance.new(Type)
        for Index, Value in pairs(Properties) do
            if Index == "TextStrokeTransparency" and Value == 0 then
                local Stroke = Instance.new("UIStroke")
                Stroke.Parent = Object
                Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                Library.Objects[Stroke] = {Stroke, {Parent = Object, LineJoinMode = Enum.LineJoinMode.Miter}, Hidden}
            else
                Object[Index] = Value
            end
        end
        Library.Objects[Object] = {Object, Properties, Hidden}
        return Object
    end

    function Library:AddTheme(Object, Properties)
        for Index, Value in pairs(Properties) do
            Library.Theme.Objects[Object] = Library.Theme.Objects[Object] or {}
            Library.Theme.Objects[Object][Index] = Value
        end
    end

    function Library:UpdateColor(ColorType, ColorValue)
        Library.Theme.Default[ColorType] = ColorValue
        for Object, Properties in pairs(Library.Theme.Objects) do
            for Property, ThemeKeys in pairs(Properties) do
                if typeof(ThemeKeys) == "table" then
                    if Object:IsA("UIGradient") and Property == "Color" then
                        if Library.Theme.Default[ThemeKeys[1]] then
                            Object.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Library.Theme.Default[ThemeKeys[1]]), ColorSequenceKeypoint.new(1, Library.Theme.Default[ThemeKeys[2]])}
                        end
                    end
                else
                    if ThemeKeys == ColorType then
                        Object[Property] = Library.Theme.Default[ThemeKeys]
                    end
                end
            end
        end
    end

    function Library:GetObjectsTable(MainUI, AddMain, Ignored)
        AddMain = AddMain or false
        Ignored = Ignored or {}
        local DescendantTable = {}
        local NewTable = {}
        for _, Descendant in pairs(MainUI:GetDescendants()) do
            if not table.find(Ignored, Descendant) then table.insert(DescendantTable, Descendant) end
        end
        if AddMain then table.insert(DescendantTable, MainUI) end
        for _, Descendant in pairs(DescendantTable) do
            local Found = Library.Objects[Descendant]
            if Found then table.insert(NewTable, {Descendant, Found[2], Found[3]}) end
        end
        return NewTable
    end

    function Library:Fade(State, Table, MainUI, Speed)
        local IsMainUI = Table == Library.Objects
        MainUI.Active = State
        if State then MainUI.Visible = true end
        if IsMainUI then Library.UI.Faded = not State end
        if not State and IsMainUI then
            for _, obj in pairs(MainUI:GetDescendants()) do
                if obj.ClassName == "Frame" and obj.Name == "ToggleMain" then
                    obj.BackgroundTransparency = 1
                end
            end
        end
        for _, Object in pairs(Table) do
            if not Object[3] then
                if Object[1].ClassName == "Frame" and (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                    Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                elseif Object[1].ClassName == "ImageLabel" or Object[1].ClassName == "ImageButton" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1 end
                    if (Object[2]["ImageTransparency"] or 0) ~= 1 then Object[1].ImageTransparency = State and (Object[2]["ImageTransparency"] or 0) or 1 end
                elseif Object[1].ClassName == "TextLabel" or Object[1].ClassName == "TextButton" or Object[1].ClassName == "TextBox" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1 end
                    if (Object[2]["TextTransparency"] or 0) ~= 1 then Object[1].TextTransparency = State and (Object[2]["TextTransparency"] or 0) or 1 end
                elseif Object[1].ClassName == "ScrollingFrame" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1 end
                    if (Object[2]["ScrollBarImageTransparency"] or 0) ~= 1 then Object[1].ScrollBarImageTransparency = State and (Object[2]["ScrollBarImageTransparency"] or 0) or 1 end
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

    function Library:Resizable(Object, DragFrame, MinResize, MaxResize)
        -- Simplified dragging setup for size stability
        local Dragging, MouseLocation, StartingSize
        Library:Connection(DragFrame.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                MouseLocation = UserInputService:GetMouseLocation()
                StartingSize = Object.Size
            end
        end)
        Library:Connection(UserInputService.InputChanged, function(Input)
            if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                local Delta = UserInputService:GetMouseLocation() - MouseLocation
                local NewX = math.clamp(StartingSize.X.Offset + Delta.X, MinResize.X.Offset, MaxResize.X.Offset)
                local NewY = math.clamp(StartingSize.Y.Offset + Delta.Y, MinResize.Y.Offset, MaxResize.Y.Offset)
                Object.Size = UDim2.new(0, NewX, 0, NewY)
            end
        end)
        Library:Connection(UserInputService.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
        end)
    end

    Library.__index = Library
    Library.Sections = {}
    Library.Sections.__index = Library.Sections
    local Sections = Library.Sections

    function Library:Window(Options)
        Options = Library:Validate({Name = "gamesense", Size = UDim2.new(0, 700, 0, 612), CloseBind = Enum.KeyCode.Insert}, Options or {})
        local Window = {Visible = true, CurrentTab = nil, Tabs = {}}
        Library.UI.CloseBind = Options.CloseBind

        local MainUI = Library:CreateObject("ScreenGui", {ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder = 1000, ResetOnSpawn = false, IgnoreGuiInset = true, Name = "\0", Parent = gethui and gethui() or CoreGui})
        Library.UI.ScreenGUI = MainUI

        local Outline = Library:CreateObject("Frame", {Name = "Outline", Position = UDim2.new(0.5, -Options.Size.X.Offset/2, 0.5, -Options.Size.Y.Offset/2), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = Options.Size, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = MainUI})
        Library.UI.MainUI = Outline
        Outline.Active = true
        Outline.Draggable = true

        local Inline = Library:CreateObject("Frame", {Name = "Inline", Position = UDim2.new(0, 1, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(60, 60, 60), Parent = Outline})
        local Inner = Library:CreateObject("Frame", {Name = "Inner", Position = UDim2.new(0, 1, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Inline})
        local Outline_1 = Library:CreateObject("Frame", {Name = "Outline_1", Position = UDim2.new(0, 3, 0, 3), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -6, 1, -6), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(60, 60, 60), Parent = Inner})
        
        local TopBarGradientHolder = Library:CreateObject("Frame", {Name = "TopBarGradientHolder", Position = UDim2.new(0, 1, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, -2, 0, 4), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = Outline_1})
        local UIGradient = Library:CreateObject("UIGradient", {Rotation = 90, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.55)}, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))}, Parent = TopBarGradientHolder})
        
        local TitleText = Library:CreateObject("TextLabel", {Text = Options.Name, BackgroundTransparency = 1, Size = UDim2.new(1, -15, 0, 20), Position = UDim2.new(0, 10, 0, -22), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 14, Parent = Outline})
        
        local SideBarMain = Library:CreateObject("Frame", {Name = "SideBarMain", Position = UDim2.new(0, 1, 0, 5), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(0, 75, 1, -6), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(12, 12, 12), ClipsDescendants = true, Parent = Outline_1})
        local Outline_2 = Library:CreateObject("Frame", {AnchorPoint = Vector2.new(1, 0), Name = "Outline_2", Position = UDim2.new(1, 0, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = SideBarMain})
        
        local Holder = Library:CreateObject("Frame", {BackgroundTransparency = 1, Name = "Holder", Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, Parent = SideBarMain})
        local UIListLayout = Library:CreateObject("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = Holder})
        local UIPadding = Library:CreateObject("UIPadding", {PaddingTop = UDim.new(0, 10), Parent = Holder})

        function Window:SetTab(Number)
            for Index, Tab in pairs(Window.Tabs) do
                if Index == Number then
                    if Window.CurrentTab ~= nil then Window.CurrentTab:Deactivate() end
                    Tab:Activate()
                end
            end
        end

        Library:Connection(UserInputService.InputBegan, function(Input)
            if Input.KeyCode == Library.UI.CloseBind then
                Window.Visible = not Window.Visible
                Library:Fade(Window.Visible, Library.Objects, Outline, 0.2)
            end
        end)

        function Window:CreateTab(Options)
            Options = Library:Validate({Icon = "rbxassetid://8547236654", Name = "Tab"}, Options or {})
            local Tab = {Active = false, Index = Library.UI.TabIndex + 1, Sides = {Left = {Sections = {}, Sizes = 0}, Right = {Sections = {}, Sizes = 0}}}
            Library.UI.TabIndex = Tab.Index

            local TabActive = Library:CreateObject("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, -2, 0, 64), Parent = Holder})
            local Outline_3 = Library:CreateObject("Frame", {Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(0, 0, 0), Visible = false, Parent = TabActive})
            local Inline_1 = Library:CreateObject("Frame", {Size = UDim2.new(1, 1, 1, -2), Position = UDim2.new(0, 0, 0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Outline_3})
            local Main = Library:CreateObject("Frame", {Size = UDim2.new(1, 1, 1, -2), Position = UDim2.new(0, 0, 0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = Inline_1})
            
            local Button = Library:CreateObject("TextButton", {Text = Options.Name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromRGB(90, 90, 90), Font = Library.UI.NewFont, TextSize = 12, TextYAlignment = Enum.TextYAlignment.Bottom, Parent = TabActive})
            local Icon = Library:CreateObject("ImageLabel", {Image = Options.Icon, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5, 0, 0.4, 0), ImageColor3 = Color3.fromRGB(109, 109, 109), BorderSizePixel = 0, Parent = TabActive})

            local SectionsHolder = Library:CreateObject("Frame", {BackgroundTransparency = 1, Visible = false, Position = UDim2.new(0, 76, 0, 5), Size = UDim2.new(1, -78, 1, -6), ClipsDescendants = true, Parent = Outline_1})
            local Left = Library:CreateObject("ScrollingFrame", {BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0, Parent = SectionsHolder})
            local UIListLayout12 = Library:CreateObject("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Left})
            local UIPadding12 = Library:CreateObject("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,5), Parent = Left})
            
            local Right = Library:CreateObject("ScrollingFrame", {BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), ScrollBarThickness = 0, Parent = SectionsHolder})
            local UIListLayout52 = Library:CreateObject("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Right})
            local UIPadding52 = Library:CreateObject("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,10), Parent = Right})

            function Tab:Activate()
                if not Tab.Active then
                    if Window.CurrentTab ~= nil then Window.CurrentTab:Deactivate() end
                    Tab.Active = true
                    Icon.ImageColor3 = Color3.fromRGB(210, 210, 210)
                    Button.TextColor3 = Color3.fromRGB(210, 210, 210)
                    Outline_3.Visible = true
                    SectionsHolder.Visible = true
                    Window.CurrentTab = Tab
                end
            end

            function Tab:Deactivate()
                if Tab.Active then
                    Tab.Active = false
                    Outline_3.Visible = false
                    SectionsHolder.Visible = false
                    Icon.ImageColor3 = Color3.fromRGB(90, 90, 90)
                    Button.TextColor3 = Color3.fromRGB(90, 90, 90)
                end
            end

            Library:Connection(Button.MouseButton1Click, function() Tab:Activate() end)

            Window.Tabs[#Window.Tabs + 1] = Tab

            function Tab:Section(Options)
                Options = Library:Validate({Name = "Section", Side = "Left"}, Options or {})
                local Parent = Options.Side == "Left" and Left or Right
                
                local SectionOutline = Library:CreateObject("Frame", {BorderColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = Parent})
                local SectionInline = Library:CreateObject("Frame", {Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = SectionOutline})
                local SectionMain = Library:CreateObject("Frame", {Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(23, 23, 23), Parent = SectionInline})
                
                local TitleInline = Library:CreateObject("Frame", {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Position = UDim2.new(0, 9, 0, 0), Size = UDim2.new(0, 0, 0, 2), ZIndex = 5, Parent = SectionOutline})
                local UIGradient2 = Library:CreateObject("UIGradient", {Rotation = 90, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 19, 19)), ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24))}, Parent = TitleInline})
                local Title = Library:CreateObject("TextLabel", {AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -26, 0, 15), ZIndex = 5, Font = Library.UI.NewFont, RichText = true, Text = "<b>" .. Options.Name .. "</b>", TextColor3 = Color3.fromRGB(198, 198, 198), TextSize = Library.UI.FontSize, TextXAlignment = "Left", Parent = SectionOutline})
                Title.Size = UDim2.fromOffset(Title.TextBounds.X, 15)
                TitleInline.Size = UDim2.new(0, Title.TextBounds.X + 6, 0, 2)

                local ContentHolder = Library:CreateObject("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,-15), Position = UDim2.new(0,0,0,15), Parent = SectionMain})
                local UIListLayout = Library:CreateObject("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ContentHolder})
                local UIPadding = Library:CreateObject("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), Parent = ContentHolder})

                Library:Connection(UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    SectionOutline.Size = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y + 35)
                    Parent.CanvasSize = UDim2.new(0,0,0, Parent.UIListLayout.AbsoluteContentSize.Y + 20)
                end)

                local Section = setmetatable({Elements = {ContentHolder = ContentHolder}}, Sections)
                return Section
            end
            return Tab
        end

        function Library:Notify(Options)
            Options = Library:Validate({Message = "Notification", Delay = 3, Position = "Top Left"}, Options or {})
            local Path = Options.Position == "Top Left" and Library.UI.Notifications.TopLeft or Library.UI.Notifications.Middle
            
            local NotificationFrameObject = Library:CreateObject("Frame", {Position = UDim2.new(0, -400, 0, 0), Size = UDim2.new(0, 400, 0, 20), ZIndex = 10000, BackgroundColor3 = Color3.fromRGB(0, 0, 0), Parent = Library.UI.ScreenGUI}, true)
            local NotificationText = Library:CreateObject("TextLabel", {Font = Library.UI.NewFont, TextColor3 = Color3.fromRGB(208, 208, 208), Text = Options.Message, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, RichText = true, TextSize = 14, Parent = NotificationFrameObject}, true)
            Library:CreateObject("UIPadding", {PaddingRight = UDim.new(0, 22), PaddingLeft = UDim.new(0, 22), Parent = NotificationText}, true)

            local NotificationFrame = {Object = NotificationFrameObject, Text = NotificationText}
            NotificationText.Text = Options.Message
            NotificationFrameObject.Size = UDim2.new(0, NotificationText.TextBounds.X + 44, 0, NotificationText.TextBounds.Y + 8)

            table.insert(Path, 1, NotificationFrame)

            local function UpdatePositions()
                local TotalHeight = Options.Position == "Top Left" and 50 or -150
                local Padding = 6
                for Index = #Path, 1, -1 do
                    local Value = Path[Index]
                    local NewPosition = Options.Position == "Top Left" and UDim2.new(0, 5, 0, TotalHeight) or UDim2.new(0, Viewport.X / 2 - Value.Object.Size.X.Offset / 2, 1, TotalHeight - (Index * 24))
                    if Options.Position == "Top Left" then TotalHeight = TotalHeight + Value.Object.AbsoluteSize.Y + Padding end
                    Library:TweenObject(Value.Object, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = NewPosition})
                end
            end
            UpdatePositions()

            if Options.Delay ~= math.huge then
                task.delay(Options.Delay, function()
                    Library:TweenObject(NotificationFrameObject, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                    Library:TweenObject(NotificationText, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1})
                    task.delay(0.25, function()
                        NotificationFrameObject:Destroy()
                        table.remove(Path, table.find(Path, NotificationFrame))
                        UpdatePositions()
                    end)
                end)
            end
        end

        function Library:Init()
            Library.UI.Initialized = true
            Library:Connection(Camera:GetPropertyChangedSignal("ViewportSize"), function()
                Viewport = Camera.ViewportSize
                Outline.Position = UDim2.fromOffset((Viewport.X / 2) - (Outline.Size.X.Offset / 2), (Viewport.Y / 2) - (Outline.Size.Y.Offset / 2))
            end)
        end

        function Library:Unload()
            for _, Value in pairs(Library.Connections) do Value:Disconnect() end
            MainUI:Destroy()
        end

        return setmetatable(Window, Library)
    end

    function Sections:Button(Options)
        Options = Library:Validate({Name = "Button", Callback = function() end}, Options or {})
        local ButtonOutline = Library:CreateObject("Frame", {Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = self.Elements.ContentHolder})
        local ButtonInline = Library:CreateObject("Frame", {Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Parent = ButtonOutline})
        local ButtonMain = Library:CreateObject("Frame", {Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2), BackgroundColor3 = Color3.fromRGB(25, 25, 25), Parent = ButtonInline})
        local ButtonTxt = Library:CreateObject("TextLabel", {Text = "<b>" .. Options.Name .. "</b>", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, RichText = true, TextSize = 13, Parent = ButtonMain})
        local Click = Library:CreateObject("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = ButtonOutline})
        
        Library:Connection(Click.MouseButton1Click, function()
            Library:TweenObject(ButtonMain, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
            task.delay(0.1, function() Library:TweenObject(ButtonMain, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}) end)
            Options.Callback()
        end)
    end

    function Sections:Toggle(Options)
        Options = Library:Validate({Name = "Toggle", Default = false, Callback = function() end}, Options or {})
        local State = Options.Default
        local ToggleContainer = Library:CreateObject("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), Parent = self.Elements.ContentHolder})
        local ToggleBox = Library:CreateObject("Frame", {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 0, 0.5, -5), BackgroundColor3 = State and Library.Theme.Default.Accent or Color3.fromRGB(35, 35, 35), Parent = ToggleContainer})
        local ToggleLabel = Library:CreateObject("TextLabel", {Text = Options.Name, BackgroundTransparency = 1, Size = UDim2.new(1, -18, 1, 0), Position = UDim2.new(0, 18, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 13, Parent = ToggleContainer})
        local Click = Library:CreateObject("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = ToggleContainer})
        
        Library:Connection(Click.MouseButton1Click, function()
            State = not State
            Library:TweenObject(ToggleBox, TweenInfo.new(0.15), {BackgroundColor3 = State and Library.Theme.Default.Accent or Color3.fromRGB(35, 35, 35)})
            Options.Callback(State)
        end)
        
        return {
            Set = function(self, val)
                State = val
                Library:TweenObject(ToggleBox, TweenInfo.new(0.15), {BackgroundColor3 = State and Library.Theme.Default.Accent or Color3.fromRGB(35, 35, 35)})
                Options.Callback(State)
            end
        }
    end

    function Sections:Slider(Options)
        Options = Library:Validate({Name = "Slider", Min = 0, Max = 100, Default = 50, Decimal = 1, Ending = "", Callback = function() end}, Options or {})
        local SliderContainer = Library:CreateObject("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Parent = self.Elements.ContentHolder})
        local SliderLabel = Library:CreateObject("TextLabel", {Text = Options.Name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 13, Parent = SliderContainer})
        local SliderValue = Library:CreateObject("TextLabel", {Text = tostring(Options.Default)..Options.Ending, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 13, Parent = SliderContainer})
        
        local SliderBG = Library:CreateObject("Frame", {Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = Color3.fromRGB(35, 35, 35), Parent = SliderContainer})
        local SliderFill = Library:CreateObject("Frame", {Size = UDim2.new((Options.Default - Options.Min) / (Options.Max - Options.Min), 0, 1, 0), BackgroundColor3 = Library.Theme.Default.Accent, Parent = SliderBG})
        local Click = Library:CreateObject("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = SliderBG})
        
        local Dragging = false
        local function Update(Input)
            local Percent = math.clamp((Input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            local Value = math.floor((Options.Min + (Options.Max - Options.Min) * Percent) * (1/Options.Decimal)) / (1/Options.Decimal)
            SliderValue.Text = tostring(Value) .. Options.Ending
            Library:TweenObject(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(Percent, 0, 1, 0)})
            Options.Callback(Value)
        end

        Library:Connection(Click.InputBegan, function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update(Input) end end)
        Library:Connection(Click.InputEnded, function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
        Library:Connection(UserInputService.InputChanged, function(Input) if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then Update(Input) end end)
        
        return {
            Set = function(self, val)
                local Percent = (val - Options.Min) / (Options.Max - Options.Min)
                SliderValue.Text = tostring(val) .. Options.Ending
                Library:TweenObject(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(Percent, 0, 1, 0)})
                Options.Callback(val)
            end
        }
    end

    function Sections:TextBox(Options)
        Options = Library:Validate({Name = "TextBox", Default = "", ClearOnFocus = false, Callback = function() end}, Options or {})
        local TextContainer = Library:CreateObject("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), Parent = self.Elements.ContentHolder})
        local TextLabel = Library:CreateObject("TextLabel", {Text = Options.Name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 13, Parent = TextContainer})
        local TextBoxBG = Library:CreateObject("Frame", {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 16), BackgroundColor3 = Color3.fromRGB(25, 25, 25), Parent = TextContainer})
        local Box = Library:CreateObject("TextBox", {Text = Options.Default, ClearTextOnFocus = Options.ClearOnFocus, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TextBoxBG})
        
        Library:Connection(Box.FocusLost, function()
            Options.Callback(Box.Text)
        end)
    end

    function Sections:Dropdown(Options)
        Options = Library:Validate({Name = "Dropdown", Content = {}, Default = "None", Callback = function() end}, Options or {})
        local DropdownContainer = Library:CreateObject("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), Parent = self.Elements.ContentHolder})
        local DropLabel = Library:CreateObject("TextLabel", {Text = Options.Name .. ": " .. Options.Default, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 13, Parent = DropdownContainer})
        local DropBG = Library:CreateObject("Frame", {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 16), BackgroundColor3 = Color3.fromRGB(25, 25, 25), Parent = DropdownContainer})
        local Click = Library:CreateObject("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "Click to cycle ->", TextColor3 = Color3.fromRGB(150, 150, 150), Font = Library.UI.NewFont, TextSize = 12, Parent = DropBG})
        
        local Index = 1
        local DropList = Options.Content
        Library:Connection(Click.MouseButton1Click, function()
            if #DropList == 0 then return end
            Index = Index + 1
            if Index > #DropList then Index = 1 end
            DropLabel.Text = Options.Name .. ": " .. DropList[Index]
            Options.Callback(DropList[Index])
        end)
        
        return {
            Set = function(self, val)
                for i, v in ipairs(DropList) do
                    if v == val then Index = i end
                end
                DropLabel.Text = Options.Name .. ": " .. val
                Options.Callback(val)
            end,
            Refresh = function(self, newItems, delete)
                if delete then DropList = {} end
                for _, item in ipairs(newItems) do table.insert(DropList, item) end
            end
        }
    end

    function Sections:Label(Options)
        Options = Library:Validate({Message = "Label"}, Options or {})
        local Label = Library:CreateObject("TextLabel", {Text = Options.Message, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.UI.NewFont, TextSize = 13, Parent = self.Elements.ContentHolder})
        return {
            Set = function(self, newText) Label.Text = newText end,
            ColorPicker = function(self, colorOpts) end,
            Keybind = function(self, bindOpts) end
        }
    end
end

-- =========================================================================
-- ORION API COMPATIBILITY LAYER
-- (This forces Gamesense to understand Orion scripts)
-- =========================================================================

function Library:MakeWindow(Config)
    Config = Config or {}
    local win = self:Window({
        Name = Config.Name or "Gamesense",
        Size = UDim2.new(0, 700, 0, 612),
        CloseBind = Enum.KeyCode.Insert
    })

    function win:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        local tab = self:CreateTab({
            Name = TabConfig.Name or "Tab",
            Icon = TabConfig.Icon or "rbxassetid://4483345998"
        })
        
        -- Default hidden section so Orion's Tab:AddButton() works natively
        local defaultSection = tab:Section({Name = TabConfig.Name, Side = "Left"})
        
        function tab:AddSection(SecConfig)
            SecConfig = SecConfig or {}
            return tab:Section({Name = SecConfig.Name or "Section", Side = "Left"})
        end
        
        -- Aliases attached to the Tab object
        function tab:AddButton(cfg) return defaultSection:Button({Name = cfg.Name, Callback = cfg.Callback}) end
        function tab:AddToggle(cfg) return defaultSection:Toggle({Name = cfg.Name, Default = cfg.Default, Callback = cfg.Callback}) end
        function tab:AddSlider(cfg) return defaultSection:Slider({Name = cfg.Name, Min = cfg.Min, Max = cfg.Max, Default = cfg.Default, Decimal = cfg.Increment, Ending = cfg.ValueName and (" " .. cfg.ValueName) or "", Callback = cfg.Callback}) end
        function tab:AddDropdown(cfg) return defaultSection:Dropdown({Name = cfg.Name, Default = cfg.Default, Content = cfg.Options, Callback = cfg.Callback}) end
        function tab:AddTextbox(cfg) return defaultSection:TextBox({Name = cfg.Name, Default = cfg.Default, ClearOnFocus = cfg.TextDisappear, Callback = cfg.Callback}) end
        function tab:AddLabel(text) return defaultSection:Label({Message = text}) end
        function tab:AddParagraph(title, content) return defaultSection:Label({Message = title .. "\n" .. content}) end
        function tab:AddColorpicker(cfg) local lbl = defaultSection:Label({Message = cfg.Name}) return lbl:ColorPicker(cfg) end
        function tab:AddBind(cfg) local lbl = defaultSection:Label({Message = cfg.Name}) return lbl:Keybind(cfg) end
        
        return tab
    end

    return win
end

function Library.Sections:AddButton(cfg) return self:Button({Name = cfg.Name, Callback = cfg.Callback}) end
function Library.Sections:AddToggle(cfg) return self:Toggle({Name = cfg.Name, Default = cfg.Default, Callback = cfg.Callback}) end
function Library.Sections:AddSlider(cfg) return self:Slider({Name = cfg.Name, Min = cfg.Min, Max = cfg.Max, Default = cfg.Default, Decimal = cfg.Increment, Ending = cfg.ValueName and (" " .. cfg.ValueName) or "", Callback = cfg.Callback}) end
function Library.Sections:AddDropdown(cfg) return self:Dropdown({Name = cfg.Name, Default = cfg.Default, Content = cfg.Options, Callback = cfg.Callback}) end
function Library.Sections:AddTextbox(cfg) return self:TextBox({Name = cfg.Name, Default = cfg.Default, ClearOnFocus = cfg.TextDisappear, Callback = cfg.Callback}) end
function Library.Sections:AddLabel(text) return self:Label({Message = text}) end
function Library.Sections:AddParagraph(title, content) return self:Label({Message = title .. "\n" .. content}) end
function Library.Sections:AddColorpicker(cfg) local lbl = self:Label({Message = cfg.Name}) return lbl:ColorPicker(cfg) end
function Library.Sections:AddBind(cfg) local lbl = self:Label({Message = cfg.Name}) return lbl:Keybind(cfg) end

function Library:MakeNotification(Config)
    self:Notify({
        Message = (Config.Name and "<b>"..Config.Name.."</b>\n" or "") .. (Config.Content or ""),
        Delay = Config.Time or 5,
        Position = "Top Left"
    })
end

function Library:Destroy()
    self:Unload()
end

return Library
