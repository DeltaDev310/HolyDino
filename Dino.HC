#link <SDL2>
#link <SDL2_image>

extern "c" I32 SDL_RenderFillRect(U8 *renderer, I32 *rect);
extern "c" I32 SDL_Init(U32 flags);
extern "c" U0 SDL_Quit();
extern "c" U8 *SDL_CreateWindow(U8 *title, I32 x, I32 y, I32 w, I32 h, U32 flags);
extern "c" U8 *SDL_CreateRenderer(U8 *window, I32 index, U32 flags);
extern "c" U8 *IMG_Load(U8 *file);
extern "c" U8 *SDL_CreateTextureFromSurface(U8 *renderer, U8 *surface);
extern "c" U0 SDL_FreeSurface(U8 *surface);
extern "c" I32 SDL_SetRenderDrawColor(U8 *renderer, U8 r, U8 g, U8 b, U8 a);
extern "c" I32 SDL_RenderClear(U8 *renderer);
extern "c" I32 SDL_RenderCopy(U8 *renderer, U8 *texture, U8 *src, I32 *dst);
extern "c" U0 SDL_RenderPresent(U8 *renderer);
extern "c" U0 SDL_Delay(U32 ms);
extern "c" U0 SDL_PumpEvents();
extern "c" U8 *SDL_GetKeyboardState(I32 *numkeys);
extern "c" U32 SDL_GetTicks();
extern "c" U0 SDL_DestroyTexture(U8 *texture);
extern "c" U0 SDL_DestroyRenderer(U8 *renderer);
extern "c" U0 SDL_DestroyWindow(U8 *window);

U8 *LoadPNG(U8 *renderer, U8 *path)
{
    U8 *surface;
    U8 *texture;

    surface = IMG_Load(path);
    if (!surface)
        return 0;

    texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);
    return texture;
}

U0 Draw(U8 *renderer, U8 *texture, I32 x, I32 y, I32 w, I32 h)
{
    I32 rect[4];

    rect[0] = x;
    rect[1] = y;
    rect[2] = w;
    rect[3] = h;

    SDL_RenderCopy(renderer, texture, 0, rect);
}

U8 *Glyph(U8 c)
{
    switch (c)
    {
        case '0': return "111101101101111";
        case '1': return "010110010010111";
        case '2': return "111001111100111";
        case '3': return "111001111001111";
        case '4': return "101101111001001";
        case '5': return "111100111001111";
        case '6': return "111100111101111";
        case '7': return "111001001001001";
        case '8': return "111101111101111";
        case '9': return "111101111001111";
        case 'A': return "010101111101101";
        case 'C': return "111100100100111";
        case 'E': return "111100110100111";
        case 'G': return "111100101101111";
        case 'M': return "101111111101101";
        case 'O': return "111101101101111";
        case 'R': return "110101110101101";
        case 'S': return "111100111001111";
        case 'V': return "101101101101010";
        case ':': return "000010000010000";
        default:  return "000000000000000";
    }
}

U0 DrawText(U8 *renderer, U8 *text, I32 x, I32 y, I32 scale)
{
    I32 i, j, px, py, rect[4];
    U8 *bits;

    SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255);

    for (i = 0; text[i]; i++)
    {
        bits = Glyph(text[i]);

        for (j = 0; j < 15; j++)
        {
            if (bits[j] == '1')
            {
                px = x + (i * 4 + (j % 3)) * scale;
                py = y + (j / 3) * scale;

                rect[0] = px;
                rect[1] = py;
                rect[2] = scale;
                rect[3] = scale;

                SDL_RenderFillRect(renderer, rect);
            }
        }
    }
}

U0 DrawScore(U8 *renderer, I32 score)
{
    U8 digits[16];
    I32 n, i;

    n = 0;

    if (score == 0)
        digits[n++] = '0';

    while (score > 0 && n < 15)
    {
        digits[n++] = '0' + (score % 10);
        score /= 10;
    }

    for (i = 0; i < n / 2; i++)
    {
        U8 temp;
        temp = digits[i];
        digits[i] = digits[n - 1 - i];
        digits[n - 1 - i] = temp;
    }

    digits[n] = 0;

    DrawText(renderer, "SCORE:", 16, 16, 3);
    DrawText(renderer, digits, 100, 16, 3);
}

U0 main()
{
    U8 *window;
    U8 *renderer;
    U8 *dino;
    U8 *cactus;
    U8 *ground;
    U8 *background;
    U8 *keys;

    I32 dinoX;
    I32 dinoY;
    I32 velocity;
    I32 jumping;
    I32 cactusX;
    I32 groundX;
    I32 score;
    I32 gameOver;
    I32 previousSpace;
    I32 space;
    I32 i;
    I32 groundY;
    I32 dinoW;
    I32 dinoH;
    I32 cactusW;
    I32 cactusH;
    I32 groundW;
    I32 groundH;
    I32 hit;

    U32 lastTime;
    U32 now;

    if (SDL_Init(32) < 0)
        return;

    window = SDL_CreateWindow(
        "HolyC Chrome Dino",
        0x2FFF0000, 0x2FFF0000,
        800, 400, 4
    );

    if (!window)
    {
        SDL_Quit();
        return;
    }

    renderer = SDL_CreateRenderer(window, -1, 2);

    if (!renderer)
    {
        SDL_DestroyWindow(window);
        SDL_Quit();
        return;
    }

    dino = LoadPNG(renderer, "assets/dino.png");
    cactus = LoadPNG(renderer, "assets/cactus.png");
    ground = LoadPNG(renderer, "assets/ground.png");
    background = LoadPNG(renderer, "assets/background.png");

    if (!dino || !cactus || !ground || !background)
    {
        "Could not load sprites. Check assets/ filenames.\n";
        if (dino) SDL_DestroyTexture(dino);
        if (cactus) SDL_DestroyTexture(cactus);
        if (ground) SDL_DestroyTexture(ground);
        if (background) SDL_DestroyTexture(background);
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return;
    }

    dinoX = 80;
    dinoY = 256;
    dinoW = 48;
    dinoH = 48;

    cactusX = 800;
    cactusW = 32;
    cactusH = 48;

    groundY = 250;
    groundW = 32;
    groundH = 32;
    groundX = 0;

    velocity = 0;
    jumping = 0;
    score = 0;
    gameOver = 0;
    previousSpace = 0;

    lastTime = SDL_GetTicks();

    while (1)
    {
        SDL_PumpEvents();
        keys = SDL_GetKeyboardState(0);

        if (keys[41])
            break;

        space = keys[44];
        now = SDL_GetTicks();

        if (now - lastTime < 16)
        {
            SDL_Delay(1);
            continue;
        }

        lastTime = now;

        if (gameOver)
        {
            if (space && !previousSpace)
            {
                dinoY = 256;
                velocity = 0;
                jumping = 0;
                cactusX = 800;
                groundX = 0;
                score = 0;
                gameOver = 0;
            }
        }
        else
        {
            if (space && !previousSpace && !jumping)
            {
                velocity = -15;
                jumping = 1;
            }

            if (jumping)
            {
                dinoY += velocity;
                velocity += 1;

                if (dinoY >= 256)
                {
                    dinoY = 256;
                    velocity = 0;
                    jumping = 0;
                }
            }

            cactusX -= 6;
            groundX -= 6;

            if (cactusX < -cactusW)
                cactusX = 800 + 180 + (score % 150);

            if (groundX <= -groundW)
                groundX += groundW;

            score += 1;

            hit = 0;

            if (dinoX + dinoW - 8 > cactusX + 4 &&
                dinoX + 8 < cactusX + cactusW - 4 &&
                dinoY + dinoH - 4 > groundY - cactusH + 8)
            {
                hit = 1;
            }

            if (hit)
                gameOver = 1;
        }

        previousSpace = space;

        /* Clear frame. */
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_RenderClear(renderer);

        /* Sky/background. */
        Draw(renderer, background, 0, 0, 800, 400);

        /* Ground tiles. */
        for (i = -1; i < 27; i++)
        {
            Draw(renderer, ground,
                groundX + i * groundW,
                groundY,
                groundW, groundH);
        }

        /* Cactus stays on the ground. */
        Draw(renderer, cactus,
            cactusX,
            groundY - cactusH + 55,
            cactusW, cactusH);

        /* Dinosaur. */
        Draw(renderer, dino,
            dinoX, dinoY,
            dinoW, dinoH);
	DrawScore(renderer, score / 10);

if (gameOver)
{
    DrawText(renderer, "GAME OVER", 300, 170, 4);
}
        SDL_RenderPresent(renderer);
    }

    SDL_DestroyTexture(dino);
    SDL_DestroyTexture(cactus);
    SDL_DestroyTexture(ground);
    SDL_DestroyTexture(background);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}
