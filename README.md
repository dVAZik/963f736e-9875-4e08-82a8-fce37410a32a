```markdown
# 🌸 NekoUI Library v2.0

> Dark Pastel Cyberpunk UI Library для Roblox Executors
> Стильный, адаптивный, функциональный интерфейс для мод-меню

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Roblox](https://img.shields.io/badge/platform-Roblox-red.svg)](https://roblox.com)
[![Version](https://img.shields.io/badge/version-2.0-pink.svg)](https://github.com/dVAZik)

---

## 📦 Установка

```lua
local NekoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a/refs/heads/main/Library.lua"))()
```

---

## 📚 Все методы библиотеки

### `NekoUI:CreateWindow(config)`
**Создаёт главное окно меню**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | `string` | Название скрипта (отображается в заголовке окна) |
| `Theme` | `string` | Тема оформления: `"Cyberpunk"`, `"Pastel"`, `"Dark"` |
| `Key` | `Enum.KeyCode` | Клавиша для открытия/закрытия меню на ПК |
| `MobileButton` | `boolean` | Показывать плавающую кнопку на мобильных устройствах |

**Возвращает:** объект `Window`

**Пример:**
```lua
local Window = NekoUI:CreateWindow({
    Name = "My Script",
    Theme = "Cyberpunk",
    Key = Enum.KeyCode.Insert,
    MobileButton = true
})
```

---

### `Window:CreateTab(name, icon)`
**Создаёт вкладку в меню**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `name` | `string` | Название вкладки |
| `icon` | `string` | Emoji иконка (необязательно) |

**Возвращает:** объект `Tab`

**Пример:**
```lua
local MainTab = Window:CreateTab("Главная", "🏠")
local PlayerTab = Window:CreateTab("Игрок", "🎮")
local VisualTab = Window:CreateTab("Визуал", "👁")
```

---

### `Tab:CreateSection(name)`
**Создаёт заголовок-разделитель для группировки элементов**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `name` | `string` | Название секции |

**Пример:**
```lua
PlayerTab:CreateSection("Передвижение")
PlayerTab:CreateSection("Телепортация")
PlayerTab:CreateSection("Способности")
```

---

### `Tab:CreateToggle(config)`
**Создаёт переключатель с анимированным ползунком (Вкл/Выкл)**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | `string` | Название функции |
| `Default` | `boolean` | Начальное состояние: `true` или `false` |
| `Callback` | `function(enabled)` | Функция, вызываемая при переключении |

**Методы объекта Toggle:**
- `Toggle:SetState(state)` — программно изменить состояние
- `Toggle:GetState()` — получить текущее состояние (`true`/`false`)

**Пример:**
```lua
local flyToggle = PlayerTab:CreateToggle({
    Name = "Режим полёта",
    Default = false,
    Callback = function(enabled)
        if enabled then
            print("Полёт включён!")
        else
            print("Полёт выключен!")
        end
    end
})

-- Управление программно
flyToggle:SetState(true)  -- Включить
local state = flyToggle:GetState()  -- Проверить состояние
```

---

### `Tab:CreateSlider(config)`
**Создаёт ползунок для выбора числового значения**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | `string` | Название функции |
| `Min` | `number` | Минимальное значение |
| `Max` | `number` | Максимальное значение |
| `Default` | `number` | Значение по умолчанию |
| `Callback` | `function(value)` | Функция, вызываемая при каждом изменении |

**Методы объекта Slider:**
- `Slider:SetValue(value)` — программно установить значение
- `Slider:GetValue()` — получить текущее значение

**Пример:**
```lua
local speedSlider = PlayerTab:CreateSlider({
    Name = "Скорость ходьбы",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- Управление программно
speedSlider:SetValue(100)  -- Установить скорость 100
local currentSpeed = speedSlider:GetValue()  -- Узнать текущую скорость
```

---

### `Tab:CreateButton(config)`
**Создаёт кнопку с анимацией нажатия**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | `string` | Текст на кнопке |
| `Callback` | `function()` | Функция, вызываемая при нажатии |

**Пример:**
```lua
PlayerTab:CreateButton({
    Name = "Телепорт к ближайшему игроку",
    Callback = function()
        print("Телепортация...")
        -- Ваш код здесь
    end
})

PlayerTab:CreateButton({
    Name = "Respawn",
    Callback = function()
        game.Players.LocalPlayer.Character:BreakJoints()
    end
})
```

---

### `Tab:CreateDropdown(config)`
**Создаёт выпадающий список для выбора опции**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | `string` | Название выпадающего списка |
| `Options` | `table` | Список опций: `{"Опция1", "Опция2", "Опция3"}` |
| `Default` | `string` | Опция, выбранная по умолчанию |
| `Callback` | `function(selected)` | Функция, вызываемая при выборе опции |

**Методы объекта Dropdown:**
- `Dropdown:GetValue()` — получить текущую выбранную опцию
- `Dropdown:SetOptions(options)` — обновить список опций

**Пример:**
```lua
local weaponDropdown = PlayerTab:CreateDropdown({
    Name = "Выбор оружия",
    Options = {"Меч", "Пистолет", "Граната", "Снайперка"},
    Default = "Пистолет",
    Callback = function(selected)
        print("Выбрано оружие:", selected)
        -- Дать игроку выбранное оружие
    end
})

-- Управление программно
local currentWeapon = weaponDropdown:GetValue()  -- Получить выбранное оружие
weaponDropdown:SetOptions({"Нож", "Дробовик", "РПГ"})  -- Обновить список
```

---

### `Tab:CreateColorPicker(config)`
**Создаёт палитру для выбора цвета из пресетов**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | `string` | Название палитры |
| `Default` | `Color3` | Цвет по умолчанию |
| `Callback` | `function(color)` | Функция, вызываемая при выборе цвета |

**Методы объекта ColorPicker:**
- `ColorPicker:GetColor()` — получить текущий выбранный цвет

**Пример:**
```lua
local colorPicker = VisualTab:CreateColorPicker({
    Name = "Цвет подсветки",
    Default = Color3.fromRGB(255, 59, 122),
    Callback = function(color)
        print("Выбран цвет:", color)
        -- Изменить цвет элементов
    end
})

-- Получить текущий цвет
local currentColor = colorPicker:GetColor()
```

---

### `Tab:CreateTextBox(config)`
**Создаёт поле для ввода текста**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | `string` | Название поля (не отображается) |
| `Placeholder` | `string` | Текст-подсказка в пустом поле |
| `Default` | `string` | Текст по умолчанию |
| `Callback` | `function(text, enterPressed)` | Функция при потере фокуса |

**Методы объекта TextBox:**
- `TextBox:GetText()` — получить введённый текст
- `TextBox:SetText(text)` — программно установить текст

**Пример:**
```lua
local searchBox = SettingsTab:CreateTextBox({
    Name = "Поиск",
    Placeholder = "Введите название функции...",
    Default = "",
    Callback = function(text, enterPressed)
        if enterPressed then
            print("Поиск по запросу:", text)
        end
    end
})

-- Управление программно
local currentText = searchBox:GetText()  -- Получить текст
searchBox:SetText("Новый текст")  -- Установить текст
```

---

### `NekoUI:AddTheme(name, themeTable)`
**Добавляет кастомную тему оформления**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `name` | `string` | Название темы |
| `themeTable` | `table` | Таблица с настройками цветов и шрифтов |

**Пример:**
```lua
NekoUI:AddTheme("MyTheme", {
    Background = Color3.fromRGB(20, 20, 30),
    Surface = Color3.fromRGB(30, 30, 40),
    SurfaceLight = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(100, 255, 150),
    AccentSecondary = Color3.fromRGB(150, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    Success = Color3.fromRGB(80, 255, 80),
    Warning = Color3.fromRGB(255, 200, 50),
    Danger = Color3.fromRGB(255, 80, 80),
    CornerRadius = 12,
    Font = Enum.Font.GothamBold,
    FontSecondary = Enum.Font.GothamSemibold
})

-- Использование кастомной темы
local Window = NekoUI:CreateWindow({
    Name = "Custom Theme Window",
    Theme = "MyTheme",
    Key = Enum.KeyCode.Insert,
    MobileButton = true
})
```

---

## 🚀 Полный пример скрипта

```lua
-- Загрузка библиотеки
local NekoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a/refs/heads/main/Library.lua"))()

-- Создание окна
local Window = NekoUI:CreateWindow({
    Name = "Ultimate Script",
    Theme = "Cyberpunk",
    Key = Enum.KeyCode.Insert,
    MobileButton = true
})

-- Вкладка "Игрок"
local PlayerTab = Window:CreateTab("Игрок", "🎮")

PlayerTab:CreateSection("Передвижение")

PlayerTab:CreateSlider({
    Name = "Скорость ходьбы",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

PlayerTab:CreateSlider({
    Name = "Сила прыжка",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

PlayerTab:CreateSection("Способности")

PlayerTab:CreateToggle({
    Name = "Бесконечный прыжок",
    Default = false,
    Callback = function(enabled)
        getgenv().InfiniteJump = enabled
    end
})

PlayerTab:CreateToggle({
    Name = "Режим полёта",
    Default = false,
    Callback = function(enabled)
        getgenv().FlyEnabled = enabled
    end
})

PlayerTab:CreateSection("Телепортация")

PlayerTab:CreateButton({
    Name = "К ближайшему игроку",
    Callback = function()
        print("Телепортация к ближайшему игроку...")
    end
})

-- Вкладка "Визуал"
local VisualTab = Window:CreateTab("Визуал", "👁")

VisualTab:CreateSection("Эффекты")

VisualTab:CreateToggle({
    Name = "ESP",
    Default = false,
    Callback = function(enabled)
        getgenv().ESP = enabled
    end
})

VisualTab:CreateToggle({
    Name = "Chams",
    Default = false,
    Callback = function(enabled)
        getgenv().Chams = enabled
    end
})

VisualTab:CreateColorPicker({
    Name = "Цвет Chams",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        getgenv().ChamsColor = color
    end
})

VisualTab:CreateSlider({
    Name = "Яркость",
    Min = 1,
    Max = 10,
    Default = 2,
    Callback = function(value)
        game.Lighting.Brightness = value
    end
})

-- Вкладка "Оружие"
local WeaponTab = Window:CreateTab("Оружие", "🔫")

WeaponTab:CreateSection("Aimbot")

WeaponTab:CreateDropdown({
    Name = "Тип аима",
    Options = {"Silent", "Lock", "Trigger"},
    Default = "Silent",
    Callback = function(selected)
        getgenv().AimType = selected
    end
})

WeaponTab:CreateToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(enabled)
        getgenv().Aimbot = enabled
    end
})

WeaponTab:CreateToggle({
    Name = "Бесконечные патроны",
    Default = false,
    Callback = function(enabled)
        getgenv().InfAmmo = enabled
    end
})

-- Вкладка "Утилиты"
local UtilTab = Window:CreateTab("Утилиты", "🛠")

UtilTab:CreateSection("Система")

UtilTab:CreateToggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(enabled)
        getgenv().AntiAFK = enabled
    end
})

UtilTab:CreateButton({
    Name = "Respawn",
    Callback = function()
        game.Players.LocalPlayer.Character:BreakJoints()
    end
})

UtilTab:CreateButton({
    Name = "Очистить чат",
    Callback = function()
        local chat = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Chat")
        if chat then chat:Destroy() end
    end
})

-- Вкладка "Настройки"
local SettingsTab = Window:CreateTab("Настройки", "⚙")

SettingsTab:CreateSection("Интерфейс")

SettingsTab:CreateDropdown({
    Name = "Тема",
    Options = {"Cyberpunk", "Pastel", "Dark"},
    Default = "Cyberpunk",
    Callback = function(selected)
        print("Тема изменена на:", selected)
    end
})

SettingsTab:CreateTextBox({
    Name = "Поиск",
    Placeholder = "Введите название функции...",
    Default = "",
    Callback = function(text, enterPressed)
        if enterPressed then
            print("Поиск:", text)
        end
    end
})
```

---

## 🎯 Горячие клавиши

| Клавиша | Действие |
|---------|----------|
| `Insert` | Открыть/закрыть меню (ПК) |
| `🌸 Кнопка` | Открыть/закрыть меню (Мобильные) |
| Перетаскивание TitleBar | Перемещение окна |
| Кнопка 📌 | Закрепить меню (не закрывается при клике вне) |

---

## 🤝 Поддержка платформ

| Executor | Статус |
|----------|--------|
| Delta Executor | ✅ Полная поддержка |
| Codex | ✅ Полная поддержка |
| Synapse X | ✅ Полная поддержка |
| ScriptWare | ✅ Полная поддержка |
| KRNL | ✅ Полная поддержка |
| Fluxus | ✅ Полная поддержка |
| Electron | ✅ Полная поддержка |

---

## 📄 Лицензия

MIT License - свободное использование с указанием авторства

---

**Сделано с 💖 для комьюнити Roblox Exploiting**
```
