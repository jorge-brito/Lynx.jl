using Lynx
using Luxor
using Colors
using Observables

include("utils.jl")

canvas  = Canvas(hexpand = true, vexpand = true)
name    = Observable("image.png")
image   = Image(asset"image.png")

# image = slice(image, 0, 0, 300, 300)
# image = image[0, 0, 300, 300]

mouse  = Mouse(canvas)
pos    = Point(200, 100)
zoom   = 1.0

zoom_btn = SpinButton(0:10:300, start = 100)

on(zoom_btn) do x
    global zoom = x / 100
end

function setimage!(path::String)
    global image;
    if !isempty(path)
        name[] = basename(path)
        image = Image(path)
    end
end

function updateimg(args...)
    path = Lynx.file!("Choose an image", filters = ["*.png"])
    setimage!(path)
end

rotr(args...) = rotl!(image)
rotl(args...) = rotr!(image)

onupdate(canvas) do dt, c
    background("#fff")
    origin(pos.x, pos.y)
    scale(zoom)
    drawimage(image)
end

onscroll(canvas) do e
    z = 10 * e.direction
    zoom_btn[] = clamp(zoom_btn[] + z, 10, 300)
end

onmousedrag(canvas) do event
    global pos += Point(mouse.dx, mouse.dy)
end

app = Window("Images", 900, 800,
    Box(:v,
        Paned(:v, position = 750,
            Paned(:v, position = 60,
                Box(:h, margin = 10, spacing = 5,
                    Button(updateimg, "insert-image", :Button, tooltip_text = "Select image"),
                    Button(rotl, "object-rotate-left", :Button, tooltip_text = "Rotate left"),
                    Button(rotr, "object-rotate-right", :Button, tooltip_text = "Rotate right"),
                ), # Box
                canvas,
            ), # Paned,
            Box(:h, spacing = 10, margin = 10,
                Label(name[], label = name, halign = Start),
                Box(:h, halign = End, hexpand = true, spacing = 10,
                    Label("Zoom "),
                    zoom_btn
                ) # Box
            ) # Box
        ) # Paned
    ) # Box
) # Window

@showall app; nothing