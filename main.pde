import controlP5.*;
ControlP5 ui;

// Estados
boolean enMenu = true;

// = Variables del jugador 
float px = 100f, py = 300f;
float vx = 0f, vy = 0f;
float acel = 0.6f;
float fric = 0.85f;
float velMax = 8f;
float grav = 0.5f;
boolean enSuelo = false;

// = VIDA 
int vidaMax = 3;
int vida = vidaMax;
boolean invulnerable = false;
int tiempoInvul = 1000; 
int ultimoHit = 0;


// = Gancho
boolean ganchoAct = false;
PVector hook = new PVector();
float lenCuerda = 0f;
float tens = 0.1f;

// = Cámara 
float camX = 0f;
float camDelay = 0.1f;

// = Asteroides
ArrayList<PVector> ast = new ArrayList<PVector>();
float astDist = 400f;
float ultAstX = 0f;

// = PLATAFORMAS 
ArrayList<Plataforma> plataformas;

// = NIVEL Y TIEMPO 
int tiempoMax = 60;     // segundos de duración del nivel
int tiempoRestante;      // contador regresivo
int inicioNivel;         // momento en que empezó la partida
boolean nivelTerminado = false;

// = GEMAS 
ArrayList<Gema> gemas;
int score = 0;

// = OBSTÁCULOS
ArrayList<Obstaculo> obstaculos;
float probObstaculo = 0.3f; // 30% de probabilidad de que aparezca uno por plataforma

// = SETUP 
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

// = LOOP PRINCIPAL 
void draw() {
  background(10, 20, 35);

  if (enMenu) {
    mostrarMenu();
  } else {
    jugar();
  }
}

// = MENÚ 
void mostrarMenu() {
  fill(255);
  textSize(48);
  textAlign(LEFT);
  text("ASTRO SWING", 100, 120);
}

// = INICIAR JUEGO 
void iniciarJuego() {
  px = 100f;
  py = 300f;
  vx = 0f;
  vy = 0f;
  camX = 0f;
  score = 0;

  generarAsteroidesIniciales();
  plataformas = new ArrayList<Plataforma>();
  generarNivel();
  gemas = new ArrayList<Gema>();
  generarGemas();
  obstaculos = new ArrayList<Obstaculo>();
  generarObstaculos();

}

// = JUEGO 
void jugar() {
if (!nivelTerminado) {
  // Actualizar tiempo
  int transcurrido = (millis() - inicioNivel) / 1000;
  tiempoRestante = max(0, tiempoMax - transcurrido);
  
  if (vida <= 0) {
  nivelTerminado = true;
  }

  if (tiempoRestante <= 0) {
    nivelTerminado = true;
  }

  // Cámara y jugabilidad normales
  camX += (px - camX - width / 2f) * camDelay;
  translate(-camX, 0);
  
  generarAsteroidesProcedural();
  generarPlataformasProcedural();
  moverJugador();
  manejarGancho();

  dibujarSuelo();
  dibujarAsteroides();
  for (Plataforma p : plataformas) {
  p.dibujar();
  }
  dibujarJugador();
  dibujarGemas();
  dibujarObstaculos();
  verificarColisionObstaculos();

  // Mostrar UI
  mostrarHUD();
} else {
  mostrarPantallaFinal();
}

  // = GEMAS 
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

// = GgEMAS 
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
  text("Vidas: " + vida, camX + 50, 110);
}

void mostrarPantallaFinal() {
  // Centramos el texto respecto a la cámara actual
  pushMatrix();
  translate(-camX, 0);

  // Velo transparente para dar contraste al texto (reemplazable)
  fill(0, 0, 0, 180);
  noStroke();
  rect(camX, 0, width, height);

  // Texto 
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
  vida = vidaMax;       
  invulnerable = false; 
  nivelTerminado = false;
  inicioNivel = millis();
  ast.clear();
  generarAsteroidesIniciales();
  gemas.clear();
  generarGemas();
  plataformas.clear();
  generarNivel();   
  plataformas.add(new Plataforma(px - 50, py + 100, 200, 20)); 
}



void generarNivel() {
  plataformas.clear();
  plataformas.add(new Plataforma(50, height - 80, 200, 25));

  float x = 300;
  for (int i = 0; i < 15; i++) {
    float ancho = random(150, 300);
    float alto = random(20, 30);
    float y = random(400, 700);

    plataformas.add(new Plataforma(x, y, ancho, alto));

    // distancia variable (espacio vacío)
    x += ancho + random(200, 500);
  }
}

void generarPlataformasProcedural() {
  if (plataformas.size() == 0) return;

  Plataforma ultima = plataformas.get(plataformas.size() - 1);

  // Si el jugador está a menos de 1000px del final del nivel actual, genera más plataformas
  if (px > ultima.x + ultima.w - 1000) {
    float x = ultima.x + ultima.w + random(200, 500);

    for (int i = 0; i < 5; i++) {
      float w = random(150, 300);
      float h = random(20, 30);
      float y = random(400, 700);

      plataformas.add(new Plataforma(x, y, w, h));
      x += w + random(200, 500);
    }
  }

  // Opcional: eliminar las más lejanas (para optimizar)
  for (int i = plataformas.size() - 1; i >= 0; i--) {
    Plataforma p = plataformas.get(i);
    if (p.x + p.w < camX - width) {
      plataformas.remove(i);
    }
  }
}

void generarObstaculos() {
  obstaculos.clear();
  for (Plataforma p : plataformas) {
    if (random(1) < probObstaculo) {
      float ox = p.x + random(0, p.w);
      float oy = p.y - 30; // un poco encima de la plataforma
      obstaculos.add(new Obstaculo(ox, oy, 20));
    }
  }
}

void dibujarObstaculos() {
  for (Obstaculo o : obstaculos) {
    o.dibujar();
  }
}

void verificarColisionObstaculos() {
  for (Obstaculo o : obstaculos) {
    float d = dist(px, py, o.pos.x, o.pos.y);
    if (d < o.radio + 15) { // contacto con el jugador
      vida--;
      obstaculos.remove(o);
      break;
    }
  }
}
