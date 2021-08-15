using Luxor
using Lynx

include("utils.jl")

mutable struct SpriteSheet
    image::Image
    sprites::Dict{NTuple{4, Int}, Image}
    SpriteSheet() = new()
end

function SpriteSheet(image::Image)
    this = SpriteSheet()
    this.sprites = Dict{NTuple{4, Int}, Image}()
    this.image = image
    return this
end

SpriteSheet(path::AbstractString) = SpriteSheet(Image(path))

function Base.getindex(this::SpriteSheet, x::Int, y::Int, w::Int, h::Int)
    return get!(this.sprites, (x, y, w, h), this.image[x, y, w, h])
end

Lynx.init("SpriteSheet", 800, 600)

sprites = SpriteSheet(asset"fruits.png")
w, h = 128, 128
tiles = Tiler(800, 600, 3, 3)

function update(dt)
    background("#111")
    origin()
    for (pos, n) in tiles
        i, j = 16 .* (tiles.currentrow - 1, tiles.currentcol - 1)
        drawimage(sprites[i, j, 16, 16], pos.x, pos.y, w, h, centered = true)
    end
end

run!(update)