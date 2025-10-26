// ======================================================
// ÍNDICE DE VARIABLES, FUNCIONES Y GUÍA DE SPRITES
// ======================================================
//
// --- GENERAL ---
// enMenu → indica si estás en el menú principal
// ui → interfaz gráfica del menú (botones y sliders)
// tiempoMax, tiempoRestante, inicioNivel → controlan el tiempo del nivel
// nivelTerminado → true cuando acaba el nivel
//
// --- JUGADOR ---
// px, py → posición del jugador
// vx, vy → velocidad en X y Y
// acel → aceleración lateral
// fric → fricción cuando no se mueve
// velMax → velocidad máxima horizontal
// grav → gravedad
// enSuelo → indica si está tocando el suelo o una plataforma
//
// movIzq, movDer, saltar → controlan el movimiento con el teclado
//
// vida → puntos de vida del jugador
// invulnerable, ultimoHit, tiempoInvul → controlan el tiempo sin recibir daño tras ser golpeado
//
// --- GANCHO ---
// ganchoAct → indica si el gancho está activo
// hook → coordenadas del punto donde se engancha
// lenCuerda → largo de la cuerda del gancho
// tens → tensión del gancho (influye en el estiramiento)
//
// --- CÁMARA ---
// camX → posición horizontal de la cámara
// camDelay → suavidad con que la cámara sigue al jugador
//
// --- ASTEROIDES ---
// ast → lista de asteroides
// astDist → distancia mínima entre asteroides
// ultAstX → última posición X donde se generó uno
//
// --- PLATAFORMAS ---
// plataformas → lista de plataformas del nivel
// generarNivel() → crea plataformas aleatorias
//
// --- GEMAS ---
// gemas → lista de gemas (coleccionables)
// score → número de gemas recogidas
// generarGemas(), dibujarGemas(), verificarRecoleccion() → manejo completo
//
// --- OBSTÁCULOS ---
// obstaculos → lista de bolas rojas que hacen daño al tocarse
// generarObstaculos(), dibujarObstaculos(), verificarDañoObstaculos() → controlan su aparición y colisión
//
// --- DAÑO Y VIDA ---
// Si el jugador toca el suelo del fondo, recibe daño (ver moverJugador())
// Al recibir daño se activa un rebote (vy = -8f)
// Al reiniciar el nivel, la vida vuelve a su valor inicial (vida = 3)
//
// --- HUD (INTERFAZ DEL JUEGO) ---
// mostrarHUD() → muestra tiempo, puntuación y vidas
// mostrarPantallaFinal() → muestra la pantalla al acabar el nivel
//
// --- REINICIO ---
// reiniciarNivel() → reinicia todas las variables y vuelve a generar el nivel
//
// ======================================================
// CÓMO AÑADIR SPRITES (IMÁGENES)
// ======================================================
//
// 1️⃣ CREA UNA CARPETA llamada "data" dentro del proyecto de Processing.
//
// 2️⃣ COLOCA TUS IMÁGENES dentro de esa carpeta, por ejemplo:
//     - jugador.png
//     - gema.png
//     - obstaculo.png
//     - fondo.png
//
// 3️⃣ DECLARA variables de tipo PImage:
//
//     PImage imgJugador;
//     PImage imgGema;
//     PImage imgObstaculo;
//     PImage imgFondo;
//
// 4️⃣ CARGA LAS IMÁGENES en setup():
//
//     void setup() {
//       size(1600, 900);
//       imgJugador = loadImage("jugador.png");
//       imgGema = loadImage("gema.png");
//       imgObstaculo = loadImage("obstaculo.png");
//       imgFondo = loadImage("fondo.png");
//       // resto de setup...
//     }
//
// 5️⃣ DIBUJA LAS IMÁGENES en lugar de las figuras:
//
//     // Jugador:
//     image(imgJugador, px - 20, py - 30, 40, 60);
//
//     // Gema:
//     image(imgGema, g.pos.x - 10, g.pos.y - 10, 20, 20);
//
//     // Obstáculo:
//     image(imgObstaculo, o.pos.x - 15, o.pos.y - 15, 30, 30);
//
//     // Fondo (antes de todo):
//     image(imgFondo, camX, 0, width, height);
//
// 6️⃣ OPCIONAL: Si quieres animaciones, puedes usar varios fotogramas:
//     - Crea un array de PImage[] con cada frame del sprite.
//     - Usa frameCount % númeroFrames para alternarlos.
//
// ======================================================
// FIN DEL ÍNDICE
// ======================================================
