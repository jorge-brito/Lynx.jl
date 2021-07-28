# This code is an adaptation from the original
# "Coding Challenge #85: The Game of Life"
# by Daniel Shiffman
#
# https://thecodingtrain.com/CodingChallenges/085-the-game-of-life.html

using Lynx
using Luxor

const config = (
    background = "#111",
    cell_color = "white",
    resolution = 10,
    width = 800,
    height = 600,
    pause = "space", 
    clear = "Escape"
)

@info """Running 'The Game of Life' example
    Press $(config.pause) to pause/unpause
    Press $(config.clear) to clear all cells
    Click and drag with mouse to activate cells
"""

App("The Game of Life", config.width, config.height)

function GameOfLife()
    paused = false
    res = config.resolution
    rows = width(@window) ÷ res
    cols = height(@window) ÷ res
    grid = rand(0:1, rows, cols)

    onkeypress(@window) do w, event
        key = event.keyval
        if key == gkey(config.pause)
            paused = !paused
        elseif key == gkey(config.clear)
            grid = zeros(Int, rows, cols)
        end
    end

    onmousedrag(@canvas) do event
        i = floor(Int, event.x / res) + 1
        j = floor(Int, event.y / res) + 1
        grid[i, j] = 1
    end
    
    function update(dt)
        background(config.background)
        sethue(config.cell_color)

        for i in 1:rows, j in 1:cols
            x = (i - 1) * res
            y = (j - 1) * res
            if grid[i, j] == 1
                rect(x, y, res, res, :fill)
            end
        end

        paused && return
        next = zeros(Int, rows, cols)
        # compute the next generation
        for i in 1:rows, j in 1:cols
            state = grid[i, j]
            neighbors = countNeighbors(grid, i, j) 
            
            if state == 0 && neighbors == 3
                next[i, j] = 1
            elseif state == 1 && (neighbors > 3 || neighbors < 2)
                next[i, j] = 0
            else
                next[i, j] = grid[i, j]
            end
        end
    
        grid = next
    end 

    function countNeighbors(grid, x, y)
        sum = 0
        for i in -1:1, j in -1:1
            row = mod(x + i, 1:rows)
            col = mod(y + j, 1:cols)
            sum += grid[row, col]
        end
        sum -= grid[x, y]
        return sum
    end

    return update
end

run!(GameOfLife(); await = true)