###############################################################################
# CHAOS GAME — FRACTAL ANIMATION (LUXOR.JL)
#
# Author:        Igo da Costa Andrade
# GitHub:        https://github.com/costandrad
# TikTok:        https://www.tiktok.com/@igoandrade
# Repository:    https://github.com/costandrad/chaos-game-sierpinski-triangle
# Date:          2025-12-10
#
# DESCRIPTION
#   Generates a vertical-format animation (1080×1920), suitable for TikTok/Reels,
#   illustrating the Chaos Game for regular polygons.
#
# FEATURES
#   • Frame-by-frame rendering using Luxor.jl
#   • Accumulation of chaos-game orbit points
#   • Automatic GIF export
#   • Optional lossless MP4 export via ffmpeg
#   • Structured output directory (/output/)
#
# ABOUT THE CHAOS GAME
#   At each iteration, a polygon vertex is chosen at random and the current
#   point moves a fixed fraction r toward it. Over many iterations, the orbit
#   converges to a fractal attractor (e.g., the Sierpinski triangle for n = 3).
#
# LICENSE
#   MIT License
###############################################################################

using Luxor, Colors, Random, Printf

###############################################################################
# FILESYSTEM UTILITIES
###############################################################################

# Create (or recreate) a directory
# Cria (ou recria) um diretório
function create_directory(path::AbstractString)
    if isdir(path)
        rm(path; force = true, recursive = true)
    end
    mkdir(path)
end

###############################################################################
# COLOR AND GEOMETRY UTILITIES
###############################################################################

# HSV color based on polar angle (good contrast on black background)
# Cor HSV baseada no ângulo polar (bom contraste em fundo preto)
function polar_hsv_color(p::Point)
    θ = atan(p.y, p.x)
    hue = θ ≥ 0 ? rad2deg(θ) : rad2deg(θ) + 360
    return HSV(hue, 0.5, 1.0)
end

# Optimal contraction ratio for regular n-gons
# Razão de contração "ótima" para n-gonos regulares
function optimal_contraction_ratio(n::Int)
    if n % 4 == 0
        return 1 / (1 + tan(π / n))
    elseif n % 4 == 2
        return 1 / (1 + sin(π / n))
    else
        return 1 / (1 + 2sin(π / (2n)))
    end
end


###############################################################################
# MAIN EXECUTION BLOCK
# Bloco principal de execução da animação
###############################################################################

###############################################################################
# GLOBAL ANIMATION PARAMETERS
###############################################################################

frame_rate = 25                      # frames per second
canvas_width, canvas_height = 1080, 1920

###############################################################################
# POLYGON CONFIGURATION
###############################################################################

polygon_names = Dict(
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

num_sides = 7
central_angle = 2π / num_sides
polygon_radius = 0.2 * canvas_width

# contraction_ratio = optimal_contraction_ratio(num_sides)
expanded_ratio = 1/optimal_contraction_ratio(num_sides)
polygon_label = num_sides == 3 ? "Sierpinski Triangle" : polygon_names[num_sides]

###############################################################################
# CHAOS GAME DATA GENERATION
###############################################################################

total_iterations = 100_000
points_per_frame = 500

# Polygon vertices
polygon_vertices = [
    Point(
        polygon_radius * cos((k - 1) * central_angle - π/2),
        polygon_radius * sin((k - 1) * central_angle - π/2)
    ) for k in 1:num_sides
]

# Chaos-game orbit
orbit_points = [Point(0, 0)]
random_vertices = polygon_vertices[rand(1:num_sides, total_iterations - 1)]

for vertex in random_vertices
    push!(
        orbit_points,
        between(orbit_points[end], vertex, expanded_ratio)
    )
end

###############################################################################
# FRAME COUNT AND OUTPUT STRUCTURE
###############################################################################

intro_frames = 8 * frame_rate
total_frames = (intro_frames - 1) + total_iterations ÷ points_per_frame

project_root = pwd()
animation_name = replace(
    @sprintf(
        "%s_r%.3f_frames%d_fps%d",
        polygon_label,
        expanded_ratio,
        total_frames,
        frame_rate
    ),
    "." => "_"
)

output_directory = joinpath(project_root, "output", animation_name)
frames_directory = joinpath(output_directory, "frames")

create_directory(output_directory)
create_directory(frames_directory)

###############################################################################
# MOVIE OBJECT
###############################################################################

movie = Movie(canvas_width, canvas_height, animation_name, 1:total_frames)

###############################################################################
# SCENE 1 — BACKGROUND AND STATIC ELEMENTS
###############################################################################

function draw_background(scene, frame)
    background("black")
    setcolor("white")

    setfont("Arial Bold", 60)
    settext(
        "Chaos Game",
        Point(0, -0.30 * canvas_height),
        halign = "center", valign = "center"
    )

    setline(3)
    ngon(Point(0, 0), polygon_radius, num_sides, -π/2, action = :stroke)

    setfont("Arial", 45)
    if num_sides == 3
        settext(
            @sprintf("%s", polygon_label),
            Point(0, -0.26 * canvas_height),
            halign = "center", valign = "center"
        )
    else
        settext(
            @sprintf("%s (r = %.3f)", polygon_label, expanded_ratio),
            Point(0, -0.26 * canvas_height),
            halign = "center", valign = "center"
        )
    end

end

###############################################################################
# SCENE 2 — CHAOS GAME EVOLUTION
###############################################################################

function draw_chaos_game(scene, frame)
    setfont("Arial", 45)
    setcolor("white")
    k = 0

    if frame <= frame_rate
        message = "1. Start with a polygon and an initial point P."
        circle(orbit_points[1], 15, :fill)

    elseif frame <= 2frame_rate
        message = "2. Choose a vertex V at random."
        circle(orbit_points[1], 15, :fill)
        circle(random_vertices[1], 15, :fill)

    elseif frame <= 3frame_rate
        message = "3. Move P a fixed fraction r > 1 toward V."
        circle(orbit_points[1], 15, :fill)
        circle(random_vertices[1], 15, :fill)
        line(orbit_points[1], orbit_points[2], :stroke)
        setcolor(polar_hsv_color(orbit_points[2]))
        circle(orbit_points[2], 15, :fill)
        setcolor("white")

    elseif frame < 8frame_rate
        message = "4. Iterate the procedure over many points." # 4
        k = (frame - 3*frame_rate) ÷ (frame_rate ÷ 2) + 1
        for p in orbit_points[1:k]
            setcolor(polar_hsv_color(p))
            circle(p, 10, :fill)
            setcolor("white")
        end
        circle(orbit_points[k], 15, :fill)
        circle(random_vertices[k], 15, :fill)
        line(orbit_points[k], orbit_points[k+1], :stroke)
        setcolor(polar_hsv_color(orbit_points[k+1]))
        circle(orbit_points[k+1], 15, :fill)
        setcolor("white")

    else
        message = "5. Iteration produces a fractal."
        k = points_per_frame * (frame - 8frame_rate + 1)

        for p in orbit_points[1:k]
            setcolor(polar_hsv_color(p))
            circle(p, 1, :fill)
            setcolor("white")
        end
    end

    setcolor("white")
    settext(
        message,
        Point(0, 0.30 * canvas_height),
        halign = "center", valign = "center"
    )

    if frame ≥ 3frame_rate
        settext(
            @sprintf("n = %6d", k),
            Point(0, 0.34 * canvas_height),
            halign = "center", valign = "center"
        )
    end
end

###############################################################################
# ANIMATION RENDERING
###############################################################################

animate(
    movie,
    [
        Scene(movie, draw_background, 1:total_frames),
        Scene(movie, draw_chaos_game, 1:total_frames),
    ],
    creategif     = true,
    framerate     = frame_rate,
    tempdirectory = frames_directory,
    pathname      = joinpath(output_directory, "$(animation_name).gif")
)

###############################################################################
# OPTIONAL: SAVE LAST IMAGE
###############################################################################
last_image = @sprintf("%010d.png", total_frames)
old_path = joinpath(frames_directory, "$(last_image)")
new_path = joinpath(output_directory, "$(animation_name).png")
mv(old_path, new_path)

###############################################################################
# OPTIONAL: MP4 EXPORT (requires ffmpeg)
###############################################################################
mp4_path = joinpath(output_directory, "$(animation_name).mp4")

ffmpeg_cmd = `ffmpeg -r $frame_rate -i "$frames_directory/%10d.png" -c:v h264 -crf 0 "$mp4_path"`

println("\nGenerating MP4 using ffmpeg...\n")
run(ffmpeg_cmd)
println("\nMP4 generated at: $mp4_path")
