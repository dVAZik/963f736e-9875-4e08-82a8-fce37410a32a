--[[
	🌸 NekoUI Library v2.8 FINAL
	"Dark Minimal" - UI Library for Roblox Executors
	GitHub: github.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a
	
	ИСПРАВЛЕНИЯ v2.8:
	- Dropdown: выпадает ПОВЕРХ всего, не обрезается
	- Dropdown: правильный ZIndex и позиционирование
	- Мобильная кнопка: Draggable + Active
	- Окно: увеличено до 620x420
	- Все объекты с правильными ZIndex
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
local Base = Create("ScreenGui", { Name = "NekoUI", Parent = CG, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
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
	self.Dropdowns = {} -- Список всех дропдаунов для закрытия
	
	self.Holder = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = Container })
	
	-- УВЕЛИЧЕННОЕ ОКНО: 620x420
	self.Main = Create("Frame", {
		Size = UDim2.new(0, 620, 0, 420),
		Position = UDim2.new(0.5, -310, 0.5, -210),
		BackgroundColor3 = T.Bg, BorderSizePixel = 0, Visible = false,
		Parent = self.Holder,
		ZIndex = 1
	})
	Create("UICorner", { CornerRadius = UDim.new(0, T.R), Parent = self.Main })
	Create("UIStroke", { Thickness = 1, Color = T.Sf2, Parent = self.Main })
	
	-- TitleBar
	local bar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.Sf, BorderSizePixel = 0,
		Parent = self.Main
	})
	Create("UICorner", { CornerRadius = UDim.new(0, T.R), Parent = bar })
	
	Create("TextLabel", {
		Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1, Text = self.Name, TextColor3 = T.Tx,
		Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
		Parent = bar
	})
	
	local close = Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -34, 0, 6),
		BackgroundColor3 = T.Sf2, Text = "✕", TextColor3 = T.Tx,
		Font = Enum.Font.GothamBold, TextSize = 14, Parent = bar
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = close })
	close.MouseButton1Click:Connect(function()
		self.Main.Visible = false
		-- Закрыть все дропдауны
		for _, dd in ipairs(self.Dropdowns) do
			pcall(function() dd:Close() end)
		end
	end)
	
	local pin = Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -66, 0, 6),
		BackgroundColor3 = T.Sf2, Text = "📌", TextColor3 = T.Tx,
		Font = Enum.Font.GothamBold, TextSize = 12, Parent = bar
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = pin })
	local pinned = false
	pin.MouseButton1Click:Connect(function()
		pinned = not pinned
		pin.BackgroundColor3 = pinned and T.Tx2 or T.Sf2
	end)
	
	-- Drag через Draggable + Active
	local dragging = false
	local dragStart, frameStart
	
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			frameStart = self.Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
		end
	end)
	
	-- TabBar
	self.TabBar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = T.Sf, BorderSizePixel = 0, Parent = self.Main
	})
	
	self.TabScroll = Create("ScrollingFrame", {
		Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 4),
		BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.Tx2, CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.TabBar
	})
	
	local tabLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.TabScroll
	})
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TabScroll.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 10, 0, 0)
	end)
	
	-- Content
	self.Content = Create("ScrollingFrame", {
		Size = UDim2.new(1, -8, 1, -84), Position = UDim2.new(0, 4, 0, 80),
		BackgroundTransparency = 1, ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Tx2, CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.Main,
		ZIndex = 1
	})
	
	self.CLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Content
	})
	self.CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Content.CanvasSize = UDim2.new(0, 0, 0, self.CLayout.AbsoluteContentSize.Y + 8)
	end)
	
	-- Клик вне меню
	UIS.InputBegan:Connect(function(input)
		if not pinned and input.UserInputType == Enum.UserInputType.MouseButton1 and self.Main.Visible then
			local m = UIS:GetMouseLocation()
			local p = self.Main.AbsolutePosition
			local s = self.Main.AbsoluteSize
			if m.X < p.X or m.X > p.X + s.X or m.Y < p.Y or m.Y > p.Y + s.Y then
				self.Main.Visible = false
				for _, dd in ipairs(self.Dropdowns) do
					pcall(function() dd:Close() end)
				end
			end
		end
	end)
	
	-- Горячая клавиша
	UIS.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == self.Key then
			self.Main.Visible = not self.Main.Visible
		end
	end)
	
	-- Мобильная кнопка (Draggable + Active)
	if cfg.MobileButton ~= false then
		local mb = Create("TextButton", {
			Size = UDim2.new(0, 50, 0, 50),
			Position = UDim2.new(1, -65, 1, -65),
			BackgroundColor3 = T.Bg,
			Text = "☰",
			TextColor3 = T.Tx,
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = self.Holder,
			Draggable = true,
			Active = true,
			ZIndex = 100
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mb })
		Create("UIStroke", { Thickness = 1.5, Color = T.Tx2, Parent = mb })
		mb.MouseButton1Click:Connect(function()
			self.Main.Visible = not self.Main.Visible
		end)
	end
	
	return self
end

-- ==================== CREATE TAB ====================
function Window:CreateTab(name, icon)
	local tab = { Window = self }
	
	local btn = Create("TextButton", {
		Size = UDim2.new(0, 100, 0, 26), BackgroundColor3 = T.Sf2,
		Text = (icon or "") .. " " .. name, TextColor3 = T.Tx2,
		Font = Enum.Font.GothamSemibold, TextSize = 12,
		Parent = self.TabScroll
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	
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
		-- Закрыть все дропдауны
		for _, dd in ipairs(self.Dropdowns) do
			pcall(function() dd:Close() end)
		end
		
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
			Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = sec })
		Create("TextLabel", {
			Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1, Text = name, TextColor3 = T.Tx,
			Font = Enum.Font.GothamBold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = sec
		})
		return sec
	end
	
	-- ==================== TOGGLE ====================
	function tab:CreateToggle(cfg)
		cfg = cfg or {}
		local on = cfg.Default or false
		
		local ToggleController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		Create("TextLabel", {
			Size = UDim2.new(0.65, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1, Text = cfg.Name or "Toggle", TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = box
		})
		
		local sw = Create("TextButton", {
			Size = UDim2.new(0, 44, 0, 22), Position = UDim2.new(1, -56, 0.5, -11),
			BackgroundColor3 = on and T.Tx or T.Sf2, Text = "", BorderSizePixel = 0,
			Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
		
		local knob = Create("Frame", {
			Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(on and 1 or 0, on and -19 or 3, 0.5, -8),
			BackgroundColor3 = T.Bg, Parent = sw
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		
		local function updateVisual(s)
			TweenObj(sw, 0.2, { BackgroundColor3 = s and T.Tx or T.Sf2 })
			TweenObj(knob, 0.2, { Position = UDim2.new(s and 1 or 0, s and -19 or 3, 0.5, -8) })
		end
		
		sw.MouseButton1Click:Connect(function()
			on = not on
			updateVisual(on)
			if cfg.Callback then pcall(cfg.Callback, on) end
		end)
		
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
	
	-- ==================== SLIDER ====================
	function tab:CreateSlider(cfg)
		cfg = cfg or {}
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local val = cfg.Default or min
		
		local SliderController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		local label = Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 4),
			BackgroundTransparency = 1, TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = box
		})
		
		local bar = Create("TextButton", {
			Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 30),
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
			Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, -7, 0.5, -7),
			BackgroundColor3 = T.Tx, Parent = bar
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		
		local function UpdateVisual(newVal)
			val = math.clamp(newVal, min, max)
			local percent = (val - min) / (max - min)
			fill.Size = UDim2.new(percent, 0, 1, 0)
			knob.Position = UDim2.new(percent, -7, 0.5, -7)
			label.Text = string.format("%s: %.0f", cfg.Name or "Slider", val)
		end
		
		UpdateVisual(val)
		
		local dragging = false
		
		local function UpdateFromMouse()
			local mouseX = UIS:GetMouseLocation().X
			local barX = bar.AbsolutePosition.X
			local barW = bar.AbsoluteSize.X
			local percent = math.clamp((mouseX - barX) / barW, 0, 1)
			UpdateVisual(min + (max - min) * percent)
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
			Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = T.Sf,
			Text = cfg.Name or "Button", TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 14, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn2 })
		btn2.MouseButton1Click:Connect(function()
			TweenObj(btn2, 0.1, { BackgroundColor3 = T.Sf2 })
			task.wait(0.1)
			TweenObj(btn2, 0.1, { BackgroundColor3 = T.Sf })
			if cfg.Callback then pcall(cfg.Callback) end
		end)
		return btn2
	end
	
	-- ==================== DROPDOWN (ПОЛНОСТЬЮ ПЕРЕРАБОТАН) ====================
	function tab:CreateDropdown(cfg)
		cfg = cfg or {}
		local opts = cfg.Options or {}
		local sel = cfg.Default or opts[1] or ""
		local open = false
		
		local DropdownController = {}
		
		-- Основной контейнер (НОРМАЛЬНЫЙ ZINDEX)
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = T.Sf,
			Parent = content,
			ZIndex = 1
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		-- Кнопка
		local btn3 = Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "▼  " .. cfg.Name .. ": " .. sel,
			TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			Parent = box,
			ZIndex = 1
		})
		
		-- Выпадающий список (СОЗДАЁМ В САМОМ ВЕРХНЕМ КОНТЕЙНЕРЕ)
		local list = Create("Frame", {
			Name = "DropdownList",
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = T.Sf,
			Visible = false,
			Parent = self.Holder, -- ВАЖНО: родитель - Holder, а не content!
			ZIndex = 999,
			BorderSizePixel = 0
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = list })
		Create("UIStroke", { Thickness = 1.5, Color = T.Tx, Parent = list })
		
		local listLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 1),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = list
		})
		
		-- Обновление позиции списка
		local function UpdateListPosition()
			local boxPos = box.AbsolutePosition
			local boxSize = box.AbsoluteSize
			list.Position = UDim2.new(0, boxPos.X, 0, boxPos.Y + boxSize.Y + 4)
			list.Size = UDim2.new(0, boxSize.X, 0, listLayout.AbsoluteContentSize.Y + 2)
		end
		
		local frames = {}
		local function build()
			for _, f in ipairs(frames) do f:Destroy() end
			frames = {}
			for _, o in ipairs(opts) do
				local ob = Create("TextButton", {
					Size = UDim2.new(1, -4, 0, 26),
					Position = UDim2.new(0, 2, 0, 0),
					BackgroundColor3 = T.Sf2,
					Text = o,
					TextColor3 = T.Tx2,
					Font = Enum.Font.GothamSemibold,
					TextSize = 12,
					Parent = list,
					ZIndex = 999
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = ob })
				
				ob.MouseButton1Click:Connect(function()
					sel = o
					btn3.Text = "▼  " .. cfg.Name .. ": " .. sel
					open = false
					list.Visible = false
					if cfg.Callback then pcall(cfg.Callback, sel) end
				end)
				table.insert(frames, ob)
			end
			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if open then
					UpdateListPosition()
				end
			end)
		end
		build()
		
		-- Открытие/закрытие
		local function OpenDropdown()
			-- Закрыть все другие дропдауны
			for _, dd in ipairs(self.Dropdowns) do
				if dd ~= DropdownController then
					pcall(function() dd:Close() end)
				end
			end
			open = true
			UpdateListPosition()
			list.Visible = true
			btn3.Text = "▲  " .. cfg.Name .. ": " .. sel
		end
		
		local function CloseDropdown()
			open = false
			list.Visible = false
			btn3.Text = "▼  " .. cfg.Name .. ": " .. sel
		end
		
		btn3.MouseButton1Click:Connect(function()
			if open then
				CloseDropdown()
			else
				OpenDropdown()
			end
		end)
		
		-- Закрытие по клику вне
		UIS.InputBegan:Connect(function(input)
			if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
				local m = UIS:GetMouseLocation()
				local lp = list.AbsolutePosition
				local ls = list.AbsoluteSize
				local bp = box.AbsolutePosition
				local bs = box.AbsoluteSize
				
				-- Клик вне списка И вне кнопки
				local outsideList = m.X < lp.X or m.X > lp.X + ls.X or m.Y < lp.Y or m.Y > lp.Y + ls.Y
				local outsideBox = m.X < bp.X or m.X > bp.X + bs.X or m.Y < bp.Y or m.Y > bp.Y + bs.Y
				
				if outsideList and outsideBox then
					CloseDropdown()
				end
			end
		end)
		
		-- Методы контроллера
		function DropdownController:GetValue()
			return sel
		end
		
		function DropdownController:SetOptions(newOpts)
			opts = newOpts
			build()
		end
		
		function DropdownController:Close()
			CloseDropdown()
		end
		
		function DropdownController:Open()
			OpenDropdown()
		end
		
		DropdownController._box = box
		DropdownController._list = list
		
		-- Добавляем в список дропдаунов окна
		table.insert(self.Dropdowns, DropdownController)
		
		return DropdownController
	end
	
	-- ==================== COLOR PICKER ====================
	function tab:CreateColorPicker(cfg)
		cfg = cfg or {}
		local col = cfg.Default or Color3.new(1, 1, 1)
		
		local ColorPickerController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 12, 0, 3),
			BackgroundTransparency = 1, Text = cfg.Name or "Color", TextColor3 = T.Tx,
			Font = Enum.Font.GothamSemibold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = box
		})
		
		local pf = Create("Frame", {
			Size = UDim2.new(1, -24, 0, 26), Position = UDim2.new(0, 12, 0, 23),
			BackgroundTransparency = 1, Parent = box
		})
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
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
				Size = UDim2.new(0, 22, 0, 22), BackgroundColor3 = p, Text = "", Parent = pf
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
		
		function ColorPickerController:GetColor()
			return col
		end
		
		ColorPickerController._box = box
		return ColorPickerController
	end
	
	-- ==================== TEXTBOX ====================
	function tab:CreateTextBox(cfg)
		cfg = cfg or {}
		
		local TextBoxController = {}
		
		local box = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.Sf, Parent = content
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
		
		local inp = Create("TextBox", {
			Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 6),
			BackgroundColor3 = T.Sf2, Text = cfg.Default or "",
			PlaceholderText = cfg.Placeholder or "Enter text...",
			TextColor3 = T.Tx, PlaceholderColor3 = T.Tx2,
			Font = Enum.Font.GothamSemibold, TextSize = 13,
			ClearTextOnFocus = false, Parent = box
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = inp })
		
		inp.FocusLost:Connect(function(enter)
			if cfg.Callback then pcall(cfg.Callback, inp.Text, enter) end
		end)
		
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
