###############################################################################
# ANIMAÇÃO DO TRIÂNGULO DE SIERPINSKI — Jogo do Caos
# Usando Luxor.jl
#
# Autor:        Igo da Costa Andrade
# GitHub:       https://github.com/costandrad
# TikTok:       https://www.tiktok.com/@igoandrade
# Repositório:    <@seu_instagram>           # opcional
# Data:         <AAAA-MM-DD>
#
# Descrição:
#   Este script cria uma animação vertical (formato TikTok — 1080×1920)
#   mostrando o processo iterativo conhecido como "Jogo do Caos", que gera
#   o famoso Triângulo de Sierpinski.
#
#   O código:
#     • Gera imagens quadro a quadro com Luxor.jl
#     • Mantém os pontos acumulados ao longo da animação
#     • Exporta automaticamente um GIF (e opcionalmente MP4)
#     • Organiza a saída em pastas limpas dentro de /output
#
# Licença:      <MIT | Apache 2.0 | CC BY-SA | sua escolha>
###############################################################################


using Luxor, Random, Printf

# ---------------------------------------------------------------------------
# Função auxiliar: recria um diretório (remove se existir e cria novo)
# ---------------------------------------------------------------------------
function create_dir(complete_dir_name)
    if isdir(complete_dir_name)
        rm(complete_dir_name; force=true, recursive=true)
    end
    mkdir(complete_dir_name)
end


begin
    ###############################################################################
    # CONFIGURAÇÕES GERAIS DA ANIMAÇÃO
    ###############################################################################
    total_frames = 25             # Número total de quadros
    frame_rate   = 60             # Quadros por segundo da animação final

    width        = 1080           # Largura — formato vertical (TikTok/Reels)
    height       = 1920           # Altura   — formato 9:16


    ###############################################################################
    # PARÂMETROS DO TRIÂNGULO DE SIERPINSKI
    ###############################################################################
    n     = 3                     # Número de vértices (triângulo)
    α     = 2π / n                # Ângulo entre vértices
    raio  = 0.5 * width           # Raio do polígono base

    # Armazena todos os pontos sucessivos gerados pelo Jogo do Caos
    positions = [Point(0, 0)]


    ###############################################################################
    # ESTRUTURA DE PASTAS (OUTPUT / FRAMES)
    ###############################################################################
    project_dir = pwd()
    main_name   = @sprintf("sierpinski_anim_f%d_fps%d", total_frames, frame_rate)

    output_dir  = joinpath(project_dir, "output", main_name)
    frames_dir  = joinpath(output_dir, "frames")

    create_dir(output_dir)
    create_dir(frames_dir)


    ###############################################################################
    # CRIAÇÃO DO OBJETO MOVIE
    ###############################################################################
    movie_sierpinski = Movie(width, height, main_name, 1:total_frames)


    ###############################################################################
    # FUNÇÃO DE CENÁRIO (FUNDO / TEXTOS)
    ###############################################################################
    function backdrop(scene, frame)
        background("black")

        # Título principal
        setfont("Arial Bold", 80)
        setcolor("white")
        settext("Jogo do Caos",
            Point(0, -0.35 * height),
            halign="center", valign="center")

        # Subtítulo
        setfont("Arial", 72)
        settext("Triângulo de Sierpinski",
            Point(0, 0.20 * height),
            halign="center", valign="center")

        # Número do frame
        setfont("Arial", 60)
        settext(@sprintf("n = %4d", frame),
            Point(0, 0.25 * height),
            halign="center", valign="center")
    end


    ###############################################################################
    # FUNÇÃO DO MÉTODO DO JOGO DO CAOS (Sierpinski)
    ###############################################################################
    function sierpinski(scene, frame)
        # Cálculo dos vértices do triângulo
        vertices = [
            Point( raio * cos((k - 1) * α - π/2),
                   raio * sin((k - 1) * α - π/2) )
            for k in 1:n
        ]

        # Desenha o triângulo base
        setline(3)
        setcolor("white")
        ngon(Point(0, 0), raio, n, -π/2, action=:stroke)

        # Parâmetros visuais das partículas
        setcolor("blue")

        # Passo do Jogo do Caos
        vertice = vertices[rand(1:n)]
        p = midpoint(positions[end], vertice)

        # Guarda ponto acumulado
        push!(positions, p)

        # Desenha trilha acumulada
        for point in positions
            circle(point, 3.5, :fill)
        end

        # Destaque do ponto atual
        setcolor("white")
        circle(p, 15, :fill)
    end


    ###############################################################################
    # EXECUÇÃO DA ANIMAÇÃO
    ###############################################################################
    animate(
        movie_sierpinski,
        [
            Scene(movie_sierpinski, backdrop,   1:total_frames),
            Scene(movie_sierpinski, sierpinski, 1:total_frames)
        ],
        creategif    = true,
        framerate    = frame_rate,
        tempdirectory= frames_dir,
        pathname     = joinpath(output_dir, "$(main_name).gif")
    )
end
