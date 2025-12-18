using Luxor, Colors, Random, Printf

function ease_hold(t; a=0.3, b=0.7)
    if t < a
        return t/a * 0.5
    elseif t ≤ b
        return 0.5
    else
        return 0.5 + (t-b)/(1-b) * 0.5
    end
end

total_frames = 100

function backdrop(scene, frame)
    background("black")
end

function draw_pattern(scene, frame)
    setcolor("white")
    t = frame/(total_frames)
    θ = 2π * ease_hold(t)

    x, y = 100 * cos(θ), 100 * sin(θ)

    circle(Point(x, y), 5, :fill)


end

movie = Movie(600, 600, "testes", 1:total_frames)

animate(movie, 
    [
        Scene(movie, backdrop, 1:total_frames),
        Scene(movie, draw_pattern, 1:total_frames)
    ],
    creategif     = true,
)