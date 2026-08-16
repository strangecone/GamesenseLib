if getgenv().Gamesense and getgenv().Gamesense.Unload then getgenv().Gamesense:Unload() end

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

if not isfolder("gamesense") then makefolder("gamesense") end
if not isfolder("gamesense/Configs") then makefolder("gamesense/Configs") end

local Library = {
    Connections = {}, Errors = {}, Tweens = {}, Objects = {}, Sections = {}, ThemeSections = {}, Flags = {}, UnnamedFlags = 0,
    Build = "Beta", UID = "1", UnsafeMode = false, InitTime = os.clock(), Folder = "gamesense", ConfigFolder = "gamesense/Configs",
    UI = {
        Name = "gamesense", CloseBind = Enum.KeyCode.Insert, SectionResizeIncrements = 1, WatermarkRefreshRate = 1,
        MainUI = nil, Initialized = false, Faded = false, LastCopiedColor = nil, TabIndex = 0, Viewing = false,
        TotalColorPickers = 0, TotalKeybindModes = 0, TweenSpeed = 0.15, OpenColorFrames = 0, ScreenGUI = nil,
        NewFont = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        FontSize = 13, Notifications = {TopLeft = {}, Middle = {}},
        Keys = {[Enum.KeyCode.LeftShift]="LSHF",[Enum.KeyCode.RightShift]="RSHF",[Enum.KeyCode.LeftControl]="LCTR",[Enum.KeyCode.RightControl]="RCTR",[Enum.KeyCode.LeftAlt]="LALT",[Enum.KeyCode.RightAlt]="RALT",[Enum.KeyCode.Space]="SPCE",[Enum.KeyCode.Insert]="INS"}
    },
    Theme = {
        Objects = {}, Default = { Accent = Color3.fromRGB(153, 196, 39), SecondAccent = Color3.fromRGB(124, 158, 32), TextColor = Color3.fromRGB(205, 205, 205), Risky = Color3.fromRGB(165, 165, 120) }
    }
}
Library.__index = Library
Library.Sections.__index = Library.Sections
local Sections = Library.Sections

function Library:Validate(Defaults, Options) for Index, Value in pairs(Defaults) do if Options[Index] == nil then Options[Index] = Value end end return Options end
function Library:Connection(Signal, Func) local Connection; Connection = Signal:Connect(function(...) local Args={...} pcall(function() coroutine.wrap(Func)(unpack(Args)) end) end) table.insert(self.Connections, Connection) return Connection end
function Library:TweenObject(Object, Info, Goal, Callback) if not Object then return end local Tween = TweenService:Create(Object, Info, Goal) self:Connection(Tween.Completed, Callback or function() end) Tween:Play() table.insert(self.Tweens, Tween) end
function Library:NewFlag() self.UnnamedFlags = self.UnnamedFlags + 1 return "UnknownFlag" .. tostring(self.UnnamedFlags) end
function Library:CreateObject(Type, Properties, Hidden)
    local Obj = Instance.new(Type)
    for Index, Value in pairs(Properties) do if Index == "TextStrokeTransparency" and Value == 0 then local Stroke = Instance.new("UIStroke", Obj) Stroke.LineJoinMode = Enum.LineJoinMode.Miter self.Objects[Stroke] = {Stroke, {Parent=Obj, LineJoinMode=Enum.LineJoinMode.Miter}, Hidden or false} else Obj[Index] = Value end end
    self.Objects[Obj] = {Obj, Properties, Hidden or false} return Obj
end
function Library:GetConfig() local Cfg={} for Idx, Val in pairs(self.Flags) do if Val.Get and not string.find(Idx, "_Status") then if typeof(Val:Get())=="table" and Val:Get().Color then local H,S,V=Val:Get().Color:ToHSV() Cfg[Idx]={H,S,V,Val:Get().Transparency} else Cfg[Idx]=Val:Get() end end end return HttpService:JSONEncode(Cfg) end
function Library:LoadConfig(Cfg) local Data=HttpService:JSONDecode(Cfg) for Idx, Val in pairs(Data) do if self.Flags[Idx] and self.Flags[Idx].Set then self.Flags[Idx]:Set(Val) end end end
function Library:AddTheme(Object, Properties) for Idx, Val in pairs(Properties) do self.Theme.Objects[Object] = self.Theme.Objects[Object] or {} self.Theme.Objects[Object][Idx] = Val end end
function Library:UpdateColor(Type, Val)
    self.Theme.Default[Type] = Val
    for Obj, Props in pairs(self.Theme.Objects) do
        for Prop, ThemeKeys in pairs(Props) do
            if typeof(ThemeKeys)=="table" then if Obj:IsA("UIGradient") and Prop=="Color" then Obj.Color=ColorSequence.new{ColorSequenceKeypoint.new(0, self.Theme.Default[ThemeKeys[1]]), ColorSequenceKeypoint.new(1, self.Theme.Default[ThemeKeys[2]])} end
            elseif ThemeKeys==Type then Obj[Prop]=self.Theme.Default[ThemeKeys] end
        end
    end
end
function Library:GetObjectsTable(MainUI, AddMain, Ignored)
    local T, NT = {}, {} Ignored = Ignored or {}
    for _, Desc in ipairs(MainUI:GetDescendants()) do if not table.find(Ignored, Desc) then table.insert(T, Desc) end end
    if AddMain then table.insert(T, MainUI) end
    for _, Desc in ipairs(T) do local Found=self.Objects[Desc] if Found then table.insert(NT, {Desc, Found[2], Found[3]}) end end
    return NT
end
function Library:Fade(State, Table, MainUI, Speed)
    MainUI.Active = State if State then MainUI.Visible = true end if Table == self.Objects then self.UI.Faded = not State end
    if not State and Table == self.Objects then for _, obj in pairs(MainUI:GetDescendants()) do if obj.ClassName=="Frame" and obj.Name=="ToggleMain" then obj.BackgroundTransparency=1 end end end
    for _, Obj in pairs(Table) do
        if not Obj[3] then
            if Obj[1].ClassName=="Frame" or Obj[1].ClassName=="ScrollingFrame" then Obj[1].BackgroundTransparency = State and (Obj[2]["BackgroundTransparency"] or 0) or 1
            elseif Obj[1].ClassName=="ImageLabel" or Obj[1].ClassName=="ImageButton" then Obj[1].BackgroundTransparency = State and (Obj[2]["BackgroundTransparency"] or 0) or 1 Obj[1].ImageTransparency = State and (Obj[2]["ImageTransparency"] or 0) or 1
            elseif Obj[1].ClassName=="TextLabel" or Obj[1].ClassName=="TextButton" or Obj[1].ClassName=="TextBox" then Obj[1].BackgroundTransparency = State and (Obj[2]["BackgroundTransparency"] or 0) or 1 Obj[1].TextTransparency = State and (Obj[2]["TextTransparency"] or 0) or 1
            elseif Obj[1].ClassName=="UIStroke" then Obj[1].Transparency = State and (Obj[2]["Transparency"] or 0) or 1 end
        end
    end
    if not State then task.delay(Speed, function() if MainUI.Parent then MainUI.Visible = false end end) end
end
function Library:ScrollingCheck(ScrollingFrame, Frame)
    if not ScrollingFrame:IsA("ScrollingFrame") then return true end
    local VTL = ScrollingFrame.CanvasPosition local VBR = VTL + ScrollingFrame.AbsoluteWindowSize
    local FTL = Frame.AbsolutePosition - ScrollingFrame.AbsolutePosition + ScrollingFrame.CanvasPosition local FBR = FTL + Frame.AbsoluteSize
    return FBR.X > VTL.X and FTL.X < VBR.X and FBR.Y > VTL.Y and FTL.Y < VBR.Y
end
function Library:ClampString(String, MaxWidth)
    local Clamped = String local Lbl = self:CreateObject("TextLabel", {FontFace=self.UI.NewFont, Text=String, Size=UDim2.new(1,0,1,0), Visible=false, TextSize=self.UI.FontSize, Parent=Client.PlayerGui})
    if Lbl.TextBounds.X <= MaxWidth then Lbl:Destroy() return String end
    while Lbl.TextBounds.X > MaxWidth and #Clamped > 0 do Clamped = Clamped:sub(1, #Clamped - 1) Lbl.Text = Clamped .. "..." task.wait() end
    Lbl:Destroy() return Clamped .. "..."
end
function Library:CheckFrameFirst(FrameA, FrameB)
    local Frames={} for _, Child in ipairs(FrameA.Parent:GetChildren()) do if Child:IsA("Frame") then table.insert(Frames, Child) end end
    table.sort(Frames, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
    local IdxA, IdxB for i, F in ipairs(Frames) do if F==FrameA then IdxA=i end if F==FrameB then IdxB=i end end return IdxA and IdxB and IdxA < IdxB
end

function Library:ColorPicker(Options)
    Options = self:Validate({Name="Preview", Default=self.Theme.Default.Accent, Alpha=0, AlphaBar=true, Parent=nil, MainUI=nil, TabUI=nil, Count=1, Flag=self:NewFlag(), Callback=function() end}, Options or {})
    local Hue, Sat, Val = Options.Default:ToHSV()
    local ColorPicker = {Color=Options.Default, Saturation={Sat, Val}, Alpha=Options.Alpha, Hue=Hue, Active=false}
    self.Flags[Options.Flag] = ColorPicker self.UI.TotalColorPickers = self.UI.TotalColorPickers + 1
    
    local Outline = self:CreateObject("Frame", {AnchorPoint=Vector2.new(1,0), Name="CP"..self.UI.TotalColorPickers, Position=UDim2.new(1, 0-(Options.Count-1)*22, 0, 0), Size=UDim2.new(0,17,0,9), BackgroundColor3=Color3.fromRGB(12,12,12), Parent=Options.Parent})
    local Btn = self:CreateObject("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=Outline})
    local Inline = self:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.new(1,1,1), Parent=Outline})
    local Grad = self:CreateObject("UIGradient", {Rotation=90, Parent=Inline})
    
    function ColorPicker:Update()
        self.Color = Color3.fromHSV(self.Hue, self.Saturation[1], self.Saturation[2])
        local Sec = Color3.fromRGB(math.max(math.floor(self.Color.R*255)-23,0), math.max(math.floor(self.Color.G*255)-23,0), math.max(math.floor(self.Color.B*255)-23,0))
        Grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, self.Color), ColorSequenceKeypoint.new(1, Sec)}
        Options.Callback(self.Color, self.Alpha)
    end
    function ColorPicker:Set(C, A)
        if typeof(C)=="table" then C=Color3.fromHSV(C[1],C[2],C[3]) A=C[4] end
        local h,s,v = C:ToHSV() self.Color = C self.Alpha = A or 1 self.Hue = h self.Saturation={s,v} self:Update()
    end
    function ColorPicker:Get() return {Color=self.Color, Transparency=self.Alpha} end
    ColorPicker:Update()
    return ColorPicker
end

function Library:Keybind(Options)
    Options = self:Validate({Default=Enum.KeyCode.Backspace, Mode="Toggle", Parent=nil, Toggle=nil, Flag=self:NewFlag(), Count=1, Callback=function() end}, Options or {})
    local Keybind = {Keybind=Options.Default, State=false, Mode=Options.Mode, SelectingKeybind=false}
    self.Flags[Options.Flag] = Keybind self.UI.TotalKeybindModes = self.UI.TotalKeybindModes + 1
    
    local Outline = self:CreateObject("TextLabel", {FontFace=self.UI.NewFont, TextColor3=Color3.fromRGB(117,117,117), Text="[-]", AnchorPoint=Vector2.new(1,0), Size=UDim2.new(0,16,0,7), BackgroundTransparency=1, Position=UDim2.new(1, 0-(Options.Count-1)*22, 0, 0), TextXAlignment=Enum.TextXAlignment.Right, TextSize=9, Parent=Options.Parent})
    local Btn = self:CreateObject("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=Outline})
    
    function Keybind:Set(Key)
        if typeof(Key)=="EnumItem" then self.RegKeybind=Key end
        local KeyStr = self.RegKeybind and (self.RegKeybind.EnumType==Enum.KeyCode and UserInputService:GetStringForKeyCode(self.RegKeybind) or self.RegKeybind.Name) or "[-]"
        if KeyStr=="" and self.RegKeybind then KeyStr=self.RegKeybind.Name end
        Outline.Text = "["..string.upper(KeyStr).."]"
        Outline.Size = UDim2.new(0, Outline.TextBounds.X+2, 0, 7)
        Options.Callback(Key)
    end
    function Keybind:Get() return self.RegKeybind and self.RegKeybind.Name or "[-]" end
    task.delay(0.5, function() Keybind:Set(Options.Default) end)
    
    self:Connection(Btn.MouseButton1Click, function()
        Keybind.SelectingKeybind = true Outline.TextColor3 = Color3.fromRGB(255,0,0)
        local Conn; Conn = UserInputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType.Name:find("MouseButton") then
                Keybind:Set(Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode or Input.UserInputType)
                Outline.TextColor3 = Color3.fromRGB(117,117,117)
                Keybind.SelectingKeybind = false Conn:Disconnect()
            end
        end)
    end)
    return Keybind
end

function Library:Window(Options)
    Options = self:Validate({Name="gamesense", Size=UDim2.new(0,700,0,612), CloseBind=Enum.KeyCode.Insert}, Options or {})
    local Window = {Visible=true, Tabs={}}
    local MainUI = self:CreateObject("ScreenGui", {DisplayOrder=1000, ResetOnSpawn=false, IgnoreGuiInset=true, Parent=gethui and gethui() or CoreGui})
    self.UI.ScreenGUI = MainUI
    local Outline = self:CreateObject("Frame", {Position=UDim2.new(0.5, -Options.Size.X.Offset/2, 0.5, -Options.Size.Y.Offset/2), BorderColor3=Color3.new(0,0,0), Size=Options.Size, BackgroundColor3=Color3.fromRGB(12,12,12), Parent=MainUI})
    self:Connection(UserInputService.InputBegan, function(Input) if Input.KeyCode == Options.CloseBind then Window.Visible = not Window.Visible Outline.Visible = Window.Visible end end)
    
    local Inline = self:CreateObject("Frame", {Position=UDim2.new(0,1,0,1), Size=UDim2.new(1,-2,1,-2), BackgroundColor3=Color3.fromRGB(60,60,60), BorderSizePixel=0, Parent=Outline})
    local Inner = self:CreateObject("Frame", {Position=UDim2.new(0,1,0,1), Size=UDim2.new(1,-2,1,-2), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, Parent=Inline})
    local Out1 = self:CreateObject("Frame", {Position=UDim2.new(0,3,0,3), Size=UDim2.new(1,-6,1,-6), BackgroundColor3=Color3.fromRGB(60,60,60), BorderSizePixel=0, Parent=Inner})
    
    local PatHolder = self:CreateObject("Frame", {Position=UDim2.new(0,1,0,1), Size=UDim2.new(1,-2,1,-2), BackgroundColor3=Color3.fromRGB(20,20,20), BorderSizePixel=0, Parent=Out1})
    self:CreateObject("ImageLabel", {Image="rbxassetid://8547666218", ScaleType=Enum.ScaleType.Tile, TileSize=UDim2.new(0,8,0,8), Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ImageColor3=Color3.fromRGB(12,12,12), Parent=PatHolder})
    
    local DragBar = self:CreateObject("Frame", {Position=UDim2.new(0,1,0,1), Size=UDim2.new(1,-2,0,4), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, Parent=Out1})
    self:CreateObject("UIGradient", {Rotation=90, Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.55)}, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(12,12,12)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}, Parent=DragBar})
    
    local SideBar = self:CreateObject("Frame", {Position=UDim2.new(0,1,0,5), Size=UDim2.new(0,75,1,-6), BackgroundColor3=Color3.fromRGB(12,12,12), BorderSizePixel=0, ClipsDescendants=true, Parent=Out1})
    self:CreateObject("Frame", {Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,1,1,0), AnchorPoint=Vector2.new(1,0), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, Parent=SideBar})
    
    local TabHolder = self:CreateObject("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=SideBar})
    self:CreateObject("UIListLayout", {Padding=UDim.new(0,0), Parent=TabHolder})
    self:CreateObject("UIPadding", {PaddingTop=UDim.new(0,10), Parent=TabHolder})
    
    local Dragging, DragInput, MousePos, FramePos
    self:Connection(DragBar.InputBegan, function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true MousePos = Input.Position FramePos = Outline.Position end end)
    self:Connection(UserInputService.InputChanged, function(Input) if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end if Input == DragInput and Dragging then local Delta = Input.Position - MousePos Outline.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y) end end)
    self:Connection(UserInputService.InputEnded, function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)

    function Window:SetTab(Number)
        for Index, Tab in pairs(Window.Tabs) do if Index == Number then Tab:Activate() end end
    end

    function Window:CreateTab(Opt)
        Opt = Library:Validate({Name="Tab", Icon="rbxassetid://8547236654"}, Opt or {})
        local Tab = {Active=false, Index=#Window.Tabs+1, Sections=0}
        
        local TabBtn = Library:CreateObject("TextButton", {Size=UDim2.new(1,-2,0,64), BackgroundTransparency=1, Text="", Parent=TabHolder})
        local Icon = Library:CreateObject("ImageLabel", {Image=Opt.Icon, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ImageColor3=Color3.fromRGB(109,109,109), ZIndex=3, Parent=TabBtn})
        
        local SecHolder = Library:CreateObject("Frame", {Position=UDim2.new(0,76,0,5), Size=UDim2.new(1,-78,1,-6), BackgroundTransparency=1, Visible=false, Parent=Out1})
        local Left = Library:CreateObject("ScrollingFrame", {Size=UDim2.new(0.5,0,1,0), BackgroundTransparency=1, ScrollBarThickness=0, Parent=SecHolder})
        Library:CreateObject("UIPadding", {PaddingTop=UDim.new(0,19), PaddingLeft=UDim.new(0,21), PaddingRight=UDim.new(0,8), Parent=Left})
        Library:CreateObject("UIListLayout", {Padding=UDim.new(0,19), Parent=Left})
        
        local Right = Library:CreateObject("ScrollingFrame", {Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0.5,0,0,0), BackgroundTransparency=1, ScrollBarThickness=0, Parent=SecHolder})
        Library:CreateObject("UIPadding", {PaddingTop=UDim.new(0,19), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,19), Parent=Right})
        Library:CreateObject("UIListLayout", {Padding=UDim.new(0,19), Parent=Right})

        function Tab:Activate()
            for _, T in pairs(Window.Tabs) do T.Active = false T.SecHolder.Visible = false T.Icon.ImageColor3 = Color3.fromRGB(90,90,90) end
            self.Active = true SecHolder.Visible = true Icon.ImageColor3 = Color3.fromRGB(210,210,210)
        end
        Tab.SecHolder = SecHolder Tab.Icon = Icon
        Library:Connection(TabBtn.MouseButton1Click, function() Tab:Activate() end)
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Activate() end

        function Tab:Section(SOpt)
            SOpt = Library:Validate({Name="Section", Side="Left"}, SOpt or {})
            Tab.Sections = Tab.Sections + 1
            local Parent = SOpt.Side == "Left" and Left or Right
            local SecOut = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,40), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=Color3.fromRGB(12,12,12), BorderSizePixel=0, Parent=Parent})
            local SecIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, Parent=SecOut})
            local SecMain = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(23,23,23), BorderSizePixel=0, Parent=SecIn})
            local Title = Library:CreateObject("TextLabel", {Text="<b>"..SOpt.Name.."</b>", RichText=true, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Color3.fromRGB(198,198,198), BackgroundTransparency=1, Position=UDim2.new(0,12,0,-8), Size=UDim2.new(1,0,0,15), TextXAlignment="Left", Parent=SecOut})
            local TitleLine = Library:CreateObject("Frame", {Size=UDim2.new(0,40,0,2), Position=UDim2.new(0,8,0,0), BackgroundColor3=Color3.fromRGB(24,24,24), BorderSizePixel=0, Parent=SecOut})
            Library:Connection(Title:GetPropertyChangedSignal("TextBounds"), function() TitleLine.Size = UDim2.new(0, Title.TextBounds.X+8, 0, 2) end)
            Library:CreateObject("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder, Parent=SecMain})
            Library:CreateObject("UIPadding", {PaddingTop=UDim.new(0,15), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,18), PaddingRight=UDim.new(0,18), Parent=SecMain})

            local SectionAPI = {}
            function SectionAPI:Toggle(TOpt)
                TOpt = Library:Validate({Name="Toggle", Default=false, Flag=Library:NewFlag(), Callback=function() end}, TOpt or {})
                local State = TOpt.Default Library.Flags[TOpt.Flag] = {Get = function() return State end, Set = function(self, val) State = val TOpt.Callback(State) end}
                local TFrame = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,12), BackgroundTransparency=1, Text="", Parent=SecMain})
                local TBox = Library:CreateObject("Frame", {Size=UDim2.new(0,8,0,8), Position=UDim2.new(0,0,0.5,-4), BackgroundColor3=Color3.fromRGB(12,12,12), BorderSizePixel=0, Parent=TFrame})
                local TIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(60,60,60), BorderSizePixel=0, Parent=TBox})
                local TFill = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Library.Theme.Default.Accent, BackgroundTransparency=State and 0 or 1, BorderSizePixel=0, Parent=TIn})
                Library:CreateObject("TextLabel", {Text=TOpt.Name, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Library.Theme.Default.TextColor, BackgroundTransparency=1, Position=UDim2.new(0,20,0,0), Size=UDim2.new(1,-20,1,0), TextXAlignment="Left", Parent=TFrame})
                Library:Connection(TFrame.MouseButton1Click, function() State = not State TFill.BackgroundTransparency = State and 0 or 1 TOpt.Callback(State) end)
                
                local ReturnAPI = { Set = function(self, v) State = v TFill.BackgroundTransparency = State and 0 or 1 TOpt.Callback(State) end }
                function ReturnAPI:Keybind(KOpt) return Library:Keybind(KOpt) end
                function ReturnAPI:ColorPicker(COpt) return Library:ColorPicker(COpt) end
                return ReturnAPI
            end

            function SectionAPI:Slider(SlOpt)
                SlOpt = Library:Validate({Name="Slider", Min=0, Max=100, Default=50, Flag=Library:NewFlag(), Callback=function() end}, SlOpt or {})
                local State = SlOpt.Default Library.Flags[SlOpt.Flag] = {Get = function() return State end, Set = function(self, val) State = val SlOpt.Callback(State) end}
                local SFrame = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=SecMain})
                Library:CreateObject("TextLabel", {Text=SlOpt.Name, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Library.Theme.Default.TextColor, BackgroundTransparency=1, Size=UDim2.new(1,0,0,15), TextXAlignment="Left", Parent=SFrame})
                local SBox = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,0,20), BackgroundColor3=Color3.fromRGB(12,12,12), Text="", BorderSizePixel=0, Parent=SFrame})
                local SIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(60,60,60), BorderSizePixel=0, Parent=SBox})
                local SFill = Library:CreateObject("Frame", {Size=UDim2.new((SlOpt.Default-SlOpt.Min)/(SlOpt.Max-SlOpt.Min),0,1,0), BackgroundColor3=Library.Theme.Default.Accent, BorderSizePixel=0, Parent=SIn})
                local SVal = Library:CreateObject("TextLabel", {Text=tostring(SlOpt.Default), FontFace=Library.UI.NewFont, TextSize=12, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=SFill})
                
                local Dragging = false
                Library:Connection(SBox.InputBegan, function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
                Library:Connection(UserInputService.InputEnded, function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                Library:Connection(UserInputService.InputChanged, function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        local Pct = math.clamp((Input.Position.X - SIn.AbsolutePosition.X) / SIn.AbsoluteSize.X, 0, 1)
                        local Val = math.floor(SlOpt.Min + ((SlOpt.Max - SlOpt.Min) * Pct))
                        SFill.Size = UDim2.new(Pct, 0, 1, 0) SVal.Text = tostring(Val) State = Val SlOpt.Callback(Val)
                    end
                end)
                return {Set = function(self, v) local s=(v-SlOpt.Min)/(SlOpt.Max-SlOpt.Min) SFill.Size=UDim2.new(s,0,1,0) SVal.Text=tostring(v) State=v SlOpt.Callback(v) end}
            end

            function SectionAPI:Button(BOpt)
                BOpt = Library:Validate({Name="Button", Callback=function() end}, BOpt or {})
                local BBox = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,20), BackgroundColor3=Color3.fromRGB(12,12,12), Text="", BorderSizePixel=0, Parent=SecMain})
                local BIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Parent=BBox})
                local BText = Library:CreateObject("TextLabel", {Text=BOpt.Name, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Library.Theme.Default.TextColor, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=BIn})
                if BOpt.Risky then BText.TextColor3 = Library.Theme.Default.Risky end
                local Confirmed = false
                Library:Connection(BBox.MouseButton1Click, function()
                    if BOpt.Confirmation and not Confirmed then
                        Confirmed = true BText.Text = "Are you sure?"
                        task.delay(3, function() Confirmed = false BText.Text = BOpt.Name end)
                    else
                        Confirmed = false BText.Text = BOpt.Name BOpt.Callback()
                    end
                end)
            end

            function SectionAPI:Dropdown(DOpt)
                DOpt = Library:Validate({Name="Dropdown", Content={}, Default="", Flag=Library:NewFlag(), Callback=function() end}, DOpt or {})
                local State = DOpt.Default Library.Flags[DOpt.Flag] = {Get = function() return State end, Set = function(self, val) State = val DOpt.Callback(State) end}
                local DFrame = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=SecMain})
                Library:CreateObject("TextLabel", {Text=DOpt.Name, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Library.Theme.Default.TextColor, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), TextXAlignment="Left", Parent=DFrame})
                local DBox = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,1,-18), BackgroundColor3=Color3.fromRGB(12,12,12), Text="", BorderSizePixel=0, Parent=DFrame})
                local DIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Parent=DBox})
                local DVal = Library:CreateObject("TextLabel", {Text=DOpt.Default, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Color3.fromRGB(152,152,152), BackgroundTransparency=1, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,8,0,0), TextXAlignment="Left", Parent=DIn})
                
                local Expanded = false
                local OList = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,#DOpt.Content*18), Position=UDim2.new(0,0,1,1), BackgroundColor3=Color3.fromRGB(35,35,35), BorderColor3=Color3.fromRGB(12,12,12), BorderSizePixel=1, Visible=false, ZIndex=10, Parent=DBox})
                Library:CreateObject("UIListLayout", {Parent=OList})
                
                for _, opt in pairs(DOpt.Content) do
                    local OptBtn = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,18), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Text=opt, TextColor3=Library.Theme.Default.TextColor, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, ZIndex=11, Parent=OList})
                    Library:Connection(OptBtn.MouseButton1Click, function() DVal.Text = opt Expanded = false OList.Visible = false State = opt DOpt.Callback(opt) end)
                end
                Library:Connection(DBox.MouseButton1Click, function() Expanded = not Expanded OList.Visible = Expanded end)
            end

            function SectionAPI:MultiBox(MOpt)
                MOpt = Library:Validate({Name="MultiBox", Content={}, Default={}, Flag=Library:NewFlag(), Callback=function() end}, MOpt or {})
                local State = MOpt.Default Library.Flags[MOpt.Flag] = {Get = function() return State end, Set = function(self, val) State = val MOpt.Callback(State) end}
                local DFrame = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=SecMain})
                Library:CreateObject("TextLabel", {Text=MOpt.Name, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Library.Theme.Default.TextColor, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), TextXAlignment="Left", Parent=DFrame})
                local DBox = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,1,-18), BackgroundColor3=Color3.fromRGB(12,12,12), Text="", BorderSizePixel=0, Parent=DFrame})
                local DIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Parent=DBox})
                local DVal = Library:CreateObject("TextLabel", {Text=table.concat(MOpt.Default, ", "), FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Color3.fromRGB(152,152,152), BackgroundTransparency=1, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,8,0,0), TextXAlignment="Left", Parent=DIn})
                
                local Expanded = false
                local OList = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,#MOpt.Content*18), Position=UDim2.new(0,0,1,1), BackgroundColor3=Color3.fromRGB(35,35,35), BorderColor3=Color3.fromRGB(12,12,12), BorderSizePixel=1, Visible=false, ZIndex=10, Parent=DBox})
                Library:CreateObject("UIListLayout", {Parent=OList})
                
                for _, opt in pairs(MOpt.Content) do
                    local OptBtn = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,18), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Text=opt, TextColor3=Library.Theme.Default.TextColor, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, ZIndex=11, Parent=OList})
                    if table.find(State, opt) then OptBtn.TextColor3 = Library.Theme.Default.Accent end
                    Library:Connection(OptBtn.MouseButton1Click, function() 
                        if table.find(State, opt) then table.remove(State, table.find(State, opt)) OptBtn.TextColor3 = Library.Theme.Default.TextColor
                        else table.insert(State, opt) OptBtn.TextColor3 = Library.Theme.Default.Accent end
                        DVal.Text = table.concat(State, ", ") MOpt.Callback(State)
                    end)
                end
                Library:Connection(DBox.MouseButton1Click, function() Expanded = not Expanded OList.Visible = Expanded end)
            end

            function SectionAPI:Label(LOpt)
                LOpt = Library:Validate({Message="Label"}, LOpt or {})
                local Lbl = Library:CreateObject("TextLabel", {Text=LOpt.Message, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Color3.fromRGB(198,198,198), BackgroundTransparency=1, Size=UDim2.new(1,0,0,15), TextXAlignment="Left", Parent=SecMain})
                local ReturnAPI = {}
                function ReturnAPI:ColorPicker(COpt) return Library:ColorPicker(COpt) end
                return ReturnAPI
            end

            function SectionAPI:TextBox(TxOpt)
                TxOpt = Library:Validate({Name="TextBox", Default="", Flag=Library:NewFlag(), Callback=function() end}, TxOpt or {})
                local State = TxOpt.Default Library.Flags[TxOpt.Flag] = {Get = function() return State end, Set = function(self, val) State = val TxOpt.Callback(State) end}
                local TxFrame = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=SecMain})
                Library:CreateObject("TextLabel", {Text=TxOpt.Name, FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Library.Theme.Default.TextColor, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), TextXAlignment="Left", Parent=TxFrame})
                local TxBox = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,1,-18), BackgroundColor3=Color3.fromRGB(12,12,12), BorderSizePixel=0, Parent=TxFrame})
                local TxIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Parent=TxBox})
                local InputBox = Library:CreateObject("TextBox", {Text=TxOpt.Default, PlaceholderText="...", FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextColor3=Color3.fromRGB(205,205,205), BackgroundTransparency=1, Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,5,0,0), TextXAlignment="Left", Parent=TxIn})
                Library:Connection(InputBox.FocusLost, function() State = InputBox.Text TxOpt.Callback(InputBox.Text) end)
            end

            function SectionAPI:List(LiOpt)
                LiOpt = Library:Validate({Size=100, Flag=Library:NewFlag(), Callback=function() end}, LiOpt or {})
                local LFrame = Library:CreateObject("Frame", {Size=UDim2.new(1,0,0,LiOpt.Size), BackgroundColor3=Color3.fromRGB(12,12,12), BorderSizePixel=0, Parent=SecMain})
                local LIn = Library:CreateObject("Frame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Parent=LFrame})
                local LScroll = Library:CreateObject("ScrollingFrame", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundTransparency=1, ScrollBarThickness=4, AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0), Parent=LIn})
                Library:CreateObject("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Parent=LScroll})
                Library:CreateObject("UIPadding", {PaddingLeft=UDim.new(0,5), PaddingRight=UDim.new(0,5), PaddingTop=UDim.new(0,5), Parent=LScroll})
                
                local ListAPI = {}
                function ListAPI:AddValue(Val)
                    local ValBtn = Library:CreateObject("TextButton", {Size=UDim2.new(1,0,0,18), BackgroundTransparency=1, Text=Val, TextColor3=Color3.fromRGB(205,205,205), FontFace=Library.UI.NewFont, TextSize=Library.UI.FontSize, TextXAlignment="Left", Parent=LScroll})
                    Library:Connection(ValBtn.MouseButton1Click, function() LiOpt.Callback(Val) end)
                end
                function ListAPI:RemoveValue(Val)
                    for _, child in ipairs(LScroll:GetChildren()) do if child:IsA("TextButton") and child.Text == Val then child:Destroy() end end
                end
                return ListAPI
            end

            return SectionAPI
        end
        return Tab
    end

    function Library:CreateWatermark()
        local WM = self:CreateObject("Frame", {Position=UDim2.new(0,0,0,0), BackgroundColor3=Color3.new(0,0,0), Size=UDim2.new(0,400,0,20), BorderSizePixel=0, ZIndex=10000, Parent=self.UI.ScreenGUI})
        local WMText = self:CreateObject("TextLabel", {Text="gamesense", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, TextXAlignment="Left", RichText=true, TextSize=14, TextColor3=Color3.fromRGB(208,208,208), Parent=WM})
        self:CreateObject("UIPadding", {PaddingRight=UDim.new(0,10), PaddingLeft=UDim.new(0,10), Parent=WMText})
        self.WMFrame, self.WMText = WM, WMText
    end
    function Library:ToggleWatermark(State) if self.WMFrame then self.WMFrame.Visible = State end end
    function Library:UpdateWatermark(Text) if self.WMText and self.WMFrame then self.WMText.Text = Text self.WMFrame.Size = UDim2.new(0, self.WMText.TextBounds.X + 20, 0, 20) self.WMFrame.Position = UDim2.new(1, -(self.WMFrame.Size.X.Offset) - 5, 0, 5) end end

    function Library:Notify(Options)
        Options = self:Validate({Message="Notification", Delay=3}, Options or {})
        local NFrame = self:CreateObject("Frame", {BackgroundColor3=Color3.fromRGB(12,12,12), Size=UDim2.new(0,250,0,45), Position=UDim2.new(0,-300,0,20+(#self.UI.Notifications.TopLeft*50)), ZIndex=10000, Parent=self.UI.ScreenGUI})
        self:CreateObject("TextLabel", {Text=Options.Message, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0), TextColor3=Color3.fromRGB(208,208,208), BackgroundTransparency=1, RichText=true, TextSize=14, TextXAlignment="Left", Parent=NFrame})
        table.insert(self.UI.Notifications.TopLeft, NFrame)
        self:TweenObject(NFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position=UDim2.new(0,20,0,20+((#self.UI.Notifications.TopLeft-1)*50))})
        task.delay(Options.Delay, function() self:TweenObject(NFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position=UDim2.new(0,-300,0,NFrame.Position.Y.Offset)}) task.wait(0.5) NFrame:Destroy() end)
    end
    
    function Library:Unload()
        for _, Conn in pairs(self.Connections) do Conn:Disconnect() end
        for _, Obj in pairs(self.Objects) do Obj[1]:Destroy() end
        MainUI:Destroy()
    end

    return Window
end

getgenv().Gamesense = Library
return Library
