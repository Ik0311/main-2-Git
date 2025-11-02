import controlP5.*;
ControlP5 ui;

// Estados
boolean enMenu = true;
boolean enPeleaJefe = false;

// IMÁGENES DEL MENÚ
PImage imgTitulo;
PImage imgEmpezar;
PImage imgCreditos;
PImage imgGravedad;
PImage imgOpciones;
PImage imgSalir;
PImage imgBack;

// SISTEMA DE GALAXIA
ArrayList<Estrella> estrellas;
ArrayList<Nebulosa> nebulosas;

// Variables del jugador 
float px = 100f, py = 300f;
float vx = 0f, vy = 0f;
float acel = 0.6f;
float fric = 0.85f;
float velMax = 8f;
float grav = 0.5f;
boolean enSuelo = false;

// ESTADO DE TECLAS
boolean movIzq = false;
boolean movDer = false;
boolean saltar = false;

// VIDA 
int vidaMax = 3;
int vida = vidaMax;
boolean invulnerable = false;
int tiempoInvul = 1000; 
int ultimoHit = 0;

// Gancho
boolean ganchoAct = false;
PVector hook = new PVector();
float lenCuerda = 0f;
float tens = 0.1f;

// Cámara 
float camX = 0f;
float camDelay = 0.1f;

// Auto-scroll procedural
float camAutoBase = 1.5f;
float camAutoSpeed = camAutoBase;
float camAutoMax = 6.0f;
float camAutoIncreaseRate = 0.08f;

// Asteroides
ArrayList<PVector> ast = new ArrayList<PVector>();
float astDist = 400f;
float ultAstX = 0f;

// PLATAFORMAS 
ArrayList<Plataforma> plataformas;

// NIVEL Y TIEMPO 
int tiempoMax = 60;
int tiempoRestante;
int inicioNivel;
boolean nivelTerminado = false;

// META
float metaX = 0;
float metaY = 0;
float metaAncho = 150;
float metaAlto = 200;
boolean metaCreada = false;
boolean llegoALaMeta = false;
float metaAnimacion = 0;
boolean metaAnimacionCompleta = false;

// GEMAS 
ArrayList<Gema> gemas;
int score = 0;

// OBSTÁCULOS
ArrayList<Obstaculo> obstaculos;
float probObstaculo = 0.3f;

void setup() {
  size(1600, 900);
  ui = new ControlP5(this);

  // CARGAR IMÁGENES DEL MENÚ
  imgTitulo = loadImage("menu/titulo.png");
  imgEmpezar = loadImage("menu/empezar.png");
  imgCreditos = loadImage("menu/creditos.png");
  imgGravedad = loadImage("menu/gravedad.png");
  imgOpciones = loadImage("menu/opciones.png");
  imgSalir = loadImage("menu/salir.png");
  imgBack = loadImage("menu/back.png");
  
  // INICIALIZAR GALAXIA
  inicializarGalaxia();
  
  // CARGAR JUGADOR
  cargarJugador();

  // Botón JUGAR
  ui.addButton("JUGAR")
    .setPosition(width/2 - 75, 495)
    .setSize(150, 40)
    .setColorBackground(color(0, 0, 0, 0))
    .setColorForeground(color(0, 0, 0, 0))
    .setColorActive(color(0, 0, 0, 0))
    .setLabel("")
    .getCaptionLabel().setVisible(false);
    
    // Botón CRÉDITOS
  ui.addButton("CREDITOS")
    .setPosition(width/2 - 75, 595) // debajo del botón JUGAR
    .setSize(150, 40)
    .setColorBackground(color(0, 0, 0, 0))
    .setColorForeground(color(0, 0, 0, 0))
    .setColorActive(color(0, 0, 0, 0))
    .setLabel("")
    .getCaptionLabel().setVisible(false);

  // Botón SALIR
  ui.addButton("SALIR")
    .setPosition(width/2 - 75, 695)
    .setSize(150, 40)
    .setColorBackground(color(0, 0, 0, 0))
    .setColorForeground(color(0, 0, 0, 0))
    .setColorActive(color(0, 0, 0, 0))
    .setLabel("")
    .getCaptionLabel().setVisible(false);

  // Slider de gravedad
  ui.addSlider("grav")
    .setPosition(50, 810)
    .setSize(150, 15)
    .setRange(0.1f, 1.0f)
    .setValue(0.5f)
    .setLabel("")
    .getCaptionLabel().setVisible(false);

    for (ControllerInterface<?> c : ui.getAll()) {
  if (c instanceof Button) {
    Button b = (Button) c;
    b.setColorBackground(color(0, 0));  // fondo invisible
    b.setColorForeground(color(0, 0));  // sin resalte
    b.setColorActive(color(0, 0));      // sin color al presionar
    b.getCaptionLabel().setVisible(false); // oculta texto
    b.hideBackground();                 // elimina dibujo base del botón
  }
}

  generarAsteroidesIniciales();
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    if (theEvent.getController().getName().equals("JUGAR")) {
      println("Botón JUGAR presionado");
      enMenu = false;
      ui.hide();
      iniciarJuego();
    }
    if (theEvent.getController().getName().equals("SALIR")) {
      println("Botón SALIR presionado");
      exit();
    }
  }
}

void draw() {
  background(10, 20, 35);

  if (enMenu) {
    mostrarMenu();
  } else if (enPeleaJefe) {
    actualizarPeleaJefe();
  } else {
    jugar();
  }
}

void mostrarMenu() {
  background(10, 20, 35);
  
  if (imgBack != null) {
    imageMode(CORNER);
    image(imgBack, 0, 0, width, height);
  }
  
  if (imgTitulo != null) {
    imageMode(CENTER);
    image(imgTitulo, width/2, 250, imgTitulo.width * 0.5, imgTitulo.height * 0.5);
  }
  
  if (imgEmpezar != null) {
    imageMode(CENTER);
    image(imgEmpezar, width/2, 515, imgEmpezar.width * 0.35, imgEmpezar.height * 0.35);
  }
  
  if (imgCreditos != null) {
  imageMode(CENTER);
  image(imgCreditos, width/2, 615, imgCreditos.width * 0.35, imgCreditos.height * 0.35);
  }
  
  if (imgSalir != null) {
    imageMode(CENTER);
    image(imgSalir, width/2, 715, imgSalir.width * 0.35, imgSalir.height * 0.35);
  }
  
  if (imgGravedad != null) {
    imageMode(CORNER);
    image(imgGravedad, 50, 775, imgGravedad.width * 0.6, imgGravedad.height * 0.6);
  }
}

void iniciarJuego() {
  println("Iniciando juego...");
  
  px = 100f;
  py = 300f;
  vx = 0f;
  vy = 0f;
  camX = 0f;
  camAutoSpeed = camAutoBase;
  hook.set(0,0);
  lenCuerda = 0;
  ganchoAct = false;
  score = 0;
  vida = vidaMax;
  metaCreada = false;
  llegoALaMeta = false;
  metaAnimacion = 0;
  metaAnimacionCompleta = false;

  generarAsteroidesIniciales();
  plataformas = new ArrayList<Plataforma>();
  generarNivel();
  gemas = new ArrayList<Gema>();
  generarGemas();
  obstaculos = new ArrayList<Obstaculo>();
  generarObstaculos();

  inicioNivel = millis();
  tiempoRestante = tiempoMax;
  nivelTerminado = false;
  
  println("Juego iniciado!");
}

void jugar() {
  dibujarGalaxia();
  
  if (!nivelTerminado && !llegoALaMeta) {
    int transcurrido = (millis() - inicioNivel) / 1000;
    tiempoRestante = max(0, tiempoMax - transcurrido);

    if (vida <= 0) nivelTerminado = true;
    
    if (tiempoRestante <= 0 && !metaCreada) {
      crearMeta();
    }

    float elapsedSec = (millis() - inicioNivel) / 1000.0f;
    camAutoSpeed = camAutoBase + camAutoIncreaseRate * elapsedSec;
    if (camAutoSpeed > camAutoMax) camAutoSpeed = camAutoMax;

    camX += camAutoSpeed;

    translate(-camX, 0);

    generarAsteroidesProcedural();
    generarPlataformasProcedural();

    moverJugador();

    float leftLimit = camX + 50;
    float rightLimit = camX + width - 50;
    if (px < leftLimit) {
      px = leftLimit;
      vx = 0;
    }
    if (px > rightLimit) {
      px = rightLimit;
      vx = 0;
    }

    manejarGancho();

    dibujarSuelo();
    dibujarAsteroides();
    for (Plataforma p : plataformas) {
      p.dibujar();
    }
    
    if (metaCreada) {
      dibujarMeta();
      verificarLlegadaMeta();
    }
    
    dibujarJugador();
    dibujarGemas();
    dibujarObstaculos();
    verificarColisionObstaculos();

    mostrarHUD();

  } else if (llegoALaMeta) {
    pushMatrix();
    translate(-camX, 0);

    fill(0, 0, 0, 200);
    noStroke();
    rect(camX, 0, width, height);

    fill(255, 215, 0);
    textAlign(CENTER);
    textSize(64);
    text("¡LLEGASTE A LA META!", camX + width / 2f, height / 2f - 60);
    
    fill(255);
    textSize(32);
    text("Puntaje: " + score, camX + width / 2f, height / 2f + 20);
    
    textSize(24);
    text("Presiona ESPACIO para enfrentar al JEFE", camX + width / 2f, height / 2f + 80);

    popMatrix();
  } else {
    mostrarPantallaFinal();
  }

  fill(255);
  textAlign(RIGHT);
  textSize(24);
  text("Gemas: " + score, camX + width - 50, 40);
}

void crearMeta() {
  if (plataformas.size() > 0) {
    Plataforma ultima = plataformas.get(plataformas.size() - 1);
    metaX = ultima.x + ultima.w + 300;
    metaY = 0;
    metaAncho = 150;
    metaAlto = height;
    metaCreada = true;
    metaAnimacion = 0;
    metaAnimacionCompleta = false;
    println("¡PORTAL CREADO en X=" + metaX + "!");
  }
}

void dibujarMeta() {
  pushStyle();
  
  // Animación de aparición
  if (!metaAnimacionCompleta) {
    metaAnimacion += 0.02;
    if (metaAnimacion >= 1.0) {
      metaAnimacion = 1.0;
      metaAnimacionCompleta = true;
    }
  }
  
  float escalaAnimacion = easeOutElastic(metaAnimacion);
  float alphaAnimacion = metaAnimacion * 255;
  
  float tiempo = millis() * 0.001;
  
  colorMode(HSB, 360, 100, 100, 255);
  
  // Tonos de morado que cambian suavemente
  float hueBase = 280 + sin(tiempo * 0.5) * 20; // 260-300 (morado)
  float hue2 = 260 + cos(tiempo * 0.7) * 25;
  float hue3 = 290 + sin(tiempo * 0.3) * 15;
  
  // Centro del portal circular
  float centroX = metaX + metaAncho / 2;
  float centroY = height / 2;
  float radioPortal = 200; // Radio del portal circular
  
  pushMatrix();
  translate(centroX, centroY);
  scale(escalaAnimacion);
  translate(-centroX, -centroY);
  
  // Explosión inicial de partículas
  if (metaAnimacion < 1.0) {
    for (int i = 0; i < 50; i++) {
      float angulo = (i / 50.0) * TWO_PI;
      float distancia = metaAnimacion * 400;
      float x = centroX + cos(angulo) * distancia;
      float y = centroY + sin(angulo) * distancia;
      float tamaño = (1 - metaAnimacion) * 30;
      
      noStroke();
      fill(hueBase + i * 2, 80, 95, (int)((1 - metaAnimacion) * 200));
      ellipse(x, y, tamaño, tamaño);
    }
  }
  
  // Ondas de energía expansivas circulares
  for (int onda = 0; onda < 5; onda++) {
    float offsetOnda = (tiempo * 100 + onda * 60) % 400;
    float alphaOnda = map(offsetOnda, 0, 400, 150, 0) * (alphaAnimacion / 255.0);
    
    noFill();
    strokeWeight(4);
    stroke(hue2, 70, 90, (int)alphaOnda);
    ellipse(centroX, centroY, offsetOnda, offsetOnda);
    
    strokeWeight(2);
    stroke(hue2, 80, 95, (int)(alphaOnda * 0.6));
    ellipse(centroX, centroY, offsetOnda * 0.8, offsetOnda * 0.8);
  }
  
  // Vórtice en espiral (más denso)
  pushMatrix();
  translate(centroX, centroY);
  
  for (int espiral = 0; espiral < 50; espiral++) {
    float anguloEspiral = tiempo * 2 + espiral * 0.25;
    float radioEspiral = (espiral / 50.0) * radioPortal;
    float x = cos(anguloEspiral) * radioEspiral;
    float y = sin(anguloEspiral) * radioEspiral;
    
    float hue = (hue3 + espiral * 5) % 40 + 260;
    float tamaño = 25 - (espiral / 50.0) * 20;
    
    noStroke();
    fill(hue, 90, 95, (int)(220 * alphaAnimacion / 255.0));
    ellipse(x, y, tamaño, tamaño);
    
    fill(hue, 70, 100, (int)(180 * alphaAnimacion / 255.0));
    ellipse(x, y, tamaño * 0.6, tamaño * 0.6);
  }
  
  popMatrix();
  
  // Partículas orbitando en círculo
  for (int i = 0; i < 30; i++) {
    float angulo = (tiempo + i * 0.2) % TWO_PI;
    float radio = radioPortal + sin(tiempo * 3 + i) * 40;
    float particleX = centroX + cos(angulo) * radio;
    float particleY = centroY + sin(angulo) * radio;
    float tamaño = 8 + sin(tiempo * 4 + i) * 4;
    float hue = (hueBase + i * 10) % 40 + 260;
    
    noStroke();
    fill(hue, 80, 100, (int)(200 * alphaAnimacion / 255.0));
    ellipse(particleX, particleY, tamaño, tamaño);
    
    fill(0, 0, 100, (int)(250 * alphaAnimacion / 255.0));
    ellipse(particleX, particleY, tamaño * 0.5, tamaño * 0.5);
  }
  
  // Anillos giratorios concéntricos
  pushMatrix();
  translate(centroX, centroY);
  for (int anillo = 0; anillo < 4; anillo++) {
    pushMatrix();
    rotate(tiempo * (anillo + 1) * 0.4);
    noFill();
    strokeWeight(3);
    stroke(hueBase + anillo * 10, 75, 95, (int)(150 * alphaAnimacion / 255.0));
    ellipse(0, 0, radioPortal - anillo * 30, radioPortal - anillo * 30);
    
    // Puntos brillantes en los anillos
    for (int p = 0; p < 8; p++) {
      float anguloPunto = (TWO_PI / 8) * p;
      float radioPunto = (radioPortal - anillo * 30) / 2;
      float px = cos(anguloPunto) * radioPunto;
      float py = sin(anguloPunto) * radioPunto;
      
      noStroke();
      fill(hueBase + anillo * 10, 80, 100, (int)(200 * alphaAnimacion / 255.0));
      ellipse(px, py, 8, 8);
    }
    popMatrix();
  }
  popMatrix();
  
  // Borde principal del portal circular
  noFill();
  strokeWeight(12);
  stroke(hueBase, 70, 100, (int)(220 * alphaAnimacion / 255.0));
  ellipse(centroX, centroY, radioPortal * 2, radioPortal * 2);
  
  strokeWeight(8);
  stroke(hue2, 80, 95, (int)(240 * alphaAnimacion / 255.0));
  ellipse(centroX, centroY, radioPortal * 2, radioPortal * 2);
  
  strokeWeight(4);
  stroke(0, 0, 100, (int)(255 * alphaAnimacion / 255.0));
  ellipse(centroX, centroY, radioPortal * 2, radioPortal * 2);
  
  // Glow exterior
  for (int i = 0; i < 3; i++) {
    strokeWeight(2);
    stroke(hueBase, 60, 90, (int)(50 * alphaAnimacion / 255.0));
    ellipse(centroX, centroY, radioPortal * 2 + i * 20, radioPortal * 2 + i * 20);
  }
  
  // Núcleo oscuro central
  noStroke();
  fill(0, 0, 5, (int)(200 * alphaAnimacion / 255.0));
  ellipse(centroX, centroY, radioPortal * 0.6, radioPortal * 0.6);
  
  // Brillo en el núcleo
  fill(hue3, 70, 80, (int)(150 * alphaAnimacion / 255.0));
  ellipse(centroX, centroY, radioPortal * 0.4, radioPortal * 0.4);
  
  // Destellos de luz cruzados
  pushMatrix();
  translate(centroX, centroY);
  rotate(tiempo * 0.5);
  strokeWeight(3);
  stroke(0, 0, 100, (int)(180 * alphaAnimacion / 255.0));
  line(-radioPortal * 0.3, 0, radioPortal * 0.3, 0);
  line(0, -radioPortal * 0.3, 0, radioPortal * 0.3);
  popMatrix();
  
  // Texto flotante con efecto
  textAlign(CENTER, CENTER);
  textSize(56);
  float textoY = centroY + sin(tiempo * 2) * 15;
  
  fill(0, 0, 0, (int)(180 * alphaAnimacion / 255.0));
  text("PORTAL", centroX + 4, textoY + 4);
  
  fill(hueBase, 60, 100, (int)(alphaAnimacion));
  text("PORTAL", centroX, textoY);
  
  textSize(28);
  fill(0, 0, 100, (int)(240 * alphaAnimacion / 255.0));
  text("¡Entra!", centroX, textoY + 50);
  
  popMatrix();
  
  colorMode(RGB, 255);
  popStyle();
}

// Función de easing para animación elástica
float easeOutElastic(float t) {
  float c4 = (2 * PI) / 3;
  if (t == 0) return 0;
  if (t == 1) return 1;
  return pow(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1;
}

void verificarLlegadaMeta() {
  float centroX = metaX + metaAncho / 2;
  float centroY = height / 2;
  float radioPortal = 200;
  
  float distancia = dist(px, py, centroX, centroY);
  
  if (distancia < radioPortal) {
    llegoALaMeta = true;
    println("¡JUGADOR ENTRÓ AL PORTAL!");
  }
}

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
  pushStyle();
  
  fill(255);
  textSize(24);
  textAlign(LEFT);
  
  if (tiempoRestante <= 0) {
    text("Tiempo: ¡BUSCA LA META!", camX + 50, 50);
  } else {
    text("Tiempo: " + tiempoRestante, camX + 50, 50);
  }
  
  text("Puntaje: " + score, camX + 50, 80);
  
  text("Vidas: ", camX + 50, 110);
  
  for (int i = 0; i < vidaMax; i++) {
    if (i < vida) {
      fill(255, 100, 150);
      dibujarCorazonHUD(camX + 140 + i * 35, 100, 12);
      
      fill(255, 180, 200, 200);
      dibujarCorazonHUD(camX + 140 + i * 35, 100, 10);
      
      fill(255, 255, 255, 180);
      dibujarCorazonHUD(camX + 138 + i * 35, 98, 6);
    } else {
      fill(80, 80, 100);
      dibujarCorazonHUD(camX + 140 + i * 35, 100, 12);
      
      fill(60, 60, 80);
      dibujarCorazonHUD(camX + 140 + i * 35, 100, 10);
    }
  }
  
  popStyle();
}

void dibujarCorazonHUD(float x, float y, float tamaño) {
  pushMatrix();
  translate(x, y);
  scale(tamaño / 10.0);
  
  beginShape();
  vertex(0, 2);
  bezierVertex(-5, -3, -10, 0, 0, 10);
  vertex(0, 2);
  bezierVertex(5, -3, 10, 0, 0, 10);
  endShape(CLOSE);
  
  popMatrix();
}

void mostrarPantallaFinal() {
  pushMatrix();
  translate(-camX, 0);

  fill(0, 0, 0, 180);
  noStroke();
  rect(camX, 0, width, height);

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
  enMenu = true;
  ui.show();
  
  px = 100;
  py = 300;
  vx = 0;
  vy = 0;
  score = 0;
  vida = vidaMax;
  invulnerable = false;
  nivelTerminado = false;
  metaCreada = false;
  llegoALaMeta = false;
  enPeleaJefe = false;
  inicioNivel = millis();
  camX = 0f;
  camAutoSpeed = camAutoBase;
  ast.clear();
  generarAsteroidesIniciales();
  gemas.clear();
  generarGemas();
  plataformas.clear();
  generarNivel();
  obstaculos.clear();
  generarObstaculos();
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
    x += ancho + random(200, 500);
  }
}

void generarPlataformasProcedural() {
  if (plataformas.size() == 0) return;

  Plataforma ultima = plataformas.get(plataformas.size() - 1);

  if (camX + width > ultima.x + ultima.w - 1000) {
    float x = ultima.x + ultima.w + random(200, 500);

    for (int i = 0; i < 5; i++) {
      float w = random(150, 300);
      float h = random(20, 30);
      float y = random(400, 700);

      plataformas.add(new Plataforma(x, y, w, h));
      x += w + random(200, 500);
    }
  }

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
      float oy = p.y - 30;
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
  for (int i = obstaculos.size() - 1; i >= 0; i--) {
    Obstaculo o = obstaculos.get(i);
    float d = dist(px, py, o.pos.x, o.pos.y);
    if (d < o.radio + 15) {
      vida--;
      obstaculos.remove(i);
      break;
    }
  }
}

void keyPressed() {
  if (key == 'a' || key == 'A') movIzq = true;
  if (key == 'd' || key == 'D') movDer = true;
  if (key == 'w' || key == 'W') saltar = true;
  
  if (enPeleaJefe) {
    manejarInputJefe();
  } else if (!enMenu) {
    if (key == ' ') {
      if (llegoALaMeta) {
        enPeleaJefe = true;
        iniciarPeleaJefe();
      } else if (!ganchoAct) {
        float worldMouseX = camX + mouseX;
        float worldMouseY = mouseY;
        hook.set(worldMouseX, worldMouseY);
        lenCuerda = dist(px, py, hook.x, hook.y);
        ganchoAct = true;
      } else {
        ganchoAct = false;
        lenCuerda = 0;
      }
    }

    if (key == 'r' || key == 'R') {
      reiniciarNivel();
    }
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A') movIzq = false;
  if (key == 'd' || key == 'D') movDer = false;
  if (key == 'w' || key == 'W') saltar = false;
}
