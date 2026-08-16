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
local GamesenseLib = {
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
                local Hue, Saturation, Val = Value:Get().Color:ToHSV()
                Config[Index] = {Hue, Saturation, Val, Transparency}
            else
                Config[Index] = Value:Get()
            end
        end
    end
    return HttpService:JSONEncode(Config)
end

function GamesenseLib:LoadConfig(Config)
    local Decoded = HttpService:JSONDecode(Config)
    for Index, Value in Decoded do
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
            NewTable[#NewTable + 1] = {Descendant, Found[2], Found[3]}
        end
    end
    return NewTable
end

function GamesenseLib:ScrollingCheck(ScrollingFrame, Frame)
    if not ScrollingFrame:IsA("ScrollingFrame") then return true end
    local VisibleTopLeft = ScrollingFrame.CanvasPosition
    local VisibleBottomRight = VisibleTopLeft + ScrollingFrame.AbsoluteWindowSize
    local FrameTopLeft = Frame.AbsolutePosition - ScrollingFrame.AbsolutePosition + ScrollingFrame.CanvasPosition
    local FrameBottomRight = FrameTopLeft + Frame.AbsoluteSize
    return FrameBottomRight.X > VisibleTopLeft.X and FrameTopLeft.X < VisibleBottomRight.X and FrameBottomRight.Y > VisibleTopLeft.Y and FrameTopLeft.Y < VisibleBottomRight.Y
end

function GamesenseLib:Fade(State, Table, MainUI, Speed)
    local IsMainUI = Table == GamesenseLib.Objects
    MainUI.Active = State
    if State then MainUI.Visible = true end
    if IsMainUI then GamesenseLib.UI.Faded = not State end
    
    for _, Object in Table do
        if not Object[3] then
            if Object[1].ClassName == "Frame" and (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
            elseif Object[1].ClassName == "ImageLabel" or Object[1].ClassName == "ImageButton" then
                if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1 end
                if (Object[2]["ImageTransparency"] or 0) ~= 1 then Object[1].ImageTransparency = State and (Object[2]["ImageTransparency"] or 0) or 1 end
            elseif Object[1].ClassName == "TextLabel" or Object[1].ClassName == "TextButton" or Object[1].ClassName == "TextBox" then
                if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1 end
                if (Object[2]["TextTransparency"] or 0) ~= 1 then Object[1].TextTransparency = State and (Object[2]["TextTransparency"] or 0) or 1 end
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

function GamesenseLib:Resizable(Object, DragFrame, MinResize, MaxResize, Increments, UseIcon, UseParent, Delay)
    local StartingSize, Dragging, MouseLocation, NewMouse, Hovering
    local function UpdateSize()
        if not MouseLocation then return end
        GamesenseLib.UI.Resizing = true
        local CurrentMousePosition = UserInputService:GetMouseLocation()
        local Delta = CurrentMousePosition - MouseLocation
        local NewSizeX = StartingSize.X.Offset + Delta.X
        local NewSizeY = StartingSize.Y.Offset + Delta.Y
        NewSizeY = math.clamp(NewSizeY, MinResize.Y.Offset, MaxResize.Y.Offset)
        NewSizeX = math.clamp(NewSizeX, MinResize.X.Offset, MaxResize.X.Offset)
        return UDim2.new(0, NewSizeX, 0, NewSizeY)
    end
    GamesenseLib:Connection(DragFrame.MouseEnter, function() Hovering = true end)
    GamesenseLib:Connection(DragFrame.MouseLeave, function() if NewMouse then NewMouse:Destroy() NewMouse = nil end UserInputService.MouseIconEnabled = true Hovering = false end)
    GamesenseLib:Connection(DragFrame.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            MouseLocation = UserInputService:GetMouseLocation()
            StartingSize = Object.Size
        end
    end)
    GamesenseLib:Connection(RunService.PreRender, function()
        if Dragging then Object.Size = UpdateSize() end
    end)
    GamesenseLib:Connection(UserInputService.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
            UserInputService.MouseIconEnabled = true
            Dragging = false
            GamesenseLib.UI.Resizing = false
        end
    end)
end

GamesenseLib.__index = GamesenseLib
GamesenseLib.Sections.__index = GamesenseLib.Sections
local Sections = GamesenseLib.Sections

-- Window, Tab, Section, and Item creation logic goes here...
-- [Include all core UI functions like Window, CreateTab, Section, Toggle, Slider, Dropdown, Button, Label, TextBox, List, Notify, Init, Unload, etc.]

-- CRITICAL FIX: Return the library table at the very end so loadstring() works!
getgenv().GamesenseLib = GamesenseLib
return GamesenseLib
