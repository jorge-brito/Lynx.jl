# This code is an adaptation from the original
# "Coding Challenge #85: The Game of Life"
# by Daniel Shiffman
#
# https://thecodingtrain.com/CodingChallenges/085-the-game-of-life.html

using Lynx
using Luxor

Lynx.init("The Game of Life", 1280, 720, layout = SideBar(
    size = .25,
    props = (
        margin = 20,
        spacing = 20
    )
))

global config = (
    background = ColorButton("#111", hexpand=true),
    cell_color = ColorButton("white", hexpand=true),
    resolution = 10,
    pause = "space", 
    clear = "Escape",
    pause_btn = Button("Pause")
)

@use Label("Press $(config.pause) to pause/unpause")
@use Label("Press $(config.clear) to clear all cells")
@use Label("Click and drag with mouse to activate cells")

function GameOfLife()
    paused = false
    res = config.resolution
    rows = @width() ÷ res
    cols = @height() ÷ res
    grid = rand(0:1, rows, cols)

    onevent(:clicked, config.pause_btn) do btn
        paused = !paused
        config.pause_btn["label"] = paused ? "Unpause" : "Pause"
    end

    @use Grid(spacing = 10,
        "Background color: " => config.background,
        "Cell color: " => config.cell_color,
        "#hide" => config.pause_btn,
    ) # Grid

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
        background(config.background[])
        sethue(config.cell_color[])

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