// ============================================
// GANCHO.PDE 
// ============================================

void manejarGancho() {
  if (mousePressed && !ganchoAct) {
    PVector target = new PVector(mouseX + camX, mouseY);
    float minDist = 99999f;
    
    for (PVector a : ast) {
      float d = dist(a.x, a.y, target.x, target.y);
      if (d < 60f && d < minDist) {
        hook = a.copy();
        minDist = d;
      }
    }
    if (minDist < 99999f) {
      ganchoAct = true;
      lenCuerda = dist(px, py, hook.x, hook.y);
    }
  } else if (!mousePressed) {
    ganchoAct = false;
  }
  
  if (ganchoAct) {
    dibujarRayoGalactico();
    
    PVector dir = new PVector(px - hook.x, py - hook.y);
    float distAct = dir.mag();
    
    if (distAct > lenCuerda) {
      dir.normalize();
      float exc = distAct - lenCuerda;
      px -= dir.x * exc * tens;
      py -= dir.y * exc * tens;
      
      PVector vel = new PVector(vx, vy);
      PVector tang = new PVector(-dir.y, dir.x);
      float tangVel = vel.dot(tang);
      vx = tang.x * tangVel * 0.98f;
      vy = tang.y * tangVel * 0.98f;
    } else {
      vy += grav * 0.3f;
    }
  }
}

void dibujarRayoGalactico() {
  pushStyle();
  
  float tiempo = millis() * 0.003;
  float distancia = dist(px, py, hook.x, hook.y);
  
  colorMode(HSB, 360, 100, 100, 255);
  float hueVal = (tiempo * 50) % 360;
  
  // Línea ondulante gruesa (aura exterior)
  int segmentos = 40;
  PVector inicio = new PVector(px, py);
  PVector fin = new PVector(hook.x, hook.y);
  
  // Múltiples capas del rayo
  for (int capa = 5; capa > 0; capa--) {
    strokeWeight(capa * 4);
    
    beginShape();
    noFill();
    
    for (int i = 0; i <= segmentos; i++) {
      float t = i / (float)segmentos;
      float x = lerp(inicio.x, fin.x, t);
      float y = lerp(inicio.y, fin.y, t);
      
      // Ondulación suave
      float angulo = atan2(fin.y - inicio.y, fin.x - inicio.x);
      float offset = sin(tiempo * 5 + t * TWO_PI * 3) * (8 - capa);
      x += cos(angulo + HALF_PI) * offset;
      y += sin(angulo + HALF_PI) * offset;
      
      float alpha = map(capa, 1, 5, 255, 80);
      float hue = (hueVal + t * 30) % 360;
      stroke(hue, 80, 90 + capa * 2, (int)alpha);
      vertex(x, y);
    }
    endShape();
  }
  
  // Línea central brillante
  strokeWeight(2);
  stroke(hueVal, 50, 100, 255);
  line(px, py, hook.x, hook.y);
  
  // Partículas de energía viajando
  noStroke();
  int numParticulas = 20;
  for (int i = 0; i < numParticulas; i++) {
    float t = (tiempo * 3 + i * 0.1) % 1.0;
    float particX = lerp(px, hook.x, t);
    float particY = lerp(py, hook.y, t);
    
    // Ondulación en las partículas
    float angulo = atan2(hook.y - py, hook.x - px);
    float offset = sin(tiempo * 5 + t * TWO_PI * 3) * 5;
    particX += cos(angulo + HALF_PI) * offset;
    particY += sin(angulo + HALF_PI) * offset;
    
    float tamaño = 10 + sin(tiempo * 8 + i) * 4;
    float particHue = (hueVal + i * 10) % 360;
    
    // Aura de la partícula
    fill(particHue, 70, 100, 150);
    ellipse(particX, particY, tamaño * 2, tamaño * 2);
    
    // Núcleo de la partícula
    fill(particHue, 85, 100, 230);
    ellipse(particX, particY, tamaño, tamaño);
    
    // Centro brillante
    fill(0, 0, 100, 255);
    ellipse(particX, particY, tamaño * 0.4, tamaño * 0.4);
  }
  
  // Efecto en el punto de conexión (agujero negro)
  for (int i = 4; i > 0; i--) {
    float alpha = map(i, 0, 4, 0, 180);
    float tamaño = 30 + i * 10 + sin(tiempo * 6) * 5;
    fill(hueVal, 80, 90, (int)alpha);
    ellipse(hook.x, hook.y, tamaño, tamaño);
  }
  
  fill(hueVal, 70, 100, 230);
  ellipse(hook.x, hook.y, 15, 15);
  
  fill(0, 0, 100, 255);
  ellipse(hook.x, hook.y, 8, 8);
  
  // Efecto en el jugador
  for (int i = 3; i > 0; i--) {
    float alpha = map(i, 0, 3, 0, 150);
    float tamaño = 40 + i * 8 + cos(tiempo * 6) * 5;
    fill(hueVal, 70, 95, (int)alpha);
    ellipse(px, py, tamaño, tamaño);
  }
  
  fill(hueVal, 60, 100, 230);
  ellipse(px, py, 20, 20);
  
  fill(0, 0, 100, 255);
  ellipse(px, py, 10, 10);
  
  // Anillos de energía que se expanden
  if (frameCount % 15 == 0) {
    noFill();
    strokeWeight(3);
    stroke(hueVal, 70, 100, 200);
    ellipse(px, py, 50, 50);
  }
  
  colorMode(RGB, 255);
  popStyle();
}
