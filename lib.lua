-- GameSense Lib v2
-- Highly accurate Skeet/GameSense UI replication.

local GameSenseLib = {
	Flags = {},
	Binds = {},
	Theme = {
		Background = Color3.fromRGB(23, 23, 23),
		MenuBg = Color3.fromRGB(17, 17, 17),
		Outline = Color3.fromRGB(45, 45, 45),
		DarkOutline = Color3.fromRGB(10, 10, 10),
		Accent = Color3.fromRGB(149, 194, 43),
		Text = Color3.fromRGB(200, 200, 200),
		DarkText = Color3.fromRGB(130, 130, 130),
		Font = Enum.Font.Code
	}
}

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function MakeDraggable(topbarobject, object)
	local Dragging, DragInput, DragStart, StartPosition
	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then Dragging = false end
			end)
		end
	end)
	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - DragStart
			object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end
	end)
end

function GameSenseLib:MakeWindow(options)
	options = options or {}
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GameSenseUI"
	ScreenGui.ResetOnSpawn = false
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	self.Gui = ScreenGui

	-- Watermark
	local Watermark = Instance.new("TextLabel")
	Watermark.Size = UDim2.new(0, 250, 0, 20)
	Watermark.Position = UDim2.new(1, -260, 0, 10)
	Watermark.BackgroundColor3 = self.Theme.MenuBg
	Watermark.BorderColor3 = self.Theme.Outline
	Watermark.TextColor3 = self.Theme.Text
	Watermark.Font = self.Theme.Font
	Watermark.TextSize = 13
	Watermark.Text = " gamesense | " .. LocalPlayer.Name .. " | 0 fps"
	Watermark.TextXAlignment = Enum.TextXAlignment.Left
	Watermark.Parent = ScreenGui
	Watermark.Visible = false

	local WMGradient = Instance.new("Frame")
	WMGradient.Size = UDim2.new(1, 0, 0, 1)
	WMGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WMGradient.BorderSizePixel = 0
	WMGradient.Parent = Watermark
	
	local uiGrad = Instance.new("UIGradient")
	uiGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
	})
	uiGrad.Parent = WMGradient

	-- Keybinds List
	local KeybindsFrame = Instance.new("Frame")
	KeybindsFrame.Size = UDim2.new(0, 180, 0, 25)
	KeybindsFrame.Position = UDim2.new(0, 10, 0.5, 0)
	KeybindsFrame.BackgroundColor3 = self.Theme.MenuBg
	KeybindsFrame.BorderColor3 = self.Theme.Outline
	KeybindsFrame.Parent = ScreenGui
	KeybindsFrame.Visible = false
	MakeDraggable(KeybindsFrame, KeybindsFrame)
	
	local KBGrad = WMGradient:Clone()
	KBGrad.Parent = KeybindsFrame
	
	local KBTitle = Instance.new("TextLabel")
	KBTitle.Size = UDim2.new(1, 0, 1, 0)
	KBTitle.BackgroundTransparency = 1
	KBTitle.Text = "keybinds"
	KBTitle.TextColor3 = self.Theme.Text
	KBTitle.Font = self.Theme.Font
	KBTitle.TextSize = 13
	KBTitle.Parent = KeybindsFrame

	local KBContainer = Instance.new("Frame")
	KBContainer.Size = UDim2.new(1, 0, 0, 0)
	KBContainer.Position = UDim2.new(0, 0, 1, 2)
	KBContainer.BackgroundColor3 = self.Theme.MenuBg
	KBContainer.BorderColor3 = self.Theme.Outline
	KBContainer.Parent = KeybindsFrame
	
	local KBLayout = Instance.new("UIListLayout")
	KBLayout.Parent = KBContainer

	RunService.RenderStepped:Connect(function(dt)
		if Watermark.Visible then
			Watermark.Text = string.format(" gamesense | %s | %d fps", LocalPlayer.Name, math.floor(1/dt))
		end
		
		-- Update Keybinds Frame Size
		if KeybindsFrame.Visible then
			KBContainer.Size = UDim2.new(1, 0, 0, KBLayout.AbsoluteContentSize.Y)
		end
	end)

	function self:SetWatermarkVisibility(state) Watermark.Visible = state end
	function self:SetKeybindsVisibility(state) KeybindsFrame.Visible = state end

	-- Main Window
	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0, 600, 0, 450)
	Main.Position = UDim2.new(0.5, -300, 0.5, -225)
	Main.BackgroundColor3 = self.Theme.MenuBg
	Main.BorderColor3 = self.Theme.DarkOutline
	Main.BorderSizePixel = 2
	Main.Parent = ScreenGui
	MakeDraggable(Main, Main)

	local InnerMain = Instance.new("Frame")
	InnerMain.Size = UDim2.new(1, -2, 1, -2)
	InnerMain.Position = UDim2.new(0, 1, 0, 1)
	InnerMain.BackgroundColor3 = self.Theme.MenuBg
	InnerMain.BorderColor3 = self.Theme.Outline
	InnerMain.Parent = Main

	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = InnerMain
	uiGrad:Clone().Parent = TopBar

	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 60, 1, -2)
	Sidebar.Position = UDim2.new(0, 0, 0, 2)
	Sidebar.BackgroundColor3 = self.Theme.MenuBg
	Sidebar.BorderColor3 = self.Theme.Outline
	Sidebar.Parent = InnerMain

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Parent = Sidebar

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -61, 1, -2)
	ContentContainer.Position = UDim2.new(0, 61, 0, 2)
	ContentContainer.BackgroundColor3 = self.Theme.Background
	ContentContainer.BorderSizePixel = 0
	ContentContainer.Parent = InnerMain

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
			Main.Visible = not Main.Visible
		end
	end)

	local WindowObj = {Tabs = {}}

	function WindowObj:MakeTab(tabOptions)
		tabOptions = tabOptions or {}
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 60)
		TabBtn.BackgroundTransparency = 1
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
		LeftCol.Size = UDim2.new(0.5, -15, 1, -20)
		LeftCol.Position = UDim2.new(0, 10, 0, 10)
		LeftCol.BackgroundTransparency = 1
		LeftCol.ScrollBarThickness = 0
		LeftCol.Parent = TabContent
		local LeftLayout = Instance.new("UIListLayout")
		LeftLayout.Padding = UDim.new(0, 15)
		LeftLayout.Parent = LeftCol

		local RightCol = Instance.new("ScrollingFrame")
		RightCol.Size = UDim2.new(0.5, -15, 1, -20)
		RightCol.Position = UDim2.new(0.5, 5, 0, 10)
		RightCol.BackgroundTransparency = 1
		RightCol.ScrollBarThickness = 0
		RightCol.Parent = TabContent
		local RightLayout = Instance.new("UIListLayout")
		RightLayout.Padding = UDim.new(0, 15)
		RightLayout.Parent = RightCol

		TabBtn.MouseButton1Click:Connect(function()
			for _, tab in pairs(WindowObj.Tabs) do
				tab.Content.Visible = false
				tab.Icon.ImageColor3 = GameSenseLib.Theme.DarkText
			end
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
		end)

		if #WindowObj.Tabs == 0 then
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
		end

		local TabObj = {Content = TabContent, Icon = IconImg}
		table.insert(WindowObj.Tabs, TabObj)

		function TabObj:AddSection(secOptions)
			secOptions = secOptions or {}
			local side = secOptions.Side or "Left"
			local ParentCol = (side == "Right") and RightCol or LeftCol

			local Groupbox = Instance.new("Frame")
			Groupbox.Size = UDim2.new(1, 0, 0, 20)
			Groupbox.BackgroundColor3 = GameSenseLib.Theme.MenuBg
			Groupbox.BorderColor3 = GameSenseLib.Theme.Outline
			Groupbox.Parent = ParentCol

			local TitleBg = Instance.new("Frame")
			TitleBg.Position = UDim2.new(0, 15, 0, -6)
			TitleBg.Size = UDim2.new(0, 5, 0, 12)
			TitleBg.BackgroundColor3 = GameSenseLib.Theme.Background
			TitleBg.BorderSizePixel = 0
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
			TitleLabel.Parent = TitleBg
			
			-- Auto size title background to cut border
			TitleBg.Size = UDim2.new(0, TitleLabel.TextBounds.X + 4, 0, 12)

			local ItemContainer = Instance.new("Frame")
			ItemContainer.Size = UDim2.new(1, -20, 1, -15)
			ItemContainer.Position = UDim2.new(0, 10, 0, 10)
			ItemContainer.BackgroundTransparency = 1
			ItemContainer.Parent = Groupbox

			local ItemLayout = Instance.new("UIListLayout")
			ItemLayout.Padding = UDim.new(0, 8)
			ItemLayout.Parent = ItemContainer

			ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Groupbox.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y + 20)
				ParentCol.CanvasSize = UDim2.new(0, 0, 0, (side == "Right" and RightLayout or LeftLayout).AbsoluteContentSize.Y + 20)
			end)

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

				local function Fire(val)
					state = val
					Box.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.DarkOutline
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = state end
					if opt.Callback then pcall(opt.Callback, state) end
				end
				Frame.MouseButton1Click:Connect(function() Fire(not state) end)
				Fire(state)
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
				Track.Size = UDim2.new(1, 0, 0, 10)
				Track.Position = UDim2.new(0, 0, 0, 18)
				Track.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Track.BorderColor3 = GameSenseLib.Theme.Outline
				Track.Text = ""
				Track.Parent = Frame

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
				Fill.BackgroundColor3 = GameSenseLib.Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = Track

				local ValLabel = Instance.new("TextLabel")
				ValLabel.Size = UDim2.new(1, -2, 1, 0)
				ValLabel.BackgroundTransparency = 1
				ValLabel.Text = tostring(val) .. (opt.ValueName or "")
				ValLabel.TextColor3 = Color3.new(1,1,1)
				ValLabel.Font = GameSenseLib.Theme.Font
				ValLabel.TextSize = 10
				ValLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValLabel.Parent = Track

				local dragging = false
				local function Update(input)
					local perc = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
					local newVal = math.floor(opt.Min + (opt.Max - opt.Min) * perc)
					Fill.Size = UDim2.new(perc, 0, 1, 0)
					ValLabel.Text = tostring(newVal) .. (opt.ValueName or "")
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = newVal end
					if opt.Callback then pcall(opt.Callback, newVal) end
				end
				Track.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(inp) end end)
				UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
				UserInputService.InputChanged:Connect(function(inp) if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then Update(inp) end end)
				if opt.Flag then GameSenseLib.Flags[opt.Flag] = val end
			end

			function SectionObj:AddDropdown(opt)
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
				MainBtn.Text = " " .. tostring(opt.Default or (opt.Options and opt.Options[1] or ""))
				MainBtn.TextColor3 = GameSenseLib.Theme.DarkText
				MainBtn.Font = GameSenseLib.Theme.Font
				MainBtn.TextSize = 12
				MainBtn.TextXAlignment = Enum.TextXAlignment.Left
				MainBtn.Parent = Frame

				local DropContainer = Instance.new("Frame")
				DropContainer.Size = UDim2.new(1, 0, 0, 0)
				DropContainer.Position = UDim2.new(0, 0, 1, 2)
				DropContainer.BackgroundColor3 = GameSenseLib.Theme.MenuBg
				DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
				DropContainer.ZIndex = 5
				DropContainer.Visible = false
				DropContainer.Parent = MainBtn
				local DropLayout = Instance.new("UIListLayout")
				DropLayout.Parent = DropContainer

				local open = false
				local function Populate(list)
					for _, v in pairs(DropContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
					DropContainer.Size = UDim2.new(1, 0, 0, #list * 18)
					for _, item in ipairs(list) do
						local Btn = Instance.new("TextButton")
						Btn.Size = UDim2.new(1, 0, 0, 18)
						Btn.BackgroundColor3 = GameSenseLib.Theme.MenuBg
						Btn.BorderSizePixel = 0
						Btn.Text = " " .. tostring(item)
						Btn.TextColor3 = GameSenseLib.Theme.Text
						Btn.Font = GameSenseLib.Theme.Font
						Btn.TextSize = 12
						Btn.TextXAlignment = Enum.TextXAlignment.Left
						Btn.ZIndex = 6
						Btn.Parent = DropContainer
						Btn.MouseButton1Click:Connect(function()
							open = false DropContainer.Visible = false
							MainBtn.Text = " " .. tostring(item)
							if opt.Flag then GameSenseLib.Flags[opt.Flag] = item end
							if opt.Callback then pcall(opt.Callback, item) end
						end)
					end
				end
				Populate(opt.Options or {})
				MainBtn.MouseButton1Click:Connect(function() open = not open DropContainer.Visible = open end)
				if opt.Flag then GameSenseLib.Flags[opt.Flag] = opt.Default end
			end

			function SectionObj:AddBind(opt)
				local key = opt.Default or Enum.KeyCode.E
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
				Btn.Text = "[" .. key.Name .. "]"
				Btn.TextColor3 = GameSenseLib.Theme.DarkText
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 11
				Btn.Parent = Frame

				-- Add to keybinds list UI
				local KBItem = Instance.new("TextLabel")
				KBItem.Size = UDim2.new(1, -10, 0, 18)
				KBItem.Position = UDim2.new(0, 5, 0, 0)
				KBItem.BackgroundTransparency = 1
				KBItem.Text = opt.Name .. " [" .. key.Name .. "]"
				KBItem.TextColor3 = GameSenseLib.Theme.Text
				KBItem.Font = GameSenseLib.Theme.Font
				KBItem.TextSize = 12
				KBItem.TextXAlignment = Enum.TextXAlignment.Left
				KBItem.Parent = KBContainer

				local listening = false
				Btn.MouseButton1Click:Connect(function() listening = true Btn.Text = "[...]" end)
				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						key = input.KeyCode
						Btn.Text = "[" .. key.Name .. "]"
						KBItem.Text = opt.Name .. " [" .. key.Name .. "]"
						listening = false
					elseif not listening and input.KeyCode == key and not gpe then
						if opt.Callback then pcall(opt.Callback) end
					end
				end)
			end
			
			function SectionObj:AddColorpicker(opt)
				local clr = opt.Default or Color3.fromRGB(255,0,0)
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
				Btn.BackgroundColor3 = clr
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = ""
				Btn.Parent = Frame
				
				Btn.MouseButton1Click:Connect(function()
					clr = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
					Btn.BackgroundColor3 = clr
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = clr end
					if opt.Callback then pcall(opt.Callback, clr) end
				end)
			end

			function SectionObj:AddTextbox(opt)
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
				Box.Text = opt.Default or ""
				Box.TextColor3 = GameSenseLib.Theme.Text
				Box.Font = GameSenseLib.Theme.Font
				Box.TextSize = 12
				Box.ClearTextOnFocus = false
				Box.Parent = Frame

				Box.FocusLost:Connect(function()
					local val = Box.Text
					if opt.TextDisappear then Box.Text = "" end
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = val end
					if opt.Callback then pcall(opt.Callback, val) end
				end)
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
				Btn.MouseButton1Click:Connect(function() if opt.Callback then pcall(opt.Callback) end end)
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
			end

			return SectionObj
		end
		return TabObj
	end

	function GameSenseLib:Destroy() if self.Gui then self.Gui:Destroy() end end
	function GameSenseLib:Init() end
	function GameSenseLib:MakeNotification(opt) print("[GameSense] " .. (opt.Name or "") .. " - " .. (opt.Content or "")) end

	return WindowObj
end

return GameSenseLib
