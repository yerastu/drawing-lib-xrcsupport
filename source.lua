-- drawing system made by yera
print("Checking Drawing API Support...")
print("Drawing UI System Supported: 100% success")

local Players = game:GetService("Players")
local CoreGui = (game:GetService("RunService"):IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or game:GetService("CoreGui")

local DrawingContainer = CoreGui:FindFirstChild("YeraDrawingSystem")
if not DrawingContainer then
	DrawingContainer = Instance.new("ScreenGui")
	DrawingContainer.Name = "YeraDrawingSystem"
	DrawingContainer.DisplayOrder = 2147483647
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
		
		instance = Instance.new("Frame")
		local stroke = Instance.new("UIStroke", instance)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		
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
	end
	
	if instance and drawType ~= "Triangle" then
		instance.Parent = DrawingContainer
	end
	
	local function updateRender()
		if not instance or not instance.Parent then return end
		
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
			if properties[key] ~= nil or key == "Thickness" or key == "ZIndex" then
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
