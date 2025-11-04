// =========================================
// TAB JEFE 
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
      
      tint(obtenerTinteJefeNivel());
      image(f, 0, 0, f.width * scaleFactor, f.height * scaleFactor);
      noTint();
      
      if (frameCount % jefeEnemyFrameDelay == 0) {
        jefeCurrentEnemyFrame = (jefeCurrentEnemyFrame + 1) % jefeEnemyFrameCount;
      }
    } else {
      noStroke();
      fill(180);
      ellipse(0, 0, jefeMonsterBaseSize, jefeMonsterBaseSize * 1.2);
    }
    popMatrix();

    dibujarBarraVidaJefe();
  }

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
  
  for (int i = jefeExplosionStars.size() - 1; i >= 0; i--) {
    JefeExplosionStar s = jefeExplosionStars.get(i);
    s.update();
    s.display();
    if (s.isDead()) {
      jefeExplosionStars.remove(i);
    }
  }

  popMatrix();

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

color obtenerTinteJefeNivel() {
  int colorIndex = (nivelActual - 1) % 6;
  switch(colorIndex) {
    case 0: return color(200, 150, 255);
    case 1: return color(150, 200, 255);
    case 2: return color(150, 255, 255);
    case 3: return color(150, 255, 150);
    case 4: return color(255, 200, 150);
    case 5: return color(255, 150, 150);
    default: return color(255);
  }
}

void dibujarFondoEspacialJefe() {
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    int c = lerpColor(color(10, 5, 35), color(25, 5, 50), inter);
    stroke(c);
    line(0, i, width, i);
  }
  
  dibujarNebulosasBoss();
  
  for (JefeBackgroundStar star : jefeBackgroundStars) {
    star.update();
    star.display();
  }
  
  dibujarPolvoEstelarBoss();
}

void dibujarNebulosasBoss() {
  pushStyle();
  float tiempo = millis() * 0.0002;
  
  for (int i = 0; i < 3; i++) {
    float offsetX = sin(tiempo + i) * 100;
    float offsetY = cos(tiempo * 0.7 + i) * 50;
    
    noStroke();
    fill(150, 50, 200, 15);
    ellipse(width * 0.3 + offsetX, height * 0.3 + offsetY, 400 + i * 100, 300 + i * 80);
  }
  
  for (int i = 0; i < 3; i++) {
    float offsetX = cos(tiempo * 0.8 + i) * 120;
    float offsetY = sin(tiempo * 0.6 + i) * 70;
    
    noStroke();
    fill(50, 100, 255, 12);
    ellipse(width * 0.7 + offsetX, height * 0.5 + offsetY, 350 + i * 90, 280 + i * 70);
  }
  
  for (int i = 0; i < 3; i++) {
    float offsetX = sin(tiempo * 0.9 + i) * 80;
    float offsetY = cos(tiempo * 1.1 + i) * 60;
    
    noStroke();
    fill(255, 80, 150, 10);
    ellipse(width * 0.5 + offsetX, height * 0.7 + offsetY, 300 + i * 80, 250 + i * 60);
  }
  
  popStyle();
}

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

void dibujarBalaEstrella(float x, float y) {
  pushStyle();
  pushMatrix();
  translate(x, y);
  rotate(jefeBulletRotation);
  
  float tiempo = millis() * 0.001;
  colorMode(HSB, 360, 100, 100, 255);
  float hue = (tiempo * 50) % 360;
  
  float pulso = sin(jefeBulletAnimFrame) * 10 + 40;
  noStroke();
  fill(hue, 70, 100, 80);
  dibujarEstrellaForma(0, 0, pulso, 10);
  
  fill(hue, 85, 100, 220);
  dibujarEstrellaForma(0, 0, 30, 10);
  
  fill(hue, 70, 100, 200);
  dibujarEstrellaForma(0, 0, 20, 10);
  
  fill(0, 0, 100, 255);
  ellipse(0, 0, 12, 12);
  
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

void crearExplosionEstrellas(float x, float y) {
  for (int i = 0; i < 30; i++) {
    jefeExplosionStars.add(new JefeExplosionStar(x, y));
  }
}

void dibujarBarraVidaJefe() {
  pushStyle();
  float barWidth = 150;
  float barHeight = 15;
  float adjustedOffset = jefeMonsterBaseSize * jefeMonsterScale;
  
  noStroke();
  fill(20, 10, 40, 220);
  rectMode(CENTER);
  rect(jefeMonsterX, jefeMonsterY - adjustedOffset - 40, barWidth + 8, barHeight + 8, 8);
  
  noFill();
  strokeWeight(2);
  color bordeColor = obtenerTinteJefeNivel();
  stroke(red(bordeColor), green(bordeColor), blue(bordeColor), 180);
  rect(jefeMonsterX, jefeMonsterY - adjustedOffset - 40, barWidth + 8, barHeight + 8, 8);
  
  rectMode(CORNER);
  float left = jefeMonsterX - barWidth/2;
  float top = jefeMonsterY - adjustedOffset - 40 - barHeight/2;
  float healthWidth = barWidth * (jefeMonsterHealth/100.0);
  
  for (int i = 0; i < healthWidth; i++) {
    float t = i / healthWidth;
    color c1 = color(100, 255, 150);
    color c2 = color(255, 100, 100);
    color c = lerpColor(c2, c1, jefeMonsterHealth / 100.0);
    stroke(c);
    line(left + i, top, left + i, top + barHeight);
  }
  
  fill(255);
  textAlign(CENTER);
  textSize(12);
  text((int)jefeMonsterHealth + "%", jefeMonsterX, jefeMonsterY - adjustedOffset - 40 + 4);
  
  popStyle();
}

void dibujarHUDJefe() {
  pushStyle();
  
  fill(15, 10, 35, 200);
  noStroke();
  rectMode(CORNER);
  rect(20, 20, 280, 140, 12);
  
  noFill();
  strokeWeight(2);
  color bordeColor = obtenerTinteJefeNivel();
  stroke(red(bordeColor), green(bordeColor), blue(bordeColor), 150);
  rect(20, 20, 280, 140, 12);
  
  fill(red(bordeColor), green(bordeColor), blue(bordeColor));
  textAlign(LEFT);
  textSize(24);
  text("⚔ JEFE NIVEL " + nivelActual, 40, 50);
  
  textSize(16);
  if (jefeBulletActive) {
    fill(255, 100, 100);
    text("● DISPARADO", 40, 80);
  } else {
    fill(100, 255, 150);
    text("● LISTO", 40, 80);
  }
  
  fill(200, 220, 255);
  textSize(14);
  text("ESPACIO - Disparar", 40, 105);
  text("Elimina al jefe!", 40, 125);
  text("Puntaje: " + (scoreTotalAcumulado + score), 40, 145);
  
  popStyle();
}

void dibujarMenuJefe() {
  fill(0, 0, 0, 200);
  rectMode(CORNER);
  noStroke();
  rect(0, 0, width, height);
  
  float tiempo = millis() * 0.001;
  
  // Estrellas animadas
  pushStyle();
  for (int i = 0; i < 80; i++) {
    float x = (width * 0.2 + sin(tiempo * (i * 0.1) + i) * width * 0.6) % width;
    float y = (height * 0.2 + cos(tiempo * (i * 0.08) + i) * height * 0.6) % height;
    float brillo = 150 + sin(tiempo * 10 + i) * 105;
    float tam = 2 + sin(tiempo * 5 + i) * 1;
    
    noStroke();
    fill(255, brillo);
    ellipse(x, y, tam, tam);
  }
  popStyle();
  
  // Portal giratorio
  pushStyle();
  pushMatrix();
  translate(width / 2, height / 2);
  rotate(tiempo * 0.5);
  
  noFill();
  colorMode(HSB, 360, 100, 100);
  for (int i = 0; i < 5; i++) {
    strokeWeight(3);
    float hue = (tiempo * 50 + i * 30) % 360;
    stroke(hue, 80, 90, 80);
    ellipse(0, 0, 300 + i * 50, 300 + i * 50);
  }
  colorMode(RGB, 255);
  popMatrix();
  popStyle();
  
  if (jefeGameWon) {
    // Ovnis celebrando
    pushStyle();
    for (int i = 0; i < 3; i++) {
      float ox = width * (0.15 + i * 0.35) + sin(tiempo * 2 + i) * 40;
      float oy = height * 0.2 + cos(tiempo * 1.5 + i) * 25;
      dibujarOvniJefe(ox, oy, 35, color(100 + i * 50, 200, 255 - i * 50));
    }
    popStyle();
    
    // Título de victoria
    pushStyle();
    textFont(fuenteMenu);
    fill(255, 215, 0, 100);
    textAlign(CENTER);
    textSize(70);
    text("¡JEFE DERROTADO!", width/2 + 4, height/2 - 80 + 4);
    
    fill(255, 215, 0);
    textSize(68);
    text("¡JEFE DERROTADO!", width/2, height/2 - 80);
    
    // Estrellas decorativas
    for (int i = 0; i < 6; i++) {
      float angulo = (TWO_PI / 6) * i + tiempo;
      float dist = 180 + sin(tiempo * 3) * 20;
      float sx = width/2 + cos(angulo) * dist;
      float sy = height/2 - 80 + sin(angulo) * dist;
      
      pushMatrix();
      translate(sx, sy);
      rotate(tiempo * 2 + i);
      
      fill(255, 215, 0, 200);
      noStroke();
      beginShape();
      for (int j = 0; j < 10; j++) {
        float a = (TWO_PI / 10) * j;
        float r = (j % 2 == 0) ? 12 : 5;
        vertex(cos(a) * r, sin(a) * r);
      }
      endShape(CLOSE);
      popMatrix();
    }
    
    fill(200, 255, 200);
    textSize(36);
    text("Nivel " + nivelActual + " completado", width/2, height/2 - 10);
    
    fill(255);
    textSize(32);
    text("Puntaje: " + (scoreTotalAcumulado + score), width/2, height/2 + 30);
    
    float brillo = 200 + sin(tiempo * 5) * 55;
    fill(100, 255, 150, brillo);
    textSize(32);
    text("Presiona 'N' para SIGUIENTE NIVEL", width/2, height/2 + 90);
    
    fill(200, 220, 255, brillo);
    textSize(24);
    text("Presiona 'R' para volver al menú", width/2, height/2 + 130);
    popStyle();
    
  } else {
    pushStyle();
    textFont(fuenteMenu);
    
    fill(255, 100, 100, 100);
    textAlign(CENTER);
    textSize(54);
    text("DERROTA", width/2 + 4, height/2 - 40 + 4);
    
    fill(255, 100, 100);
    textSize(52);
    text("DERROTA", width/2, height/2 - 40);
    
    fill(255);
    textSize(28);
    text("El jefe te ha vencido", width/2, height/2 + 20);
    
    float brillo = 200 + sin(tiempo * 5) * 55;
    fill(255, 180, 100, brillo);
    textSize(24);
    text("Presiona 'R' para volver al menú", width/2, height/2 + 80);
    popStyle();
  }
}

void dibujarOvniJefe(float x, float y, float tam, color col) {
  pushMatrix();
  translate(x, y);
  
  float tiempo = millis() * 0.001;
  rotate(sin(tiempo * 2) * 0.1);
  
  noStroke();
  fill(col, 180);
  ellipse(0, -tam * 0.3, tam * 0.8, tam * 0.6);
  
  fill(col, 220);
  ellipse(0, -tam * 0.3, tam * 0.5, tam * 0.4);
  
  fill(col);
  ellipse(0, 0, tam * 1.5, tam * 0.5);
  
  fill(red(col) + 30, green(col) + 30, blue(col) + 30);
  ellipse(0, 0, tam * 1.2, tam * 0.4);
  
  for (int i = 0; i < 5; i++) {
    float angulo = (TWO_PI / 5) * i;
    float lx = cos(angulo + tiempo * 2) * tam * 0.5;
    float ly = tam * 0.2;
    
    fill(255, 255, 100, 200);
    ellipse(lx, ly, 5, 5);
    
    noStroke();
    fill(255, 255, 150, 40);
    beginShape();
    vertex(lx - 2, ly);
    vertex(lx + 2, ly);
    vertex(lx + 6, ly + 40);
    vertex(lx - 6, ly + 40);
    endShape(CLOSE);
  }
  
  popMatrix();
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
  
  if ((key == 'n' || key == 'N') && jefeGameEnded && jefeGameWon) {
    siguienteNivel();
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

class JefeBackgroundStar {
  float x, y, brillo, velocidadBrillo, tamaño;
  
  JefeBackgroundStar() {
    x = random(width);
    y = random(height);
    brillo = random(100, 255);
    velocidadBrillo = random(1, 3);
    tamaño = random(1, 4);
  }
  
  void update() {
    brillo += velocidadBrillo;
    if (brillo > 255 || brillo < 100) velocidadBrillo *= -1;
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

class JefeExplosionStar {
  float x, y, vx, vy, vida, tamaño, rotacion, velocidadRotacion;
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
    
    int tipo = int(random(4));
    if (tipo == 0) col = color(255, 215, 0);
    else if (tipo == 1) col = color(255, 100, 255);
    else if (tipo == 2) col = color(100, 200, 255);
    else col = color(255, 150, 150);
  }
  
  void update() {
    x += vx;
    y += vy;
    vy += 0.3;
    vida -= 8;
    rotacion += velocidadRotacion;
    tamaño *= 0.95;
  }
  
  void display() {
    pushStyle();
    pushMatrix();
    translate(x, y);
    rotate(rotacion);
    
    noStroke();
    fill(col, vida * 0.4);
    dibujarEstrellaExplosion(0, 0, tamaño * 1.5);
    
    fill(col, vida);
    dibujarEstrellaExplosion(0, 0, tamaño);
    
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

class JefeEnergyWave {
  float x, y, size, alpha;
  
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
