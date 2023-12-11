-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- Brick class
require 'Brick'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]




function love.load()
    
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('breaKout!')

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)


    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['lose'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the score and rounds
    playerScore = 0
    round = 1

    -- initialize player paddle and ball and bricks
    x = 30
    player = Paddle(VIRTUAL_WIDTH/2 - 10, VIRTUAL_HEIGHT - 40, x, 5)
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT - 45, 4, 4)
    
    -- Initialize table to store bricks
    bricks = {}

    -- Brick dimensions
    brickWidth = 50
    brickHeight = 10

    -- Number of rows and columns for bricks
    rows = 4
    columns = 8

    -- Create bricks and insert them into the table
    for i = 1, rows do
        for j = 1, columns do
            brick = Brick(4 + (j - 1) * (brickWidth + 4), 4 + (i - 1) * (brickHeight + 4), brickWidth, brickHeight)
            table.insert(bricks, brick)
        end
    end

    gameState = 'start'
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    if gameState == 'serve' then
        ball.dx = math.random(-50, 50)
        ball.dy = -200 - (round*25)
        ball.x = player.x + (player.width / 2) - (ball.width / 2)
        ball.y = player.y - ball.height

    elseif gameState == 'play' then
        -- detect ball collision with paddle, reversing dy if true and
        -- slightly increasing it, then altering the dx based on the position of collision
        if ball:collides(player) then
            ball.dy = -ball.dy
            ball.dx = math.random(-70, 70)
            sounds['hit']:play()
        end

        -- detect ball collision with bricks, reversing dy if true and
        -- slightly increasing it, then altering the dx based on the position of collision
            for _, brick in pairs(bricks) do
                if brick.visible and ball:collides(brick) then
                    ball.dy = -ball.dy
                    ball.dx = math.random(-70, 70)
                    sounds['hit']:play()
                    brick.visible = false
                    playerScore = playerScore + 111
                end
            end

        -- detect upper screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['hit']:play()
        end


        -- detect side boundaries and reverse if collided
        if ball.x <= 0 or ball.x >= VIRTUAL_WIDTH - 4 then
            ball.dx = -ball.dx
            sounds['hit']:play()
        end



        -- if we reach the bottom of the screen, 
        -- go back to start and update rounds
        if ball.y >= VIRTUAL_HEIGHT then
            round = round + 1
            sounds['lose']:play()
            player = Paddle(VIRTUAL_WIDTH/2 - 10, VIRTUAL_HEIGHT - 40, x-5, 5)

            
            -- if we've reached a 5 rounds, the game is over; set the
            -- state to done so we can show the victory message
            if round == 6 or playerScore > 3552 then
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
                player:reset()
                
            end
        end

        ball:update(dt)
    end

    -- player movement
    if love.keyboard.isDown('d') then
        player.dx = PADDLE_SPEED
        
    elseif love.keyboard.isDown('a') then
        player.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        player.dx = PADDLE_SPEED
    elseif love.keyboard.isDown('left') then
        player.dx = -PADDLE_SPEED
    else
        player.dx = 0
    end

    player:update(dt)
end


--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
            
        elseif gameState == 'done' then
            gameState = 'start'
            round = 1
            playerScore = 0
            player: reset()
            ball: reset()
            for _, brick in pairs(bricks) do
                brick:reset()
            end
        end
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)
    displayScore()

    if gameState == 'start' then
        love.graphics.setColor(0.6,0.8,1, 0.3)
        for _, brick in ipairs(bricks) do
            brick:render()
        end  
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(scoreFont)
        love.graphics.printf('Welcome to breaKout!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(0.6,0.8,1, 0.3)
        
    elseif gameState == 'serve' then
        love.graphics.setColor(0.6,0.8,1, 0.3)
        for _, brick in ipairs(bricks) do
            brick:render()
        end  
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(smallFont)
        love.graphics.printf('Current score: ' .. tostring(playerScore), 0, 30, VIRTUAL_WIDTH, 'center')    
        love.graphics.printf('Round: ' .. tostring(round).." of 5", 0, 50, VIRTUAL_WIDTH, 'center')    
        love.graphics.printf('Press Enter to serve!', 0, 40, VIRTUAL_WIDTH, 'center')  
        
    elseif gameState == 'play' then
        love.graphics.setColor(0.6,0.8,1, 0.3)
        for _, brick in ipairs(bricks) do
            brick:render()
        end     
        love.graphics.setColor(1,1,1,1)

        -- no UI messages to display in play
    elseif gameState == 'done' then
        love.graphics.setFont(scoreFont)
        if playerScore < 3552 then
            love.graphics.setColor(1,0,0,1)
            love.graphics.printf('You did not destroy all of the bricks.\nBetter luck next time!', 0, 50, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.setColor(0,1,0,1)
            love.graphics.printf('You destroyed all of the bricks!\nYou are SO AMAZING!', 0, 50, VIRTUAL_WIDTH, 'center')
        end    
        love.graphics.setFont(smallFont)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf('The final score is: ' .. tostring(playerScore) .. ' !', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        
        love.graphics.setColor(0.6,0.8,1, 0.3)
        for _, brick in ipairs(bricks) do
            brick:render()
        end
        love.graphics.setColor(1,1,1,1)

    end

    player:render()
    ball:render()
    
    

    push:apply('end')
end

function displayScore()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(playerScore), 10, VIRTUAL_HEIGHT - 50)
    love.graphics.setColor(1, 1, 1, 1)

end
