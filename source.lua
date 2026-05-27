local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local uiTarget = (rs:IsStudio() and plrs.LocalPlayer:WaitForChild("PlayerGui")) or game:GetService("CoreGui")
print("Drawing XRC Api Supported: 100%")

local box = uiTarget:FindFirstChild("DrawAPI")
if not box then
	box = Instance.new("ScreenGui")
	box.Name = "DrawAPI"
	box.DisplayOrder = 2147483646
	box.IgnoreGuiInset = true
	box.ResetOnSpawn = false
	box.Parent = uiTarget
end

local Draw = {}
Draw.Fonts = {
	UI = 0,
	System = 1,
	Plex = 2,
	Monospace = 3
}

local fonts = {
	[0] = Enum.Font.SourceSans,
	[1] = Enum.Font.Arial,
	[2] = Enum.Font.RobotoMono,
	[3] = Enum.Font.Code
}

function Draw.new(kind)
	local props = {
		Visible = false,
		Color = Color3.new(0, 0, 0),
		Transparency = 1,
		ZIndex = 1
	}

	local ui
	local parts = {} 
	
	if kind == "Line" then
		props.Thickness = 1
		props.From = Vector2.zero
		props.To = Vector2.zero
		
		ui = Instance.new("Frame")
		ui.BorderSizePixel = 0
		ui.AnchorPoint = Vector2.new(0.5, 0.5)
		
	elseif kind == "Text" then
		props.Text = ""
		props.Size = 16
		props.Center = false
		props.Outline = false
		props.OutlineColor = Color3.new(0, 0, 0)
		props.Position = Vector2.zero
		props.Font = Draw.Fonts.UI
		props.TextBounds = Vector2.zero
		
		ui = Instance.new("TextLabel")
		ui.BackgroundTransparency = 1
		
	elseif kind == "Circle" then
		props.Thickness = 1
		props.NumSides = 0
		props.Radius = 0
		props.Filled = false
		props.Position = Vector2.zero
		
		ui = Instance.new("Frame")
		ui.AnchorPoint = Vector2.new(0.5, 0.5)
		local round = Instance.new("UICorner", ui)
		round.CornerRadius = UDim.new(1, 0)
		local line = Instance.new("UIStroke", ui)
		line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		
	elseif kind == "Square" then
		props.Thickness = 1
		props.Size = Vector2.zero
		props.Position = Vector2.zero
		props.Filled = false
		props.Rounding = 0 
		
		ui = Instance.new("Frame")
		local line = Instance.new("UIStroke", ui)
		line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local round = Instance.new("UICorner", ui)
		round.Name = "UICorner"
		
	elseif kind == "Triangle" then
		props.Thickness = 1
		props.PointA = Vector2.zero
		props.PointB = Vector2.zero
		props.PointC = Vector2.zero
		props.Filled = false
		
		ui = Instance.new("Folder")
		for i = 1, 3 do
			local l = Instance.new("Frame")
			l.BorderSizePixel = 0
			l.AnchorPoint = Vector2.new(0.5, 0.5)
			l.Parent = box
			parts[i] = l
		end

	elseif kind == "Quad" then
		props.Thickness = 1
		props.PointA = Vector2.zero
		props.PointB = Vector2.zero
		props.PointC = Vector2.zero
		props.PointD = Vector2.zero
		props.Filled = false
		
		ui = Instance.new("Folder")
		for i = 1, 4 do
			local l = Instance.new("Frame")
			l.BorderSizePixel = 0
			l.AnchorPoint = Vector2.new(0.5, 0.5)
			l.Parent = box
			parts[i] = l
		end

	elseif kind == "Image" then
		props.Size = Vector2.zero
		props.Position = Vector2.zero
		props.Data = ""
		props.Rounding = 0 
		
		ui = Instance.new("ImageLabel")
		ui.BackgroundTransparency = 1
		ui.BorderSizePixel = 0
		local round = Instance.new("UICorner", ui)
		round.Name = "UICorner"
	end
	
	if ui and kind ~= "Triangle" and kind ~= "Quad" then
		ui.Parent = box
	end
	
	local function update()
		if not ui or (ui.ClassName ~= "Folder" and not ui.Parent) then return end
		
		local alpha = 1 - props.Transparency
		
		if kind == "Line" then
			ui.Visible = props.Visible
			ui.BackgroundColor3 = props.Color
			ui.BackgroundTransparency = alpha
			
			local mid = (props.From + props.To) / 2
			local dist = (props.To - props.From).Magnitude
			local angle = math.deg(math.atan2(props.To.Y - props.From.Y, props.To.X - props.From.X))
			
			ui.Position = UDim2.new(0, mid.X, 0, mid.Y)
			ui.Size = UDim2.new(0, dist, 0, props.Thickness)
			ui.Rotation = angle
			ui.ZIndex = props.ZIndex
			
		elseif kind == "Text" then
			ui.Visible = props.Visible
			ui.TextColor3 = props.Color
			ui.TextTransparency = alpha
			ui.Text = props.Text
			ui.TextSize = props.Size
			ui.Font = fonts[props.Font] or Enum.Font.SourceSans
			
			ui.TextStrokeTransparency = props.Outline and alpha or 1
			ui.TextStrokeColor3 = props.OutlineColor
			
			if props.Center then
				ui.AnchorPoint = Vector2.new(0.5, 0)
			else
				ui.AnchorPoint = Vector2.new(0, 0)
			end
			ui.Position = UDim2.new(0, props.Position.X, 0, props.Position.Y)
			ui.Size = UDim2.new(0, 0, 0, 0)
			props.TextBounds = ui.TextBounds
			ui.ZIndex = props.ZIndex
			
		elseif kind == "Circle" then
			ui.Visible = props.Visible
			ui.Position = UDim2.new(0, props.Position.X, 0, props.Position.Y)
			ui.Size = UDim2.new(0, props.Radius * 2, 0, props.Radius * 2)
			ui.ZIndex = props.ZIndex
			
			local line = ui:FindFirstChildOfClass("UIStroke")
			if props.Filled then
				ui.BackgroundTransparency = alpha
				ui.BackgroundColor3 = props.Color
				if line then line.Transparency = 1 end
			else
				ui.BackgroundTransparency = 1
				if line then
					line.Transparency = alpha
					line.Color = props.Color
					line.Thickness = props.Thickness
				end
			end
			
		elseif kind == "Square" then
			ui.Visible = props.Visible
			ui.Position = UDim2.new(0, props.Position.X, 0, props.Position.Y)
			ui.Size = UDim2.new(0, props.Size.X, 0, props.Size.Y)
			ui.ZIndex = props.ZIndex
			
			if ui:FindFirstChild("UICorner") then
				ui.UICorner.CornerRadius = UDim.new(0, props.Rounding)
			end
			
			local line = ui:FindFirstChildOfClass("UIStroke")
			if props.Filled then
				ui.BackgroundTransparency = alpha
				ui.BackgroundColor3 = props.Color
				if line then line.Transparency = 1 end
			else
				ui.BackgroundTransparency = 1
				if line then
					line.Transparency = alpha
					line.Color = props.Color
					line.Thickness = props.Thickness
				end
			end
			
		elseif kind == "Triangle" then
			local pts = {props.PointA, props.PointB, props.PointC}
			local nextPts = {props.PointB, props.PointC, props.PointA}
			
			for i = 1, 3 do
				local l = parts[i]
				if l then
					l.Visible = props.Visible
					l.BackgroundColor3 = props.Color
					l.BackgroundTransparency = alpha
					l.ZIndex = props.ZIndex
					
					local p1 = pts[i]
					local p2 = nextPts[i]
					
					local mid = (p1 + p2) / 2
					local dist = (p2 - p1).Magnitude
					local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
					
					l.Position = UDim2.new(0, mid.X, 0, mid.Y)
					l.Size = UDim2.new(0, dist, 0, props.Thickness)
					l.Rotation = angle
				end
			end

		elseif kind == "Quad" then
			local pts = {props.PointA, props.PointB, props.PointC, props.PointD}
			local nextPts = {props.PointB, props.PointC, props.PointD, props.PointA}
			
			for i = 1, 4 do
				local l = parts[i]
				if l then
					l.Visible = props.Visible
					l.BackgroundColor3 = props.Color
					l.BackgroundTransparency = alpha
					l.ZIndex = props.ZIndex
					
					local p1 = pts[i]
					local p2 = nextPts[i]
					
					local mid = (p1 + p2) / 2
					local dist = (p2 - p1).Magnitude
					local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
					
					l.Position = UDim2.new(0, mid.X, 0, mid.Y)
					l.Size = UDim2.new(0, dist, 0, props.Thickness)
					l.Rotation = angle
				end
			end

		elseif kind == "Image" then
			ui.Visible = props.Visible
			ui.ImageTransparency = alpha
			ui.Image = props.Data
			ui.Size = UDim2.new(0, props.Size.X, 0, props.Size.Y)
			ui.Position = UDim2.new(0, props.Position.X, 0, props.Position.Y)
			ui.ZIndex = props.ZIndex
			
			if ui:FindFirstChild("UICorner") then
				ui.UICorner.CornerRadius = UDim.new(0, props.Rounding)
			end
		end
	end

	local obj = {}
	function obj:Remove()
		if ui then
			ui:Destroy()
			ui = nil
		end
		for _, part in ipairs(parts) do
			if part then part:Destroy() end
		end
	end
	
	setmetatable(obj, {
		__index = function(self, key)
			if key == "Remove" then return obj.Remove end
			if kind == "Text" and key == "TextBounds" and ui then return ui.TextBounds end
			return props[key]
		end,
		__newindex = function(self, key, value)
			if props[key] ~= nil or key == "Thickness" or key == "ZIndex" or key == "Rounding" then
				props[key] = value
				update()
			end
		end
	})
	
	update()
	return obj
end

getgenv = getgenv or function() return _G end
getgenv().Drawing = Draw
