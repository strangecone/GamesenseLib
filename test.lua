-- GameSense-style UI Library V13
-- Fixes over V12: Keybinds List actually renders now, Configs tab added (matches reference
-- screenshot: list + Save/Update/Load/Delete/Refresh/autoload/Export/Import), live accent
-- color, safer colorpicker gradient construction, RenderStepped connections cleaned up on
-- Destroy(), mobile touch support added throughout.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 100% Crash-Proof Anti-Duplicate System
pcall(function()
	if getgenv().GameSense_UI_Instance then getgenv().GameSense_UI_Instance:Destroy() getgenv().GameSense_UI_Instance = nil end
	if getgenv().GameSense_Menu_Connection then getgenv().GameSense_Menu_Connection:Disconnect() getgenv().GameSense_Menu_Connection = nil end
	if getgenv().GameSense_Render_Connection then getgenv().GameSense_Render_Connection:Disconnect() getgenv().GameSense_Render_Connection = nil end
	for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "GameSenseUI" then v:Destroy() end end
	if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
		for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do if v.Name == "GameSenseUI" then v:Destroy() end end
	end
end)

local GameSenseLib = {
	Flags = {},
	Elements = {},
	Binds = {},
	MenuKey = Enum.KeyCode.Insert,
	ConfigFolder = "GameSense",
	AutoSaveEnabled = false,
	Theme = {
		Background = Color3.fromRGB(23, 23, 23),
		MenuBg = Color3.fromRGB(17, 17, 17),
		Outline = Color3.fromRGB(45, 45, 45),
		DarkOutline = Color3.fromRGB(10, 10, 10),
		Accent = Color3.fromRGB(149, 194, 43),
		Text = Color3.fromRGB(200, 200, 200),
		DarkText = Color3.fromRGB(130, 130, 130),
		Font = Enum.Font.Code
	},
	-- FIX: Theme.Accent is a value, not a reference -- every element that painted itself with
	-- Theme.Accent at creation time was frozen at that color forever. AccentBind is a list of
	-- setter callbacks that live-repaint whenever the accent changes (see SetAccentColor below).
	AccentBind = {}
}

local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end
local delfile = delfile or function() end
local listfiles = listfiles or function() return {} end

-- FIX: original MakeDraggable never distinguished mouse vs touch cleanly for multi-touch
-- devices and leaked one InputChanged connection per drag start (never disconnected).
-- Rewritten to track a single UserInputService-level connection per draggable object.
local function MakeDraggable(topbarobject, object)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function GameSenseLib:SetWatermarkVisibility(state) if self.Watermark then self.Watermark.Visible = state end end
function GameSenseLib:SetKeybindsVisibility(state) if self.KeybindsFrame then self.KeybindsFrame.Visible = state end end

-- FIX: new -- accent color was previously baked into each element at creation and never
-- updated. This registers a repaint callback and immediately applies the new color to
-- every element that opted in (toggles, sliders, active tab icon, colorpicker swatches, etc).
function GameSenseLib:SetAccentColor(color)
	self.Theme.Accent = color
	for _, fn in ipairs(self.AccentBind) do
		pcall(fn, color)
	end
end

function GameSenseLib:MakeWindow(options)
	options = options or {}
	self.ConfigFolder = options.ConfigFolder or "GameSense"
	self.AutoSaveEnabled = options.SaveConfig or false

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GameSenseUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	self.Gui = ScreenGui
	getgenv().GameSense_UI_Instance = ScreenGui

	local NotifContainer = Instance.new("Frame")
	NotifContainer.Size = UDim2.new(0, 250, 1, -20)
	NotifContainer.Position = UDim2.new(1, -260, 0, 10)
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.ZIndex = 1000
	NotifContainer.Parent = ScreenGui
	self.NotifContainer = NotifContainer

	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.Padding = UDim.new(0, 10)
	NotifLayout.Parent = NotifContainer

	function GameSenseLib:MakeNotification(opt)
		local title = opt.Name or "Notification"
		local content = opt.Content or ""
		local time = opt.Time or 5

		local NotifFrame = Instance.new("Frame")
		NotifFrame.Size = UDim2.new(1, 0, 0, 50)
		NotifFrame.Position = UDim2.new(1, 300, 0, 0)
		NotifFrame.BackgroundColor3 = self.Theme.MenuBg
		NotifFrame.BorderColor3 = self.Theme.Outline
		NotifFrame.ZIndex = 1000
		NotifFrame.Parent = self.NotifContainer

		local NGrad = Instance.new("Frame")
		NGrad.Size = UDim2.new(1, 0, 0, 1)
		NGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NGrad.BorderSizePixel = 0
		NGrad.ZIndex = 1001
		NGrad.Parent = NotifFrame

		local UIG = Instance.new("UIGradient")
		UIG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
		})
		UIG.Parent = NGrad

		local NTitle = Instance.new("TextLabel")
		NTitle.Size = UDim2.new(1, -10, 0, 15)
		NTitle.Position = UDim2.new(0, 5, 0, 5)
		NTitle.BackgroundTransparency = 1
		NTitle.Text = title
		NTitle.TextColor3 = self.Theme.Text
		NTitle.Font = self.Theme.Font
		NTitle.TextSize = 13
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.ZIndex = 1001
		NTitle.Parent = NotifFrame

		local NContent = Instance.new("TextLabel")
		NContent.Size = UDim2.new(1, -10, 1, -25)
		NContent.Position = UDim2.new(0, 5, 0, 20)
		NContent.BackgroundTransparency = 1
		NContent.Text = content
		NContent.TextColor3 = self.Theme.DarkText
		NContent.Font = self.Theme.Font
		NContent.TextSize = 12
		NContent.TextXAlignment = Enum.TextXAlignment.Left
		NContent.TextYAlignment = Enum.TextYAlignment.Top
		NContent.TextWrapped = true
		NContent.ZIndex = 1001
		NContent.Parent = NotifFrame

		local tweenIn = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
		tweenIn:Play()

		task.delay(time, function()
			local tweenOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 0, 0)})
			tweenOut:Play()
			tweenOut.Completed:Connect(function() NotifFrame:Destroy() end)
		end)
	end

	local Watermark = Instance.new("TextLabel")
	Watermark.Size = UDim2.new(0, 250, 0, 20)
	Watermark.Position = UDim2.new(1, -260, 0, 10)
	Watermark.BackgroundColor3 = self.Theme.MenuBg
	Watermark.BorderColor3 = self.Theme.Outline
	Watermark.TextColor3 = self.Theme.Text
	Watermark.Font = self.Theme.Font
	Watermark.TextSize = 13
	Watermark.TextXAlignment = Enum.TextXAlignment.Left
	Watermark.Parent = ScreenGui
	Watermark.Visible = false
	self.Watermark = Watermark

	local WMGradient = Instance.new("Frame")
	WMGradient.Size = UDim2.new(1, 0, 0, 1)
	WMGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WMGradient.BorderSizePixel = 0
	WMGradient.Parent = Watermark

	local uiGrad = Instance.new("UIGradient")
	uiGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
	})
	uiGrad.Parent = WMGradient

	local KeybindsFrame = Instance.new("Frame")
	KeybindsFrame.Size = UDim2.new(0, 180, 0, 25)
	KeybindsFrame.Position = UDim2.new(0, 10, 0.5, 0)
	KeybindsFrame.BackgroundColor3 = self.Theme.MenuBg
	KeybindsFrame.BorderColor3 = self.Theme.Outline
	KeybindsFrame.Parent = ScreenGui
	KeybindsFrame.Visible = false
	self.KeybindsFrame = KeybindsFrame
	MakeDraggable(KeybindsFrame, KeybindsFrame)

	WMGradient:Clone().Parent = KeybindsFrame

	local KBTitle = Instance.new("TextLabel")
	KBTitle.Size = UDim2.new(1, 0, 1, 0)
	KBTitle.BackgroundTransparency = 1
	KBTitle.Text = " keybinds"
	KBTitle.TextColor3 = self.Theme.Text
	KBTitle.Font = self.Theme.Font
	KBTitle.TextSize = 13
	KBTitle.TextXAlignment = Enum.TextXAlignment.Left
	KBTitle.Parent = KeybindsFrame

	local KBContainer = Instance.new("Frame")
	KBContainer.Size = UDim2.new(1, 0, 0, 0)
	KBContainer.Position = UDim2.new(0, 0, 1, 2)
	KBContainer.BackgroundColor3 = self.Theme.MenuBg
	KBContainer.BorderColor3 = self.Theme.Outline
	KBContainer.Parent = KeybindsFrame
	local KBLayout = Instance.new("UIListLayout")
	KBLayout.Parent = KBContainer

	-- FIX: stored so Destroy() can disconnect it (previously leaked -- see anti-duplicate
	-- pcall block above, which now also cleans this up on next script run).
	getgenv().GameSense_Render_Connection = RunService.RenderStepped:Connect(function(dt)
		if Watermark.Visible then Watermark.Text = string.format(" gamesense | %s | %d fps", LocalPlayer.Name, math.floor(1 / dt)) end
		if KeybindsFrame.Visible then
			local count = 0
			for _, bind in ipairs(GameSenseLib.Binds) do
				if bind.Key ~= Enum.KeyCode.Unknown then
					count = count + 1
					bind.Label.Visible = true
					bind.Label.LayoutOrder = count
					local isActive = false
					if bind.Mode == "Always" then isActive = true
					elseif bind.Mode == "Hold" then
						for _, k in pairs(UserInputService:GetKeysPressed()) do if k.KeyCode == bind.Key then isActive = true break end end
					elseif bind.Mode == "Toggle" then isActive = bind.Toggled end
					bind.Label.TextColor3 = isActive and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
					bind.Label.Text = string.format(" %s [%s]", bind.Name, bind.Mode)
				else
					bind.Label.Visible = false
				end
			end
			KBContainer.Size = UDim2.new(1, 0, 0, count * 18)
		end
	end)

	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0, 600, 0, 450)
	Main.Position = UDim2.new(0.5, -300, 0.5, -225)
	Main.BackgroundColor3 = self.Theme.MenuBg
	Main.BorderColor3 = self.Theme.DarkOutline
	Main.BorderSizePixel = 2
	Main.Parent = ScreenGui
	MakeDraggable(Main, Main)

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = Main

	-- FIX: on phone-sized screens 600x450 doesn't fit and there was no mobile affordance at
	-- all (no way to open the menu without a physical Insert/RightShift key). This adds a
	-- floating toggle button, always present, that shows/hides Main -- works alongside the
	-- keyboard bind on devices that have one.
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	if isMobile then
		uiScale.Scale = 0.72
	end

	local MobileToggle = Instance.new("ImageButton")
	MobileToggle.Name = "GameSenseMobileToggle"
	MobileToggle.Size = UDim2.new(0, 44, 0, 44)
	MobileToggle.Position = UDim2.new(0, 10, 0, 100)
	MobileToggle.BackgroundColor3 = self.Theme.MenuBg
	MobileToggle.BorderColor3 = self.Theme.Outline
	MobileToggle.BorderSizePixel = 1
	MobileToggle.Image = "rbxassetid://3926305904"
	MobileToggle.ImageRectOffset = Vector2.new(764, 244)
	MobileToggle.ImageRectSize = Vector2.new(36, 36)
	MobileToggle.ImageColor3 = self.Theme.Text
	MobileToggle.Visible = isMobile
	MobileToggle.ZIndex = 500
	MobileToggle.Parent = ScreenGui
	MakeDraggable(MobileToggle, MobileToggle)
	MobileToggle.MouseButton1Click:Connect(function()
		Main.Visible = not Main.Visible
	end)

	-- FIXED POPUP LAYER (properly glued inside Main so math coordinates match perfectly)
	local PopupContainer = Instance.new("Frame")
	PopupContainer.Size = UDim2.new(1, 0, 1, 0)
	PopupContainer.BackgroundTransparency = 1
	PopupContainer.ZIndex = 1000
	PopupContainer.Parent = Main

	local PopupCatcher = Instance.new("TextButton")
	PopupCatcher.Size = UDim2.new(1, 0, 1, 0)
	PopupCatcher.BackgroundTransparency = 1
	PopupCatcher.Text = ""
	PopupCatcher.ZIndex = 999
	PopupCatcher.Visible = false
	PopupCatcher.Parent = PopupContainer

	local function ClosePopups()
		for _, v in pairs(PopupContainer:GetChildren()) do if v ~= PopupCatcher then v:Destroy() end end
		PopupCatcher.Visible = false
	end
	PopupCatcher.MouseButton1Click:Connect(ClosePopups)
	-- FIX: original popup catcher only closed on MouseButton1Click, so on touch devices a
	-- dropdown/colorpicker/bind-mode popup could never be dismissed by tapping outside it.
	PopupCatcher.TouchTap:Connect(ClosePopups)

	local InnerMain = Instance.new("Frame")
	InnerMain.Size = UDim2.new(1, -2, 1, -2)
	InnerMain.Position = UDim2.new(0, 1, 0, 1)
	InnerMain.BackgroundColor3 = self.Theme.MenuBg
	InnerMain.BorderColor3 = self.Theme.Outline
	InnerMain.ClipsDescendants = true
	InnerMain.Parent = Main

	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TopBar.BorderSizePixel = 0
	TopBar.ZIndex = 50
	TopBar.Parent = InnerMain
	uiGrad:Clone().Parent = TopBar

	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 60, 1, -2)
	Sidebar.Position = UDim2.new(0, 0, 0, 2)
	Sidebar.BackgroundColor3 = self.Theme.MenuBg
	Sidebar.BorderColor3 = self.Theme.Outline
	Sidebar.Parent = InnerMain
	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar
	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingTop = UDim.new(0, 15)
	SidebarPadding.Parent = Sidebar

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -61, 1, -2)
	ContentContainer.Position = UDim2.new(0, 61, 0, 2)
	ContentContainer.BackgroundColor3 = self.Theme.Background
	ContentContainer.BorderSizePixel = 0
	ContentContainer.ClipsDescendants = true
	ContentContainer.Parent = InnerMain

	getgenv().GameSense_Menu_Connection = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == GameSenseLib.MenuKey then
			Main.Visible = not Main.Visible
			ClosePopups()
		end
	end)

	local WindowObj = {Tabs = {}, TabCount = 0, FirstUserTab = false}

	function WindowObj:MakeTab(tabOptions)
		WindowObj.TabCount = WindowObj.TabCount + 1
		local isBottomTab = tabOptions.IsSettingsTab or tabOptions.IsConfigTab or false

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 50)
		TabBtn.BackgroundTransparency = 1
		-- FIX: both Settings and Configs used LayoutOrder 99999 in the naive version of this
		-- change, which put them in an undefined relative order. Configs sits just above
		-- Settings at the bottom of the rail, matching the reference screenshot (save icon
		-- above the profile/settings icon).
		if tabOptions.IsConfigTab then
			TabBtn.LayoutOrder = 99998
		elseif tabOptions.IsSettingsTab then
			TabBtn.LayoutOrder = 99999
		else
			TabBtn.LayoutOrder = WindowObj.TabCount
		end
		TabBtn.Text = ""
		TabBtn.Parent = Sidebar

		local IconImg = Instance.new("ImageLabel")
		IconImg.Size = UDim2.new(0, 30, 0, 30)
		IconImg.Position = UDim2.new(0.5, -15, 0.5, -15)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = tabOptions.Icon or ""
		IconImg.ImageColor3 = GameSenseLib.Theme.DarkText
		IconImg.Parent = TabBtn

		local TabContent = Instance.new("Frame")
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.BackgroundTransparency = 1
		TabContent.Visible = false
		TabContent.Parent = ContentContainer

		local LeftCol = Instance.new("ScrollingFrame")
		LeftCol.Size = UDim2.new(0.5, -15, 1, 0)
		LeftCol.Position = UDim2.new(0, 10, 0, 0)
		LeftCol.BackgroundTransparency = 1
		LeftCol.ScrollBarThickness = 3
		LeftCol.ScrollBarImageColor3 = GameSenseLib.Theme.Outline
		LeftCol.ClipsDescendants = true
		LeftCol.Parent = TabContent
		local LeftLayout = Instance.new("UIListLayout")
		LeftLayout.Padding = UDim.new(0, 15)
		LeftLayout.Parent = LeftCol
		local LeftPad = Instance.new("UIPadding")
		LeftPad.PaddingTop = UDim.new(0, 12)
		LeftPad.PaddingBottom = UDim.new(0, 12)
		LeftPad.Parent = LeftCol

		local RightCol = Instance.new("ScrollingFrame")
		RightCol.Size = UDim2.new(0.5, -15, 1, 0)
		RightCol.Position = UDim2.new(0.5, 5, 0, 0)
		RightCol.BackgroundTransparency = 1
		RightCol.ScrollBarThickness = 3
		RightCol.ScrollBarImageColor3 = GameSenseLib.Theme.Outline
		RightCol.ClipsDescendants = true
		RightCol.Parent = TabContent
		local RightLayout = Instance.new("UIListLayout")
		RightLayout.Padding = UDim.new(0, 15)
		RightLayout.Parent = RightCol
		local RightPad = Instance.new("UIPadding")
		RightPad.PaddingTop = UDim.new(0, 12)
		RightPad.PaddingBottom = UDim.new(0, 12)
		RightPad.Parent = RightCol

		LeftCol:GetPropertyChangedSignal("CanvasPosition"):Connect(ClosePopups)
		RightCol:GetPropertyChangedSignal("CanvasPosition"):Connect(ClosePopups)

		local function SelectThisTab()
			for _, tab in pairs(WindowObj.Tabs) do
				tab.Content.Visible = false
				tab.Icon.ImageColor3 = GameSenseLib.Theme.DarkText
			end
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
			ClosePopups()
		end
		TabBtn.MouseButton1Click:Connect(SelectThisTab)
		-- FIX: tab buttons had no touch handler, so tapping a tab icon on mobile did nothing.
		TabBtn.TouchTap:Connect(SelectThisTab)

		if not isBottomTab and not WindowObj.FirstUserTab then
			WindowObj.FirstUserTab = true
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
		end

		-- FIX: active-tab icon color was set once at creation and never followed live accent
		-- changes. Register it so SetAccentColor repaints whichever tab is currently active.
		table.insert(GameSenseLib.AccentBind, function(color)
			if TabContent.Visible then IconImg.ImageColor3 = color end
		end)

		table.insert(WindowObj.Tabs, {Content = TabContent, Icon = IconImg, Select = SelectThisTab})

		local TabObj = {}

		local DefaultSection = nil
		local function GetDefaultSection()
			if not DefaultSection then DefaultSection = TabObj:AddSection({ Name = "General", Side = "Left" }) end
			return DefaultSection
		end

		function TabObj:AddToggle(opt) return GetDefaultSection():AddToggle(opt) end
		function TabObj:AddSlider(opt) return GetDefaultSection():AddSlider(opt) end
		function TabObj:AddDropdown(opt) return GetDefaultSection():AddDropdown(opt) end
		function TabObj:AddBind(opt) return GetDefaultSection():AddBind(opt) end
		function TabObj:AddColorpicker(opt) return GetDefaultSection():AddColorpicker(opt) end
		function TabObj:AddTextbox(opt) return GetDefaultSection():AddTextbox(opt) end
		function TabObj:AddButton(opt) return GetDefaultSection():AddButton(opt) end
		function TabObj:AddLabel(text) return GetDefaultSection():AddLabel(text) end
		function TabObj:AddParagraph(t, c) return GetDefaultSection():AddParagraph(t, c) end

		function TabObj:AddSection(secOptions)
			local side = secOptions.Side or "Left"
			local ParentCol = (side == "Right") and RightCol or LeftCol

			local Groupbox = Instance.new("Frame")
			Groupbox.Size = UDim2.new(1, 0, 0, 20)
			Groupbox.BackgroundColor3 = GameSenseLib.Theme.MenuBg
			Groupbox.BorderColor3 = GameSenseLib.Theme.Outline
			Groupbox.ZIndex = 1
			Groupbox.Parent = ParentCol

			local TitleBg = Instance.new("Frame")
			TitleBg.Position = UDim2.new(0, 15, 0, -6)
			TitleBg.Size = UDim2.new(0, 5, 0, 12)
			TitleBg.BackgroundColor3 = GameSenseLib.Theme.Background
			TitleBg.BorderSizePixel = 0
			TitleBg.ZIndex = 2
			TitleBg.Parent = Groupbox

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Position = UDim2.new(0, 2, 0, -1)
			TitleLabel.Size = UDim2.new(0, 0, 1, 0)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Text = secOptions.Name or "Section"
			TitleLabel.TextColor3 = GameSenseLib.Theme.Text
			TitleLabel.Font = GameSenseLib.Theme.Font
			TitleLabel.TextSize = 13
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.ZIndex = 3
			TitleLabel.Parent = TitleBg
			TitleBg.Size = UDim2.new(0, TitleLabel.TextBounds.X + 4, 0, 12)

			local ItemContainer = Instance.new("Frame")
			ItemContainer.Size = UDim2.new(1, -20, 1, -15)
			ItemContainer.Position = UDim2.new(0, 10, 0, 10)
			ItemContainer.BackgroundTransparency = 1
			ItemContainer.ZIndex = 2
			ItemContainer.Parent = Groupbox

			local ItemLayout = Instance.new("UIListLayout")
			ItemLayout.Padding = UDim.new(0, 8)
			ItemLayout.Parent = ItemContainer

			local function UpdateSize()
				Groupbox.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y + 20)
				local targetLayout = side == "Right" and RightLayout or LeftLayout
				ParentCol.CanvasSize = UDim2.new(0, 0, 0, targetLayout.AbsoluteContentSize.Y + 25)
			end
			ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

			local SectionObj = {}

			function SectionObj:AddToggle(opt)
				local state = opt.Default or false
				local Frame = Instance.new("TextButton")
				Frame.Size = UDim2.new(1, 0, 0, 12)
				Frame.BackgroundTransparency = 1
				Frame.Text = ""
				Frame.Parent = ItemContainer

				local Box = Instance.new("Frame")
				Box.Size = UDim2.new(0, 10, 0, 10)
				Box.Position = UDim2.new(0, 0, 0.5, -5)
				Box.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.DarkOutline
				Box.BorderColor3 = GameSenseLib.Theme.Outline
				Box.Parent = Frame

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -20, 1, 0)
				Label.Position = UDim2.new(0, 18, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Toggle"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local function Set(val)
					state = val
					Box.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.DarkOutline

					if opt.Flag then
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = state
					end

					if opt.Callback then pcall(opt.Callback, state) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config") end
				end
				Frame.MouseButton1Click:Connect(function() Set(not state) end)
				-- FIX: no touch handler -- toggles were unusable on mobile without a mouse.
				Frame.TouchTap:Connect(function() Set(not state) end)

				-- FIX: keep the box in sync if the accent color changes live while toggled on.
				table.insert(GameSenseLib.AccentBind, function(color)
					if state then Box.BackgroundColor3 = color end
				end)

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(state)

				local Obj = {}
				function Obj:Set(val) Set(val) end
				return Obj
			end

			function SectionObj:AddSlider(opt)
				local val = opt.Default or opt.Min
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 30)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Slider"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Track = Instance.new("TextButton")
				Track.Size = UDim2.new(1, 0, 0, 16)
				Track.Position = UDim2.new(0, 0, 0, 18)
				Track.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Track.BorderColor3 = GameSenseLib.Theme.Outline
				Track.Text = ""
				Track.Parent = Frame
				-- FIX: original track was 10px tall which is a poor touch target (Apple/Google
				-- HIG recommend >=24px). Bumped to 16px; still reads as a thin bar visually.

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
				Fill.BackgroundColor3 = GameSenseLib.Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = Track

				local ValLabel = Instance.new("TextLabel")
				ValLabel.Size = UDim2.new(1, -2, 1, 0)
				ValLabel.BackgroundTransparency = 1
				ValLabel.Text = tostring(val) .. (opt.ValueName or "")
				ValLabel.TextColor3 = Color3.new(1, 1, 1)
				ValLabel.Font = GameSenseLib.Theme.Font
				ValLabel.TextSize = 10
				ValLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValLabel.Parent = Track

				local function Set(newVal)
					val = math.clamp(newVal, opt.Min, opt.Max)
					Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
					ValLabel.Text = tostring(val) .. (opt.ValueName or "")

					if opt.Flag then
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = val
					end

					if opt.Callback then pcall(opt.Callback, val) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config") end
				end

				local dragging = false
				local function Update(input)
					local perc = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
					Set(math.floor(opt.Min + (opt.Max - opt.Min) * perc))
				end

				Track.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						Update(inp)
					end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
						Update(inp)
					end
				end)
				-- FIX: original only handled Enum.UserInputType.MouseButton1 in InputBegan and
				-- MouseMovement in InputChanged, so sliders could not be dragged at all on a
				-- touchscreen. Now handles Touch alongside mouse in all three connections.

				table.insert(GameSenseLib.AccentBind, function(color) Fill.BackgroundColor3 = color end)

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(val)

				local Obj = {}
				function Obj:Set(v) Set(v) end
				return Obj
			end

			function SectionObj:AddDropdown(opt)
				local selected = opt.Default or (opt.Options and opt.Options[1] or "")
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 35)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Dropdown"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local MainBtn = Instance.new("TextButton")
				MainBtn.Size = UDim2.new(1, 0, 0, 18)
				MainBtn.Position = UDim2.new(0, 0, 0, 15)
				MainBtn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				MainBtn.BorderColor3 = GameSenseLib.Theme.Outline
				MainBtn.Text = " " .. tostring(selected)
				MainBtn.TextColor3 = GameSenseLib.Theme.DarkText
				MainBtn.Font = GameSenseLib.Theme.Font
				MainBtn.TextSize = 12
				MainBtn.TextXAlignment = Enum.TextXAlignment.Left
				MainBtn.Parent = Frame

				local function Set(val)
					selected = val
					MainBtn.Text = " " .. tostring(val)

					if opt.Flag then
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = val
					end

					if opt.Callback then pcall(opt.Callback, val) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config") end
				end

				local function Refresh(newList, preserve)
					opt.Options = newList or {}
					if not preserve and #opt.Options > 0 then Set(opt.Options[1]) end
				end

				local function OpenDropdown()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (MainBtn.AbsolutePosition.X - Main.AbsolutePosition.X) / uiScale.Scale
					local relY = (MainBtn.AbsolutePosition.Y - Main.AbsolutePosition.Y) / uiScale.Scale

					local DropContainer = Instance.new("Frame")
					DropContainer.Size = UDim2.new(0, MainBtn.AbsoluteSize.X / uiScale.Scale, 0, #(opt.Options or {}) * 18)
					DropContainer.Position = UDim2.new(0, relX, 0, relY + 20)
					DropContainer.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
					DropContainer.ZIndex = 1001
					DropContainer.Parent = PopupContainer

					local DropLayout = Instance.new("UIListLayout")
					DropLayout.Parent = DropContainer

					for _, item in ipairs(opt.Options or {}) do
						local Btn = Instance.new("TextButton")
						Btn.Size = UDim2.new(1, 0, 0, 18)
						Btn.BackgroundColor3 = GameSenseLib.Theme.MenuBg
						Btn.BorderSizePixel = 0
						Btn.Text = " " .. tostring(item)
						Btn.TextColor3 = GameSenseLib.Theme.Text
						Btn.Font = GameSenseLib.Theme.Font
						Btn.TextSize = 12
						Btn.TextXAlignment = Enum.TextXAlignment.Left
						Btn.ZIndex = 1002
						Btn.Parent = DropContainer

						local function pick() Set(item) ClosePopups() end
						Btn.MouseButton1Click:Connect(pick)
						Btn.TouchTap:Connect(pick)
					end
				end
				MainBtn.MouseButton1Click:Connect(OpenDropdown)
				MainBtn.TouchTap:Connect(OpenDropdown)
				-- FIX: dropdown open + option pick had no TouchTap handlers.

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(selected)

				local Obj = {}
				function Obj:Set(v) Set(v) end
				function Obj:Refresh(l, p) Refresh(l, p) end
				return Obj
			end

			function SectionObj:AddBind(opt)
				local key = opt.Default or Enum.KeyCode.Unknown
				local mode = opt.Mode or "Toggle"
				-- FIX: original hardcoded mode = "Toggle" and silently ignored an opt.Mode
				-- argument if the dev tried to pass one in.

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 15)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -50, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Bind"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(0, 45, 0, 15)
				Btn.Position = UDim2.new(1, -45, 0, 0)
				Btn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = "[" .. (key == Enum.KeyCode.Unknown and "None" or key.Name) .. "]"
				Btn.TextColor3 = GameSenseLib.Theme.DarkText
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 11
				Btn.Parent = Frame

				-- FIX (the big one): KBItem was built with Label = KBItem pushed into
				-- GameSenseLib.Binds, but KBItem.Parent was NEVER SET. The "Keybinds List"
				-- watermark toggle in the Settings tab therefore did nothing -- the frame it
				-- was supposed to show/hide had zero children. Parenting it to KBContainer
				-- (declared earlier in MakeWindow, in scope here via closure) is the fix.
				local KBItem = Instance.new("TextLabel")
				KBItem.Size = UDim2.new(1, -10, 0, 18)
				KBItem.BackgroundTransparency = 1
				KBItem.Font = GameSenseLib.Theme.Font
				KBItem.TextSize = 12
				KBItem.TextXAlignment = Enum.TextXAlignment.Left
				KBItem.Visible = false
				KBItem.Parent = KBContainer

				local bindData = {Name = opt.Name, Key = key, Mode = mode, Toggled = false, Label = KBItem}
				table.insert(GameSenseLib.Binds, bindData)

				local function Set(newKey)
					key = newKey
					bindData.Key = newKey
					Btn.Text = "[" .. (key == Enum.KeyCode.Unknown and "None" or key.Name) .. "]"

					if opt.Flag then
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = newKey
					end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config") end
				end

				local function OpenModePicker()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (Btn.AbsolutePosition.X - Main.AbsolutePosition.X) / uiScale.Scale
					local relY = (Btn.AbsolutePosition.Y - Main.AbsolutePosition.Y) / uiScale.Scale

					local Modes = {"Always", "Hold", "Toggle"}
					local DropContainer = Instance.new("Frame")
					DropContainer.Size = UDim2.new(0, 60, 0, #Modes * 18)
					DropContainer.Position = UDim2.new(0, relX, 0, relY + 18)
					DropContainer.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
					DropContainer.ZIndex = 1001
					DropContainer.Parent = PopupContainer
					local DropLayout = Instance.new("UIListLayout")
					DropLayout.Parent = DropContainer

					for _, m in ipairs(Modes) do
						local MBtn = Instance.new("TextButton")
						MBtn.Size = UDim2.new(1, 0, 0, 18)
						MBtn.BackgroundColor3 = GameSenseLib.Theme.MenuBg
						MBtn.BorderSizePixel = 0
						MBtn.Text = (bindData.Mode == m and "> " or "  ") .. m
						MBtn.TextColor3 = bindData.Mode == m and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
						MBtn.Font = GameSenseLib.Theme.Font
						MBtn.TextSize = 11
						MBtn.TextXAlignment = Enum.TextXAlignment.Left
						MBtn.ZIndex = 1002
						MBtn.Parent = DropContainer
						local function pick() bindData.Mode = m ClosePopups() end
						MBtn.MouseButton1Click:Connect(pick)
						MBtn.TouchTap:Connect(pick)
					end
				end
				Btn.MouseButton2Click:Connect(OpenModePicker)
				-- FIX: right-click-only mode picker was unreachable on mobile (no
				-- MouseButton2 equivalent for touch). A long-press (0.5s hold) now opens it too.
				do
					local touchStart = nil
					Btn.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Touch then
							touchStart = tick()
							task.delay(0.5, function()
								if touchStart and tick() - touchStart >= 0.5 then
									OpenModePicker()
								end
							end)
						end
					end)
					Btn.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Touch then touchStart = nil end
					end)
				end

				local listening = false
				local function startListening() listening = true Btn.Text = "[...]" end
				Btn.MouseButton1Click:Connect(startListening)
				Btn.TouchTap:Connect(startListening)
				-- FIX: bind-capture click had no TouchTap; couldn't rebind a key on mobile at all
				-- (arguably keybinds matter less on mobile, but the button should still respond).

				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						Set(input.KeyCode)
						listening = false
						if opt.OnKeyChange then pcall(opt.OnKeyChange, key) end
					elseif not listening and input.KeyCode == key and key ~= Enum.KeyCode.Unknown and not gpe then
						if bindData.Mode == "Toggle" then bindData.Toggled = not bindData.Toggled end
						if opt.Callback then pcall(opt.Callback) end
					end
				end)
				-- FIX: added key ~= Enum.KeyCode.Unknown guard -- previously if two unbound
				-- binds both defaulted to Unknown, any keypress with KeyCode == Unknown
				-- (input.KeyCode is Unknown for non-keyboard inputs in some edge cases) could
				-- spuriously fire every unbound bind's callback simultaneously.

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end

				local Obj = {}
				function Obj:Set(v) Set(v) end
				return Obj
			end

			function SectionObj:AddColorpicker(opt)
				local h, s, v = Color3.toHSV(opt.Default or Color3.fromRGB(255, 0, 0))
				local rainbow = false
				local rbConn = nil

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 15)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -30, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Color"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(0, 25, 0, 12)
				Btn.Position = UDim2.new(1, -25, 0.5, -6)
				Btn.BackgroundColor3 = Color3.fromHSV(h, s, v)
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = ""
				Btn.Parent = Frame

				local activeSVMap = nil

				local function Set(clr)
					if type(clr) == "table" then h, s, v = clr[1], clr[2], clr[3] else h, s, v = Color3.toHSV(clr) end
					local c = Color3.fromHSV(h, s, v)
					Btn.BackgroundColor3 = c

					if opt.Flag then
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = {h, s, v}
					end

					if opt.Callback then pcall(opt.Callback, c) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config") end
				end

				local function ToggleRainbow(state)
					rainbow = state
					if rainbow then
						if not rbConn then
							rbConn = RunService.RenderStepped:Connect(function()
								h = (tick() % 5) / 5
								local c = Color3.fromHSV(h, s, v)
								Btn.BackgroundColor3 = c
								if activeSVMap and activeSVMap.Parent then activeSVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1) end
								if opt.Flag then
									if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
									GameSenseLib.Flags[opt.Flag].Value = {h, s, v}
								end
								if opt.Callback then pcall(opt.Callback, c) end
							end)
						end
					else
						if rbConn then rbConn:Disconnect(); rbConn = nil end
					end
				end

				local function OpenPicker()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (Btn.AbsolutePosition.X - Main.AbsolutePosition.X) / uiScale.Scale
					local relY = (Btn.AbsolutePosition.Y - Main.AbsolutePosition.Y) / uiScale.Scale

					local Picker = Instance.new("Frame")
					Picker.Size = UDim2.new(0, 140, 0, 165)
					Picker.Position = UDim2.new(0, relX - 115, 0, relY + 15)
					Picker.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					Picker.BorderColor3 = GameSenseLib.Theme.Outline
					Picker.ZIndex = 1001
					Picker.Parent = PopupContainer

					local SVMap = Instance.new("TextButton")
					SVMap.Size = UDim2.new(0, 130, 0, 120)
					SVMap.Position = UDim2.new(0, 5, 0, 5)
					SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					SVMap.BorderSizePixel = 0
					SVMap.Text = ""
					SVMap.AutoButtonColor = false
					SVMap.ZIndex = 1002
					SVMap.Parent = Picker
					activeSVMap = SVMap

					-- FIX: original built these as
					--   Instance.new("UIGradient", Instance.new("Frame", SVMap))
					-- which works but is a maintenance trap: the overlay Frame's properties
					-- are then set via WGrad.Parent.X, one typo away from silently writing to
					-- the wrong object. Split into named locals -- identical visual result,
					-- much harder to break by accident.
					local WhiteOverlay = Instance.new("Frame")
					WhiteOverlay.Size = UDim2.new(1, 0, 1, 0)
					WhiteOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
					WhiteOverlay.BorderSizePixel = 0
					WhiteOverlay.ZIndex = 1003
					WhiteOverlay.Parent = SVMap
					local WGrad = Instance.new("UIGradient")
					WGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
					WGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
					WGrad.Parent = WhiteOverlay

					local BlackOverlay = Instance.new("Frame")
					BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
					BlackOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
					BlackOverlay.BorderSizePixel = 0
					BlackOverlay.ZIndex = 1004
					BlackOverlay.Parent = SVMap
					local BGrad = Instance.new("UIGradient")
					BGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
					BGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
					BGrad.Rotation = 90
					BGrad.Parent = BlackOverlay

					local HueMap = Instance.new("TextButton")
					HueMap.Size = UDim2.new(0, 130, 0, 15)
					HueMap.Position = UDim2.new(0, 5, 0, 127)
					HueMap.BackgroundColor3 = Color3.new(1, 1, 1)
					HueMap.BorderSizePixel = 0
					HueMap.Text = ""
					HueMap.ZIndex = 1002
					HueMap.Parent = Picker

					local HGrad = Instance.new("UIGradient")
					HGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					})
					HGrad.Parent = HueMap

					local RbToggle = Instance.new("TextButton")
					RbToggle.Size = UDim2.new(1, -10, 0, 15)
					RbToggle.Position = UDim2.new(0, 5, 0, 145)
					RbToggle.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
					RbToggle.BorderColor3 = GameSenseLib.Theme.Outline
					RbToggle.Text = rainbow and "Rainbow: ON" or "Rainbow: OFF"
					RbToggle.TextColor3 = rainbow and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
					RbToggle.Font = GameSenseLib.Theme.Font
					RbToggle.TextSize = 11
					RbToggle.ZIndex = 1002
					RbToggle.Parent = Picker

					local function toggleRb()
						rainbow = not rainbow
						RbToggle.Text = rainbow and "Rainbow: ON" or "Rainbow: OFF"
						RbToggle.TextColor3 = rainbow and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
						ToggleRainbow(rainbow)
					end
					RbToggle.MouseButton1Click:Connect(toggleRb)
					RbToggle.TouchTap:Connect(toggleRb)

					local draggingSV, draggingH = false, false

					local function UpdateSV(input)
						s = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
						v = 1 - math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
						Set({h, s, v})
					end
					local function UpdateH(input)
						if rainbow then ToggleRainbow(false); RbToggle.Text = "Rainbow: OFF"; RbToggle.TextColor3 = GameSenseLib.Theme.Text end
						h = math.clamp((input.Position.X - HueMap.AbsolutePosition.X) / HueMap.AbsoluteSize.X, 0, 1)
						SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						Set({h, s, v})
					end

					SVMap.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							draggingSV = true
							UpdateSV(i)
						end
					end)
					HueMap.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							draggingH = true
							UpdateH(i)
						end
					end)
					UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							draggingSV = false
							draggingH = false
						end
					end)
					UserInputService.InputChanged:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
							if draggingSV then UpdateSV(i) elseif draggingH then UpdateH(i) end
						end
					end)
					-- FIX: SV map and hue bar only handled MouseButton1/MouseMovement, so the
					-- colorpicker (a headline feature you asked for -- "rainbow toggle") could
					-- not be dragged on a touchscreen at all. Touch now works identically to mouse.
				end
				Btn.MouseButton1Click:Connect(OpenPicker)
				Btn.TouchTap:Connect(OpenPicker)

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set({h, s, v})

				local Obj = {}
				function Obj:Set(v) Set(v) end
				return Obj
			end

			function SectionObj:AddTextbox(opt)
				local val = opt.Default or ""
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 35)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Textbox"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Box = Instance.new("TextBox")
				Box.Size = UDim2.new(1, 0, 0, 18)
				Box.Position = UDim2.new(0, 0, 0, 15)
				Box.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Box.BorderColor3 = GameSenseLib.Theme.Outline
				Box.Text = val
				Box.TextColor3 = GameSenseLib.Theme.Text
				Box.Font = GameSenseLib.Theme.Font
				Box.TextSize = 12
				Box.ClearTextOnFocus = false
				Box.Parent = Frame

				local function Set(newVal)
					Box.Text = newVal

					if opt.Flag then
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = newVal
					end

					if opt.Callback then pcall(opt.Callback, newVal) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config") end
				end

				Box.FocusLost:Connect(function()
					local t = Box.Text
					if opt.TextDisappear then Box.Text = "" end
					Set(t)
				end)

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(val)

				local Obj = {}
				function Obj:Set(v) Set(v) end
				return Obj
			end

			function SectionObj:AddButton(opt)
				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1, 0, 0, 20)
				Btn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = opt.Name or "Button"
				Btn.TextColor3 = GameSenseLib.Theme.Text
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 12
				Btn.Parent = ItemContainer
				local function fire() if opt.Callback then pcall(opt.Callback) end end
				Btn.MouseButton1Click:Connect(fire)
				Btn.TouchTap:Connect(fire)

				local Obj = {}
				Obj.Instance = Btn
				return Obj
			end

			function SectionObj:AddLabel(text)
				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = text
				Label.TextColor3 = GameSenseLib.Theme.DarkText
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = ItemContainer
				local Obj = {}
				function Obj:Set(val) Label.Text = val end
				return Obj
			end

			function SectionObj:AddParagraph(title, content)
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 30)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local T = Instance.new("TextLabel")
				T.Size = UDim2.new(1, 0, 0, 15)
				T.BackgroundTransparency = 1
				T.Text = title
				T.TextColor3 = GameSenseLib.Theme.Text
				T.Font = GameSenseLib.Theme.Font
				T.TextSize = 12
				T.TextXAlignment = Enum.TextXAlignment.Left
				T.Parent = Frame

				local C = Instance.new("TextLabel")
				C.Size = UDim2.new(1, 0, 0, 15)
				C.Position = UDim2.new(0, 0, 0, 15)
				C.BackgroundTransparency = 1
				C.Text = content
				C.TextColor3 = GameSenseLib.Theme.DarkText
				C.Font = GameSenseLib.Theme.Font
				C.TextSize = 12
				C.TextXAlignment = Enum.TextXAlignment.Left
				C.Parent = Frame

				local Obj = {}
				function Obj:Set(newTitle, newContent) T.Text = newTitle; C.Text = newContent end
				return Obj
			end

			-- NEW: hands back the section's own ItemContainer so a caller (including this
			-- library's own Configs tab, built below) can construct bespoke layouts -- a
			-- scrolling list, a grid, whatever -- using the exact same parent every built-in
			-- element uses, instead of needing SectionObj to expose its internals everywhere.
			function SectionObj:AddCustom()
				return ItemContainer
			end

			return SectionObj
		end
		return TabObj
	end


	-- ============================================================
	-- Configs tab -- matches the reference screenshot: a scrollable
	-- list of saved config names, a name field, and Save/Update /
	-- Load / Delete / Refresh / autoload / Export / Import buttons.
	-- ============================================================
	local ConfigsTab = WindowObj:MakeTab({ Name = "Configs", Icon = "rbxassetid://7734053495", IsConfigTab = true })
	local ConfigsSection = ConfigsTab:AddSection({ Name = "Configs", Side = "Left" })
	local ConfigsParent = ConfigsSection:AddCustom()

	local selectedConfigName = nil
	local autoloadName = nil

	-- --- scrollable list of saved configs ---
	local ListFrame = Instance.new("ScrollingFrame")
	ListFrame.Size = UDim2.new(1, 0, 0, 140)
	ListFrame.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
	ListFrame.BorderColor3 = GameSenseLib.Theme.Outline
	ListFrame.ScrollBarThickness = 3
	ListFrame.ScrollBarImageColor3 = GameSenseLib.Theme.Outline
	ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ListFrame.Parent = ConfigsParent

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Parent = ListFrame

	local listRows = {}

	local function paintListRows()
		for name, row in pairs(listRows) do
			local isSelected = (name == selectedConfigName)
			local isAutoload = (name == autoloadName)
			row.Label.TextColor3 = isSelected and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
			row.Label.Text = (isAutoload and "* " or "  ") .. name
		end
	end
	table.insert(GameSenseLib.AccentBind, function() paintListRows() end)

	local function RefreshConfigList()
		for _, row in pairs(listRows) do row.Frame:Destroy() end
		listRows = {}

		local files = listfiles(GameSenseLib.ConfigFolder)
		local prefix = tostring(game.PlaceId) .. "_"
		local names = {}
		for _, path in ipairs(files) do
			local fname = path:match("([^/\\]+)%.json$")
			if fname and fname:sub(1, #prefix) == prefix then
				table.insert(names, fname:sub(#prefix + 1))
			end
		end
		table.sort(names)

		for _, name in ipairs(names) do
			local Row = Instance.new("TextButton")
			Row.Size = UDim2.new(1, 0, 0, 18)
			Row.BackgroundTransparency = 1
			Row.Text = ""
			Row.Parent = ListFrame

			local RowLabel = Instance.new("TextLabel")
			RowLabel.Size = UDim2.new(1, -6, 1, 0)
			RowLabel.Position = UDim2.new(0, 4, 0, 0)
			RowLabel.BackgroundTransparency = 1
			RowLabel.Text = "  " .. name
			RowLabel.TextColor3 = GameSenseLib.Theme.Text
			RowLabel.Font = GameSenseLib.Theme.Font
			RowLabel.TextSize = 12
			RowLabel.TextXAlignment = Enum.TextXAlignment.Left
			RowLabel.Parent = Row

			listRows[name] = {Frame = Row, Label = RowLabel}

			local function select()
				selectedConfigName = name
				paintListRows()
			end
			Row.MouseButton1Click:Connect(select)
			Row.TouchTap:Connect(select)
		end

		ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
		paintListRows()
	end

	-- --- name field ---
	local NameFieldFrame = Instance.new("Frame")
	NameFieldFrame.Size = UDim2.new(1, 0, 0, 18)
	NameFieldFrame.BackgroundTransparency = 1
	NameFieldFrame.Parent = ConfigsParent

	local NameField = Instance.new("TextBox")
	NameField.Size = UDim2.new(1, 0, 1, 0)
	NameField.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
	NameField.BorderColor3 = GameSenseLib.Theme.Outline
	NameField.PlaceholderText = "config name..."
	NameField.Text = ""
	NameField.TextColor3 = GameSenseLib.Theme.Text
	NameField.PlaceholderColor3 = GameSenseLib.Theme.DarkText
	NameField.Font = GameSenseLib.Theme.Font
	NameField.TextSize = 12
	NameField.ClearTextOnFocus = false
	NameField.Parent = NameFieldFrame

	NameField.FocusLost:Connect(function()
		if NameField.Text ~= "" then selectedConfigName = NameField.Text end
	end)

	local function currentName()
		if NameField.Text ~= "" then return NameField.Text end
		return selectedConfigName
	end

	-- --- action buttons ---
	local function addConfigButton(name, callback)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 20)
		Btn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
		Btn.BorderColor3 = GameSenseLib.Theme.Outline
		Btn.Text = name
		Btn.TextColor3 = GameSenseLib.Theme.Text
		Btn.Font = GameSenseLib.Theme.Font
		Btn.TextSize = 12
		Btn.Parent = ConfigsParent
		Btn.MouseButton1Click:Connect(callback)
		Btn.TouchTap:Connect(callback)
		return Btn
	end

	addConfigButton("Save/Update", function()
		local name = currentName()
		if not name or name == "" then
			GameSenseLib:MakeNotification({Name = "Error", Content = "Enter a config name first.", Time = 3})
			return
		end
		GameSenseLib:SaveConfig(name)
		selectedConfigName = name
		RefreshConfigList()
	end)

	addConfigButton("Load", function()
		local name = currentName()
		if not name or name == "" then
			GameSenseLib:MakeNotification({Name = "Error", Content = "Select or type a config name first.", Time = 3})
			return
		end
		GameSenseLib:LoadConfig(name)
	end)

	addConfigButton("Delete", function()
		local name = currentName()
		if not name or name == "" then return end
		local path = GameSenseLib.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_" .. name .. ".json"
		pcall(delfile, path)
		if selectedConfigName == name then selectedConfigName = nil end
		if autoloadName == name then autoloadName = nil end
		RefreshConfigList()
		GameSenseLib:MakeNotification({Name = "Config Deleted", Content = "Deleted " .. name, Time = 3})
	end)

	addConfigButton("Refresh", function() RefreshConfigList() end)

	local AutoloadBtn = addConfigButton("Set autoload", function() end)
	local StopAutoloadBtn = addConfigButton("Stop autoload", function() end)
	AutoloadBtn.MouseButton1Click:Connect(function()
		local name = currentName()
		if not name or name == "" then return end
		autoloadName = name
		writefile(GameSenseLib.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_autoload.txt", name)
		paintListRows()
		GameSenseLib:MakeNotification({Name = "Autoload Set", Content = name .. " will load automatically.", Time = 3})
	end)
	StopAutoloadBtn.MouseButton1Click:Connect(function()
		autoloadName = nil
		pcall(delfile, GameSenseLib.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_autoload.txt")
		paintListRows()
		GameSenseLib:MakeNotification({Name = "Autoload Cleared", Content = "No config will autoload.", Time = 3})
	end)

	addConfigButton("Export", function()
		local name = currentName()
		if not name or name == "" then return end
		local path = GameSenseLib.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_" .. name .. ".json"
		if isfile(path) then
			local data = readfile(path)
			if setclipboard then
				pcall(setclipboard, data)
				GameSenseLib:MakeNotification({Name = "Exported", Content = "Config copied to clipboard.", Time = 3})
			else
				GameSenseLib:MakeNotification({Name = "Export", Content = "setclipboard not supported by this executor.", Time = 4})
			end
		end
	end)

	-- --- import-from-clipboard box ---
	local ImportFrame = Instance.new("Frame")
	ImportFrame.Size = UDim2.new(1, 0, 0, 18)
	ImportFrame.BackgroundTransparency = 1
	ImportFrame.Parent = ConfigsParent

	local ImportBox = Instance.new("TextBox")
	ImportBox.Size = UDim2.new(1, 0, 1, 0)
	ImportBox.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
	ImportBox.BorderColor3 = GameSenseLib.Theme.Outline
	ImportBox.PlaceholderText = "paste config json here..."
	ImportBox.Text = ""
	ImportBox.TextColor3 = GameSenseLib.Theme.Text
	ImportBox.PlaceholderColor3 = GameSenseLib.Theme.DarkText
	ImportBox.Font = GameSenseLib.Theme.Font
	ImportBox.TextSize = 12
	ImportBox.ClearTextOnFocus = false
	ImportBox.Parent = ImportFrame

	addConfigButton("Import from box", function()
		local raw = ImportBox.Text
		if raw == "" then return end
		local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok or type(decoded) ~= "table" then
			GameSenseLib:MakeNotification({Name = "Import Failed", Content = "Clipboard text is not valid config JSON.", Time = 4})
			return
		end
		for flag, val in pairs(decoded) do
			if GameSenseLib.Elements[flag] then pcall(function() GameSenseLib.Elements[flag].Set(val) end) end
		end
		ImportBox.Text = ""
		GameSenseLib:MakeNotification({Name = "Imported", Content = "Applied config from pasted text.", Time = 3})
	end)

	RefreshConfigList()

	local BuiltInSettings = WindowObj:MakeTab({ Name = "Settings", Icon = "rbxassetid://7734053495", IsSettingsTab = true })

	local UISec = BuiltInSettings:AddSection({ Name = "UI Settings", Side = "Left" })
	UISec:AddBind({ Name = "Menu Keybind", Default = Enum.KeyCode.Insert, OnKeyChange = function(key) GameSenseLib.MenuKey = key end })
	UISec:AddSlider({ Name = "UI Scale", Min = 50, Max = 150, Default = math.floor(uiScale.Scale * 100), ValueName = "%", Callback = function(val) uiScale.Scale = val / 100 end })
	-- FIX: default was hardcoded to 100 even when isMobile had already set uiScale.Scale to
	-- 0.72 -- the slider's displayed default and the actual applied scale disagreed on load.

	-- NEW: live accent color picker, matching "Menu Accent Color" swatch in the reference
	-- screenshot. Wired through GameSenseLib:SetAccentColor so every bound element repaints.
	UISec:AddColorpicker({
		Name = "Menu Accent Color",
		Default = GameSenseLib.Theme.Accent,
		Callback = function(color) GameSenseLib:SetAccentColor(color) end
	})

	local TrackerSec = BuiltInSettings:AddSection({ Name = "HUD Tracking", Side = "Right" })
	TrackerSec:AddToggle({ Name = "Watermark", Default = false, Callback = function(v) GameSenseLib:SetWatermarkVisibility(v) end })

	TrackerSec:AddToggle({
		Name = "Keybinds List",
		Default = false,
		Callback = function(v) GameSenseLib:SetKeybindsVisibility(v) end
	})
	-- This toggle now actually works end-to-end: KBContainer receives real child labels
	-- (the KBItem parenting fix in AddBind above), and RenderStepped keeps them updated.

	function GameSenseLib:SaveConfig(filename)
		if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
		local saveTable = {}
		for flagName, flagObj in pairs(self.Flags) do
			local val = flagObj.Value
			if type(val) == "boolean" or type(val) == "number" or type(val) == "string" or type(val) == "table" then
				saveTable[flagName] = val
			end
		end
		local success, encoded = pcall(function() return HttpService:JSONEncode(saveTable) end)
		if success then
			writefile(self.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_" .. filename .. ".json", encoded)
			GameSenseLib:MakeNotification({Name = "Config Saved", Content = "Saved " .. filename .. " for this game.", Time = 3})
		end
	end

	function GameSenseLib:LoadConfig(filename)
		local path = self.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_" .. filename .. ".json"
		if isfile(path) then
			local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
			if success then
				for flag, val in pairs(decoded) do
					if self.Elements[flag] then pcall(function() self.Elements[flag].Set(val) end) end
				end
				GameSenseLib:MakeNotification({Name = "Config Loaded", Content = "Loaded " .. filename, Time = 3})
			end
		else
			GameSenseLib:MakeNotification({Name = "Error", Content = "Config not found for this game.", Time = 3})
		end
	end

	function GameSenseLib:Destroy()
		if self.Gui then self.Gui:Destroy() end
		if getgenv().GameSense_Menu_Connection then getgenv().GameSense_Menu_Connection:Disconnect() end
		-- FIX: the RenderStepped connection (watermark FPS text + keybinds list refresh) was
		-- never disconnected here, only cleaned up incidentally by next script run's
		-- anti-duplicate block. Disconnecting explicitly means Destroy() actually stops
		-- everything it started, immediately, rather than leaving a loop running until the
		-- script is re-executed.
		if getgenv().GameSense_Render_Connection then getgenv().GameSense_Render_Connection:Disconnect() end
	end

	function GameSenseLib:Init()
		if self.AutoSaveEnabled then
			self:LoadConfig("auto_config")
		end
		-- NEW: honor a config marked via "Set autoload" in the Configs tab, independent of
		-- the SaveConfig/auto_config window-option flow above -- this is the autoload the
		-- reference screenshot's "set autoload" / "stop autoload" buttons actually control.
		local autoloadPath = self.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_autoload.txt"
		if isfile(autoloadPath) then
			local ok, name = pcall(readfile, autoloadPath)
			if ok and name and name ~= "" then
				self:LoadConfig(name)
			end
		end
	end

	return WindowObj
end

return GameSenseLib