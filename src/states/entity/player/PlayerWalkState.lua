--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerWalkState = Class{__includes = EntityWalkState}

function PlayerWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerWalkState:update(dt)
    -- change the animation if the pot is being carried
    local animation = ''
    if self.entity.pot ~= nil and self.entity.pot.lifting and self.entity.pot.thrown == false then
        animation = 'pot-'
    end

    local throwPotX = 0
    local throwPotY = 0

    if self.entity.pot ~= nil then
        throwPotX = self.entity.pot.x
        throwPotY = self.entity.pot.y
    end

    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation(animation .. 'walk-left')
        throwPotX = throwPotX - POT_THROW_DISTANCE
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation(animation .. 'walk-right')
        throwPotX = throwPotX + POT_THROW_DISTANCE
    elseif love.keyboard.isDown('up') then
        throwPotY = throwPotY - POT_THROW_DISTANCE
        self.entity.direction = 'up'
        self.entity:changeAnimation(animation .. 'walk-up')
    elseif love.keyboard.isDown('down') then
        throwPotY = throwPotY + POT_THROW_DISTANCE 
        self.entity.direction = 'down'
        self.entity:changeAnimation(animation .. 'walk-down')
    else
        self.entity:changeState('idle')
    end

    if animation == '' and love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    if love.keyboard.wasPressed('return') then
        if animation == '' and self.entity.pot ~= nil then -- if currently no pot is being carried
            local distance = math.abs(self.entity.x - self.entity.pot.x) + math.abs(self.entity.y - self.entity.pot.y)
            if distance < 26 then self.entity:changeState('lift-pot') end
        elseif self.entity.pot ~= nil then -- if a pot is being carried throw it
            local obj = self.entity.pot
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

            Timer.tween(flytime, { [self.entity.pot] = {x = throwPotX, y = throwPotY } }):finish(function()
                self.entity.pot.lifting = false
                self.entity.pot.thrown = false
                if self.entity.pot.state ~= 'broken' then self.entity.pot.state = finalState end
                self.entity.pot = nil
            end)

            self.entity:changeState('idle')
        end
    end

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)

    -- make the pot move with the player 
    if animation == 'pot-' then
        self.entity.pot.x = self.entity.x - POT_OFFSET_X
        self.entity.pot.y = self.entity.y - self.entity.pot.height + POT_OFFSET_Y
    end

    -- if we bumped something when checking collision, check any object collisions
    if self.bumped then
        if self.entity.direction == 'left' then
            
            -- temporarily adjust position
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-left')
                end
            end

            -- readjust
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'right' then
            
            -- temporarily adjust position
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-right')
                end
            end

            -- readjust
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'up' then
            
            -- temporarily adjust position
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-up')
                end
            end

            -- readjust
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
        else
            
            -- temporarily adjust position
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
            
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-down')
                end
            end

            -- readjust
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
        end
    end
end