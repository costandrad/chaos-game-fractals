###############################################################################
# Chaos Game Animation
# Using Luxor.jl
#
# Author:      Igo da Costa Andrade
# GitHub:      https://github.com/costandrad
# TikTok:      https://www.tiktok.com/@igoandrade
# Repository:  https://github.com/costandrad/chaos-game-sierpinski-triangle
# Date:        2025-12-10
#
# DESCRIPTION
#   This script generates a vertical-format animation (1080×1920, suitable for
#   TikTok/Reels) illustrating the iterative construction of the
#   Sierpinski Triangle using the classical "Chaos Game" method.
#
#   Features:
#     • Frame-by-frame rendering with Luxor.jl
#     • Accumulation of all generated chaos-game points
#     • Automatic GIF export (and optional lossless MP4 via ffmpeg)
#     • Structured output folder inside /output/
#
#   About the Chaos Game:
#     The chaotic iterative map repeatedly selects a polygon vertex at random
#     and moves a fixed fraction toward it. Over many iterations, the orbit
#     converges to a fractal attractor — e.g., the Sierpinski triangle when
#     n = 3. This script supports general n-gons, using an "optimal" rate for
#     fractal formation.
#
# LICENSE
#   MIT License
###############################################################################


using Luxor, Colors, Random, Printf


function create_dir(complete_dir_name)
    if isdir(complete_dir_name)
        rm(complete_dir_name; force=true, recursive=true)
    end
    mkdir(complete_dir_name)
end

function vibrant_on_black(point)
    x = point.x
    y = point.y

    θ = atan(y, x)
    hue_deg = ifelse(θ >= 0, rad2deg(θ), rad2deg(θ) + 360)

    return HSV(hue_deg, 0.5, 1.0)
end

function optimal_rate(n)
    if n % 4 == 0
        r_opt = 1/(1 + tan(π/n))
    elseif n % 4 == 2
        r_opt = 1/(1 + sin(π/n))
    else
        r_opt = 1/(1 + 2 * sin(π/(2n)))
    end
    return r_opt
end


frame_rate   = 25

width  = 1080
height = 1920

polygons = Dict(
    3  => "Triangle",
    4  => "Square",
    5  => "Pentagon",
    6  => "Hexagon",
    7  => "Heptagon",
    8  => "Octagon",
    9  => "Nonagon",
    10 => "Decagon",
    11 => "Hendecagon",
    12 => "Dodecagon",
    20 => "Icosagon"
)

n = 8
α = 2π / n
radius = 0.45 * width
r_opt = optimal_rate(n)
polygon_name = polygons[n]

positions = [Point(0, 0)]
vertices = [
    Point(
        radius * cos((k - 1) * α - π/2),
        radius * sin((k - 1) * α - π/2)
    )
    for k in 1:n
]

total_points = 10000
m = 500
total_frames = (8*frame_rate - 1) + total_points ÷ m
random_vertices = vertices[rand(1:n, total_points-1)]
for vertice in random_vertices
    push!(positions, between(positions[end], vertice, r_opt))
end


project_dir = pwd()
main_name   = replace(@sprintf("%s_ropt%.3f_f%d_fps%d",
                                polygon_name, r_opt, total_frames, frame_rate),
                        "." => "_")

output_dir = joinpath(project_dir, "output", main_name)
frames_dir = joinpath(output_dir, "frames")


create_dir(output_dir)
create_dir(frames_dir)

###############################################################################
# MOVIE OBJECT
###############################################################################
movie = Movie(width, height, main_name, 1:total_frames)

###############################################################################
# BACKGROUND SCENE (TEXT / BACKDROP)
###############################################################################
function backdrop(scene, frame)
    background("black")

    setcolor("white")
    
    setfont("Arial Bold", 80)
    settext("Chaos Game",
        Point(0, -1.4 * radius),
        halign = "center", valign = "center")

    # Draw base polygon
    setline(3)
    ngon(Point(0, 0), radius, n, -π/2, action = :stroke)

    setfont("Arial", 60)
    settext(@sprintf("%s (r = %.3f)", polygon_name, r_opt),
        Point(0, - 1.2 * radius),
        halign = "center", valign = "center")
end



function draw_pattern(scene, frame)
    # Compute polygon vertices


    setfont("Arial", 45)
    setcolor("white")
    if frame < frame_rate
        msg = "1. Start with a polygon and an initial point P." # 1
        circle(positions[1], 15, :fill)
    elseif frame < 2*frame_rate
        msg = "2. Choose a vertex V at random." # 2
        circle(positions[1], 15, :fill)
        circle(random_vertices[1], 15, :fill)
    elseif frame < 3*frame_rate
        msg = "3. Move P a fixed fraction r toward V." # 3
        circle(positions[1], 15, :fill)
        circle(random_vertices[1], 15, :fill)
        line(positions[1], random_vertices[1], :stroke)
        setcolor(vibrant_on_black(positions[2]))
        circle(positions[2], 15, :fill)
        setcolor("white")
    elseif frame < 8*frame_rate
        msg = "4. Iterate the procedure over many points." # 4
        k = (frame - 3*frame_rate) ÷ (frame_rate ÷ 2) + 1
        for point in positions[1:k]
            setcolor(vibrant_on_black(point))
            circle(point, 5, :fill)
            setcolor("white")
        end
        circle(positions[k], 15, :fill)
        circle(random_vertices[k], 15, :fill)
        line(positions[k], random_vertices[k], :stroke)
        setcolor(vibrant_on_black(positions[k+1]))
        circle(positions[k+1], 15, :fill)
        setcolor("white")
    else 
        msg = "5. Iteration produces a fractal." # 5
        k = m * (frame - 8*frame_rate + 1)
        for point in positions[1:k]
            setcolor(vibrant_on_black(point))
            circle(point, 1, :fill)
            setcolor("white")
        end
    end
        
    settext(msg,
        Point(0, 1.2 * radius),
        halign = "center", valign = "center")

    if frame >= 3*frame_rate
    settext(@sprintf("n = %6d", k),
        Point(0, 1.4 * radius),
        halign = "center", valign = "center")
    end
end

animate(
    movie,
    [
        Scene(movie, backdrop,     1:total_frames),
        Scene(movie, draw_pattern, 1:total_frames),
    ],
    creategif     = true,
    framerate     = frame_rate,
    tempdirectory = frames_dir,
    pathname      = joinpath(output_dir, "$(main_name).gif")
)

    ###############################################################################
    # OPTIONAL MP4 EXPORT (requires ffmpeg)
    ###############################################################################
    mp4_path = joinpath(output_dir, "$(main_name).mp4")

    cmd = `ffmpeg -r $frame_rate -i "$frames_dir/%10d.png" -c:v h264 -crf 0 "$mp4_path"`

    println("\nGenerating MP4 using ffmpeg...\n")
    println(cmd)

    run(cmd)

    println("\nMP4 generated at: $mp4_path")