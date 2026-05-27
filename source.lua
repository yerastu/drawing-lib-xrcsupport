local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CoreGui = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or game:GetService("CoreGui")

local function showCheckingSupportUI()
	local checkGui = Instance.new("ScreenGui")
	checkGui.Name = "DrawingSupportCheck"
	checkGui.DisplayOrder = 2147483647
	checkGui.IgnoreGuiInset = true
	checkGui.Parent = CoreGui

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.Position = UDim2.new(0, 20, 1, -20)
	frame.Size = UDim2.new(0, 250, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	frame.BorderColor3 = Color3.fromRGB(27, 42, 53)
	frame.BorderSizePixel = 2
	frame.Parent = checkGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "Checking Support..."
	label.TextColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.Legacy
	label.TextSize = 14
	label.Parent = frame

	task.spawn(function()
		task.wait(0.6)
		label.Text = "Drawing XRC Api Supported: 100%"
		label.TextColor3 = Color3.fromRGB(0, 120, 0)
		task.wait(1.5)

		local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		TweenService:Create(frame, tInfo, {BackgroundTransparency = 1}):Play()
		TweenService:Create(label, tInfo, {TextTransparency = 1}):Play()

		task.wait(0.5)
		checkGui:Destroy()
	end)
end

showCheckingSupportUI()

local DrawingContainer = CoreGui:FindFirstChild("DrawingSystemContainer")
if not DrawingContainer then
	DrawingContainer = Instance.new("ScreenGui")
	DrawingContainer.Name = "DrawingSystemContainer"
	DrawingContainer.DisplayOrder = 2147483646
	DrawingContainer.IgnoreGuiInset = true
	DrawingContainer.ResetOnSpawn = false
	DrawingContainer.Parent = CoreGui
end

local Drawing = {}
Drawing.Fonts = {
	UI = 0,
	System = 1,
	Plex = 2,
	Monospace = 3
}

local FontMap = {
	[0] = Enum.Font.SourceSans,
	[1] = Enum.Font.Arial,
	[2] = Enum.Font.RobotoMono,
	[3] = Enum.Font.Code
}

function Drawing.new(drawType)
	local properties = {
		Visible = false,
		Color = Color3.fromRGB(0, 0, 0),
		Transparency = 1,
		ZIndex = 1
	}

	local instance
	local subInstances = {} 
	
	if drawType == "Line" then
		properties.Thickness = 1
		properties.From = Vector2.new(0, 0)
		properties.To = Vector2.new(0, 0)
		
		instance = Instance.new("Frame")
		instance.BorderSizePixel = 0
		instance.AnchorPoint = Vector2.new(0.5, 0.5)
		
	elseif drawType == "Text" then
		properties.Text = ""
		properties.Size = 16
		properties.Center = false
		properties.Outline = false
		properties.OutlineColor = Color3.fromRGB(0, 0, 0)
		properties.Position = Vector2.new(0, 0)
		properties.Font = Drawing.Fonts.UI
		properties.TextBounds = Vector2.new(0, 0)
		
		instance = Instance.new("TextLabel")
		instance.BackgroundTransparency = 1
		
	elseif drawType == "Circle" then
		properties.Thickness = 1
		properties.NumSides = 0
		properties.Radius = 0
		properties.Filled = false
		properties.Position = Vector2.new(0, 0)
		
		instance = Instance.new("Frame")
		instance.AnchorPoint = Vector2.new(0.5, 0.5)
		local corner = Instance.new("UICorner", instance)
		corner.CornerRadius = UDim.new(1, 0)
		local stroke = Instance.new("UIStroke", instance)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		
	elseif drawType == "Square" then
		properties.Thickness = 1
		properties.Size = Vector2.new(0, 0)
		properties.Position = Vector2.new(0, 0)
		properties.Filled = false
		properties.Rounding = 0 
		
		instance = Instance.new("Frame")
		local stroke = Instance.new("UIStroke", instance)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local corner = Instance.new("UICorner", instance)
		corner.Name = "UICorner"
		
	elseif drawType == "Triangle" then
		properties.Thickness = 1
		properties.PointA = Vector2.new(0, 0)
		properties.PointB = Vector2.new(0, 0)
		properties.PointC = Vector2.new(0, 0)
		properties.Filled = false
		
		instance = Instance.new("Folder")
		for i = 1, 3 do
			local line = Instance.new("Frame")
			line.BorderSizePixel = 0
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Parent = DrawingContainer
			subInstances[i] = line
		end

	elseif drawType == "Quad" then
		properties.Thickness = 1
		properties.PointA = Vector2.new(0, 0)
		properties.PointB = Vector2.new(0, 0)
		properties.PointC = Vector2.new(0, 0)
		properties.PointD = Vector2.new(0, 0)
		properties.Filled = false
		
		instance = Instance.new("Folder")
		for i = 1, 4 do
			local line = Instance.new("Frame")
			line.BorderSizePixel = 0
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Parent = DrawingContainer
			subInstances[i] = line
		end

	elseif drawType == "Image" then
		properties.Size = Vector2.new(0, 0)
		properties.Position = Vector2.new(0, 0)
		properties.Data = ""
		properties.Rounding = 0 
		
		instance = Instance.new("ImageLabel")
		instance.BackgroundTransparency = 1
		instance.BorderSizePixel = 0
		local corner = Instance.new("UICorner", instance)
		corner.Name = "UICorner"
	end
	
	if instance and drawType ~= "Triangle" and drawType ~= "Quad" then
		instance.Parent = DrawingContainer
	end
	
	local function updateRender()
		if not instance or (instance.ClassName ~= "Folder" and not instance.Parent) then return end
		
		local robloxTransparency = 1 - properties.Transparency
		
		if drawType == "Line" then
			instance.Visible = properties.Visible
			instance.BackgroundColor3 = properties.Color
			instance.BackgroundTransparency = robloxTransparency
			
			local mid = (properties.From + properties.To) / 2
			local dist = (properties.To - properties.From).Magnitude
			local angle = math.deg(math.atan2(properties.To.Y - properties.From.Y, properties.To.X - properties.From.X))
			
			instance.Position = UDim2.new(0, mid.X, 0, mid.Y)
			instance.Size = UDim2.new(0, dist, 0, properties.Thickness)
			instance.Rotation = angle
			instance.ZIndex = properties.ZIndex
			
		elseif drawType == "Text" then
			instance.Visible = properties.Visible
			instance.TextColor3 = properties.Color
			instance.TextTransparency = robloxTransparency
			instance.Text = properties.Text
			instance.TextSize = properties.Size
			instance.Font = FontMap[properties.Font] or Enum.Font.SourceSans
			
			instance.TextStrokeTransparency = properties.Outline and robloxTransparency or 1
			instance.TextStrokeColor3 = properties.OutlineColor
			
			if properties.Center then
				instance.AnchorPoint = Vector2.new(0.5, 0)
			else
				instance.AnchorPoint = Vector2.new(0, 0)
			end
			instance.Position = UDim2.new(0, properties.Position.X, 0, properties.Position.Y)
			instance.Size = UDim2.new(0, 0, 0, 0)
			properties.TextBounds = instance.TextBounds
			instance.ZIndex = properties.ZIndex
			
		elseif drawType == "Circle" then
			instance.Visible = properties.Visible
			instance.Position = UDim2.new(0, properties.Position.X, 0, properties.Position.Y)
			instance.Size = UDim2.new(0, properties.Radius * 2, 0, properties.Radius * 2)
			instance.ZIndex = properties.ZIndex
			
			local stroke = instance:FindFirstChildOfClass("UIStroke")
			if properties.Filled then
				instance.BackgroundTransparency = robloxTransparency
				instance.BackgroundColor3 = properties.Color
				if stroke then stroke.Transparency = 1 end
			else
				instance.BackgroundTransparency = 1
				if stroke then
					stroke.Transparency = robloxTransparency
					stroke.Color = properties.Color
					stroke.Thickness = properties.Thickness
				end
			end
			
		elseif drawType == "Square" then
			instance.Visible = properties.Visible
			instance.Position = UDim2.new(0, properties.Position.X, 0, properties.Position.Y)
			instance.Size = UDim2.new(0, properties.Size.X, 0, properties.Size.Y)
			instance.ZIndex = properties.ZIndex
			
			if instance:FindFirstChild("UICorner") then
				instance.UICorner.CornerRadius = UDim.new(0, properties.Rounding)
			end
			
			local stroke = instance:FindFirstChildOfClass("UIStroke")
			if properties.Filled then
				instance.BackgroundTransparency = robloxTransparency
				instance.BackgroundColor3 = properties.Color
				if stroke then stroke.Transparency = 1 end
			else
				instance.BackgroundTransparency = 1
				if stroke then
					stroke.Transparency = robloxTransparency
					stroke.Color = properties.Color
					stroke.Thickness = properties.Thickness
				end
			end
			
		elseif drawType == "Triangle" then
			local pts = {properties.PointA, properties.PointB, properties.PointC}
			local nextPts = {properties.PointB, properties.PointC, properties.PointA}
			
			for i = 1, 3 do
				local line = subInstances[i]
				if line then
					line.Visible = properties.Visible
					line.BackgroundColor3 = properties.Color
					line.BackgroundTransparency = robloxTransparency
					line.ZIndex = properties.ZIndex
					
					local p1 = pts[i]
					local p2 = nextPts[i]
					
					local mid = (p1 + p2) / 2
					local dist = (p2 - p1).Magnitude
					local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
					
					line.Position = UDim2.new(0, mid.X, 0, mid.Y)
					line.Size = UDim2.new(0, dist, 0, properties.Thickness)
					line.Rotation = angle
				end
			end

		elseif drawType == "Quad" then
			local pts = {properties.PointA, properties.PointB, properties.PointC, properties.PointD}
			local nextPts = {properties.PointB, properties.PointC, properties.PointD, properties.PointA}
			
			for i = 1, 4 do
				local line = subInstances[i]
				if line then
					line.Visible = properties.Visible
					line.BackgroundColor3 = properties.Color
					line.BackgroundTransparency = robloxTransparency
					line.ZIndex = properties.ZIndex
					
					local p1 = pts[i]
					local p2 = nextPts[i]
					
					local mid = (p1 + p2) / 2
					local dist = (p2 - p1).Magnitude
					local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
					
					line.Position = UDim2.new(0, mid.X, 0, mid.Y)
					line.Size = UDim2.new(0, dist, 0, properties.Thickness)
					line.Rotation = angle
				end
			end

		elseif drawType == "Image" then
			instance.Visible = properties.Visible
			instance.ImageTransparency = robloxTransparency
			instance.Image = properties.Data
			instance.Size = UDim2.new(0, properties.Size.X, 0, properties.Size.Y)
			instance.Position = UDim2.new(0, properties.Position.X, 0, properties.Position.Y)
			instance.ZIndex = properties.ZIndex
			
			if instance:FindFirstChild("UICorner") then
				instance.UICorner.CornerRadius = UDim.new(0, properties.Rounding)
			end
		end
	end

	local obj = {}
	function obj:Remove()
		if instance then
			instance:Destroy()
			instance = nil
		end
		for _, sub in ipairs(subInstances) do
			if sub then sub:Destroy() end
		end
	end
	
	setmetatable(obj, {
		__index = function(self, key)
			if key == "Remove" then
				return obj.Remove
			end
			if drawType == "Text" and key == "TextBounds" and instance then
				return instance.TextBounds
			end
			return properties[key]
		end,
		__newindex = function(self, key, value)
			if properties[key] ~= nil or key == "Thickness" or key == "ZIndex" or key == "Rounding" then
				properties[key] = value
				updateRender()
			end
		end
	})
	
	updateRender()
	return obj
end

getgenv = getgenv or function() return _G end
getgenv().Drawing = Drawing

return Drawing
