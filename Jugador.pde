// ============================================
// JUGADOR.PDE - Personaje con sprites animados + hitbox ampliada
// ============================================

// Sprites del personaje
ArrayList<PImage> spritesIdle;
ArrayList<PImage> spritesMoviendo;
int frameActual = 0;
int frameCounter = 0;
int frameDelay = 5;

ArrayList<ParticulaEstrella> estrellasMovimiento;

// ✅ TAMAÑO DEL JUGADOR
float tamañoJugador = 210; 
float radioColisionJugador = tamañoJugador * 0.70; // 🔧 HITBOX (ajústalo a gusto)

void cargarJugador() {
  spritesIdle = new ArrayList<PImage>();
  spritesMoviendo = new ArrayList<PImage>();
  estrellasMovimiento = new ArrayList<ParticulaEstrella>();
  
  println("Intentando cargar sprites...");
  
  int spritesCount = 0;
  for (int i = 1; i <= 10; i++) {
    try {
      PImage img = loadImage("personajes/" + i + ".png");
      if (img != null && img.width > 0) {
        spritesIdle.add(img);
        spritesCount++;
      }
    } catch (Exception e) {
      println("No se pudo cargar sprite " + i);
    }
  }
  
  if (spritesCount > 0) {
    spritesMoviendo = new ArrayList<PImage>(spritesIdle);
    println("Sprites cargados: " + spritesCount);
  } else {
    println("No se encontraron sprites, usando círculo por defecto");
  }
}

void moverJugador() {
  if (movIzq && !movDer) vx -= acel;
  if (movDer && !movIzq) vx += acel;
  if (!movIzq && !movDer && enSuelo) vx *= fric;

  vx = constrain(vx, -velMax, velMax);

  if (!ganchoAct) vy += grav;
  px += vx;
  py += vy;
  
  if (py > height - 20f) {
    if (!invulnerable) {
      vida--;
      invulnerable = true;
      ultimoHit = millis();
      vy = -12f;
    }
    py = height - 50f;
    enSuelo = true;
  } else {
    enSuelo = false;
  }
  
  if (invulnerable && millis() - ultimoHit > tiempoInvul) {
    invulnerable = false;
  }
  
  boolean tocandoPlataforma = false;
  for (Plataforma p : plataformas) {
    if (px > p.x && px < p.x + p.w && py + 15 > p.y && py + 15 < p.y + p.h) {
      py = p.y - 15;
      vy = 0;
      enSuelo = true;
      tocandoPlataforma = true;
    }
  }
  if (!tocandoPlataforma && py < height - 50f) {
    enSuelo = false;
  }
  
  if (saltar && enSuelo) {
    vy = -10f;
    if (movIzq && !movDer) vx = -velMax * 0.7f;
    if (movDer && !movIzq) vx = velMax * 0.7f;
  }
}

void manejarInputJugador() {
  // vacío
}

void dibujarJugador() {
  pushStyle();
  pushMatrix();
  
  translate(px, py);
  float velocidadActual = sqrt(vx * vx + vy * vy);
  boolean estaMoviendo = velocidadActual > 0.5;
  
  if (estaMoviendo && random(1) < 0.3) {
    estrellasMovimiento.add(new ParticulaEstrella(0, 0));
  }
  
  dibujarPersonajeAnimado(estaMoviendo);
  
  for (int i = estrellasMovimiento.size() - 1; i >= 0; i--) {
    ParticulaEstrella p = estrellasMovimiento.get(i);
    p.actualizar();
    p.dibujar();
    if (p.vida <= 0) estrellasMovimiento.remove(i);
  }
  
  if (invulnerable && (millis() / 100) % 2 == 0) {
    noFill();
    stroke(255, 255, 255, 200);
    strokeWeight(3);
    ellipse(0, 0, 40, 40);
  }

  // 🔧 Dibujar la hitbox (para depuración)
  // noFill();
  // stroke(255, 100, 100, 120);
  // ellipse(0, 0, radioColisionJugador * 2, radioColisionJugador * 2);

  popMatrix();
  popStyle();
}

void dibujarPersonajeAnimado(boolean estaMoviendo) {
  pushStyle();
  
  ArrayList<PImage> spritesActuales;
  
  if (estaMoviendo && spritesMoviendo != null && spritesMoviendo.size() > 0) {
    spritesActuales = spritesMoviendo;
  } else if (spritesIdle != null && spritesIdle.size() > 0) {
    spritesActuales = spritesIdle;
  } else {
    dibujarCirculoPorDefecto();
    popStyle();
    return;
  }
  
  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    frameActual++;
    if (frameActual >= spritesActuales.size()) frameActual = 0;
  }
  
  PImage spriteActual = spritesActuales.get(frameActual);
  float aspectRatio = (float)spriteActual.width / (float)spriteActual.height;
  float anchoFinal, altoFinal;
  
  if (aspectRatio > 1) {
    anchoFinal = tamañoJugador;
    altoFinal = tamañoJugador / aspectRatio;
  } else {
    anchoFinal = tamañoJugador * aspectRatio;
    altoFinal = tamañoJugador;
  }
  
  imageMode(CENTER);
  tint(255, 255);
  image(spriteActual, 0, 0, anchoFinal, altoFinal);
  noTint();
  
  popStyle();
}

void dibujarCirculoPorDefecto() {
  fill(150, 230, 200);
  stroke(100, 200, 180);
  strokeWeight(2);
  ellipse(0, 0, tamañoJugador, tamañoJugador);
}

// ✅ Método para comprobar colisiones con objetos
boolean colisionaCon(float x, float y, float r) {
  return dist(px, py, x, y) < radioColisionJugador + r;
}

// ============================================
// CLASE DE PARTÍCULAS DE MOVIMIENTO
// ============================================
class ParticulaEstrella {
  float x, y, vx, vy, vida, tamaño, rotacion, velocidadRotacion;
  color col;
  
  ParticulaEstrella(float startX, float startY) {
    x = startX;
    y = startY;
    vx = random(-2, 2);
    vy = random(-3, -1);
    vida = 255;
    tamaño = random(4, 10);
    rotacion = random(TWO_PI);
    velocidadRotacion = random(-0.2, 0.2);
    
    int tipo = int(random(4));
    if (tipo == 0) col = color(255, 200, 230);
    else if (tipo == 1) col = color(200, 230, 255);
    else if (tipo == 2) col = color(255, 255, 200);
    else col = color(200, 255, 230);
  }
  
  void actualizar() {
    x += vx;
    y += vy;
    vida -= 8;
    rotacion += velocidadRotacion;
    tamaño *= 0.98;
  }
  
  void dibujar() {
    pushStyle();
    pushMatrix();
    translate(x, y);
    rotate(rotacion);
    
    noStroke();
    fill(col, vida * 0.3);
    dibujarEstrellaForma(0, 0, tamaño * 1.5);
    fill(col, vida * 0.8);
    dibujarEstrellaForma(0, 0, tamaño);
    fill(255, 255, 255, vida);
    ellipse(0, 0, tamaño * 0.5, tamaño * 0.5);
    
    stroke(255, 255, 255, vida * 0.6);
    strokeWeight(1.5);
    line(-tamaño, 0, tamaño, 0);
    line(0, -tamaño, 0, tamaño);
    
    popMatrix();
    popStyle();
  }
  
  void dibujarEstrellaForma(float cx, float cy, float tam) {
    beginShape();
    for (int i = 0; i < 10; i++) {
      float angulo = TWO_PI / 10 * i;
      float r = (i % 2 == 0) ? tam : tam * 0.4;
      vertex(cx + cos(angulo) * r, cy + sin(angulo) * r);
    }
    endShape(CLOSE);
  }
}
