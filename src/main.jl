###############################################################################
# Sierpinski Triangle — Chaos Game Animation
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

# ---------------------------------------------------------------------------
# Utility function: recreate a directory (remove if exists, then create)
# ---------------------------------------------------------------------------
function create_dir(complete_dir_name)
    if isdir(complete_dir_name)
        rm(complete_dir_name; force=true, recursive=true)
    end
    mkdir(complete_dir_name)
end

# ---------------------------------------------------------------------------
# Color function: calculates a vibrant HSV tone based on angle/distance
# ---------------------------------------------------------------------------
function vibrant_on_black(point, radius)
    x = point.x
    y = point.y

    r = sqrt(x^2 + y^2)

    θ = atan(y, x)
    hue_deg = ifelse(θ >= 0, rad2deg(θ), rad2deg(θ) + 360)

    s = 0.4 + 0.1*(1 - r/radius)
    v = 0.9 + 0.1*(1 - r/radius)

    return HSV(hue_deg, s, v)
end

# ---------------------------------------------------------------------------
# Computes the optimal chaos-game ratio for n-sided polygons
# ---------------------------------------------------------------------------
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


begin
    ###############################################################################
    # GENERAL ANIMATION SETTINGS
    ###############################################################################
    duration = 20     # seconds
    frame_rate   = 25
    total_frames = frame_rate * duration

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

    ###############################################################################
    # CHAOS GAME PARAMETERS
    ###############################################################################
    n = 6
    α = 2π / n
    radius = 0.45 * width
    r_opt = optimal_rate(n)
    polygon_name = polygons[n]

    positions = [Point(0, 0)]


    ###############################################################################
    # FOLDER STRUCTURE
    ###############################################################################
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
    movie_sierpinski = Movie(width, height, main_name, 1:total_frames)

    ###############################################################################
    # BACKGROUND SCENE (TEXT / BACKDROP)
    ###############################################################################
    function backdrop(scene, frame)
        background("black")

        setfont("Arial Bold", 80)
        setcolor("white")
        settext("Chaos Game",
            Point(0, -1.4 * radius),
            halign = "center", valign = "center")

        setfont("Arial", 60)
        settext(@sprintf("%s (r = %.3f)", polygon_name, r_opt),
            Point(0, - 1.2 * radius),
            halign = "center", valign = "center")

        setfont("Arial", 48)
        settext(@sprintf("n = %4d", frame),
            Point(0, 1.2 * radius),
            halign = "center", valign = "center")
    end

    ###############################################################################
    # CHAOS GAME DRAWING FUNCTION
    ###############################################################################
    function draw_pattern(scene, frame)
        # Compute polygon vertices
        vertices = [
            Point(
                radius * cos((k - 1) * α - π/2),
                radius * sin((k - 1) * α - π/2)
            )
            for k in 1:n
        ]

        # Draw base polygon
        setline(3)
        setcolor("white")
        ngon(Point(0, 0), radius, n, -π/2, action = :stroke)

        # Chaos game step
        vertex = vertices[rand(1:n)]
        p = between(positions[end], vertex, r_opt)

        # Save new point
        push!(positions, p)

        # Draw accumulated points
        for point in positions[5:end]
            setcolor(vibrant_on_black(point, radius))
            circle(point, 2.5, :fill)
        end

        # Highlight current point
        setcolor("white")
        circle(p, 15, :fill)
    end

    ###############################################################################
    # RUN ANIMATION
    ###############################################################################
    animate(
        movie_sierpinski,
        [
            Scene(movie_sierpinski, backdrop,     1:total_frames),
            Scene(movie_sierpinski, draw_pattern, 1:total_frames)
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
end
