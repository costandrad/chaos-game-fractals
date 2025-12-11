# Chaos Game Fractal Generator

## 1. Visão Geral

O script produz:

* uma animação frame‑a‑frame do Chaos Game;
* uma versão em **GIF** automaticamente;
* uma versão em **MP4** usando `ffmpeg` (opcional);
* todas as imagens organizadas dentro do diretório `output/`.

É possível alterar o número de lados do polígono para gerar outros atratores fractais.

---

## 2. Estrutura do Arquivo

O arquivo está dividido nas seguintes partes principais:

1. **Cabeçalho e metadados**: informações do autor e descrição do projeto.
2. **Imports**: carregamento de Luxor, Colors, Random e demais dependências.
3. **Funções utilitárias**:

   * `create_dir` — recria diretórios de forma segura.
   * `vibrant_on_black` — gera cores vibrantes em HSV.
   * `optimal_rate` — calcula a taxa ideal do Chaos Game para *n*-gons.
4. **Parâmetros gerais da animação**: resolução, fps, duração.
5. **Configurações do Chaos Game**: número de lados, raio, vértices etc.
6. **Organização de diretórios**: criação das pastas `output/` e `frames/`.
7. **Objeto Movie do Luxor**.
8. **Função de fundo (backdrop)**.
9. **Função principal de desenho (draw_pattern)**.
10. **Chamada principal para gerar a animação**.
11. **Exportação opcional em MP4**.

---

## 3. Documentação das Funções

### 3.1 `create_dir(path)`

Remove um diretório existente (se houver) e cria novamente.

**Uso:**

* Garante que a pasta de saída sempre comece vazia.

**Argumentos:**

* `path` — caminho completo do diretório.

**Efeitos colaterais:**

* Remove arquivos existentes (`rm(..., force=true, recursive=true)`).

---

### 3.2 `vibrant_on_black(point, radius)`

Gera uma cor **vibrante e clara**, contrastando com o fundo preto.

**Ideia principal:**

* A cor depende do ângulo polar do ponto, criando um espectro circular.
* A saturação/valor dependem da distância ao centro.

**Retorna:**

* Um objeto `HSV(hue, saturation, value)`.

---

### 3.3 `optimal_rate(n)`

Computa a razão ideal para o Chaos Game em polígonos regulares.

**Baseado em:**

* aproximações geométricas conhecidas para formação de atratores.

**Retorna:**

* `r_opt ∈ (0,1)` — quanto a posição se move em direção a um vértice.

**Casos tratados:**

* `n % 4 == 0`
* `n % 4 == 2`
* qualquer outro caso

---

## 4. Parâmetros Globais da Animação

* **Duração**: 20 s
* **FPS**: 144
* **Resolução**: 1080 × 1920
* **Total de frames**: `duration * fps`

### Polígonos disponíveis

Um dicionário mapeia número de lados → nome:

* 3 → Triangle
* 4 → Square
* ...
* 12 → Dodecagon
* 20 → Icosagon

O usuário pode alterar `n = 5` para escolher o polígono.

### Parâmetros do Chaos Game

* `α = 2π/n` — ângulo entre vértices.
* `radius = 0.45 * width` — tamanho do polígono.
* `r_opt = optimal_rate(n)` — taxa ideal.
* `positions = [Point(0,0)]` — lista acumulada de pontos.

---

## 5. Organização de Diretórios

Três pastas são criadas:

* **output/** — pasta principal do projeto.
* **frames/** — todos os PNGs temporários.
* arquivo final `.gif` + `.mp4`.

Essas pastas são geradas com segurança por `create_dir`.

---

## 6. Construção da Animação com Luxor

### 6.1 Objeto Movie

```julia
movie_sierpinski = Movie(width, height, main_name, 1:total_frames)
```

Gerencia a renderização de cada frame.

---

### 6.2 Função `backdrop(scene, frame)`

Desenha:

* fundo preto;
* título "Chaos Game";
* nome do polígono + taxa r;
* número do frame.

Usa `setfont`, `settext`, e alinhamento centrado.

---

### 6.3 Função `draw_pattern(scene, frame)`

É o **coração da animação**.

Passos:

1. Calcula os vértices do polígono regular.
2. Desenha o polígono base.
3. Executa um passo do Chaos Game:

   * seleciona vértice aleatório;
   * interpola usando `between` com `r_opt`;
   * salva a posição.
4. Desenha todos os pontos anteriores:

   * com cores de `vibrant_on_black`.
5. Destaca o ponto atual com um círculo branco.

Assim, o fractal emerge gradualmente.

---

## 7. Geração da Animação

A animação é criada com:

```julia
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
```

O Luxor gera **todos os frames PNG** e depois cria o **GIF**.

---

## 8. Exportação MP4 via FFmpeg

Opcionalmente, um comando é executado:

```bash
ffmpeg -r FPS -i "%10d.png" -c:v h264 -crf 0 output.mp4
```

* `-crf 0` garante qualidade máxima (lossless).
* O arquivo final é salvo em `output/.../*.mp4`.

---

## 9. Como Modificar

### Alterar o polígono

Basta trocar:

```julia
n = 5
```

Para qualquer valor entre 3 e 20 definido no dicionário.

### Aumentar resolução

Modifique:

```julia
width, height
```

### Alterar duração ou FPS

```julia
duration = 20
frame_rate = 144
```

---
