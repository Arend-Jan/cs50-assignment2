Powerup = Class{}

function Powerup:init(x, y)
    self.x = 10 
    self.y = 9
    self.width = 16
    self.height = 16
    
    -- used to determine whether this brick should be rendered
    self.inPlay = true

    -- particle system belonging to the brick, emitted on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    -- various behavior-determining functions for the particle system
    -- https://love2d.org/wiki/ParticleSystem

    -- lasts between 0.5-1 seconds seconds
    self.psystem:setParticleLifetime(0.5, 1)

    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
    -- gives generally downward 
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    -- spread of particles; normal looks more natural than uniform
    self.psystem:setAreaSpread('normal', 10, 10)
end

function Powerup:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end



--[[
    Triggers a hit on the brick, taking it out of play if at 0 health or
    changing its color otherwise.
]]
function Powerup:hit()
    -- set the particle system to interpolate between two colors; in this case, we give
    -- it our self.color but with varying alpha; brighter for higher tiers, fading to 0
    -- over the particle's lifetime (the second color)
    self.psystem:setColors(
        paletteColors[self.color].r,
        paletteColors[self.color].g,
        paletteColors[self.color].b,
        55 * (self.tier + 1),
        paletteColors[self.color].r,
        paletteColors[self.color].g,
        paletteColors[self.color].b,
        0
    )
    self.psystem:emit(64)

    -- sound on hit
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    -- if we're at a higher tier than the base, we need to go down a tier
    -- if we're already at the lowest color, else just go down a color
    if self.tier > 0 then
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
        -- if we're in the first tier and the base color, remove brick from play
        if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

    -- play a second layer sound if the brick is destroyed
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Powerup:update(dt)
    self.psystem:update(dt)
end

function Powerup:render()
    -- if self.inPlay then
    love.graphics.draw(gTextures['main'], 
        -- multiply color by 4 (-1) to get our color offset, then add tier to that
        -- to draw the correct tier and color brick onto the screen
        gFrames['powerups'][2],
        100, 100)

    -- end
end

--[[
    Need a separate render function for our particles so it can be called after all bricks are drawn;
    otherwise, some bricks would render over other bricks' particle systems.
]]
function Powerup:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end
