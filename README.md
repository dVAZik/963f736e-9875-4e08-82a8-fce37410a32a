# 🌸 NekoUI Library v4.2
> Dark Minimal UI Library for Roblox Executors  
---

## 📦 Установка

```lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a/refs/heads/main/Library"))()
🚀 Быстрый старт
lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dVAZik/963f736e-9875-4e08-82a8-fce37410a32a/refs/heads/main/Library"))()

local menu = lib.new("My Script") -- Создание меню

menu:Category("Main")             -- Вкладка

menu:Toggle("Auto Farm", false, function(on)
    print("Farm:", on)
end)

menu:Slider("Speed", 16, 200, 16, function(v)
    print("Speed:", v)
end)

menu:Button("Click Me", function()
    print("Clicked!")
end)
🎮 Управление
Клавиша	Действие
Insert	Открыть/закрыть меню (ПК)
☰ Кнопка	Открыть/закрыть меню (Мобильные)
Перетаскивание заголовка	Перемещение окна
📚 Все методы
lib.new(name)
Создаёт главное окно меню

Параметр	Тип	Описание
name	string	Название скрипта (отображается в заголовке)
lua
local menu = lib.new("My Script")
menu:Category(name)
Создаёт вкладку-категорию. Все последующие элементы добавляются в неё.

Параметр	Тип	Описание
name	string	Название вкладки
lua
menu:Category("Main")
menu:Category("Player")
menu:Category("Visuals")
menu:Toggle(name, default, callback)
Создаёт переключатель с анимированным ползунком.

Параметр	Тип	Описание
name	string	Название
default	boolean	Начальное состояние
callback	function(on)	Вызывается при переключении
Возвращает: { On, Off, Toggle, State }

lua
local farm = menu:Toggle("Auto Farm", false, function(on)
    print("Farm:", on)
end)

farm:On()       -- Включить
farm:Off()      -- Выключить
farm:Toggle()   -- Переключить
print(farm:State()) -- Получить состояние
menu:Slider(name, min, max, default, callback)
Создаёт ползунок для числовых значений.

Параметр	Тип	Описание
name	string	Название
min	number	Минимум
max	number	Максимум
default	number	Значение по умолчанию
callback	function(v)	Вызывается при изменении
Возвращает: { Set, Get, Add, Sub }

lua
local speed = menu:Slider("Walk Speed", 16, 200, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

speed:Set(50)   -- Установить
print(speed:Get()) -- Получить
speed:Add(10)   -- +10
speed:Sub(5)    -- -5
menu:Button(name, callback)
Создаёт кнопку с анимацией нажатия.

Параметр	Тип	Описание
name	string	Текст на кнопке
callback	function()	Вызывается при клике
Возвращает: { Click }

lua
menu:Button("Respawn", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)
menu:Dropdown(name, options, default, callback)
Создаёт выпадающий список с прокруткой.

Параметр	Тип	Описание
name	string	Название
options	table	Список: {"A", "B", "C"}
default	string	По умолчанию
callback	function(v)	При выборе
Возвращает: { Get, Set, Update }

lua
local mode = menu:Dropdown("Mode", {"Easy", "Hard"}, "Easy", function(v)
    print("Mode:", v)
end)

print(mode:Get())        -- Текущее
mode:Set("Hard")         -- Сменить
mode:Update({"A", "B"})  -- Обновить список
menu:Color(name, default, callback)
Создаёт палитру выбора цвета из 7 пресетов.

Параметр	Тип	Описание
name	string	Название
default	Color3	Цвет по умолчанию
callback	function(c)	При выборе
Возвращает: { Get, Set }

lua
local col = menu:Color("ESP Color", Color3.new(1,1,1), function(c)
    print("Color:", c)
end)

print(col:Get())              -- Текущий цвет
col:Set(Color3.new(1,0,0))   -- Установить красный
menu:Input(name, placeholder, default, callback)
Создаёт поле ввода текста.

Параметр	Тип	Описание
name	string	Название
placeholder	string	Подсказка
default	string	Текст по умолчанию
callback	function(text, enter)	При потере фокуса
Возвращает: { Get, Set, Clear }

lua
local inp = menu:Input("Search", "Type...", "", function(text, enter)
    if enter then print("Search:", text) end
end)

print(inp:Get())     -- Текст
inp:Set("hello")     -- Установить
inp:Clear()          -- Очистить
menu:KeyBind(name, defaultKey, callback) 🆕
Создаёт настраиваемую привязку клавиши.
Кликните по кнопке, затем нажмите нужную клавишу.

Параметр	Тип	Описание
name	string	Название действия
defaultKey	KeyCode	Клавиша по умолчанию
callback	function()	Вызывается при нажатии
Возвращает: { SetKey, GetKey }

lua
menu:KeyBind("Сортировка", Enum.KeyCode.R, function()
    print("Сортируем...")
    sortItems()
end)

menu:KeyBind("Продажа", Enum.KeyCode.T, function()
    print("Продаём...")
    sellAll()
end)
📱 Мобильная поддержка
Автоматически: на ПК меню открыто, на мобильных — скрыто

Круглая кнопка ☰ в правом нижнем углу (можно перетаскивать)

Все элементы работают с тач-вводом

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
