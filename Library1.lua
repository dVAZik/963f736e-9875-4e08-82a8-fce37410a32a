--[[
	🌸 NekoUI Library v2.1
	"Dark Pastel Cyberpunk" - UI Library for Roblox Executors
	GitHub: github.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a
	Поддержка: Delta, Codex, Synapse X, ScriptWare, Krnl
	
	ИСПОЛЬЗОВАНИЕ:
	local NekoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a/refs/heads/main/Library.lua"))()
	
	Создание окна:
	local Window = NekoUI:CreateWindow({
		Name = "My Script",
		Theme = "Cyberpunk", -- "Cyberpunk", "Pastel", "Dark"
		Key = Enum.KeyCode.Insert,
		MobileButton = true
	})
--]]

local NekoUI = {}
local Library = {}
Library.Windows = {}
Library.Themes = {}
Library.Connections = {}

-- Сервисы Roblox
local Services = setmetatable({}, {
	__index = function(t, k)
		local service = game:GetService(k)
		t[k] = service
		return service
	end
})

-- Утилиты
local Utility = {}

function Utility.Create(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		if prop == "Parent" then
			instance.Parent = value
		else
			instance[prop] = value
		end
	end
	return instance
end

function Utility.Tween(obj, time, props, easing, dir)
	local tweenInfo = TweenInfo.new(time or 0.3, easing or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tween = Services.TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

function Utility.Dragify(frame, handle)
	local dragging, dragInput, dragStart, startPos
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	
	handle.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Дефолтные темы
Library.Themes = {
	Cyberpunk = {
		Background = Color3.fromRGB(13, 13, 20),
		Surface = Color3.fromRGB(25, 25, 35),
		SurfaceLight = Color3.fromRGB(35, 35, 45),
		Accent = Color3.fromRGB(255, 59, 122),
		AccentSecondary = Color3.fromRGB(0, 240, 255),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 200),
		Success = Color3.fromRGB(80, 255, 150),
		Warning = Color3.fromRGB(255, 200, 50),
		Danger = Color3.fromRGB(255, 80, 80),
		CornerRadius = 12,
		Font = Enum.Font.GothamBold,
		FontSecondary = Enum.Font.GothamSemibold
	},
	Pastel = {
		Background = Color3.fromRGB(30, 25, 35),
		Surface = Color3.fromRGB(40, 35, 50),
		SurfaceLight = Color3.fromRGB(50, 45, 60),
		Accent = Color3.fromRGB(255, 182, 193),
		AccentSecondary = Color3.fromRGB(180, 220, 255),
		Text = Color3.fromRGB(255, 240, 245),
		TextSecondary = Color3.fromRGB(200, 190, 210),
		Success = Color3.fromRGB(170, 255, 200),
		Warning = Color3.fromRGB(255, 220, 140),
		Danger = Color3.fromRGB(255, 140, 140),
		CornerRadius = 15,
		Font = Enum.Font.GothamBold,
		FontSecondary = Enum.Font.GothamSemibold
	},
	Dark = {
		Background = Color3.fromRGB(10, 10, 10),
		Surface = Color3.fromRGB(20, 20, 20),
		SurfaceLight = Color3.fromRGB(30, 30, 30),
		Accent = Color3.fromRGB(180, 180, 180),
		AccentSecondary = Color3.fromRGB(100, 100, 100),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(150, 150, 150),
		Success = Color3.fromRGB(100, 255, 100),
		Warning = Color3.fromRGB(255, 200, 50),
		Danger = Color3.fromRGB(255, 80, 80),
		CornerRadius = 8,
		Font = Enum.Font.GothamBold,
		FontSecondary = Enum.Font.GothamSemibold
	}
}

-- =================== Класс Window ===================
local Window = {}
Window.__index = Window

function Window.new(config)
	local self = setmetatable({}, Window)
	self.Name = config.Name or "NekoUI"
	self.Theme = Library.Themes[config.Theme] or Library.Themes.Cyberpunk
	self.Key = config.Key or Enum.KeyCode.Insert
	self.MobileEnabled = config.MobileButton ~= false
	self.Elements = {}
	self.Tabs = {}
	self.CurrentTab = nil
	
	-- Создание ScreenGui
	self.Gui = Utility.Create("ScreenGui", {
		Name = "NekoUI_" .. self.Name,
		Parent = Services.CoreGui,
		ResetOnSpawn = false,
		IgnoreGuiInset = true
	})
	
	-- UI Scale для адаптивности (ИСПРАВЛЕНО - используем GuiService)
	local guiService = game:GetService("GuiService")
	local screenResolution = guiService:GetScreenResolution()
	
	self.UIScale = Utility.Create("UIScale", {
		Parent = self.Gui,
		Scale = math.clamp(screenResolution.X / 1920, 0.6, 1.5)
	})
	
	-- Главное окно
	self.MainFrame = Utility.Create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 680, 0, 450),
		Position = UDim2.new(0.5, -340, 0.5, -225),
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
		Visible = false,
		Parent = self.Gui
	})
	
	Utility.Create("UICorner", {
		CornerRadius = UDim.new(0, self.Theme.CornerRadius),
		Parent = self.MainFrame
	})
	
	-- Эффект размытия
	Utility.Create("BlurEffect", {
		Size = 10,
		Parent = self.MainFrame
	})
	
	-- Тень с акцентным цветом
	Utility.Create("ImageLabel", {
		Size = UDim2.new(1, 24, 1, 24),
		Position = UDim2.new(0, -12, 0, -12),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843",
		ImageColor3 = self.Theme.Accent,
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Parent = self.MainFrame
	})
	
	-- TitleBar
	local titleBar = Utility.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = self.Theme.Surface,
		BorderSizePixel = 0,
		Parent = self.MainFrame
	})
	
	Utility.Create("UICorner", {
		CornerRadius = UDim.new(0, self.Theme.CornerRadius),
		Parent = titleBar
	})
	
	-- Градиент заголовка
	Utility.Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.Theme.Accent),
			ColorSequenceKeypoint.new(1, self.Theme.AccentSecondary)
		}),
		Rotation = 90,
		Parent = titleBar
	})
	
	Utility.Create("TextLabel", {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = "🌸 " .. self.Name,
		TextColor3 = self.Theme.Text,
		Font = self.Theme.Font,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})
	
	-- Кнопка закрытия
	local closeBtn = Utility.Create("TextButton", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 6),
		BackgroundColor3 = self.Theme.SurfaceLight,
		Text = "✕",
		TextColor3 = self.Theme.Text,
		Font = self.Theme.Font,
		TextSize = 16,
		Parent = titleBar
	})
	
	Utility.Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = closeBtn
	})
	
	closeBtn.MouseButton1Click:Connect(function()
		self.MainFrame.Visible = false
	end)
	
	-- Drag functionality
	Utility.Dragify(self.MainFrame, titleBar)
	
	-- Tab Container
	self.TabContainer = Utility.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 42),
		BackgroundColor3 = self.Theme.Surface,
		BorderSizePixel = 0,
		Parent = self.MainFrame
	})
	
	-- Scrolling для табов
	self.TabScroll = Utility.Create("ScrollingFrame", {
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = self.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.TabContainer
	})
	
	local tabLayout = Utility.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.TabScroll
	})
	
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TabScroll.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 10, 0, 0)
	end)
	
	-- Content Area
	self.ContentScroll = Utility.Create("ScrollingFrame", {
		Size = UDim2.new(1, -10, 1, -92),
		Position = UDim2.new(0, 5, 0, 87),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = self.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageTransparency = 0.5,
		Parent = self.MainFrame
	})
	
	self.ContentLayout = Utility.Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.ContentScroll
	})
	
	self.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ContentScroll.CanvasSize = UDim2.new(0, 0, 0, self.ContentLayout.AbsoluteContentSize.Y + 10)
	end)
	
	-- Кнопка Pin (закрепление)
	local pinBtn = Utility.Create("TextButton", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -70, 0, 6),
		BackgroundColor3 = self.Theme.SurfaceLight,
		Text = "📌",
		TextColor3 = self.Theme.Text,
		Font = self.Theme.Font,
		TextSize = 14,
		Parent = titleBar
	})
	
	Utility.Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = pinBtn
	})
	
	local pinned = false
	pinBtn.MouseButton1Click:Connect(function()
		pinned = not pinned
		pinBtn.Text = pinned and "📍" or "📌"
		pinBtn.BackgroundColor3 = pinned and self.Theme.Accent or self.Theme.SurfaceLight
	end)
	
	-- Обработчик закрытия по клику вне меню
	Services.UserInputService.InputBegan:Connect(function(input)
		if not pinned and input.UserInputType == Enum.UserInputType.MouseButton1 then
			if self.MainFrame.Visible then
				local mousePos = Services.UserInputService:GetMouseLocation()
				local framePos = self.MainFrame.AbsolutePosition
				local frameSize = self.MainFrame.AbsoluteSize
				
				if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
				   mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
					self.MainFrame.Visible = false
				end
			end
		end
	end)
	
	-- Toggle кнопка для ПК (Insert/P)
	Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == self.Key then
			self.MainFrame.Visible = not self.MainFrame.Visible
			if self.MainFrame.Visible then
				Utility.Tween(self.MainFrame, 0.3, {
					Size = UDim2.new(0, 680, 0, 450)
				}, Enum.EasingStyle.Back)
			end
		end
	end)
	
	-- Мобильная кнопка
	if self.MobileEnabled then
		local mobileBtn = Utility.Create("TextButton", {
			Size = UDim2.new(0, 55, 0, 55),
			Position = UDim2.new(1, -70, 1, -70),
			BackgroundColor3 = self.Theme.Background,
			Text = "🌸",
			TextColor3 = self.Theme.Accent,
			Font = self.Theme.Font,
			TextSize = 24,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = self.Gui
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = mobileBtn
		})
		
		-- Обводка
		Utility.Create("UIStroke", {
			Thickness = 2,
			Color = self.Theme.Accent,
			Parent = mobileBtn
		})
		
		Utility.Dragify(mobileBtn, mobileBtn)
		
		mobileBtn.MouseButton1Click:Connect(function()
			self.MainFrame.Visible = not self.MainFrame.Visible
			if self.MainFrame.Visible then
				Utility.Tween(self.MainFrame, 0.3, {
					Size = UDim2.new(0, 680, 0, 450)
				}, Enum.EasingStyle.Back)
			end
		end)
	end
	
	-- Анимация открытия
	self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	
	return self
end

function Window:CreateTab(name, icon)
	local Tab = {}
	
	local tabBtn = Utility.Create("TextButton", {
		Size = UDim2.new(0, 110, 0, 28),
		BackgroundColor3 = self.Theme.SurfaceLight,
		Text = (icon or "") .. " " .. name,
		TextColor3 = self.Theme.TextSecondary,
		Font = self.Theme.FontSecondary,
		TextSize = 12,
		Parent = self.TabScroll
	})
	
	Utility.Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = tabBtn
	})
	
	-- Создаем фрейм для контента вкладки
	local tabContent = Utility.Create("Frame", {
		Size = UDim2.new(1, -10, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.ContentScroll
	})
	
	local tabLayout = Utility.Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabContent
	})
	
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.Size = UDim2.new(1, -10, 0, tabLayout.AbsoluteContentSize.Y + 5)
	end)
	
	tabBtn.MouseButton1Click:Connect(function()
		-- Скрываем все вкладки
		for _, t in pairs(self.Tabs) do
			t.Content.Visible = false
			t.Button.BackgroundColor3 = self.Theme.SurfaceLight
			t.Button.TextColor3 = self.Theme.TextSecondary
		end
		
		-- Показываем текущую
		tabContent.Visible = true
		tabBtn.BackgroundColor3 = self.Theme.Accent
		tabBtn.TextColor3 = self.Theme.Text
		self.CurrentTab = Tab
	end)
	
	Tab.Button = tabBtn
	Tab.Content = tabContent
	Tab.Layout = tabLayout
	Tab.Window = self
	
	-- Методы для добавления элементов
	function Tab:CreateSection(name)
		local section = Utility.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = self.Window.Theme.Surface,
			Parent = self.Content
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = section
		})
		
		Utility.Create("TextLabel", {
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = "✦ " .. name,
			TextColor3 = self.Window.Theme.AccentSecondary,
			Font = self.Window.Theme.Font,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = section
		})
		
		return section
	end
	
	function Tab:CreateToggle(config)
		config = config or {}
		local enabled = config.Default or false
		
		local toggle = Utility.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = self.Window.Theme.SurfaceLight,
			Parent = self.Content
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = toggle
		})
		
		Utility.Create("TextLabel", {
			Size = UDim2.new(0.65, 0, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = config.Name or "Toggle",
			TextColor3 = self.Window.Theme.Text,
			Font = self.Window.Theme.FontSecondary,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = toggle
		})
		
		-- Switch button
		local switch = Utility.Create("TextButton", {
			Size = UDim2.new(0, 48, 0, 24),
			Position = UDim2.new(1, -58, 0.5, -12),
			BackgroundColor3 = enabled and self.Window.Theme.Success or self.Window.Theme.Surface,
			Text = "",
			BorderSizePixel = 0,
			Parent = toggle
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = switch
		})
		
		local knob = Utility.Create("Frame", {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(enabled and 1 or 0, enabled and -21 or 3, 0.5, -9),
			BackgroundColor3 = self.Window.Theme.Text,
			Parent = switch
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knob
		})
		
		local function updateVisual(state)
			Utility.Tween(switch, 0.25, {
				BackgroundColor3 = state and self.Window.Theme.Success or self.Window.Theme.Surface
			})
			Utility.Tween(knob, 0.25, {
				Position = UDim2.new(state and 1 or 0, state and -21 or 3, 0.5, -9)
			})
		end
		
		switch.MouseButton1Click:Connect(function()
			enabled = not enabled
			updateVisual(enabled)
			if config.Callback then
				pcall(config.Callback, enabled)
			end
		end)
		
		-- Setter для внешнего управления
		toggle.SetState = function(_, state)
			enabled = state
			updateVisual(state)
		end
		
		toggle.GetState = function()
			return enabled
		end
		
		return toggle
	end
	
	function Tab:CreateSlider(config)
		config = config or {}
		local min = config.Min or 0
		local max = config.Max or 100
		local value = config.Default or min
		
		local slider = Utility.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 65),
			BackgroundColor3 = self.Window.Theme.SurfaceLight,
			Parent = self.Content
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = slider
		})
		
		local label = Utility.Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 22),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			Text = string.format("%s: %.0f", config.Name or "Slider", value),
			TextColor3 = self.Window.Theme.Text,
			Font = self.Window.Theme.FontSecondary,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = slider
		})
		
		local sliderBar = Utility.Create("TextButton", {
			Size = UDim2.new(1, -20, 0, 6),
			Position = UDim2.new(0, 10, 0, 32),
			BackgroundColor3 = self.Window.Theme.Surface,
			Text = "",
			BorderSizePixel = 0,
			Parent = slider
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = sliderBar
		})
		
		local fill = Utility.Create("Frame", {
			Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
			BackgroundColor3 = self.Window.Theme.Accent,
			BorderSizePixel = 0,
			Parent = sliderBar
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = fill
		})
		
		local knob = Utility.Create("Frame", {
			Size = UDim2.new(0, 14, 0, 14),
			Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
			BackgroundColor3 = self.Window.Theme.Text,
			BorderSizePixel = 0,
			Parent = sliderBar
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knob
		})
		
		local function updateValue(newValue)
			value = math.clamp(newValue, min, max)
			local percent = (value - min) / (max - min)
			fill.Size = UDim2.new(percent, 0, 1, 0)
			knob.Position = UDim2.new(percent, -7, 0.5, -7)
			label.Text = string.format("%s: %.0f", config.Name or "Slider", value)
			
			if config.Callback then
				pcall(config.Callback, value)
			end
		end
		
		local inputBegan = false
		sliderBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				inputBegan = true
				local mousePos = Services.UserInputService:GetMouseLocation()
				local barPos = sliderBar.AbsolutePosition
				local barSize = sliderBar.AbsoluteSize
				local percent = (mousePos.X - barPos.X) / barSize.X
				updateValue(min + (max - min) * percent)
			end
		end)
		
		Services.UserInputService.InputChanged:Connect(function(input)
			if inputBegan and (input.UserInputType == Enum.UserInputType.MouseMovement) then
				local mousePos = Services.UserInputService:GetMouseLocation()
				local barPos = sliderBar.AbsolutePosition
				local barSize = sliderBar.AbsoluteSize
				local percent = (mousePos.X - barPos.X) / barSize.X
				updateValue(min + (max - min) * percent)
			end
		end)
		
		Services.UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				inputBegan = false
			end
		end)
		
		slider.SetValue = function(_, newValue)
			updateValue(newValue)
		end
		
		slider.GetValue = function()
			return value
		end
		
		return slider
	end
	
	function Tab:CreateButton(config)
		config = config or {}
		
		local button = Utility.Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 35),
			BackgroundColor3 = self.Window.Theme.Accent,
			Text = config.Name or "Button",
			TextColor3 = self.Window.Theme.Text,
			Font = self.Window.Theme.FontSecondary,
			TextSize = 14,
			Parent = self.Content
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = button
		})
		
		button.MouseButton1Click:Connect(function()
			Utility.Tween(button, 0.15, {
				BackgroundColor3 = self.Window.Theme.AccentSecondary
			})
			task.wait(0.15)
			Utility.Tween(button, 0.15, {
				BackgroundColor3 = self.Window.Theme.Accent
			})
			
			if config.Callback then
				pcall(config.Callback)
			end
		end)
		
		return button
	end
	
	function Tab:CreateDropdown(config)
		config = config or {}
		local options = config.Options or {}
		local selected = config.Default or options[1] or ""
		local expanded = false
		
		local dropdown = Utility.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 35),
			BackgroundColor3 = self.Window.Theme.SurfaceLight,
			Parent = self.Content
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = dropdown
		})
		
		local dropdownBtn = Utility.Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = config.Name .. ": " .. selected,
			TextColor3 = self.Window.Theme.Text,
			Font = self.Window.Theme.FontSecondary,
			TextSize = 13,
			Parent = dropdown
		})
		
		local optionList = Utility.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 1, 5),
			BackgroundColor3 = self.Window.Theme.Surface,
			Visible = false,
			Parent = dropdown
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = optionList
		})
		
		local optionLayout = Utility.Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = optionList
		})
		
		local optionFrames = {}
		
		local function createOptions()
			-- Очищаем старые опции
			for _, frame in ipairs(optionFrames) do
				frame:Destroy()
			end
			optionFrames = {}
			
			for _, opt in ipairs(options) do
				local optBtn = Utility.Create("TextButton", {
					Size = UDim2.new(1, -4, 0, 28),
					Position = UDim2.new(0, 2, 0, 0),
					BackgroundColor3 = self.Window.Theme.SurfaceLight,
					Text = opt,
					TextColor3 = self.Window.Theme.TextSecondary,
					Font = self.Window.Theme.FontSecondary,
					TextSize = 12,
					Parent = optionList
				})
				
				Utility.Create("UICorner", {
					CornerRadius = UDim.new(0, 6),
					Parent = optBtn
				})
				
				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					dropdownBtn.Text = config.Name .. ": " .. selected
					expanded = false
					optionList.Visible = false
					dropdown.Size = UDim2.new(1, 0, 0, 35)
					
					if config.Callback then
						pcall(config.Callback, opt)
					end
				end)
				
				table.insert(optionFrames, optBtn)
			end
			
			optionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				optionList.Size = UDim2.new(1, 0, 0, optionLayout.AbsoluteContentSize.Y + 4)
			end)
		end
		
		createOptions()
		
		dropdownBtn.MouseButton1Click:Connect(function()
			expanded = not expanded
			optionList.Visible = expanded
			dropdown.Size = UDim2.new(1, 0, 0, expanded and 35 + optionList.AbsoluteSize.Y + 5 or 35)
		end)
		
		dropdown.GetValue = function()
			return selected
		end
		
		dropdown.SetOptions = function(_, newOptions)
			options = newOptions
			createOptions()
		end
		
		return dropdown
	end
	
	function Tab:CreateColorPicker(config)
		config = config or {}
		local color = config.Default or self.Window.Theme.Accent
		
		local picker = Utility.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = self.Window.Theme.SurfaceLight,
			Parent = self.Content
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = picker
		})
		
		Utility.Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			Text = config.Name or "Color",
			TextColor3 = self.Window.Theme.Text,
			Font = self.Window.Theme.FontSecondary,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = picker
		})
		
		local presets = {
			Color3.fromRGB(255, 59, 122),  -- Pink
			Color3.fromRGB(0, 240, 255),   -- Cyan
			Color3.fromRGB(170, 0, 255),   -- Purple
			Color3.fromRGB(255, 170, 0),   -- Orange
			Color3.fromRGB(0, 255, 128),   -- Green
			Color3.fromRGB(255, 255, 255), -- White
		}
		
		local presetFrame = Utility.Create("Frame", {
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0, 10, 0, 25),
			BackgroundTransparency = 1,
			Parent = picker
		})
		
		Utility.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = presetFrame
		})
		
		local selectedFrame = nil
		
		for _, preset in ipairs(presets) do
			local colorBtn = Utility.Create("TextButton", {
				Size = UDim2.new(0, 26, 0, 26),
				BackgroundColor3 = preset,
				Text = "",
				Parent = presetFrame
			})
			
				Utility.Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = colorBtn
			})
			
			if preset == color then
				Utility.Create("UIStroke", {
					Thickness = 2,
					Color = self.Window.Theme.Text,
					Parent = colorBtn
				})
				selectedFrame = colorBtn
			end
			
			colorBtn.MouseButton1Click:Connect(function()
				if selectedFrame then
					local oldStroke = selectedFrame:FindFirstChildOfClass("UIStroke")
					if oldStroke then oldStroke:Destroy() end
				end
				
				Utility.Create("UIStroke", {
					Thickness = 2,
					Color = self.Window.Theme.Text,
					Parent = colorBtn
				})
				selectedFrame = colorBtn
				color = preset
				
				if config.Callback then
					pcall(config.Callback, color)
				end
			end)
		end
		
		picker.GetColor = function()
			return color
		end
		
		return picker
	end
	
	function Tab:CreateTextBox(config)
		config = config or {}
		
		local textBox = Utility.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = self.Window.Theme.SurfaceLight,
			Parent = self.Content
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = textBox
		})
		
		local input = Utility.Create("TextBox", {
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0, 10, 0, 6),
			BackgroundColor3 = self.Window.Theme.Surface,
			Text = config.Default or "",
			PlaceholderText = config.Placeholder or "Enter text...",
			TextColor3 = self.Window.Theme.Text,
			PlaceholderColor3 = self.Window.Theme.TextSecondary,
			Font = self.Window.Theme.FontSecondary,
			TextSize = 13,
			ClearTextOnFocus = false,
			Parent = textBox
		})
		
		Utility.Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Parent = input
		})
		
		input.FocusLost:Connect(function(enterPressed)
			if config.Callback then
				pcall(config.Callback, input.Text, enterPressed)
			end
		end)
		
		textBox.GetText = function()
			return input.Text
		end
		
		textBox.SetText = function(_, text)
			input.Text = text
		end
		
		return textBox
	end
	
	self.Tabs[#self.Tabs + 1] = Tab
	
	-- Автоматически активируем первую вкладку
	if #self.Tabs == 1 then
		tabContent.Visible = true
		tabBtn.BackgroundColor3 = self.Theme.Accent
		tabBtn.TextColor3 = self.Theme.Text
		self.CurrentTab = Tab
	end
	
	return Tab
end

-- Функция создания окна
function NekoUI:CreateWindow(config)
	local win = Window.new(config)
	Library.Windows[#Library.Windows + 1] = win
	return win
end

-- Утилиты библиотеки
function NekoUI:SetTheme(themeName)
	if Library.Themes[themeName] then
		for _, window in ipairs(Library.Windows) do
			window.Theme = Library.Themes[themeName]
			-- Обновление цветов окна
			window.MainFrame.BackgroundColor3 = window.Theme.Background
		end
	end
end

function NekoUI:AddTheme(name, theme)
	Library.Themes[name] = theme
end

return NekoUI
