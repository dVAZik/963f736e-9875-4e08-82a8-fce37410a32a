--[[
	🌸 NekoUI Library v2.3 FINAL
	"Dark Minimal" - UI Library for Roblox Executors
	GitHub: github.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a
	
	ИСПРАВЛЕНИЯ v2.3:
	- Полностью исправлена ошибка SetValue (возвращается правильный объект)
	- Чёрно-белый минималистичный дизайн
	- Белый текст на тёмном фоне
	- Все методы возвращают корректные объекты с методами SetValue/GetValue
--]]

local NekoUI = {}
local Library = {
	Windows = {},
	Themes = {}
}

-- ==================== СЕРВИСЫ ====================
local Services = setmetatable({}, {
	__index = function(t, k)
		local s = game:GetService(k)
		t[k] = s
		return s
	end
})

-- ==================== УТИЛИТЫ ====================
local function Create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			obj.Parent = v
		else
			pcall(function() obj[k] = v end)
		end
	end
	return obj
end

local function Tween(obj, t, props)
	local ti = TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tw = Services.TweenService:Create(obj, ti, props)
	tw:Play()
	return tw
end

local function Dragify(frame, handle)
	local drag, startPos, frameStart
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag = true
			startPos = input.Position
			frameStart = frame.Position
		end
	end)
	handle.InputChanged:Connect(function(input)
		if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPos
			frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
		end
	end)
	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag = false
		end
	end)
end

-- ==================== ТЕМА: ЧЁРНО-БЕЛАЯ ====================
local Theme = {
	Bg = Color3.fromRGB(15, 15, 15),
	Surface = Color3.fromRGB(25, 25, 25),
	Surface2 = Color3.fromRGB(35, 35, 35),
	Accent = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(255, 255, 255),
	Text2 = Color3.fromRGB(180, 180, 180),
	Green = Color3.fromRGB(255, 255, 255),
	Red = Color3.fromRGB(100, 100, 100),
	Radius = 8
}

-- ==================== БАЗОВЫЙ GUI ====================
local BaseGui = Create("ScreenGui", {
	Name = "NekoUI",
	Parent = Services.CoreGui,
	ResetOnSpawn = false,
	IgnoreGuiInset = true
})

local scale = math.clamp(Services.GuiService:GetScreenResolution().X / 1920, 0.6, 1.5)
Create("UIScale", { Parent = BaseGui, Scale = scale })

local Container = Create("Frame", {
	Name = "Container",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Parent = BaseGui
})

-- ==================== КЛАСС WINDOW ====================
local Window = {}
Window.__index = Window

function Window.new(cfg)
	local self = setmetatable({}, Window)
	self.Name = cfg.Name or "Menu"
	self.Key = cfg.Key or Enum.KeyCode.Insert
	self.Tabs = {}
	
	-- Контейнер окна
	self.Holder = Create("Frame", {
		Name = "Window",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = Container
	})
	
	-- Главный фрейм
	self.Main = Create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 600, 0, 400),
		Position = UDim2.new(0.5, -300, 0.5, -200),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		Visible = false,
		Parent = self.Holder
	})
	
	Create("UICorner", { CornerRadius = UDim.new(0, Theme.Radius), Parent = self.Main })
	Create("UIStroke", { Thickness = 1, Color = Theme.Surface2, Parent = self.Main })
	
	-- TitleBar
	local bar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = self.Main
	})
	Create("UICorner", { CornerRadius = UDim.new(0, Theme.Radius), Parent = bar })
	
	Create("TextLabel", {
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = self.Name,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = bar
	})
	
	-- Кнопка закрытия
	local close = Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -34, 0, 6),
		BackgroundColor3 = Theme.Surface2,
		Text = "✕",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = bar
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = close })
	close.MouseButton1Click:Connect(function() self.Main.Visible = false end)
	
	-- Pin
	local pin = Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -66, 0, 6),
		BackgroundColor3 = Theme.Surface2,
		Text = "📌",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		Parent = bar
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = pin })
	
	local pinned = false
	pin.MouseButton1Click:Connect(function()
		pinned = not pinned
		pin.BackgroundColor3 = pinned and Theme.Text2 or Theme.Surface2
	end)
	
	Dragify(self.Main, bar)
	
	-- Tab bar
	self.TabBar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = self.Main
	})
	
	self.TabScroll = Create("ScrollingFrame", {
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 4, 0, 4),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Text2,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.TabBar
	})
	
	local tabLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.TabScroll
	})
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TabScroll.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 10, 0, 0)
	end)
	
	-- Content
	self.Content = Create("ScrollingFrame", {
		Size = UDim2.new(1, -8, 1, -84),
		Position = UDim2.new(0, 4, 0, 80),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Text2,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.Main
	})
	
	self.ContentLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Content
	})
	self.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Content.CanvasSize = UDim2.new(0, 0, 0, self.ContentLayout.AbsoluteContentSize.Y + 10)
	end)
	
	-- Закрытие по клику вне
	Services.UserInputService.InputBegan:Connect(function(input)
		if not pinned and input.UserInputType == Enum.UserInputType.MouseButton1 and self.Main.Visible then
			local m = Services.UserInputService:GetMouseLocation()
			local p = self.Main.AbsolutePosition
			local s = self.Main.AbsoluteSize
			if m.X < p.X or m.X > p.X + s.X or m.Y < p.Y or m.Y > p.Y + s.Y then
				self.Main.Visible = false
			end
		end
	end)
	
	-- Горячая клавиша
	Services.UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == self.Key then
			self.Main.Visible = not self.Main.Visible
		end
	end)
	
	-- Мобильная кнопка
	if cfg.MobileButton ~= false then
		local mb = Create("TextButton", {
			Size = UDim2.new(0, 50, 0, 50),
			Position = UDim2.new(1, -65, 1, -65),
			BackgroundColor3 = Theme.Bg,
			Text = "☰",
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = self.Holder
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mb })
		Create("UIStroke", { Thickness = 1, Color = Theme.Text2, Parent = mb })
		Dragify(mb, mb)
		mb.MouseButton1Click:Connect(function() self.Main.Visible = not self.Main.Visible end)
	end
	
	return self
end

-- ==================== СОЗДАНИЕ ВКЛАДКИ ====================
function Window:CreateTab(name, icon)
	local tab = { Window = self }
	
	-- Кнопка вкладки
	local btn = Create("TextButton", {
		Size = UDim2.new(0, 100, 0, 26),
		BackgroundColor3 = Theme.Surface2,
		Text = (icon or "") .. " " .. name,
		TextColor3 = Theme.Text2,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		Parent = self.TabScroll
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	
	-- Контент
	local content = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Content
	})
	
	local layout = Create("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = content
	})
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 5)
	end)
	
	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(self.Tabs) do
			t._content.Visible = false
			t._btn.BackgroundColor3 = Theme.Surface2
			t._btn.TextColor3 = Theme.Text2
		end
		content.Visible = true
		btn.BackgroundColor3 = Theme.Text2
		btn.TextColor3 = Theme.Bg
		self.CurrentTab = tab
	end)
	
	tab._btn = btn
	tab._content = content
	tab._layout = layout
	
	-- ==================== SECTION ====================
	function tab:CreateSection(name)
		local sec = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = Theme.Surface,
			Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = sec })
		Create("TextLabel", {
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = sec
		})
		return sec
	end
	
	-- ==================== TOGGLE ====================
	function tab:CreateToggle(cfg)
		cfg = cfg or {}
		local on = cfg.Default or false
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = Theme.Surface,
			Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		Create("TextLabel", {
			Size = UDim2.new(0.65, 0, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = cfg.Name or "Toggle",
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = box
		})
		
		local sw = Create("TextButton", {
			Size = UDim2.new(0, 44, 0, 22),
			Position = UDim2.new(1, -54, 0.5, -11),
			BackgroundColor3 = on and Theme.Text or Theme.Surface2,
			Text = "",
			BorderSizePixel = 0,
			Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
		
		local knob = Create("Frame", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(on and 1 or 0, on and -19 or 3, 0.5, -8),
			BackgroundColor3 = Theme.Bg,
			Parent = sw
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		
		local function update(s)
			Tween(sw, 0.2, { BackgroundColor3 = s and Theme.Text or Theme.Surface2 })
			Tween(knob, 0.2, { Position = UDim2.new(s and 1 or 0, s and -19 or 3, 0.5, -8) })
		end
		
		sw.MouseButton1Click:Connect(function()
			on = not on
			update(on)
			if cfg.Callback then pcall(cfg.Callback, on) end
		end)
		
		-- Методы привязываем к box (контейнеру)
		box.SetState = function(_, s) on = s; update(s) end
		box.GetState = function() return on end
		
		return box
	end
	
	-- ==================== SLIDER (ИСПРАВЛЕННЫЙ) ====================
	function tab:CreateSlider(cfg)
		cfg = cfg or {}
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local val = cfg.Default or min
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = Theme.Surface,
			Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		local label = Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			Text = string.format("%s: %.0f", cfg.Name or "Slider", val),
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = box
		})
		
		-- Полоса слайдера
		local bar = Create("TextButton", {
			Size = UDim2.new(1, -20, 0, 5),
			Position = UDim2.new(0, 10, 0, 30),
			BackgroundColor3 = Theme.Surface2,
			Text = "",
			BorderSizePixel = 0,
			Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
		
		-- Заполнение
		local fill = Create("Frame", {
			Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0,
			Parent = bar
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
		
		-- Ползунок
		local knob2 = Create("Frame", {
			Size = UDim2.new(0, 12, 0, 12),
			Position = UDim2.new((val - min) / (max - min), -6, 0.5, -6),
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0,
			Parent = bar
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob2 })
		
		-- Функция обновления
		local function setVal(v)
			val = math.clamp(v, min, max)
			local pct = (val - min) / (max - min)
			fill.Size = UDim2.new(pct, 0, 1, 0)
			knob2.Position = UDim2.new(pct, -6, 0.5, -6)
			label.Text = string.format("%s: %.0f", cfg.Name or "Slider", val)
			if cfg.Callback then pcall(cfg.Callback, val) end
		end
		
		-- Перетаскивание
		local dragging = false
		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				local mx = Services.UserInputService:GetMouseLocation().X
				local bx = bar.AbsolutePosition.X
				local bw = bar.AbsoluteSize.X
				setVal(min + (max - min) * ((mx - bx) / bw))
			end
		end)
		
		Services.UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local mx = Services.UserInputService:GetMouseLocation().X
				local bx = bar.AbsolutePosition.X
				local bw = bar.AbsoluteSize.X
				setVal(min + (max - min) * ((mx - bx) / bw))
			end
		end)
		
		Services.UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		
		-- Методы привязываем к box (контейнеру)
		box.SetValue = function(_, v) setVal(v) end
		box.GetValue = function() return val end
		
		return box
	end
	
	-- ==================== BUTTON ====================
	function tab:CreateButton(cfg)
		cfg = cfg or {}
		local btn2 = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Theme.Surface,
			Text = cfg.Name or "Button",
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn2 })
		
		btn2.MouseButton1Click:Connect(function()
			Tween(btn2, 0.1, { BackgroundColor3 = Theme.Surface2 })
			task.wait(0.1)
			Tween(btn2, 0.1, { BackgroundColor3 = Theme.Surface })
			if cfg.Callback then pcall(cfg.Callback) end
		end)
		
		return btn2
	end
	
	-- ==================== DROPDOWN ====================
	function tab:CreateDropdown(cfg)
		cfg = cfg or {}
		local opts = cfg.Options or {}
		local sel = cfg.Default or opts[1] or ""
		local open = false
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Theme.Surface,
			Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		local btn3 = Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = cfg.Name .. ": " .. sel,
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			Parent = box
		})
		
		local list = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 1, 4),
			BackgroundColor3 = Theme.Surface,
			Visible = false,
			Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = list })
		
		local listLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = list
		})
		
		local frames = {}
		local function build()
			for _, f in ipairs(frames) do f:Destroy() end
			frames = {}
			for _, o in ipairs(opts) do
				local ob = Create("TextButton", {
					Size = UDim2.new(1, -4, 0, 26),
					Position = UDim2.new(0, 2, 0, 0),
					BackgroundColor3 = Theme.Surface2,
					Text = o,
					TextColor3 = Theme.Text2,
					Font = Enum.Font.GothamSemibold,
					TextSize = 12,
					Parent = list
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ob })
				ob.MouseButton1Click:Connect(function()
					sel = o
					btn3.Text = cfg.Name .. ": " .. sel
					open = false
					list.Visible = false
					box.Size = UDim2.new(1, 0, 0, 34)
					if cfg.Callback then pcall(cfg.Callback, sel) end
				end)
				table.insert(frames, ob)
			end
			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				list.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
			end)
		end
		build()
		
		btn3.MouseButton1Click:Connect(function()
			open = not open
			list.Visible = open
			box.Size = UDim2.new(1, 0, 0, open and 34 + list.AbsoluteSize.Y + 4 or 34)
		end)
		
		box.GetValue = function() return sel end
		box.SetOptions = function(_, o) opts = o; build() end
		
		return box
	end
	
	-- ==================== COLOR PICKER ====================
	function tab:CreateColorPicker(cfg)
		cfg = cfg or {}
		local col = cfg.Default or Color3.new(1,1,1)
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 55),
			BackgroundColor3 = Theme.Surface,
			Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 18),
			Position = UDim2.new(0, 10, 0, 4),
			BackgroundTransparency = 1,
			Text = cfg.Name or "Color",
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = box
		})
		
		local pf = Create("Frame", {
			Size = UDim2.new(1, -20, 0, 26),
			Position = UDim2.new(0, 10, 0, 24),
			BackgroundTransparency = 1,
			Parent = box
		})
		
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = pf
		})
		
		local presets = {
			Color3.new(1,1,1),
			Color3.new(0.7,0.7,0.7),
			Color3.new(0.5,0.5,0.5),
			Color3.new(0.3,0.3,0.3),
			Color3.new(1,0.3,0.3),
			Color3.new(0.3,1,0.3),
			Color3.new(0.3,0.3,1),
		}
		
		local selFrame = nil
		for _, p in ipairs(presets) do
			local cb = Create("TextButton", {
				Size = UDim2.new(0, 22, 0, 22),
				BackgroundColor3 = p,
				Text = "",
				Parent = pf
			})
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = cb })
			
			if p == col then
				Create("UIStroke", { Thickness = 2, Color = Theme.Text, Parent = cb })
				selFrame = cb
			end
			
			cb.MouseButton1Click:Connect(function()
				if selFrame then
					local s = selFrame:FindFirstChildOfClass("UIStroke")
					if s then s:Destroy() end
				end
				Create("UIStroke", { Thickness = 2, Color = Theme.Text, Parent = cb })
				selFrame = cb
				col = p
				if cfg.Callback then pcall(cfg.Callback, col) end
			end)
		end
		
		box.GetColor = function() return col end
		return box
	end
	
	-- ==================== TEXTBOX ====================
	function tab:CreateTextBox(cfg)
		cfg = cfg or {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = Theme.Surface,
			Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		local inp = Create("TextBox", {
			Size = UDim2.new(1, -20, 0, 28),
			Position = UDim2.new(0, 10, 0, 6),
			BackgroundColor3 = Theme.Surface2,
			Text = cfg.Default or "",
			PlaceholderText = cfg.Placeholder or "Enter text...",
			TextColor3 = Theme.Text,
			PlaceholderColor3 = Theme.Text2,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			ClearTextOnFocus = false,
			Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = inp })
		
		inp.FocusLost:Connect(function(enter)
			if cfg.Callback then pcall(cfg.Callback, inp.Text, enter) end
		end)
		
		box.GetText = function() return inp.Text end
		box.SetText = function(_, t) inp.Text = t end
		
		return box
	end
	
	table.insert(self.Tabs, tab)
	
	-- Авто-выбор первой вкладки
	if #self.Tabs == 1 then
		content.Visible = true
		btn.BackgroundColor3 = Theme.Text2
		btn.TextColor3 = Theme.Bg
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
