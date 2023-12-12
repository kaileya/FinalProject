-- https://github.com/Ulydev/push
push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

require 'Brick'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()
    
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('breaKout!')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

    sounds = {
        ['hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['lose'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score and rounds
    playerScore = 0
    round = 1

    -- initialize player paddle and ball
    -- make paddle smaller after ever round
    player = Paddle(VIRTUAL_WIDTH/2 - 10, VIRTUAL_HEIGHT - 40, 35-(round*3), 5)
    ball = Ball(player.x + (player.width / 2) - 2, player.y - 4, 4, 4)
    
    -- initialize bricks
    bricks = {}
    brickWidth = 50
    brickHeight = 10
    rows = 4
    columns = 8

    -- add bricks to table
    for i = 1, rows do
        for j = 1, columns do
            brick = Brick(4 + (j - 1) * (brickWidth + 4), 4 + (i - 1) * (brickHeight + 4), brickWidth, brickHeight)
            table.insert(bricks, brick)
        end
    end

    gameState = 'start'
end


function love.update(dt)
    if gameState == 'serve' then
        ball.dx = math.random(-50, 50)
        ball.dy = -200 - (round*25)
        ball.x = player.x + (player.width / 2) - (ball.width / 2)
        ball.y = player.y - ball.height

    elseif gameState == 'play' then
        
        -- paddle collision
        if ball:collides(player) then
            ball.dy = -ball.dy
            ball.dx = math.random(-70, 70)
            sounds['hit']:play()
        end
        
        -- brick collision
        for _, brick in pairs(bricks) do
            if brick.visible and ball:collides(brick) then
                ball.dy = -ball.dy
                ball.dx = math.random(-70, 70)
                sounds['hit']:play()
                brick.visible = false
                playerScore = playerScore + 111
            end
        end

        -- top screen collision
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['hit']:play()
        end


        -- side boundaries collision
        if ball.x <= 0 or ball.x >= VIRTUAL_WIDTH - 4 then
            ball.dx = -ball.dx
            sounds['hit']:play()
        end


        -- bottom screen restart and update rounds
        if ball.y >= VIRTUAL_HEIGHT then
            round = round + 1
            sounds['lose']:play()

            if round == 6 or playerScore > 3552 then
                gameState = 'done'

            else
                gameState = 'serve'
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


function love.draw()
    push:apply('start')

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

    elseif gameState == 'done' then
        love.graphics.setFont(scoreFont)

        if playerScore < 3552 then
            love.graphics.setColor(76/100, 57/100, 63/100, 1)
            love.graphics.printf('You did not destroy all of the bricks.\nBetter luck next time!', 0, 50, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.setColor(157/255, 194/255, 9/255, 1)
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
    love.graphics.setColor(157/255, 194/255, 9/255, 1)
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(playerScore), 10, VIRTUAL_HEIGHT - 50)
    love.graphics.setColor(1, 1, 1, 1)

end
