require "go.ui.control.StaticImage"
require "uppuRacingObject"

class 'uppuRacingTileObject' (uppuRacingObject)

function uppuRacingTileObject:__init(pos, angle, image) super(0, CLASS_SLAVE)
	self.oid = -1	-- no owner
	self.image = self:CreateBody(image, pos, angle)
end

function uppuRacingTileObject:Destroy()
	Scene.latestScene:RemoveChild(self.image)
	self.image = nil
end

function uppuRacingTileObject:CreateBody(object, pos, angle)
	Scene.latestScene:AddChild(object)

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x)
	object:SetYPos(pos.y)
	object:SetXPivot(objectWidth/2)
	object:SetYPivot(objectHeight/2)
	object:Show(true)

	return object
end
