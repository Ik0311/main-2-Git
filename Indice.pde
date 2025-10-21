// =============================================================
// 📘 ÍNDICE DE VARIABLES - Proyecto: Astro Swing
// =============================================================
// Este bloque documenta las variables globales y estructuras
// utilizadas en el juego. No interfiere con el código al estar
// completamente comentado.
// =============================================================

// -------------------------------------------------------------
// 🎮 ESTADO DEL JUEGO
// -------------------------------------------------------------
// enMenu          → true si el jugador está en el menú principal, false si está en partida.

// -------------------------------------------------------------
// 👾 JUGADOR
// -------------------------------------------------------------
// px, py          → posición del jugador.
// vx, vy          → velocidad horizontal y vertical del jugador.
// acel            → aceleración lateral.
// fric            → fricción aplicada cuando no hay entrada.
// velMax          → velocidad máxima permitida.
// grav            → gravedad global del mundo (ajustable con el deslizador).
// enSuelo         → true si el jugador está tocando el suelo.

// -------------------------------------------------------------
// 🪢 GANCHO
// -------------------------------------------------------------
// ganchoAct       → indica si el gancho está activo.
// hook            → punto de anclaje del gancho (PVector).
// lenCuerda       → longitud actual de la cuerda.
// tens            → tensión aplicada a la cuerda (rebote o elasticidad).

// -------------------------------------------------------------
// 🎥 CÁMARA
// -------------------------------------------------------------
// camX            → posición de la cámara en el eje X.
// camDelay        → suavizado del movimiento de la cámara (cuanto menor, más rápido sigue al jugador).

// -------------------------------------------------------------
// ☄️ ASTEROIDES
// -------------------------------------------------------------
// ast             → lista de posiciones de los asteroides (ArrayList<PVector>).
// astDist         → distancia horizontal entre asteroides generados.
// ultAstX         → posición X del último asteroide creado para el scroll infinito.

// -------------------------------------------------------------
// 💎 GEMAS
// -------------------------------------------------------------
// gemas           → lista de objetos tipo Gema que el jugador puede recolectar.
// score           → contador del puntaje acumulado al recolectar gemas.

// -------------------------------------------------------------
// ⚙️ INTERFAZ (UI)
// -------------------------------------------------------------
// ui              → objeto ControlP5 encargado de los botones y sliders del menú y la interfaz de usuario.

// -------------------------------------------------------------
// 🖼️ FUTURAS IMPLEMENTACIONES
// -------------------------------------------------------------
// spriteJugadorIdle, spriteJugadorSalto, spriteJugadorGancho → posibles animaciones del jugador.
// spriteAsteroide, spriteGema, spriteFondo → texturas para los objetos del mundo.
// sonidos, música de fondo y efectos especiales.
// sistema de pausa, reinicio y transición de niveles.
// =============================================================
