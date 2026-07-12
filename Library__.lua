--[[
	🌸 NekoUI Library v2.6 FINAL
	"Dark Minimal" - UI Library for Roblox Executors
	GitHub: github.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a
	
	ВСЕ МЕТОДЫ ВОЗВРАЩАЮТ ОБЪЕКТЫ-КОНТРОЛЛЕРЫ (ТАБЛИЦЫ):
	- ToggleController: SetState / GetState
	- SliderController: SetValue / GetValue
	- DropdownController: GetValue / SetOptions
	- ColorPickerController: GetColor
	- TextBoxController: GetText / SetText
	- Button: обычная кнопка
--]]

local NekoUI = {}
local Library = { Windows = {}, Themes = {} }

-- Сервисы
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CG = game:GetService("CoreGui")
local GS = game:GetService("GuiService")

-- Утилиты
local function Create(cls, props)
	local obj = Instance.new(cls)
	for k, v in pairs(props or {}) do
		if k == "Parent" then obj.Parent = v
		else pcall(function() obj[k] = v end) end
	end
	return obj
end

local function TweenObj(obj, t, props)
	local ti = TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tw = TS:Create(obj, ti, props)
	tw:Play()
end

local function Dragify(frame, handle)
	local drag, startPos, frameStart
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag, startPos, frameStart = true, input.Position, frame.Position
		end
	end)
	handle.InputChanged:Connect(function(input)
		if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPos
			frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = false end
	end)
end

-- Тема
local T = {
	Bg = Color3.fromRGB(12, 12, 12),
	Sf = Color3.fromRGB(22, 22, 22),
	Sf2 = Color3.fromRGB(32, 32, 32),
	Acc = Color3.fromRGB(255, 255, 255),
	Tx = Color3.fromRGB(255, 255, 255),
	Tx2 = Color3.fromRGB(160, 160, 160),
	R = 8
}

-- Базовый GUI
local Base = Create("ScreenGui", { Name = "NekoUI", Parent = CG, ResetOnSpawn = false, IgnoreGuiInset = true })
Create("UIScale", { Parent = Base, Scale = math.clamp(GS:GetScreenResolution().X / 1920, 0.6, 1.5) })
local Container = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = Base })

-- ==================== WINDOW ====================
local Window = {}
Window.__index = Window

function Window.new(cfg)
	local self = setmetatable({}, Window)
	self.Name = cfg.Name or "Menu"
	self.Key = cfg.Key or Enum.KeyCode.Insert
	self.Tabs = {}
	
	self.Holder = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = Container })
	
	self.Main = Create("Frame", {
		Size = UDim2.new(0, 580, 0, 380),
		Position = UDim2.new(0.5, -290, 0.5, -190),
		BackgroundColor3 = T.Bg, BorderSizePixel = 0, Visible = false,
		Parent = self.Holder
	})
	Create("UICorner", { CornerRadius = UDim.new(0, T.R), Parent = self.Main })
	Create("UIStroke", { Thickness = 1, Color = T.Sf2, Parent = self.Main })
	
	local bar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = T.Sf, BorderSizePixel = 0,
		Parent = self.Main
	})
	Create("UICorner", { CornerRadius = UDim.new(0, T.R), Parent = bar })
	
	Create("TextLabel", {
		Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1, Text = self.Name, TextColor3 = T.Tx,
		Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		Parent = bar
	})
	
	local close = Create("TextButton", {
		Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -32, 0, 6),
		BackgroundColor3 = T.Sf2, Text = "✕", TextColor3 = T.Tx,
		Font = Enum.Font.GothamBold, TextSize = 13, Parent = bar
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = close })
	close.MouseButton1Click:Connect(function() self.Main.Visible = false end)
	
	local pin = Create("TextButton", {
		Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -62, 0, 6),
		BackgroundColor3 = T.Sf2, Text = "📌", TextColor3 = T.Tx,
		Font = Enum.Font.GothamBold, TextSize = 11, Parent = bar
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = pin })
	local pinned = false
	pin.MouseButton1Click:Connect(function()
		pinned = not pinned
		pin.BackgroundColor3 = pinned and T.Tx2 or T.Sf2
	end)
	
	Dragify(self.Main, bar)
	
	self.TabBar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 38),
		BackgroundColor3 = T.Sf, BorderSizePixel = 0, Parent = self.Main
	})
	
	self.TabScroll = Create("ScrollingFrame", {
		Size = UDim2.new(1, -6, 1, 0), Position = UDim2.new(0, 3, 0, 3),
		BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.Tx2, CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.TabBar
	})
	
	local tabLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.TabScroll
	})
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TabScroll.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 8, 0, 0)
	end)
	
	self.Content = Create("ScrollingFrame", {
		Size = UDim2.new(1, -6, 1, -80), Position = UDim2.new(0, 3, 0, 76),
		BackgroundTransparency = 1, ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Tx2, CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.Main
	})
	
	self.CLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Content
	})
	self.CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Content.CanvasSize = UDim2.new(0, 0, 0, self.CLayout.AbsoluteContentSize.Y + 8)
	end)
	
	UIS.InputBegan:Connect(function(input)
		if not pinned and input.UserInputType == Enum.UserInputType.MouseButton1 and self.Main.Visible then
			local m = UIS:GetMouseLocation()
			local p = self.Main.AbsolutePosition
			local s = self.Main.AbsoluteSize
			if m.X < p.X or m.X > p.X + s.X or m.Y < p.Y or m.Y > p.Y + s.Y then
				self.Main.Visible = false
			end
		end
	end)
	
	UIS.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == self.Key then
			self.Main.Visible = not self.Main.Visible
		end
	end)
	
	if cfg.MobileButton ~= false then
		local mb = Create("TextButton", {
			Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(1, -60, 1, -60),
			BackgroundColor3 = T.Bg, Text = "☰", TextColor3 = T.Tx,
			Font = Enum.Font.GothamBold, TextSize = 20,
			AnchorPoint = Vector2.new(0.5, 0.5), Parent = self.Holder
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mb })
		Create("UIStroke", { Thickness = 1, Color = T.Tx2, Parent = mb })
		Dragify(mb, mb)
		mb.MouseButton1Click:Connect(function() self.Main.Visible = not self.Main.Visible end)
	end
	
	return self
end

-- ==================== CREATE TAB ====================
function Window:CreateTab(name, icon)
	local tab = { Window = self }
	
	local btn = Create("TextButton", {
		Size = UDim2.new(0, 95, 0, 24), BackgroundColor3 = T.Sf2,
		Text = (icon or "") .. " " .. name, TextColor3 = T.Tx2,
		Font = Enum.Font.GothamSemibold, TextSize = 11,
		Parent = self.TabScroll
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn })
	
	local content = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
		Visible = false, Parent = self.Content
	})
	
	local layout = Create("UIListLayout", {
		Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = content
	})
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 4)
	end)
	
	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(self.Tabs) do
			t._content.Visible = false
			t._btn.BackgroundColor3 = T.Sf2
			t._btn.TextColor3 = T.Tx2
		end
		content.Visible = true
		btn.BackgroundColor3 = T.Tx2
		btn.TextColor3 = T.Bg
		self.CurrentTab = tab
	end)
	
	tab._btn = btn
	tab._content = content
	
	-- ==================== SECTION ====================
	function tab:CreateSection(name)
		local sec = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = sec })
		Create("TextLabel", {
			Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1, Text = name, TextColor3 = T.Tx,
			Font = Enum.Font.GothamBold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = sec
		})
		return sec
	end
	
	-- ==================== TOGGLE (КОНТРОЛЛЕР) ====================
	function tab:CreateToggle(cfg)
		cfg = cfg or {}
		local on = cfg.Default or false
		
		-- КОНТРОЛЛЕР
		local ToggleController = {}
		
		-- Визуал
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = box })
		
		Create("TextLabel", {
			Size = UDim2.new(0.65, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1, Text = cfg.Name or "Toggle", TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = box
		})
		
		local sw = Create("TextButton", {
			Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10),
			BackgroundColor3 = on and T.Tx or T.Sf2, Text = "", BorderSizePixel = 0,
			Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
		
		local knob = Create("Frame", {
			Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(on and 1 or 0, on and -17 or 3, 0.5, -7),
			BackgroundColor3 = T.Bg, Parent = sw
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		
		local function updateVisual(s)
			TweenObj(sw, 0.2, { BackgroundColor3 = s and T.Tx or T.Sf2 })
			TweenObj(knob, 0.2, { Position = UDim2.new(s and 1 or 0, s and -17 or 3, 0.5, -7) })
		end
		
		sw.MouseButton1Click:Connect(function()
			on = not on
			updateVisual(on)
			if cfg.Callback then pcall(cfg.Callback, on) end
		end)
		
		-- Методы контроллера
		function ToggleController:SetState(state)
			on = state
			updateVisual(state)
		end
		
		function ToggleController:GetState()
			return on
		end
		
		ToggleController._box = box
		
		return ToggleController
	end
	
	-- ==================== SLIDER (КОНТРОЛЛЕР) ====================
	function tab:CreateSlider(cfg)
		cfg = cfg or {}
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local val = cfg.Default or min
		
		-- КОНТРОЛЛЕР
		local SliderController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = box })
		
		local label = Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 4),
			BackgroundTransparency = 1, TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = box
		})
		
		local bar = Create("TextButton", {
			Size = UDim2.new(1, -20, 0, 5), Position = UDim2.new(0, 10, 0, 28),
			BackgroundColor3 = T.Sf2, Text = "", BorderSizePixel = 0,
			AutoButtonColor = false, Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
		
		local fill = Create("Frame", {
			Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = T.Tx,
			BorderSizePixel = 0, Parent = bar
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
		
		local knob = Create("Frame", {
			Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, -6, 0.5, -6),
			BackgroundColor3 = T.Tx, Parent = bar
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		
		local function UpdateVisual(newVal)
			val = math.clamp(newVal, min, max)
			local percent = (val - min) / (max - min)
			fill.Size = UDim2.new(percent, 0, 1, 0)
			knob.Position = UDim2.new(percent, -6, 0.5, -6)
			label.Text = string.format("%s: %.0f", cfg.Name or "Slider", val)
		end
		
		-- Инициализация
		UpdateVisual(val)
		
		local dragging = false
		
		local function UpdateFromMouse()
			local mouseX = UIS:GetMouseLocation().X
			local barX = bar.AbsolutePosition.X
			local barW = bar.AbsoluteSize.X
			local percent = math.clamp((mouseX - barX) / barW, 0, 1)
			local newVal = min + (max - min) * percent
			UpdateVisual(newVal)
			if cfg.Callback then pcall(cfg.Callback, val) end
		end
		
		bar.MouseButton1Down:Connect(function()
			dragging = true
			UpdateFromMouse()
		end)
		
		UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				UpdateFromMouse()
			end
		end)
		
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		
		-- Методы контроллера
		function SliderController:SetValue(v)
			UpdateVisual(v)
			if cfg.Callback then pcall(cfg.Callback, val) end
		end
		
		function SliderController:GetValue()
			return val
		end
		
		SliderController._box = box
		
		return SliderController
	end
	
	-- ==================== BUTTON ====================
	function tab:CreateButton(cfg)
		cfg = cfg or {}
		local btn2 = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.Sf,
			Text = cfg.Name or "Button", TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 13, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn2 })
		btn2.MouseButton1Click:Connect(function()
			TweenObj(btn2, 0.1, { BackgroundColor3 = T.Sf2 })
			task.wait(0.1)
			TweenObj(btn2, 0.1, { BackgroundColor3 = T.Sf })
			if cfg.Callback then pcall(cfg.Callback) end
		end)
		return btn2
	end
	
	-- ==================== DROPDOWN (КОНТРОЛЛЕР) ====================
	function tab:CreateDropdown(cfg)
		cfg = cfg or {}
		local opts = cfg.Options or {}
		local sel = cfg.Default or opts[1] or ""
		local open = false
		
		-- КОНТРОЛЛЕР
		local DropdownController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = box })
		
		local btn3 = Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
			Text = cfg.Name .. ": " .. sel, TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 12, Parent = box
		})
		
		local list = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 3),
			BackgroundColor3 = T.Sf, Visible = false, Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = list })
		
		local listLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list
		})
		
		local frames = {}
		local function build()
			for _, f in ipairs(frames) do f:Destroy() end
			frames = {}
			for _, o in ipairs(opts) do
				local ob = Create("TextButton", {
					Size = UDim2.new(1, -4, 0, 24), Position = UDim2.new(0, 2, 0, 0),
					BackgroundColor3 = T.Sf2, Text = o, TextColor3 = T.Tx2,
					Font = Enum.Font.GothamSemibold, TextSize = 11, Parent = list
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ob })
				ob.MouseButton1Click:Connect(function()
					sel = o
					btn3.Text = cfg.Name .. ": " .. sel
					open = false
					list.Visible = false
					box.Size = UDim2.new(1, 0, 0, 32)
					if cfg.Callback then pcall(cfg.Callback, sel) end
				end)
				table.insert(frames, ob)
			end
			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				list.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + 2)
			end)
		end
		build()
		
		btn3.MouseButton1Click:Connect(function()
			open = not open
			list.Visible = open
			box.Size = UDim2.new(1, 0, 0, open and 32 + list.AbsoluteSize.Y + 3 or 32)
		end)
		
		-- Методы контроллера
		function DropdownController:GetValue()
			return sel
		end
		
		function DropdownController:SetOptions(newOpts)
			opts = newOpts
			build()
		end
		
		DropdownController._box = box
		
		return DropdownController
	end
	
	-- ==================== COLOR PICKER (КОНТРОЛЛЕР) ====================
	function tab:CreateColorPicker(cfg)
		cfg = cfg or {}
		local col = cfg.Default or Color3.new(1, 1, 1)
		
		-- КОНТРОЛЛЕР
		local ColorPickerController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = box })
		
		Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, 3),
			BackgroundTransparency = 1, Text = cfg.Name or "Color", TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = box
		})
		
		local pf = Create("Frame", {
			Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 22),
			BackgroundTransparency = 1, Parent = box
		})
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder, Parent = pf
		})
		
		local presets = {
			Color3.new(1,1,1), Color3.new(0.7,0.7,0.7), Color3.new(0.5,0.5,0.5),
			Color3.new(0.3,0.3,0.3), Color3.new(1,0.3,0.3), Color3.new(0.3,1,0.3),
			Color3.new(0.3,0.3,1)
		}
		
		local selFrame = nil
		for _, p in ipairs(presets) do
			local cb = Create("TextButton", {
				Size = UDim2.new(0, 20, 0, 20), BackgroundColor3 = p, Text = "", Parent = pf
			})
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = cb })
			if p == col then
				Create("UIStroke", { Thickness = 2, Color = T.Tx, Parent = cb })
				selFrame = cb
			end
			cb.MouseButton1Click:Connect(function()
				if selFrame then
					local s = selFrame:FindFirstChildOfClass("UIStroke")
					if s then s:Destroy() end
				end
				Create("UIStroke", { Thickness = 2, Color = T.Tx, Parent = cb })
				selFrame = cb
				col = p
				if cfg.Callback then pcall(cfg.Callback, col) end
			end)
		end
		
		-- Методы контроллера
		function ColorPickerController:GetColor()
			return col
		end
		
		ColorPickerController._box = box
		
		return ColorPickerController
	end
	
	-- ==================== TEXTBOX (КОНТРОЛЛЕР) ====================
	function tab:CreateTextBox(cfg)
		cfg = cfg or {}
		
		-- КОНТРОЛЛЕР
		local TextBoxController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = box })
		
		local inp = Create("TextBox", {
			Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 6),
			BackgroundColor3 = T.Sf2, Text = cfg.Default or "",
			PlaceholderText = cfg.Placeholder or "Enter text...",
			TextColor3 = T.Tx, PlaceholderColor3 = T.Tx2,
			Font = Enum.Font.GothamSemibold, TextSize = 12,
			ClearTextOnFocus = false, Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = inp })
		
		inp.FocusLost:Connect(function(enter)
			if cfg.Callback then pcall(cfg.Callback, inp.Text, enter) end
		end)
		
		-- Методы контроллера
		function TextBoxController:GetText()
			return inp.Text
		end
		
		function TextBoxController:SetText(text)
			inp.Text = text
		end
		
		TextBoxController._box = box
		
		return TextBoxController
	end
	
	table.insert(self.Tabs, tab)
	
	if #self.Tabs == 1 then
		content.Visible = true
		btn.BackgroundColor3 = T.Tx2
		btn.TextColor3 = T.Bg
		self.CurrentTab = tab
	end
	
	return tab
end

-- ==================== ГЛОБАЛЬНЫЕ ФУНКЦИИ ====================
function NekoUI:CreateWindow(cfg)
	local w = Window.new(cfg)
	table.insert(Library.Windows, w)
	return w
end

function NekoUI:AddTheme(name, t)
	Library.Themes[name] = t
end

return NekoUI
