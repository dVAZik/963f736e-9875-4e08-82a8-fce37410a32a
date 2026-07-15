# 🌸 NekoUI Library v4.1

> Dark Minimal UI Library для Roblox Executors
> Стильный, адаптивный, с поддержкой мобильных устройств

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Roblox](https://img.shields.io/badge/platform-Roblox-red.svg)](https://roblox.com)
[![Version](https://img.shields.io/badge/version-4.1-pink.svg)](https://github.com/dVAZik)

---

## 📦 Установка

```lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a/refs/heads/main/Library"))()
🚀 Быстрый старт
lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a/refs/heads/main/Library"))()

local menu = lib.new("My Script")

menu:Category("Main")
menu:Toggle("Auto Farm", false, function(on) print("Farm:", on) end)
menu:Slider("Speed", 16, 200, 16, function(v) print("Speed:", v) end)
menu:Button("Click Me", function() print("Clicked!") end)
🎮 Управление
Клавиша	Действие
Insert	Открыть/закрыть меню (ПК)
☰ Кнопка	Открыть/закрыть меню (Мобильные)
Перетаскивание заголовка	Перемещение окна
Перетаскивание ☰	Перемещение мобильной кнопки
✕	Закрыть меню
📚 Все методы
lib.new(name)
Создаёт главное окно меню

Параметр	Тип	Описание
name	string	Название скрипта (отображается в заголовке)
Возвращает: объект меню

lua
local menu = lib.new("My Script")
menu:Category(name)
Создаёт вкладку-категорию. Все последующие элементы добавляются в эту категорию.

Параметр	Тип	Описание
name	string	Название категории
lua
menu:Category("Player")
menu:Category("Visuals")
menu:Category("Settings")
menu:Toggle(name, default, callback)
Создаёт переключатель (Вкл/Выкл) с анимированным ползунком.

Параметр	Тип	Описание
name	string	Название функции
default	boolean	Начальное состояние
callback	function(enabled)	Вызывается при переключении
Возвращает контроллер: { On, Off, Toggle, State }

lua
local farm = menu:Toggle("Auto Farm", false, function(on)
    print("Farm:", on)
end)

-- Методы контроллера:
farm:On()       -- Включить
farm:Off()      -- Выключить
farm:Toggle()   -- Переключить
farm:State()    -- Получить состояние (true/false)
menu:Slider(name, min, max, default, callback)
Создаёт ползунок для выбора числового значения.

Параметр	Тип	Описание
name	string	Название
min	number	Минимальное значение
max	number	Максимальное значение
default	number	Значение по умолчанию
callback	function(value)	Вызывается при изменении
Возвращает контроллер: { Set, Get, Add, Sub }

lua
local speed = menu:Slider("Walk Speed", 16, 200, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

-- Методы контроллера:
speed:Set(50)   -- Установить значение
speed:Get()     -- Получить значение
speed:Add(10)   -- Увеличить на 10
speed:Sub(5)    -- Уменьшить на 5
menu:Button(name, callback)
Создаёт кнопку с анимацией нажатия.

Параметр	Тип	Описание
name	string	Текст на кнопке
callback	function()	Вызывается при нажатии
Возвращает контроллер: { Click }

lua
local respawn = menu:Button("Respawn", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)

-- Метод контроллера:
respawn:Click() -- Программный клик
menu:Dropdown(name, options, default, callback)
Создаёт выпадающий список с прокруткой.

Параметр	Тип	Описание
name	string	Название
options	table	Список опций: {"Опция1", "Опция2"}
default	string	Опция по умолчанию
callback	function(selected)	Вызывается при выборе
Возвращает контроллер: { Get, Set, Update }

lua
local aim = menu:Dropdown("Aim Type", {"Silent", "Lock", "Trigger"}, "Silent", function(v)
    print("Selected:", v)
end)

-- Методы контроллера:
aim:Get()                    -- Получить выбранное
aim:Set("Lock")              -- Установить опцию
aim:Update({"A", "B", "C"})  -- Обновить список опций
menu:Color(name, default, callback)
Создаёт палитру выбора цвета из пресетов.

Параметр	Тип	Описание
name	string	Название
default	Color3	Цвет по умолчанию
callback	function(color)	Вызывается при выборе
Возвращает контроллер: { Get, Set }

lua
local col = menu:Color("ESP Color", Color3.new(1,1,1), function(c)
    print("Color:", c)
end)

-- Методы контроллера:
col:Get()                  -- Получить цвет
col:Set(Color3.new(1,0,0)) -- Установить цвет
menu:Input(name, placeholder, default, callback)
Создаёт поле ввода текста.

Параметр	Тип	Описание
name	string	Название (не отображается)
placeholder	string	Текст-подсказка
default	string	Текст по умолчанию
callback	function(text, enterPressed)	Вызывается при потере фокуса
Возвращает контроллер: { Get, Set, Clear }

lua
local search = menu:Input("Search", "Type name...", "", function(text, enter)
    if enter then print("Search:", text) end
end)

-- Методы контроллера:
search:Get()          -- Получить текст
search:Set("hello")   -- Установить текст
search:Clear()        -- Очистить
📱 Мобильная поддержка
Автоматическое определение устройства (Touch + нет клавиатуры/мыши)

Плавающая кнопка ☰ в правом нижнем углу

Кнопку можно перетаскивать

На ПК меню открыто сразу, на мобильных — скрыто

🤝 Поддержка платформ
Executor	Статус
Delta Executor	✅
Codex	✅
Synapse X	✅
KRNL	✅
Fluxus	✅
Electron	✅
📄 Лицензия
MIT License — свободное использование
