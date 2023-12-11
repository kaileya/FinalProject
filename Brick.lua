
Class = require 'class'

Brick = Class{}

function Brick:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.visible = true
end

function Brick:render()
    if self.visible then
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
end

function Brick:reset()
    self.visible = true
end