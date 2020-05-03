--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(player)
    self.player = player
    
    self.animation = ''

    if self.player.pot ~= nil and self.player.pot.lifting then
        self.animation = 'pot-'
    end

    self.player:changeAnimation(self.animation .. 'idle-' .. self.player.direction)

    -- used for AI waiting
    self.waitDuration = 0
    self.waitTimer = 0
end

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 0
end

function PlayerIdleState:update(dt)
    EntityIdleState.update(self, dt)
end

function PlayerIdleState:update(dt)
    local throwPotX = 0
    local throwPotY = 0

    if self.player.pot ~= nil then
        throwPotX = self.player.pot.x
        throwPotY = self.player.pot.y
    end

    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.player:changeState('walk')
    end

    if self.animation == '' and love.keyboard.wasPressed('space') then
        self.player:changeState('swing-sword')
    end

    if love.keyboard.wasPressed('return') then
        if self.animation == '' and self.player.pot ~= nil then
            local distance = math.abs(self.player.x - self.player.pot.x) + math.abs(self.player.y - self.player.pot.y)
            if distance < 26 then self.player:changeState('lift-pot') end
        elseif self.player.pot ~= nil then
            if self.player.direction == 'up' then throwPotY = throwPotY - POT_THROW_DISTANCE
            elseif self.player.direction == 'down' then throwPotY = throwPotY + POT_THROW_DISTANCE 
            elseif self.player.direction == 'left' then throwPotX = throwPotX - POT_THROW_DISTANCE
            elseif self.player.direction == 'right' then throwPotX = throwPotX + POT_THROW_DISTANCE end
        
            local obj = self.player.pot
            local finalState = 'closed'

            obj.thrown = true

            local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE
            if (throwPotX <= MAP_RENDER_OFFSET_X + TILE_SIZE) then
                throwPotX = MAP_RENDER_OFFSET_X + TILE_SIZE
                finalState = 'broken'
            elseif (throwPotX + obj.width >= VIRTUAL_WIDTH - TILE_SIZE * 2) then
                throwPotX = VIRTUAL_WIDTH - TILE_SIZE * 2 - obj.width
                finalState = 'broken'
            elseif (throwPotY <= MAP_RENDER_OFFSET_Y + TILE_SIZE - obj.height / 2) then
                throwPotY = MAP_RENDER_OFFSET_Y + TILE_SIZE - obj.height / 2
                finalState = 'broken'
            elseif (throwPotY + obj.height >= bottomEdge) then 
                throwPotY = bottomEdge - obj.height
                finalState = 'broken'
            end

            local flytime = .01 * (math.abs(throwPotX - obj.x) + math.abs(throwPotY - obj.y))

            Timer.tween(flytime, { [self.player.pot] = {x = throwPotX, y = throwPotY } }):finish(function()
                self.player.pot.lifting = false
                self.player.pot.thrown = false
                if self.player.pot.state ~= 'broken' then self.player.pot.state = finalState end
                self.player.pot = nil
            end)

            self.player:changeAnimation('idle-' .. self.player.direction)
        end
    end
end

function PlayerIdleState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
    
    -- love.graphics.setColor(1, 0, 1, 1)
    -- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    -- love.graphics.setColor(1, 1, 1, 1)
end