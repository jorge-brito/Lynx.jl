using Lynx
using Luxor

@widget mutable struct CBox <: Box
    widget::Box
    CBox(layout::Symbol, children::Widget...; props...) = Box(layout, 
        children...; 
        halign=Center, 
        valign=Center,
        props...
    ) # Box
end

@widget mutable struct Profile <: Widget
    widget::Widget
    picture::Canvas
    image::Image
    name::TextField
    age::SpinButton
end

function Profile(name::String, age::Real, image::Image; props...)
    cw = clamp(image.w, 1, 200)
    ch = clamp(image.h, 1, 200)
    picture = Canvas(cw, ch)
    ondraw(picture) do c
        origin()
        let (width, height) = size(c)
            w, h = clamp(width, 1, 200), clamp(height, 1, 200)
            circle(O, w/2, :clip)
            drawimage(image, 0, 0, w, h, centered=true)
        end
    end
    name_w = TextField(text = name)
    age_w = SpinButton(1:120, start=age)
    container = Frame("Profile", label_xalign=0.03, hexpand=false,
        Grid(spacing = (20, 10), margin = 10,
            picture |> cspan(4), |,
            Label("Name: "), name_w, Label("Age: "), age_w,
        ) # Grid
    ; props...) # Frame
    return Profile(container, picture, image, name_w, age_w)
end

Profile(name::String, age::Real; props...) = Profile(name, age, Image(); props...)
Profile(name::String, age::Real, image::String; props...) = Profile(name, age, Image(image); props...)

imgpath = joinpath(@__DIR__, "..", "assets/image.png")
profile = Profile("Renge Miyauchi", 7, imgpath, margin = 20)

app = Window("Widgets", 800, 600, 
    CBox(:v,
        profile
    ) # CBox
) # Window

@showall app; nothing