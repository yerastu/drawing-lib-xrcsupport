local MaQueen = {}
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local GLOW_ASSET = "rbxassetid://18245826428"
local GLOW_SLICE = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
local BG_ASSET = "rbxassetid://107540586941326"

local function hsvToRgb(h, s, v)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end
	return r, g, b
end

local function rgbToHsv(r, g, b)
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local d = max - min
	local h, s, v = 0, 0, max
	s = max == 0 and 0 or d / max
	if max ~= min then
		if max == r then h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end
	return h, s, v
end

local function toHex(r, g, b)
	return string.format("#%02X%02X%02X", math.round(r * 255), math.round(g * 255), math.round(b * 255))
end

local function fromHex(hex)
	hex = hex:gsub("#", "")
	if #hex == 6 then
		local r = tonumber(hex:sub(1, 2), 16)
		local g = tonumber(hex:sub(3, 4), 16)
		local b = tonumber(hex:sub(5, 6), 16)
		if r and g and b then
			return r / 255, g / 255, b / 255
		end
	end
	return nil
end

local function ApplyDarkGradient(inst, colorTop, colorBot)
	inst.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, colorTop),
		ColorSequenceKeypoint.new(1, colorBot)
	}
	grad.Rotation = 90
	grad.Parent = inst
end

local function CreateGlow(parent, sizeInflate, startTransparency)
	startTransparency = startTransparency ~= nil and startTransparency or 0.9
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.BackgroundTransparency = 1
	glow.Image = GLOW_ASSET
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = GLOW_SLICE
	glow.ImageTransparency = startTransparency
	glow.BorderSizePixel = 0
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow.Size = UDim2.new(1, sizeInflate, 1, sizeInflate)
	glow.ZIndex = math.max(0, parent.ZIndex - 1)
	parent.ZIndex = math.max(1, parent.ZIndex)
	glow.Parent = parent
	return glow
end

local function Tween(instance, properties, duration)
	duration = duration or 0.3
	local tween = TS:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

function MaQueen:CreateWindow(options)
	local titleText = options.Title or "MaQueen |"
	local titleIconId = options.Icon or "rbxassetid://87383751970642"

	local window = {
		Gui = nil,
		Tabs = {},
		ThemeColor = options.ThemeColor or Color3.fromRGB(255, 65, 65),
		ThemeCallbacks = {}
	}

	function window:AddThemeCallback(cb)
		table.insert(self.ThemeCallbacks, cb)
		cb(self.ThemeColor)
	end

	function window:SetThemeColor(color)
		self.ThemeColor = color
		for _, cb in ipairs(self.ThemeCallbacks) do
			pcall(cb, color)
		end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "MaQueenUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	window.Gui = gui
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 500, 0, 600)
	main.Position = UDim2.new(0.5, -250, 0.5, -300)
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui
	ApplyDarkGradient(main, Color3.fromRGB(26, 26, 26), Color3.fromRGB(14, 14, 14))

	local bgImage = Instance.new("ImageLabel")
	bgImage.Size = UDim2.new(1, 0, 1, 0)
	bgImage.Position = UDim2.new(0, 0, 0, 0)
	bgImage.BackgroundTransparency = 1
	bgImage.Image = BG_ASSET
	bgImage.ImageTransparency = 0.8
	bgImage.ScaleType = Enum.ScaleType.Crop
	bgImage.ZIndex = 0
	bgImage.Parent = main

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 0
	uiScale.Parent = main
	TS:Create(uiScale, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 1}):Play()

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(75, 75, 75)
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.LineJoinMode = Enum.LineJoinMode.Miter
	mainStroke.Thickness = 1
	mainStroke.Parent = main

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 35)
	topBar.BackgroundTransparency = 1
	topBar.ZIndex = 2
	topBar.Parent = main

	local titleIcon = Instance.new("ImageLabel")
	titleIcon.Size = UDim2.new(0, 16, 0, 16)
	titleIcon.Position = UDim2.new(0, 14, 0.5, 0)
	titleIcon.AnchorPoint = Vector2.new(0, 0.5)
	titleIcon.BackgroundTransparency = 1
	titleIcon.Image = titleIconId
	titleIcon.Parent = topBar

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(0, 0, 1, 0)
	titleLbl.Position = UDim2.new(0, 36, 0, 0)
	titleLbl.AutomaticSize = Enum.AutomaticSize.X
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = titleText
	titleLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
	titleLbl.Font = Enum.Font.Code
	titleLbl.TextSize = 13
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = topBar

	local tabContainer = Instance.new("ScrollingFrame")
	tabContainer.Size = UDim2.new(1, -220, 1, 0)
	tabContainer.Position = UDim2.new(0, 130, 0, 0)
	tabContainer.BackgroundTransparency = 1
	tabContainer.ScrollBarThickness = 0
	tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabContainer.ScrollingDirection = Enum.ScrollingDirection.X
	tabContainer.ClipsDescendants = true
	tabContainer.Parent = topBar

	tabContainer.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local scrollAmount = input.Position.Z * 40
			local maxScroll = math.max(0, tabContainer.AbsoluteCanvasSize.X - tabContainer.AbsoluteSize.X)
			tabContainer.CanvasPosition = Vector2.new(math.clamp(tabContainer.CanvasPosition.X - scrollAmount, 0, maxScroll), 0)
		end
	end)

	local tabInner = Instance.new("Frame")
	tabInner.Size = UDim2.new(0, 0, 1, 0)
	tabInner.AutomaticSize = Enum.AutomaticSize.X
	tabInner.BackgroundTransparency = 1
	tabInner.Parent = tabContainer

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 14)
	tabLayout.Parent = tabInner

	local activeLine = Instance.new("Frame")
	activeLine.Size = UDim2.new(0, 0, 0, 2)
	activeLine.Position = UDim2.new(0, 0, 1, -2)
	activeLine.BorderSizePixel = 0
	activeLine.ZIndex = 3
	activeLine.Parent = tabContainer

	local activeGlow = CreateGlow(activeLine, 40, 0.9)

	window:AddThemeCallback(function(c)
		activeLine.BackgroundColor3 = c
		activeGlow.ImageColor3 = c
	end)

	local pAvatar = Instance.new("ImageLabel")
	pAvatar.Size = UDim2.new(0, 20, 0, 20)
	pAvatar.Position = UDim2.new(1, -52, 0.5, 0)
	pAvatar.AnchorPoint = Vector2.new(0, 0.5)
	pAvatar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	pAvatar.BorderSizePixel = 0
	pAvatar.Parent = topBar

	task.spawn(function()
		pcall(function()
			local thumb = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			if thumb then pAvatar.Image = thumb end
		end)
	end)

	local settingsIcon = Instance.new("ImageLabel")
	settingsIcon.Size = UDim2.new(0, 16, 0, 16)
	settingsIcon.Position = UDim2.new(1, -25, 0.5, 0)
	settingsIcon.AnchorPoint = Vector2.new(0, 0.5)
	settingsIcon.BackgroundTransparency = 1
	settingsIcon.Image = "rbxassetid://94990717221785"
	settingsIcon.ImageColor3 = Color3.fromRGB(120, 120, 120)
	settingsIcon.Parent = topBar

	local topDivider = Instance.new("Frame")
	topDivider.Size = UDim2.new(1, 0, 0, 1)
	topDivider.Position = UDim2.new(0, 0, 1, 0)
	topDivider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	topDivider.BorderSizePixel = 0
	topDivider.Parent = topBar

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, -36)
	content.Position = UDim2.new(0, 0, 0, 36)
	content.BackgroundTransparency = 1
	content.ZIndex = 2
	content.Parent = main

	local function makeDraggable(top, frame)
		local dragging, dragInput, dragStart, startPos
		top.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		top.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
		end)
		UIS.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end
	makeDraggable(topBar, main)

	local firstTab = true

	function window:CreateTab(name)
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(0, 0, 1, 0)
		tabBtn.AutomaticSize = Enum.AutomaticSize.X
		tabBtn.BackgroundTransparency = 1
		tabBtn.Text = name
		tabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
		tabBtn.Font = Enum.Font.Code
		tabBtn.TextSize = 13
		tabBtn.Parent = tabInner

		local tabFrame = Instance.new("ScrollingFrame")
		tabFrame.Size = UDim2.new(1, 0, 1, 0)
		tabFrame.Position = UDim2.new(0, 0, 0, 0)
		tabFrame.BackgroundTransparency = 1
		tabFrame.ScrollBarThickness = 0
		tabFrame.BorderSizePixel = 0
		tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabFrame.Visible = false
		tabFrame.Parent = content

		local tPadding = Instance.new("UIPadding")
		tPadding.PaddingBottom = UDim.new(0, 14)
		tPadding.Parent = tabFrame

		local leftCol = Instance.new("Frame")
		leftCol.Size = UDim2.new(0.5, -21, 0, 0)
		leftCol.Position = UDim2.new(0, 14, 0, 14)
		leftCol.AutomaticSize = Enum.AutomaticSize.Y
		leftCol.BackgroundTransparency = 1
		leftCol.Parent = tabFrame

		local rightCol = Instance.new("Frame")
		rightCol.Size = UDim2.new(0.5, -21, 0, 0)
		rightCol.Position = UDim2.new(0.5, 7, 0, 14)
		rightCol.AutomaticSize = Enum.AutomaticSize.Y
		rightCol.BackgroundTransparency = 1
		rightCol.Parent = tabFrame

		local lLayout = Instance.new("UIListLayout", leftCol)
		lLayout.SortOrder = Enum.SortOrder.LayoutOrder
		lLayout.Padding = UDim.new(0, 12)

		local rLayout = Instance.new("UIListLayout", rightCol)
		rLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rLayout.Padding = UDim.new(0, 12)

		if firstTab then
			tabFrame.Visible = true
			tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			task.spawn(function()
				task.wait()
				activeLine.Size = UDim2.new(0, tabBtn.AbsoluteSize.X, 0, 2)
				activeLine.Position = UDim2.new(0, tabBtn.AbsolutePosition.X - tabInner.AbsolutePosition.X, 1, -2)
			end)
			firstTab = false
		end

		tabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(window.Tabs) do
				t.Frame.Visible = false
				Tween(t.Btn, {TextColor3 = Color3.fromRGB(140, 140, 140)}, 0.2)
			end
			tabFrame.Visible = true
			Tween(tabBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
			Tween(activeLine, {
				Size = UDim2.new(0, tabBtn.AbsoluteSize.X, 0, 2),
				Position = UDim2.new(0, tabBtn.AbsolutePosition.X - tabInner.AbsolutePosition.X, 1, -2)
			}, 0.3)
		end)

		local tabObj = { Frame = tabFrame, Btn = tabBtn }
		table.insert(window.Tabs, tabObj)

		function tabObj:CreateGroupBox(gbName, side)
			side = side or "Left"
			local parentCol = (side == "Left") and leftCol or rightCol

			local groupbox = Instance.new("Frame")
			groupbox.Size = UDim2.new(1, -4, 0, 0)
			groupbox.AutomaticSize = Enum.AutomaticSize.Y
			groupbox.BorderSizePixel = 0
			groupbox.ZIndex = 2
			groupbox.Parent = parentCol
			ApplyDarkGradient(groupbox, Color3.fromRGB(30, 30, 30), Color3.fromRGB(18, 18, 18))

			local shadowOffset = Instance.new("Frame")
			shadowOffset.Name = "DropShadow"
			shadowOffset.Size = UDim2.new(1, 0, 1, 0)
			shadowOffset.Position = UDim2.new(0, 4, 0, 4) 
			shadowOffset.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
			shadowOffset.BackgroundTransparency = 0.4
			shadowOffset.BorderSizePixel = 0
			shadowOffset.ZIndex = 1
			shadowOffset.Parent = groupbox

			local gbStroke = Instance.new("UIStroke")
			gbStroke.Color = Color3.fromRGB(50, 50, 55)
			gbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			gbStroke.LineJoinMode = Enum.LineJoinMode.Miter
			gbStroke.Parent = groupbox

			local gbTitle = Instance.new("TextLabel")
			gbTitle.Size = UDim2.new(0, 0, 0, 14)
			gbTitle.AutomaticSize = Enum.AutomaticSize.X
			gbTitle.Position = UDim2.new(0, 12, 0, 0)
			gbTitle.AnchorPoint = Vector2.new(0, 0.5)
			gbTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			gbTitle.BorderSizePixel = 0
			gbTitle.Text = " " .. tostring(gbName or "Group") .. " "
			gbTitle.TextColor3 = Color3.fromRGB(160, 160, 160)
			gbTitle.Font = Enum.Font.Code
			gbTitle.TextSize = 12
			gbTitle.ZIndex = 3
			gbTitle.Parent = groupbox

			local itemContainer = Instance.new("Frame")
			itemContainer.Size = UDim2.new(1, 0, 0, 0)
			itemContainer.Position = UDim2.new(0, 0, 0, 14)
			itemContainer.AutomaticSize = Enum.AutomaticSize.Y
			itemContainer.BackgroundTransparency = 1
			itemContainer.ZIndex = 2
			itemContainer.Parent = groupbox

			local iPadding = Instance.new("UIPadding")
			iPadding.PaddingLeft = UDim.new(0, 12)
			iPadding.PaddingRight = UDim.new(0, 12)
			iPadding.PaddingBottom = UDim.new(0, 12)
			iPadding.Parent = itemContainer

			local iLayout = Instance.new("UIListLayout", itemContainer)
			iLayout.SortOrder = Enum.SortOrder.LayoutOrder
			iLayout.Padding = UDim.new(0, 10)

			local gbHandle = {}

			function gbHandle:CreateContainer(height)
				local container = Instance.new("Frame")
				container.Size = UDim2.new(1, 0, 0, tonumber(height) or 100)
				container.BackgroundTransparency = 1
				container.ZIndex = 3
				container.Parent = itemContainer
				return container
			end

			function gbHandle:CreateLabel(text)
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, 0, 0, 16)
				lbl.BackgroundTransparency = 1
				lbl.Text = tostring(text or "Label")
				lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
				lbl.Font = Enum.Font.Code
				lbl.TextSize = 12
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 3
				lbl.Parent = itemContainer
			end

			function gbHandle:CreateButton(text, iconId, callback)
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 24)
				btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				btn.BorderSizePixel = 0
				btn.Text = tostring(text or "Button")
				btn.TextColor3 = Color3.fromRGB(220, 220, 220)
				btn.Font = Enum.Font.Code
				btn.TextSize = 12
				btn.ZIndex = 3
				btn.Parent = itemContainer

				local stroke = Instance.new("UIStroke", btn)
				stroke.Color = Color3.fromRGB(50, 50, 50)
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				stroke.LineJoinMode = Enum.LineJoinMode.Miter

				local btnGlow = CreateGlow(btn, 36, 1)

				window:AddThemeCallback(function(c)
					btnGlow.ImageColor3 = c
				end)

				if iconId then
					local icon = Instance.new("ImageLabel", btn)
					icon.Size = UDim2.new(0, 16, 0, 16)
					icon.Position = UDim2.new(0, 6, 0.5, 0)
					icon.AnchorPoint = Vector2.new(0, 0.5)
					icon.BackgroundTransparency = 1
					icon.Image = iconId
					icon.ZIndex = 4
				end

				btn.MouseEnter:Connect(function()
					Tween(btnGlow, {ImageTransparency = 0.8}, 0.2)
					Tween(stroke, {Color = window.ThemeColor}, 0.2)
					Tween(btn, {BackgroundColor3 = Color3.fromRGB(34, 34, 34)}, 0.2)
				end)
				btn.MouseLeave:Connect(function()
					Tween(btnGlow, {ImageTransparency = 1}, 0.2)
					Tween(stroke, {Color = Color3.fromRGB(50, 50, 50)}, 0.2)
					Tween(btn, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}, 0.2)
				end)

				btn.MouseButton1Click:Connect(function()
					if callback then callback() end
				end)
			end

			function gbHandle:CreateToggle(tName, callback)
				local tContainer = Instance.new("TextButton")
				tContainer.Size = UDim2.new(1, 0, 0, 16)
				tContainer.BackgroundTransparency = 1
				tContainer.Text = ""
				tContainer.ZIndex = 2
				tContainer.Parent = itemContainer

				local state = false

				local box = Instance.new("Frame")
				box.Size = UDim2.new(0, 14, 0, 14)
				box.Position = UDim2.new(0, 0, 0.5, 0)
				box.AnchorPoint = Vector2.new(0, 0.5)
				box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				box.BorderSizePixel = 0
				box.ZIndex = 3
				box.Parent = tContainer

				local stroke = Instance.new("UIStroke", box)
				stroke.Color = Color3.fromRGB(55, 55, 55)
				stroke.LineJoinMode = Enum.LineJoinMode.Miter

				local innerBox = Instance.new("Frame")
				innerBox.Size = UDim2.new(1, -6, 1, -6)
				innerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
				innerBox.AnchorPoint = Vector2.new(0.5, 0.5)
				innerBox.BackgroundColor3 = window.ThemeColor
				innerBox.BackgroundTransparency = 1
				innerBox.BorderSizePixel = 0
				innerBox.ZIndex = 4
				innerBox.Parent = box

				local toggleGlow = CreateGlow(innerBox, 28, 1)

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -24, 1, 0)
				lbl.Position = UDim2.new(0, 24, 0, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = tostring(tName or "Toggle")
				lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
				lbl.Font = Enum.Font.Code
				lbl.TextSize = 12
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 3
				lbl.Parent = tContainer

				window:AddThemeCallback(function(c)
					innerBox.BackgroundColor3 = c
					toggleGlow.ImageColor3 = c
					if state then stroke.Color = c end
				end)

				tContainer.MouseButton1Click:Connect(function()
					state = not state
					if state then
						Tween(innerBox, {BackgroundTransparency = 0}, 0.2)
						Tween(stroke, {Color = window.ThemeColor}, 0.2)
						Tween(toggleGlow, {ImageTransparency = 0.7}, 0.2)
						Tween(lbl, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
					else
						Tween(innerBox, {BackgroundTransparency = 1}, 0.2)
						Tween(stroke, {Color = Color3.fromRGB(55, 55, 55)}, 0.2)
						Tween(toggleGlow, {ImageTransparency = 1}, 0.2)
						Tween(lbl, {TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
					end
					if callback then callback(state) end
				end)
			end

			function gbHandle:CreateSlider(sName, min, max, default, callback)
				local sContainer = Instance.new("Frame")
				sContainer.Size = UDim2.new(1, 0, 0, 32)
				sContainer.BackgroundTransparency = 1
				sContainer.ZIndex = 2
				sContainer.Parent = itemContainer

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -30, 0, 14)
				lbl.BackgroundTransparency = 1
				lbl.Text = tostring(sName or "Slider") .. ":"
				lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
				lbl.Font = Enum.Font.Code
				lbl.TextSize = 12
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 3
				lbl.Parent = sContainer

				local valBox = Instance.new("TextBox")
				valBox.Size = UDim2.new(0, 30, 0, 14)
				valBox.Position = UDim2.new(1, -30, 0, 0)
				valBox.BackgroundTransparency = 1
				valBox.Text = tostring(default)
				valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				valBox.Font = Enum.Font.Code
				valBox.TextSize = 12
				valBox.TextXAlignment = Enum.TextXAlignment.Right
				valBox.ZIndex = 3
				valBox.Parent = sContainer

				local track = Instance.new("TextButton")
				track.Size = UDim2.new(1, -6, 0, 4)
				track.Position = UDim2.new(0, 3, 1, -8)
				track.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				track.BorderSizePixel = 0
				track.Text = ""
				track.AutoButtonColor = false
				track.ZIndex = 3
				track.Parent = sContainer

				local trackStroke = Instance.new("UIStroke", track)
				trackStroke.Color = Color3.fromRGB(45, 45, 45)
				trackStroke.LineJoinMode = Enum.LineJoinMode.Miter

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BorderSizePixel = 0
				fill.ZIndex = 3
				fill.Parent = track

				local thumb = Instance.new("Frame")
				thumb.Size = UDim2.new(0, 4, 0, 14)
				thumb.AnchorPoint = Vector2.new(0.5, 0.5)
				thumb.Position = UDim2.new(1, 0, 0.5, 0)
				thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				thumb.BorderSizePixel = 0
				thumb.ZIndex = 5
				thumb.Parent = fill

				local thumbGlow = CreateGlow(thumb, 24, 0.5)

				window:AddThemeCallback(function(c)
					fill.BackgroundColor3 = c
					thumbGlow.ImageColor3 = c
					thumb.BackgroundColor3 = c
				end)

				local sliding = false
				local function updateSlider(input)
					local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local val = math.floor(min + ((max - min) * percent))
					valBox.Text = tostring(val)
					Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
					if callback then callback(val) end
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = true
						updateSlider(input)
						Tween(thumbGlow, {ImageTransparency = 0.2}, 0.2)
					end
				end)
				UIS.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = false
						Tween(thumbGlow, {ImageTransparency = 0.5}, 0.2)
					end
				end)
				UIS.InputChanged:Connect(function(input)
					if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateSlider(input)
					end
				end)

				valBox.FocusLost:Connect(function()
					local num = tonumber(valBox.Text)
					if num then
						num = math.clamp(num, min, max)
						valBox.Text = tostring(num)
						Tween(fill, {Size = UDim2.new((num - min) / (max - min), 0, 1, 0)}, 0.2)
						if callback then callback(num) end
					else
						valBox.Text = tostring(default)
					end
				end)
			end

			function gbHandle:CreateDropdown(dName, options, default, callback)
				local dropContainer = Instance.new("Frame")
				dropContainer.Size = UDim2.new(1, 0, 0, 42)
				dropContainer.BackgroundTransparency = 1
				dropContainer.ZIndex = 2
				dropContainer.Parent = itemContainer

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, 0, 0, 14)
				lbl.BackgroundTransparency = 1
				lbl.Text = tostring(dName or "Dropdown")
				lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
				lbl.Font = Enum.Font.Code
				lbl.TextSize = 12
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 3
				lbl.Parent = dropContainer

				local mainBtn = Instance.new("TextButton")
				mainBtn.Size = UDim2.new(1, 0, 0, 20)
				mainBtn.Position = UDim2.new(0, 0, 0, 18)
				mainBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				mainBtn.BorderSizePixel = 0
				mainBtn.Text = "  " .. tostring(default)
				mainBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
				mainBtn.Font = Enum.Font.Code
				mainBtn.TextSize = 12
				mainBtn.TextXAlignment = Enum.TextXAlignment.Left
				mainBtn.ZIndex = 3
				mainBtn.Parent = dropContainer
				local btnStroke = Instance.new("UIStroke")
				btnStroke.Color = Color3.fromRGB(50, 50, 50)
				btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				btnStroke.LineJoinMode = Enum.LineJoinMode.Miter
				btnStroke.Parent = mainBtn

				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.new(0, 20, 1, 0)
				arrow.Position = UDim2.new(1, -20, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Text = "▼"
				arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
				arrow.TextSize = 10
				arrow.ZIndex = 4
				arrow.Parent = mainBtn

				local searchBox = Instance.new("TextBox")
				searchBox.Size = UDim2.new(1, 0, 0, 22)
				searchBox.Position = UDim2.new(0, 0, 0, 42)
				searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				searchBox.BorderSizePixel = 0
				searchBox.Text = ""
				searchBox.PlaceholderText = " Search..."
				searchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
				searchBox.TextXAlignment = Enum.TextXAlignment.Left
				searchBox.Font = Enum.Font.Code
				searchBox.TextSize = 12
				searchBox.ZIndex = 5
				searchBox.Visible = false
				searchBox.Parent = dropContainer
				local sbStroke = Instance.new("UIStroke")
				sbStroke.Color = Color3.fromRGB(50, 50, 50)
				sbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				sbStroke.LineJoinMode = Enum.LineJoinMode.Miter
				sbStroke.Parent = searchBox

				local dropList = Instance.new("ScrollingFrame")
				dropList.Size = UDim2.new(1, 0, 0, 0)
				dropList.Position = UDim2.new(0, 0, 0, 68)
				dropList.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				dropList.BorderSizePixel = 0
				dropList.ClipsDescendants = true
				dropList.ScrollBarThickness = 2
				dropList.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
				dropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
				dropList.CanvasSize = UDim2.new(0, 0, 0, 0)
				dropList.ZIndex = 5
				dropList.Parent = dropContainer

				local listStroke = Instance.new("UIStroke")
				listStroke.Color = Color3.fromRGB(50, 50, 50)
				listStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				listStroke.LineJoinMode = Enum.LineJoinMode.Miter
				listStroke.Transparency = 1
				listStroke.Parent = dropList

				local listLayout = Instance.new("UIListLayout")
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder
				listLayout.Parent = dropList

				local isOpen = false
				local optionBtns = {}

				local function updateListHeight()
					local visibleCount = 0
					for _, o in ipairs(optionBtns) do
						if o.btn.Visible then visibleCount = visibleCount + 1 end
					end
					local listHeight = math.clamp(visibleCount * 20, 0, 140)
					Tween(dropContainer, {Size = UDim2.new(1, 0, 0, 68 + listHeight)}, 0.2)
					Tween(dropList, {Size = UDim2.new(1, 0, 0, listHeight)}, 0.2)
				end

				for i, opt in pairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 20)
					optBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					optBtn.BorderSizePixel = 0
					optBtn.Text = "  " .. tostring(opt)
					optBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
					optBtn.Font = Enum.Font.Code
					optBtn.TextSize = 12
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.ZIndex = 6
					optBtn.Parent = dropList

					table.insert(optionBtns, {btn = optBtn, text = string.lower(tostring(opt))})

					optBtn.MouseEnter:Connect(function() Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.1) end)
					optBtn.MouseLeave:Connect(function() Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}, 0.1) end)

					optBtn.MouseButton1Click:Connect(function()
						isOpen = false
						mainBtn.Text = "  " .. tostring(opt)
						Tween(arrow, {Rotation = 0}, 0.2)
						Tween(dropContainer, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
						Tween(dropList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
						Tween(listStroke, {Transparency = 1}, 0.2)
						task.delay(0.2, function()
							if not isOpen then searchBox.Visible = false end
						end)
						if callback then callback(opt) end
					end)
				end

				searchBox:GetPropertyChangedSignal("Text"):Connect(function()
					local term = string.lower(searchBox.Text)
					for _, o in ipairs(optionBtns) do
						if term == "" or string.find(o.text, term) then
							o.btn.Visible = true
						else
							o.btn.Visible = false
						end
					end
					if isOpen then updateListHeight() end
				end)

				mainBtn.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					if isOpen then
						searchBox.Text = ""
						for _, o in ipairs(optionBtns) do o.btn.Visible = true end
						searchBox.Visible = true
						Tween(arrow, {Rotation = 180}, 0.2)
						updateListHeight()
						Tween(listStroke, {Transparency = 0}, 0.2)
					else
						Tween(arrow, {Rotation = 0}, 0.2)
						Tween(dropContainer, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
						Tween(dropList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
						Tween(listStroke, {Transparency = 1}, 0.2)
						task.delay(0.2, function()
							if not isOpen then searchBox.Visible = false end
						end)
					end
				end)
			end

			function gbHandle:CreateColorPicker(cName, defaultColor, callback)
				local cContainer = Instance.new("Frame")
				cContainer.Size = UDim2.new(1, 0, 0, 20)
				cContainer.BackgroundTransparency = 1
				cContainer.ClipsDescendants = true
				cContainer.ZIndex = 2
				cContainer.Parent = itemContainer

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -30, 0, 20)
				lbl.BackgroundTransparency = 1
				lbl.Text = tostring(cName or "Color Picker")
				lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
				lbl.Font = Enum.Font.Code
				lbl.TextSize = 12
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 3
				lbl.Parent = cContainer

				local colorBtn = Instance.new("TextButton")
				colorBtn.Size = UDim2.new(0, 30, 0, 14)
				colorBtn.Position = UDim2.new(1, -30, 0, 3)
				colorBtn.BackgroundColor3 = defaultColor or Color3.new(1, 1, 1)
				colorBtn.Text = ""
				colorBtn.ZIndex = 3
				colorBtn.Parent = cContainer
				local stroke = Instance.new("UIStroke", colorBtn)
				stroke.Color = Color3.fromRGB(60, 60, 60)
				stroke.LineJoinMode = Enum.LineJoinMode.Miter

				local cGlow = CreateGlow(colorBtn, 36, 0.9)
				cGlow.ImageColor3 = colorBtn.BackgroundColor3

				local expanded = Instance.new("Frame")
				expanded.Size = UDim2.new(1, 0, 0, 130)
				expanded.Position = UDim2.new(0, 0, 0, 26)
				expanded.BackgroundTransparency = 1
				expanded.ZIndex = 3
				expanded.Parent = cContainer

				local wheelContainer = Instance.new("Frame")
				wheelContainer.Size = UDim2.new(0, 100, 0, 100)
				wheelContainer.Position = UDim2.new(0, 0, 0, 0)
				wheelContainer.BackgroundTransparency = 1
				wheelContainer.ZIndex = 4
				wheelContainer.Parent = expanded

				local wheelImage = Instance.new("ImageLabel")
				wheelImage.Size = UDim2.new(1, 0, 1, 0)
				wheelImage.BackgroundTransparency = 1
				wheelImage.Image = "rbxassetid://135475444821120"
				wheelImage.ZIndex = 4
				wheelImage.Parent = wheelContainer

				local cursor = Instance.new("Frame")
				cursor.Size = UDim2.new(0, 8, 0, 8)
				cursor.AnchorPoint = Vector2.new(0.5, 0.5)
				cursor.BackgroundColor3 = Color3.new(1, 1, 1)
				cursor.ZIndex = 5
				cursor.Parent = wheelImage
				local cursorStroke = Instance.new("UIStroke")
				cursorStroke.LineJoinMode = Enum.LineJoinMode.Miter
				cursorStroke.Parent = cursor

				local sliderContainer = Instance.new("Frame")
				sliderContainer.Size = UDim2.new(0, 100, 0, 10)
				sliderContainer.Position = UDim2.new(0, 0, 0, 110)
				sliderContainer.BackgroundColor3 = Color3.new(1, 1, 1)
				sliderContainer.BorderSizePixel = 0
				sliderContainer.ZIndex = 4
				sliderContainer.Parent = expanded
				local sStroke = Instance.new("UIStroke")
				sStroke.Color = Color3.fromRGB(45, 45, 45)
				sStroke.LineJoinMode = Enum.LineJoinMode.Miter
				sStroke.Parent = sliderContainer
				local sliderGradient = Instance.new("UIGradient")
				sliderGradient.Parent = sliderContainer

				local sliderThumb = Instance.new("Frame")
				sliderThumb.Size = UDim2.new(0, 4, 1, 4)
				sliderThumb.Position = UDim2.new(1, 0, 0.5, 0)
				sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
				sliderThumb.BackgroundColor3 = Color3.new(1, 1, 1)
				sliderThumb.BorderSizePixel = 0
				sliderThumb.ZIndex = 5
				sliderThumb.Parent = sliderContainer
				local thStroke = Instance.new("UIStroke")
				thStroke.LineJoinMode = Enum.LineJoinMode.Miter
				thStroke.Parent = sliderThumb

				local rightPanel = Instance.new("Frame")
				rightPanel.Size = UDim2.new(1, -110, 0, 130)
				rightPanel.Position = UDim2.new(0, 110, 0, 0)
				rightPanel.BackgroundTransparency = 1
				rightPanel.ZIndex = 4
				rightPanel.Parent = expanded

				local function createCPInput(px, py, lblW, boxW, text)
					local lblI = Instance.new("TextLabel")
					lblI.Size = UDim2.new(0, lblW, 0, 18)
					lblI.Position = UDim2.new(0, px, 0, py)
					lblI.BackgroundTransparency = 1
					lblI.Text = text
					lblI.Font = Enum.Font.Code
					lblI.TextSize = 12
					lblI.TextColor3 = Color3.fromRGB(160, 160, 160)
					lblI.TextXAlignment = Enum.TextXAlignment.Right
					lblI.ZIndex = 5
					lblI.Parent = rightPanel

					local box = Instance.new("TextBox")
					box.Size = UDim2.new(0, boxW, 0, 18)
					box.Position = UDim2.new(0, px + lblW + 2, 0, py)
					box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
					box.BorderSizePixel = 0
					box.Text = "0"
					box.Font = Enum.Font.Code
					box.TextSize = 12
					box.TextColor3 = Color3.fromRGB(255, 255, 255)
					box.ZIndex = 5
					box.Parent = rightPanel
					local bStroke = Instance.new("UIStroke")
					bStroke.Color = Color3.fromRGB(50, 50, 50)
					bStroke.LineJoinMode = Enum.LineJoinMode.Miter
					bStroke.Parent = box
					return box
				end

				local boxR = createCPInput(0, 0, 14, 28, "R:")
				local boxG = createCPInput(0, 24, 14, 28, "G:")
				local boxB = createCPInput(0, 48, 14, 28, "B:")
				local boxH = createCPInput(48, 0, 14, 28, "H:")
				local boxS = createCPInput(48, 24, 14, 28, "S:")
				local boxV = createCPInput(48, 48, 14, 28, "V:")
				local boxHex = createCPInput(0, 72, 26, 64, "Hex:")

				local currentColor = defaultColor or Color3.new(1, 1, 1)
				local currentH, currentS, currentV = rgbToHsv(currentColor.R, currentColor.G, currentColor.B)
				local isUpdatingCP = false

				local function updateCP()
					if isUpdatingCP then return end
					isUpdatingCP = true

					local r, g, b = hsvToRgb(currentH, currentS, currentV)
					currentColor = Color3.new(r, g, b)

					cursor.Position = UDim2.new(0.5 + math.cos(currentH * math.pi * 2) * (currentS * 0.5), 0, 0.5 + math.sin(currentH * math.pi * 2) * (currentS * 0.5), 0)

					local pureR, pureG, pureB = hsvToRgb(currentH, currentS, 1)
					sliderGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
						ColorSequenceKeypoint.new(1, Color3.new(pureR, pureG, pureB))
					})

					sliderThumb.Position = UDim2.new(currentV, 0, 0.5, 0)

					TS:Create(colorBtn, TweenInfo.new(0.2), {BackgroundColor3 = currentColor}):Play()
					TS:Create(cGlow, TweenInfo.new(0.2), {ImageColor3 = currentColor}):Play()

					boxH.Text = tostring(math.round(currentH * 360))
					boxS.Text = tostring(math.round(currentS * 100))
					boxV.Text = tostring(math.round(currentV * 100))
					boxR.Text = tostring(math.round(r * 255))
					boxG.Text = tostring(math.round(g * 255))
					boxB.Text = tostring(math.round(b * 255))
					boxHex.Text = toHex(r, g, b)

					if callback then callback(currentColor) end
					isUpdatingCP = false
				end

				updateCP()

				local isDraggingWheel, isDraggingCSlider = false, false

				local function setHSFromMouse(pos)
					local center = wheelImage.AbsolutePosition + wheelImage.AbsoluteSize / 2
					local dx = pos.X - center.X
					local dy = pos.Y - center.Y
					local angle = math.atan2(dy, dx)
					local radius = wheelImage.AbsoluteSize.X / 2
					local dist = math.min(math.sqrt(dx*dx + dy*dy), radius)
					currentH = (angle / (math.pi * 2)) % 1
					if currentH < 0 then currentH = currentH + 1 end
					currentS = dist / radius
					updateCP()
				end

				local function setVFromMouse(pos)
					local minX = sliderContainer.AbsolutePosition.X
					local maxX = minX + sliderContainer.AbsoluteSize.X
					currentV = math.clamp((pos.X - minX) / (maxX - minX), 0, 1)
					updateCP()
				end

				wheelImage.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						isDraggingWheel = true
						setHSFromMouse(input.Position)
					end
				end)

				sliderContainer.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						isDraggingCSlider = true
						setVFromMouse(input.Position)
					end
				end)

				UIS.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						if isDraggingWheel then setHSFromMouse(input.Position)
						elseif isDraggingCSlider then setVFromMouse(input.Position)
						end
					end
				end)

				UIS.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						isDraggingWheel = false
						isDraggingCSlider = false
					end
				end)

				local function applyHSV()
					local h, s, v = tonumber(boxH.Text) or 0, tonumber(boxS.Text) or 0, tonumber(boxV.Text) or 0
					currentH = math.clamp(h, 0, 360) / 360
					currentS = math.clamp(s, 0, 100) / 100
					currentV = math.clamp(v, 0, 100) / 100
					updateCP()
				end

				local function applyRGB()
					local r, g, b = tonumber(boxR.Text) or 0, tonumber(boxG.Text) or 0, tonumber(boxB.Text) or 0
					currentH, currentS, currentV = rgbToHsv(math.clamp(r, 0, 255) / 255, math.clamp(g, 0, 255) / 255, math.clamp(b, 0, 255) / 255)
					updateCP()
				end

				local function applyHex()
					local r, g, b = fromHex(boxHex.Text)
					if r and g and b then
						currentH, currentS, currentV = rgbToHsv(r, g, b)
						updateCP()
					end
				end

				boxH.FocusLost:Connect(applyHSV)
				boxS.FocusLost:Connect(applyHSV)
				boxV.FocusLost:Connect(applyHSV)
				boxR.FocusLost:Connect(applyRGB)
				boxG.FocusLost:Connect(applyRGB)
				boxB.FocusLost:Connect(applyRGB)
				boxHex.FocusLost:Connect(applyHex)

				local isOpen = false
				colorBtn.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					Tween(cContainer, {Size = UDim2.new(1, 0, 0, isOpen and 156 or 20)}, 0.3)
				end)
			end

			return gbHandle
		end
		return tabObj
	end
	return window
end

return MaQueen
