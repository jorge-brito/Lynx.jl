import Cairo
import Cairo: CairoSurface
import Cairo: CairoPattern

mutable struct Image
    surface::CairoSurface
    pattern::CairoPattern
    width::Int
    height::Int
    filter::Symbol
end

function Base.filter!(this::Image, filter::Symbol)
    cairo_filter = getfield(Cairo, Symbol(uppercase("FILTER_$filter")))
    Cairo.pattern_set_filter(this.pattern, cairo_filter)
    this.filter = filter
end

function Base.replace!(this::Image, surface::Cairo.CairoSurface)
    this.surface = surface
    this.pattern = CairoPattern(surface)
    this.width = Cairo.width(surface)
    this.height = Cairo.height(surface)
    filter!(this, this.filter)
    return this
end

Base.replace!(this::Image, other::Image) = replace!(this, other.surface)

Base.size(this::Image) = (this.width, this.height)

function Image(img::CairoSurface; filter = :NEAREST)
    pattern = CairoPattern(img)
    this = Image(img, pattern, img.width, img.height, filter)
    filter!(this, filter)
    return this
end

Image(filepath::AbstractString; kwargs...) = Image(readpng(filepath); kwargs...)

function Image(image::AbstractMatrix{UInt32}; kwargs...)
    surface = Cairo.CairoImageSurface(image, Cairo.FORMAT_ARGB32, flipxy=false)
    return Image(surface; kwargs...)
end

function Image(image::AbstractMatrix{ARGB32}; kwargs...)
    pixels = zeros(UInt32, size(image))
    data = reinterpret(UInt32, image)
    copy!(pixels, data)
    return Image(pixels; kwargs...)
end

function drawimage(this::Image, x::Real = 0, y::Real = 0, width=this.width, height=this.height; centered=false)
    if centered
        x, y = x - width/2, y - height/2
    end
    ctx = Luxor.get_current_cr()
    Cairo.save(ctx)
    sx, sy = width/this.width, height/this.height
    translate(x, y)
    scale(sx, sy)
    Cairo.set_source(ctx, this.pattern)
    rect(0, 0, width/sx, height/sy, :clip)
    paint()
    clipreset()
    Cairo.restore(ctx)
end

function getpixels(img::CairoSurface)
    buffer = zeros(UInt32, floor(Int, img.width), floor(Int, img.height))
    surface = Cairo.CairoImageSurface(buffer, Cairo.FORMAT_ARGB32, flipxy=false)
    cr = Cairo.CairoContext(surface)
    Cairo.set_source_surface(cr, img, 0, 0)
    Cairo.paint(cr)
    data = surface.data
    Cairo.finish(surface)
    Cairo.destroy(surface)
    return data
end

getpixels(img::Image) = getpixels(img.surface)

function slice(surface::CairoSurface, x::Int, y::Int, width::Int, height::Int)
    data = getpixels(surface)
    Cairo.finish(surface)
    Cairo.destroy(surface)
    sx = (x + 1):(width - 1)
    sy = (y + 1):(height - 1)
    sliced = data[sx, sy]
    return Cairo.CairoImageSurface(sliced, Cairo.FORMAT_ARGB32, flipxy=false)
end

function slice(this::Image, x::Int, y::Int, width::Int, height::Int)
    img = this.surface
    return Image(slice(img, x, y, width, height); filter = this.filter)
end

function Base.getindex(this::Image, sx::AbstractUnitRange, sy::AbstractUnitRange)
    return slice(this, first(sx), first(sy), last(sx), last(sy))
end

function rotl(this::Image)
    pixels = getpixels(this)
    return Image(rotl90(pixels), filter = this.filter)
end

function rotl!(this::Image)
    new = rotl(this)
    replace!(this, new)
end

function rotr(this::Image)
    pixels = getpixels(this)
    return Image(rotr90(pixels), filter = this.filter)
end

function rotr!(this::Image)
    new = rotr(this)
    replace!(this, new)
end

function Picture(image::Image, width = image.width, height = image.height)
    canvas = Canvas(width, height)
    ondraw(canvas) do c
        w, h = size(c)
        drawimage(image, 0, 0, w, h)
    end
    return canvas
end

Picture(image::AbstractString) = Picture(Image(image, filter = :Good))

function Picture(image::AbstractString, width::Int, height::Int; filter = :Good)
    return Picture(Image(image; filter), width, height)
end