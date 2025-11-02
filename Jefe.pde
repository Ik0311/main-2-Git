// =========================================
// TAB JEFE - Pelea con el jefe final mejorada
// =========================================

import java.awt.Robot;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.PointerInfo;

// Variables del jefe
PImage jefeSightImage;
PImage[] jefeEnemyFrames;
int jefeEnemyFrameCount = 0;
int jefeCurrentEnemyFrame = 0;
int jefeEnemyFrameDelay = 1;

float jefeAimX = 0;
float jefeAimY = 0;
float jefeAimSensitivity = 0.5;
int jefeLastMouseX, jefeLastMouseY;

Robot jefeRobot;
int jefeCenterScreenX, jefeCenterScreenY;
boolean jefeHaveRobot = false;

float jefeMonsterX, jefeMonsterY;
float jefeMonsterBaseSize = 120;
float jefeMonsterScale = 1.0;
float jefeMonsterTargetScale = 1.0;
float jefeMonsterScaleSpeed = 0.02;
float jefeMonsterSpeed = 1.5;
boolean jefeMonsterMovingRight = true;
float jefeMonsterZoomTimer = 0;

float jefeBulletX, jefeBulletY;
boolean jefeBulletActive = false;
float jefeBulletSpeed = 15;
float jefeBulletAnimFrame = 0;
float jefeBulletRotation = 0;

ArrayList<JefeEnergyWave> jefeEnergyWaves = new ArrayList<JefeEnergyWave>();
ArrayList<JefeExplosionStar> jefeExplosionStars = new ArrayList<JefeExplosionStar>();

boolean jefeMonsterAlive = true;
boolean jefeGameWon = false;
boolean jefeGameLost = false;
float jefeMonsterHealth = 100;
boolean jefeGameEnded = false;

// Estrellas de fondo del jefe
ArrayList<JefeBackgroundStar> jefeBackgroundStars;

void iniciarPeleaJefe() {
  jefeSightImage = loadImage("sight.png");
  jefeEnemyFrames = jefeLoadEnemyFrames();
  jefeEnemyFrameCount = jefeEnemyFrames.length;
  
  jefeMonsterX = width / 2;
  jefeMonsterY = height * 0.25;
  jefeAimX = 0;
  jefeAimY = 0;
  jefeLastMouseX = mouseX;
  jefeLastMouseY = mouseY;
  
  jefeMonsterAlive = true;
  jefeGameWon = false;
  jefeGameLost = false;
  jefeGameEnded = false;
  jefeMonsterHealth = 100;
  jefeMonsterScale = 1.0;
  jefeMonsterZoomTimer = 0;
  jefeBulletActive = false;
  jefeBulletRotation = 0;
  jefeEnergyWaves.clear();
  jefeExplosionStars.clear();
  
  // Crear estrellas de fondo
  jefeBackgroundStars = new ArrayList<JefeBackgroundStar>();
  for (int i = 0; i < 200; i++) {
    jefeBackgroundStars.add(new JefeBackgroundStar());
  }
  
  try {
    jefeRobot = new Robot();
    jefeCenterScreenX = displayWidth/2;
    jefeCenterScreenY = displayHeight/2;
    jefeRobot.mouseMove(jefeCenterScreenX, jefeCenterScreenY);
    jefeHaveRobot = true;
    jefeLastMouseX = jefeCenterScreenX;
    jefeLastMouseY = jefeCenterScreenY;
  } catch (Exception e) {
    jefeHaveRobot = false;
  }
  
  noCursor();
  println("¡Pelea con el jefe iniciada!");
}

void actualizarPeleaJefe() {
  dibujarFondoEspacialJefe();

  // Mouse/aim
  if (jefeHaveRobot) {
    PointerInfo pInfo = MouseInfo.getPointerInfo();
    if (pInfo != null) {
      Point loc = pInfo.getLocation();
      int absX = loc.x;
      int absY = loc.y;
      float deltaX = absX - jefeCenterScreenX;
      float deltaY = absY - jefeCenterScreenY;
      jefeAimX += deltaX * jefeAimSensitivity;
      jefeAimY += deltaY * jefeAimSensitivity;
      jefeRobot.mouseMove(jefeCenterScreenX, jefeCenterScreenY);
    }
  } else {
    float dx = mouseX - jefeLastMouseX;
    float dy = mouseY - jefeLastMouseY;
    jefeAimX += dx * 1.0;
    jefeAimY += dy * 1.0;
    jefeLastMouseX = mouseX;
    jefeLastMouseY = mouseY;
  }

  pushMatrix();
  translate(jefeAimX, jefeAimY);

  // Monster
  if (jefeMonsterAlive) {
    jefeMonsterX += jefeMonsterSpeed * (jefeMonsterMovingRight ? 1 : -1);
    jefeMonsterY += random(-1, 1);
    jefeMonsterY = constrain(jefeMonsterY, height * 0.17, height * 0.42);
    if (jefeMonsterX < -width*2 || jefeMonsterX > width*3 || random(1) < 0.02) {
      jefeMonsterMovingRight = !jefeMonsterMovingRight;
    }

    jefeMonsterZoomTimer += 0.01;
    jefeMonsterTargetScale = 1.0 + sin(jefeMonsterZoomTimer) * 0.15 + random(-0.02, 0.02);
    jefeMonsterScale = lerp(jefeMonsterScale, jefeMonsterTargetScale, jefeMonsterScaleSpeed);

    pushMatrix();
    translate(jefeMonsterX, jefeMonsterY);
    scale(jefeMonsterScale);
    imageMode(CENTER);
    if (jefeEnemyFrameCount > 0 && jefeEnemyFrames[0].width > 1) {
      PImage f = jefeEnemyFrames[jefeCurrentEnemyFrame];
      float targetW = jefeMonsterBaseSize * 2;
      float scaleFactor = targetW / (float)f.width;
      image(f, 0, 0, f.width * scaleFactor, f.height * scaleFactor);
      if (frameCount % jefeEnemyFrameDelay == 0) {
        jefeCurrentEnemyFrame = (jefeCurrentEnemyFrame + 1) % jefeEnemyFrameCount;
      }
    } else {
      noStroke();
      fill(180);
      ellipse(0, 0, jefeMonsterBaseSize, jefeMonsterBaseSize * 1.2);
    }
    popMatrix();

    // Barra de vida mejorada
    dibujarBarraVidaJefe();
  }

  // Bala estrella
  if (jefeBulletActive) {
    jefeBulletY -= jefeBulletSpeed;
    jefeBulletAnimFrame += 0.3;
    jefeBulletRotation += 0.15;
    
    if (frameCount % 2 == 0) jefeEnergyWaves.add(new JefeEnergyWave(jefeBulletX, jefeBulletY));
    
    for (int i = jefeEnergyWaves.size()-1; i>=0; i--) {
      JefeEnergyWave w = jefeEnergyWaves.get(i);
      w.update();
      w.display();
      if (w.alpha <= 0) jefeEnergyWaves.remove(i);
    }
    
    dibujarBalaEstrella(jefeBulletX, jefeBulletY);

    float hitRadius = (jefeMonsterBaseSize * jefeMonsterScale) / 2;
    if (jefeMonsterAlive && dist(jefeBulletX, jefeBulletY, jefeMonsterX, jefeMonsterY) < hitRadius) {
      // ✅ EXPLOSIÓN DE ESTRELLAS
      crearExplosionEstrellas(jefeMonsterX, jefeMonsterY);
      jefeMonsterHealth -= 20;
      
      if (jefeMonsterHealth <= 0) {
        jefeMonsterAlive = false;
        jefeGameWon = true;
      }
      
      jefeBulletActive = false;
      jefeEnergyWaves.clear();
    }
    
    if (jefeBulletY < -1000 || jefeBulletY > height + 1000) {
      jefeBulletActive = false;
      jefeEnergyWaves.clear();
    }
  }
  
  // Dibujar explosiones de estrellas
  for (int i = jefeExplosionStars.size() - 1; i >= 0; i--) {
    JefeExplosionStar s = jefeExplosionStars.get(i);
    s.update();
    s.display();
    if (s.isDead()) {
      jefeExplosionStars.remove(i);
    }
  }

  popMatrix();

  // Mira
  if (jefeSightImage != null) {
    pushMatrix();
    translate(width/2, height/2);
    rotate(HALF_PI);
    imageMode(CENTER);
    float scaleX = height / (float)jefeSightImage.width;
    float scaleY = width / (float)jefeSightImage.height;
    float scaleImg = max(scaleX, scaleY);
    image(jefeSightImage, 0, 0, jefeSightImage.width * scaleImg, jefeSightImage.height * scaleImg);
    popMatrix();
  }

  dibujarHUDJefe();

  if ((jefeGameWon || jefeGameLost) && !jefeGameEnded) {
    jefeGameEnded = true;
    cursor();
  }

  if (jefeGameEnded) {
    dibujarMenuJefe();
  }
}

// ✅ FONDO GALÁCTICO ANIMADO MEJORADO
void dibujarFondoEspacialJefe() {
  // Gradiente de fondo espacial profundo
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    int c = lerpColor(color(10, 5, 35), color(25, 5, 50), inter);
    stroke(c);
    line(0, i, width, i);
  }
  
  // Nebulosas animadas
  dibujarNebulosasBoss();
  
  // Estrellas animadas
  for (JefeBackgroundStar star : jefeBackgroundStars) {
    star.update();
    star.display();
  }
  
  // Polvo estelar
  dibujarPolvoEstelarBoss();
}

// ✅ NEBULOSAS ANIMADAS
void dibujarNebulosasBoss() {
  pushStyle();
  float tiempo = millis() * 0.0002;
  
  // Nebulosa 1 - Púrpura
  for (int i = 0; i < 3; i++) {
    float offsetX = sin(tiempo + i) * 100;
    float offsetY = cos(tiempo * 0.7 + i) * 50;
    
    noStroke();
    fill(150, 50, 200, 15);
    ellipse(width * 0.3 + offsetX, height * 0.3 + offsetY, 400 + i * 100, 300 + i * 80);
  }
  
  // Nebulosa 2 - Azul
  for (int i = 0; i < 3; i++) {
    float offsetX = cos(tiempo * 0.8 + i) * 120;
    float offsetY = sin(tiempo * 0.6 + i) * 70;
    
    noStroke();
    fill(50, 100, 255, 12);
    ellipse(width * 0.7 + offsetX, height * 0.5 + offsetY, 350 + i * 90, 280 + i * 70);
  }
  
  // Nebulosa 3 - Rosa
  for (int i = 0; i < 3; i++) {
    float offsetX = sin(tiempo * 0.9 + i) * 80;
    float offsetY = cos(tiempo * 1.1 + i) * 60;
    
    noStroke();
    fill(255, 80, 150, 10);
    ellipse(width * 0.5 + offsetX, height * 0.7 + offsetY, 300 + i * 80, 250 + i * 60);
  }
  
  popStyle();
}

// ✅ POLVO ESTELAR
void dibujarPolvoEstelarBoss() {
  pushStyle();
  float tiempo = millis() * 0.0001;
  
  for (int i = 0; i < 50; i++) {
    float x = (width * 0.5 + sin(tiempo * (i * 0.1)) * width * 0.6 + i * 20) % width;
    float y = (height * 0.5 + cos(tiempo * (i * 0.15)) * height * 0.4 + i * 15) % height;
    float brillo = 50 + sin(tiempo * 5 + i) * 50;
    float tam = 1 + sin(tiempo * 3 + i) * 0.5;
    
    noStroke();
    fill(200, 200, 255, brillo);
    ellipse(x, y, tam, tam);
  }
  
  popStyle();
}

// ✅ BALA EN FORMA DE ESTRELLA
void dibujarBalaEstrella(float x, float y) {
  pushStyle();
  pushMatrix();
  translate(x, y);
  rotate(jefeBulletRotation);
  
  float tiempo = millis() * 0.001;
  colorMode(HSB, 360, 100, 100, 255);
  float hue = (tiempo * 50) % 360;
  
  // Aura exterior pulsante
  float pulso = sin(jefeBulletAnimFrame) * 10 + 40;
  noStroke();
  fill(hue, 70, 100, 80);
  dibujarEstrellaForma(0, 0, pulso, 10);
  
  // Estrella principal
  fill(hue, 85, 100, 220);
  dibujarEstrellaForma(0, 0, 30, 10);
  
  // Estrella intermedia
  fill(hue, 70, 100, 200);
  dibujarEstrellaForma(0, 0, 20, 10);
  
  // Núcleo brillante
  fill(0, 0, 100, 255);
  ellipse(0, 0, 12, 12);
  
  // Destellos rotantes
  rotate(-jefeBulletRotation * 2);
  strokeWeight(2);
  stroke(0, 0, 100, 200);
  line(-35, 0, 35, 0);
  line(0, -35, 0, 35);
  rotate(HALF_PI / 2);
  stroke(hue, 60, 100, 150);
  line(-25, 0, 25, 0);
  line(0, -25, 0, 25);
  
  colorMode(RGB, 255);
  popMatrix();
  popStyle();
}

void dibujarEstrellaForma(float x, float y, float tamaño, int puntas) {
  beginShape();
  for (int i = 0; i < puntas * 2; i++) {
    float angulo = TWO_PI / (puntas * 2) * i;
    float r = (i % 2 == 0) ? tamaño : tamaño * 0.4;
    vertex(x + cos(angulo) * r, y + sin(angulo) * r);
  }
  endShape(CLOSE);
}

// ✅ CREAR EXPLOSIÓN DE ESTRELLAS
void crearExplosionEstrellas(float x, float y) {
  for (int i = 0; i < 30; i++) {
    jefeExplosionStars.add(new JefeExplosionStar(x, y));
  }
}

// ✅ BARRA DE VIDA MEJORADA
void dibujarBarraVidaJefe() {
  pushStyle();
  float barWidth = 150;
  float barHeight = 15;
  float adjustedOffset = jefeMonsterBaseSize * jefeMonsterScale;
  
  // Fondo de la barra
  noStroke();
  fill(20, 10, 40, 220);
  rectMode(CENTER);
  rect(jefeMonsterX, jefeMonsterY - adjustedOffset - 40, barWidth + 8, barHeight + 8, 8);
  
  // Borde brillante
  noFill();
  strokeWeight(2);
  stroke(150, 200, 255, 180);
  rect(jefeMonsterX, jefeMonsterY - adjustedOffset - 40, barWidth + 8, barHeight + 8, 8);
  
  // Barra de vida con gradiente
  rectMode(CORNER);
  float left = jefeMonsterX - barWidth/2;
  float top = jefeMonsterY - adjustedOffset - 40 - barHeight/2;
  float healthWidth = barWidth * (jefeMonsterHealth/100.0);
  
  // Gradiente de salud
  for (int i = 0; i < healthWidth; i++) {
    float t = i / healthWidth;
    color c1 = color(100, 255, 150);
    color c2 = color(255, 100, 100);
    color c = lerpColor(c2, c1, jefeMonsterHealth / 100.0);
    stroke(c);
    line(left + i, top, left + i, top + barHeight);
  }
  
  // Texto de salud
  fill(255);
  textAlign(CENTER);
  textSize(12);
  text((int)jefeMonsterHealth + "%", jefeMonsterX, jefeMonsterY - adjustedOffset - 40 + 4);
  
  popStyle();
}

// ✅ HUD MEJORADO
void dibujarHUDJefe() {
  pushStyle();
  
  // Panel principal del HUD
  fill(15, 10, 35, 200);
  noStroke();
  rectMode(CORNER);
  rect(20, 20, 280, 120, 12);
  
  // Borde brillante
  noFill();
  strokeWeight(2);
  stroke(100, 150, 255, 150);
  rect(20, 20, 280, 120, 12);
  
  // Título
  fill(150, 200, 255);
  textAlign(LEFT);
  textSize(24);
  text("⚔ JEFE FINAL", 40, 50);
  
  // Estado de disparo
  textSize(16);
  if (jefeBulletActive) {
    fill(255, 100, 100);
    text("● DISPARADO", 40, 80);
  } else {
    fill(100, 255, 150);
    text("● LISTO", 40, 80);
  }
  
  // Instrucciones
  fill(200, 220, 255);
  textSize(14);
  text("ESPACIO - Disparar", 40, 105);
  text("Elimina al jefe!", 40, 125);
  
  popStyle();
}

void dibujarMenuJefe() {
  fill(0, 0, 0, 180);
  rectMode(CORNER);
  noStroke();
  rect(0, 0, width, height);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(48);
  
  if (jefeGameWon) {
    text("¡JEFE DERROTADO!", width/2, height/2 - 40);
    textSize(24);
    text("¡HAS COMPLETADO EL JUEGO!", width/2, height/2 + 20);
  } else {
    text("DERROTA", width/2, height/2 - 40);
    textSize(24);
    text("El jefe te ha vencido", width/2, height/2 + 20);
  }
  
  textSize(18);
  text("Presiona 'R' para volver al menú", width/2, height/2 + 80);
}

void manejarInputJefe() {
  if (key == ' ' && !jefeBulletActive && jefeMonsterAlive && !jefeGameLost) {
    jefeBulletActive = true;
    jefeBulletX = width/2 - jefeAimX;
    jefeBulletY = height/2 - jefeAimY;
    jefeEnergyWaves.clear();
    jefeBulletAnimFrame = 0;
    jefeBulletRotation = 0;
  }
  
  if ((key == 'r' || key == 'R') && jefeGameEnded) {
    enMenu = true;
    enPeleaJefe = false;
    cursor();
  }
}

PImage[] jefeLoadEnemyFrames() {
  ArrayList<PImage> frames = new ArrayList<PImage>();
  int i = 0;
  while (true) {
    String n = nf(i, 2);
    String filename = "enemy/frame_" + n + "_delay-0.1s.png";
    PImage f = loadImage(filename);
    if (f == null || f.width == 0) break;
    frames.add(f);
    i++;
    if (i > 500) break;
  }
  if (frames.size() == 0) {
    PImage[] dummy = new PImage[1];
    dummy[0] = createImage(1,1,ARGB);
    return dummy;
  }
  return frames.toArray(new PImage[frames.size()]);
}

// ✅ CLASE ESTRELLA DE FONDO
class JefeBackgroundStar {
  float x, y;
  float brillo;
  float velocidadBrillo;
  float tamaño;
  
  JefeBackgroundStar() {
    x = random(width);
    y = random(height);
    brillo = random(100, 255);
    velocidadBrillo = random(1, 3);
    tamaño = random(1, 4);
  }
  
  void update() {
    brillo += velocidadBrillo;
    if (brillo > 255 || brillo < 100) {
      velocidadBrillo *= -1;
    }
  }
  
  void display() {
    noStroke();
    fill(255, brillo);
    ellipse(x, y, tamaño, tamaño);
    
    if (tamaño > 2) {
      fill(255, brillo * 0.3);
      ellipse(x, y, tamaño * 2, tamaño * 2);
    }
  }
}

// ✅ CLASE EXPLOSIÓN DE ESTRELLA
class JefeExplosionStar {
  float x, y;
  float vx, vy;
  float vida;
  float tamaño;
  float rotacion;
  float velocidadRotacion;
  color col;
  
  JefeExplosionStar(float startX, float startY) {
    x = startX;
    y = startY;
    float angulo = random(TWO_PI);
    float velocidad = random(3, 10);
    vx = cos(angulo) * velocidad;
    vy = sin(angulo) * velocidad;
    vida = 255;
    tamaño = random(8, 20);
    rotacion = random(TWO_PI);
    velocidadRotacion = random(-0.3, 0.3);
    
    // Colores variados
    int tipo = int(random(4));
    if (tipo == 0) col = color(255, 215, 0);
    else if (tipo == 1) col = color(255, 100, 255);
    else if (tipo == 2) col = color(100, 200, 255);
    else col = color(255, 150, 150);
  }
  
  void update() {
    x += vx;
    y += vy;
    vy += 0.3; // Gravedad
    vida -= 8;
    rotacion += velocidadRotacion;
    tamaño *= 0.95;
  }
  
  void display() {
    pushStyle();
    pushMatrix();
    translate(x, y);
    rotate(rotacion);
    
    // Aura
    noStroke();
    fill(col, vida * 0.4);
    dibujarEstrellaExplosion(0, 0, tamaño * 1.5);
    
    // Estrella
    fill(col, vida);
    dibujarEstrellaExplosion(0, 0, tamaño);
    
    // Núcleo
    fill(255, vida);
    ellipse(0, 0, tamaño * 0.4, tamaño * 0.4);
    
    popMatrix();
    popStyle();
  }
  
  void dibujarEstrellaExplosion(float cx, float cy, float tam) {
    beginShape();
    for (int i = 0; i < 10; i++) {
      float angulo = TWO_PI / 10 * i;
      float r = (i % 2 == 0) ? tam : tam * 0.4;
      vertex(cx + cos(angulo) * r, cy + sin(angulo) * r);
    }
    endShape(CLOSE);
  }
  
  boolean isDead() {
    return vida <= 0;
  }
}

// CLASE ONDA DE ENERGÍA
class JefeEnergyWave {
  float x, y;
  float size;
  float alpha;
  
  JefeEnergyWave(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = 20;
    this.alpha = 200;
  }
  
  void update() {
    size += 3;
    alpha -= 10;
  }
  
  void display() {
    noFill();
    strokeWeight(2);
    stroke(200, 100, 255, alpha);
    ellipse(x, y, size, size);
    stroke(255, 150, 255, alpha * 0.6);
    ellipse(x, y, size * 0.8, size * 0.8);
    noStroke();
  }
}
