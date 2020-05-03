--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerLiftPotState = Class{__includes = BaseState}

function PlayerLiftPotState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 0

    self.player:changeAnimation('lift-' .. self.player.direction)
end

function PlayerLiftPotState:enter(params)
    self.player.currentAnimation:refresh()
end

function PlayerLiftPotState:update(dt)
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle')
    end

    if self.player.pot then -- pots
        -- print('PlayerLiftPotState:update ' .. self.player.pot.x .. ' ' .. self.player.pot.y)
        self:liftPot(self.player.pot, dt)
    end

end

function PlayerLiftPotState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end

function PlayerLiftPotState:liftPot(object, dt)
    if not object.lifting then
        object.lifting = true
        Timer.tween(1.2, { [object] = {x = self.player.x - POT_OFFSET_X, y = self.player.y - object.height + POT_OFFSET_Y } })
    end
end