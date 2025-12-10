## 🔺 Triângulo de Sierpinski Animado: O Jogo do Caos

Este projeto utiliza a linguagem **Julia** e a biblioteca de gráficos **Luxor.jl** para criar uma animação vertical ($\text{1080} \times \text{1920}$ — formato $\text{9:16}$ para plataformas como TikTok e Reels) que demonstra o processo iterativo conhecido como **Jogo do Caos** (*Chaos Game*), o qual gera o famoso fractal do **Triângulo de Sierpinski**.

### 🎲 O Jogo do Caos (*Chaos Game*)

O Triângulo de Sierpinski é um dos fractais mais conhecidos, e o Jogo do Caos é um método probabilístico surpreendentemente simples para construí-lo:

1.  **Defina os Vértices:** Comece com os três vértices de um triângulo equilátero (ou, de forma mais geral, qualquer triângulo).
2.  **Ponto Inicial:** Escolha um ponto inicial aleatório em qualquer lugar.
3.  **Iteração:** Repita os seguintes passos indefinidamente:
      * Escolha um dos três vértices aleatoriamente.
      * Marque um novo ponto na metade exata do caminho entre o ponto atual e o vértice escolhido.
      * O novo ponto torna-se o ponto atual para a próxima iteração.

A animação mostra a acumulação desses pontos a cada quadro, revelando gradualmente a estrutura auto-similar do fractal.

### ⚙️ Pré-requisitos e Instalação

O projeto requer a linguagem Julia e o gerenciador de pacotes para as dependências.

1.  **Instale Julia:** Baixe e instale a versão mais recente de Julia.
2.  **Instale as Dependências do Projeto:**
      * Navegue até o diretório do projeto no terminal.
      * Inicie o ambiente Julia:
        ```bash
        julia
        ```
      * Ative o ambiente e instale os pacotes listados em `Project.toml` e `Manifest.toml`:
        ```julia
        julia> using Pkg
        julia> Pkg.activate(".")
        julia> Pkg.instantiate()
        ```
3.  **FFmpeg (Opcional, mas Recomendado):** Para exportar o vídeo final no formato MP4, você precisa ter o **FFmpeg** instalado e acessível no seu `$PATH`.

### 🚀 Como Executar

O script principal `src/main.jl` é auto-suficiente e orquestra a geração dos quadros, a criação do GIF e a conversão opcional para MP4.

1.  **Execute o script:**
    ```bash
    julia src/main.jl
    ```

### 🖼️ Estrutura de Saída

O script automaticamente cria a seguinte estrutura de pastas e arquivos no diretório raiz do projeto:

```
├── output
│   └── sierpinski_anim_f1500_fps60/ # Nome da pasta gerado automaticamente
│       ├── frames/
│       │   ├── 0000000001.png
│       │   ├── 0000000002.png
│       │   └── ...
│       ├── sierpinski_anim_f1500_fps60.gif  # Animação GIF gerada pelo Luxor
│       └── sierpinski_anim_f1500_fps60.mp4  # Vídeo MP4 gerado pelo FFmpeg
```

**Observação:** O nome da pasta de saída (`sierpinski_anim_f1500_fps60` no exemplo) é gerado dinamicamente com base no número de *frames* e na taxa de quadros (*FPS*) definidos no `main.jl`.

### 🛠️ Configurações Principais

Você pode ajustar os parâmetros da animação editando as seguintes variáveis no arquivo `src/main.jl`:

| Variável | Descrição | Valor Padrão |
| :--- | :--- | :--- |
| `total_frames` | Número total de quadros a serem gerados. | `1500` |
| `frame_rate` | Taxa de quadros por segundo (FPS) do vídeo final. | `60` |
| `width` | Largura do quadro em pixels. | `1080` |
| `height` | Altura do quadro em pixels. | `1920` |
| `n` | Número de vértices do polígono base (para Triângulo de Sierpinski, é `3`). | `3` |

-----

### 📝 Licença

Este projeto é distribuído sob a licença **[SUA ESCOLHA DE LICENÇA]**.

-----

### 🔗 Autor

  * **Igo da Costa Andrade**
  * **GitHub:** [https://github.com/costandrad](https://github.com/costandrad)
  * **TikTok:** [https://www.tiktok.com/@igoandrade](https://www.tiktok.com/@igoandrade)

-----