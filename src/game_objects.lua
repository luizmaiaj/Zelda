--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = TILE_SIZE,
        height = TILE_SIZE,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = { frame = 2 },
            ['pressed']   = { frame = 1 }
        }
    },
    ['pot'] = {
        type = 'tiles',
        texture = 'tiles',
        frame = 33,
        width = TILE_SIZE,
        height = TILE_SIZE,
        solid = true,
        defaultState = 'closed',
        states = {
            ['open']   = { frame = 14 },
            ['closed'] = { frame = 33 },
            ['broken'] = { frame = 52 }
        }
    },
    ['health'] = {
        type = 'health',
        texture = 'hearts',
        frame = 5,
        width = TILE_SIZE,
        height = TILE_SIZE,
        solid = false,
        defaultState = 'full',
        states = {
            ['full'] = { frame = 5 },
            ['half'] = { frame = 3 }
        }
    }
}