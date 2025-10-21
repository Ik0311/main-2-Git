import controlP5.*;
ControlP5 ui;

// Estados
boolean enMenu = true;

// === Variables del jugador ===
float px = 100f, py = 300f;
float vx = 0f, vy = 0f;
float acel = 0.6f;
float fric = 0.85f;
float velMax = 8f;
float grav = 0.5f;
boolean enSuelo = false;

// === Gancho ===
boolean ganchoAct = false;
PVector hook = new PVector();
float lenCuerda = 0f;
float tens = 0.1f;

// === Cámara ===
float camX = 0f;
float camDelay = 0.1f;

// === Asteroides ===
ArrayList<PVector> ast = new ArrayList<PVector>();
float astDist = 400f;
float ultAstX = 0f;

// === NIVEL Y TIEMPO ===
int tiempoMax = 60;     // segundos de duración del nivel
int tiempoRestante;      // contador regresivo
int inicioNivel;         // momento en que empezó la partida
boolean nivelTerminado = false;

// === GEMAS ===
ArrayList<Gema> gemas;
int score = 0;

// === SETUP ===
void setup() {
  size(1600, 900);
  ui = new ControlP5(this);

  // --- Menú ---
  ui.addButton("JUGAR")
    .setPosition(100, 200)
    .setSize(200, 50)
    .onClick(b -> {
      enMenu = false;
      inicioNivel = millis();
      tiempoRestante = tiempoMax;
      nivelTerminado = false;
      ui.hide();
      iniciarJuego(); // ✅ se inicia el juego completo aquí
    });

  ui.addButton("SALIR")
    .setPosition(100, 270)
    .setSize(200, 50)
    .onClick(b -> exit());

  ui.addSlider("grav")
    .setPosition(100, 400)
    .setRange(0.1f, 1.0f)
    .setValue(0.5f)
    .setLabel("Gravedad ↓ = flotar más");

  generarAsteroidesIniciales();
}

// === LOOP PRINCIPAL ===
void draw() {
  background(10, 20, 35);

  if (enMenu) {
    mostrarMenu();
  } else {
    jugar();
  }
}

// === MENÚ ===
void mostrarMenu() {
  fill(255);
  textSize(48);
  textAlign(LEFT);
  text("ASTRO SWING", 100, 120);
}

// === INICIAR JUEGO ===
void iniciarJuego() {
  px = 100f;
  py = 300f;
  vx = 0f;
  vy = 0f;
  camX = 0f;
  score = 0;

  generarAsteroidesIniciales();
  gemas = new ArrayList<Gema>();
  generarGemas(); // ✅ se generan aquí (ya todo está listo)
}

// === JUEGO ===
void jugar() {
if (!nivelTerminado) {
  // Actualizar tiempo
  int transcurrido = (millis() - inicioNivel) / 1000;
  tiempoRestante = max(0, tiempoMax - transcurrido);

  if (tiempoRestante <= 0) {
    nivelTerminado = true;
  }

  // Cámara y jugabilidad normales
  camX += (px - camX - width / 2f) * camDelay;
  translate(-camX, 0);
  
  generarAsteroidesProcedural();
  moverJugador();
  manejarGancho();

  dibujarSuelo();
  dibujarAsteroides();
  dibujarJugador();
  dibujarGemas();

  // Mostrar UI
  mostrarHUD();
} else {
  mostrarPantallaFinal();
}

  // === GEMAS ===
  if (gemas != null) {
    dibujarGemas();
    verificarRecoleccion();
  }

  // Mostrar puntaje
  fill(255);
  textAlign(RIGHT);
  textSize(24);
  text("Gemas: " + score, camX + width - 50, 40);
}

// === GEMAS ===
void generarGemas() {
  gemas.clear();
  for (int i = 0; i < 20; i++) {
    float gx = random(200, 8000);
    float gy = random(200, 600);
    gemas.add(new Gema(gx, gy));
  }
}

void dibujarGemas() {
  for (Gema g : gemas) {
    g.dibujar();
  }
}

void verificarRecoleccion() {
  for (int i = gemas.size() - 1; i >= 0; i--) {
    Gema g = gemas.get(i);
    float d = dist(px, py, g.pos.x, g.pos.y);
    if (d < 30) {
      score++;
      gemas.remove(i);
    }
  }
}

void mostrarHUD() {
  fill(255);
  textSize(24);
  textAlign(LEFT);
  text("Tiempo: " + tiempoRestante, camX + 50, 50);
  text("Puntaje: " + score, camX + 50, 80);
}

void mostrarPantallaFinal() {
  // Centramos el texto respecto a la cámara actual
  pushMatrix();
  translate(-camX, 0);

  // Velo transparente para dar contraste al texto (opcional)
  fill(0, 0, 0, 180);
  noStroke();
  rect(camX, 0, width, height);

  // Texto principal
  fill(255);
  textAlign(CENTER);
  textSize(48);
  text("¡Nivel Terminado!", camX + width / 2f, height / 2f - 40);
  textSize(32);
  text("Puntaje final: " + score, camX + width / 2f, height / 2f + 20);
  textSize(24);
  text("Presiona 'R' para reiniciar", camX + width / 2f, height / 2f + 80);

  popMatrix();
}

void reiniciarNivel() {
  px = 100;
  py = 300;
  vx = 0;
  vy = 0;
  score = 0;
  ast.clear();
  generarAsteroidesIniciales();
  gemas.clear();
  generarGemas();
  inicioNivel = millis();
  nivelTerminado = false;
}
