import Cairo
import Cairo: CairoSurfaceImage
import Cairo: CairoSurface
import Cairo: CairoPattern

function image_surface(surface::CairoSurface)
    w, h = Int(surface.width), Int(surface.height)
    buffer = zeros(UInt32, w, h)
    img = Cairo.CairoImageSurface(buffer, Cairo.FORMAT_ARGB32, flipxy=false)
    cr = Cairo.CairoContext(img)
    Cairo.set_source_surface(cr, surface, 0, 0)
    Cairo.paint(cr)
    return img
end

function image_data(surface::CairoSurface)
    img = image_surface(surface)
    data = img.data
    Cairo.finish(img)
    Cairo.destroy(img)
    return data
end

function image_data(surface::CairoSurfaceImage)
    return surface.data
end

mutable struct Image <: Iterable
    surface::CairoSurfaceImage
    w::Int
    h::Int
    Image() = new()
end

function Image(surface::CairoSurface)
    this = Image()
    this.surface = image_surface(surface)
    this.w = surface.width
    this.h = surface.height
    return this
end

function Image(pixels::AbstractMatrix{UInt32})
    Image(Cairo.CairoImageSurface(pixels, Cairo.FORMAT_ARGB32, flipxy=false))
end

function Image(pixels::AbstractMatrix{ARGB32})
    Image(reinterpret(UInt32, pixels))
end

function Image(path::String)
    surface = Cairo.read_from_png(path)
    return Image(surface)
end

function drawimage(img::Image, x::Real = 0, y::Real = 0, w::Real = img.w, h::Real = img.h; centered = false)
    ctx = Luxor.get_current_cr()

    if centered
        x = x - w/2
        y = y - h/2
    end

    Cairo.image(ctx, img.surface, x, y, w, h)
end

function slice(image::Image, x::Int, y::Int, w::Int, h::Int)
    data = image.surface.data
    sx = (x + 1):w + x
    sy = (y + 1):h + y
    pixels = data[sx, sy]
    return Image(pixels)
end

function Base.getindex(image::Image, x::Int, y::Int, w::Int, h::Int)
    return slice(image, x, y, w, h)
end

function Base.replace!(this::Image, new::Image)
    this.surface = new.surface
    this.w = new.w
    this.h = new.h
end

Base.size(this::Image) = (this.w, this.h)

function rotl(this::Image)
    pixels = this.surface.data
    return Image(rotl90(pixels))
end

function rotl!(this::Image)
    new = rotl(this)
    replace!(this, new)
end

function rotr(this::Image)
    pixels = this.surface.data
    return Image(rotr90(pixels))
end

function rotr!(this::Image)
    new = rotr(this)
    replace!(this, new)
end

function Picture(image::Image, width = image.w, height = image.h)
    canvas = Canvas(width, height)
    ondraw(canvas) do c
        w, h = size(c)
        drawimage(image, 0, 0, w, h)
    end
    return canvas
end

Picture(image::AbstractString) = Picture(Image(image))

function Picture(image::AbstractString, width::Int, height::Int)
    return Picture(Image(image), width, height)
end