// ============================================
// ASTEROIDE.PDE - Agujeros negros galácticos animados
// ============================================

void generarAsteroidesIniciales() {
  ast.clear();
  for (int i = 0; i < 8; i++) {
    float x = i * astDist + 400f;
    float y = random(150f, 350f);
    
    // Asegurar que no se superpongan
    boolean valido = true;
    for (PVector a : ast) {
      if (dist(x, y, a.x, a.y) < 150) {
        valido = false;
        break;
      }
    }
    
    if (valido) {
      ast.add(new PVector(x, y));
      ultAstX = x;
    } else {
      i--;
    }
  }
}

void generarAsteroidesProcedural() {
  if (px + width > ultAstX) {
    for (int i = 0; i < 4; i++) {
      float x = ultAstX + astDist;
      float y = random(150f, 350f);
      
      boolean valido = true;
      for (PVector a : ast) {
        if (dist(x, y, a.x, a.y) < 150) {
          y = random(150f, 350f);
          valido = true;
        }
      }
      
      ast.add(new PVector(x, y));
      ultAstX += astDist;
    }
  }
}

void dibujarAsteroides() {
  for (int i = 0; i < ast.size(); i++) {
    PVector a = ast.get(i);
    dibujarAgujeroNegroGalactico(a.x, a.y, i);
  }
}

// ✅ AGUJERO NEGRO ESTILO GALAXIA SUAVE
void dibujarAgujeroNegroGalactico(float x, float y, int indice) {
  pushStyle();
  pushMatrix();
  
  translate(x, y);
  
  float tiempo = millis() * 0.001 + indice * 2;
  
  // Color que cambia suavemente
  colorMode(HSB, 360, 100, 100, 255);
  float hueVal = (tiempo * 30 + indice * 60) % 360;
  
  // Anillos externos pulsantes
  for (int capa = 8; capa > 0; capa--) {
    float pulso = sin(tiempo * 2 + capa * 0.3) * 0.15 + 1;
    float tamaño = (60 + capa * 12) * pulso;
    float alpha = map(capa, 0, 8, 150, 30);
    
    noStroke();
    fill(hueVal, 80, 90, (int)alpha);
    ellipse(0, 0, tamaño, tamaño);
  }
  
  // Espiral rotante (disco de acreción)
  rotate(tiempo * 0.5);
  for (int i = 0; i < 20; i++) {
    float angulo = map(i, 0, 20, 0, TWO_PI * 3);
    float distancia = map(i, 0, 20, 25, 50);
    float tamaño = map(i, 0, 20, 15, 5);
    
    float px = cos(angulo) * distancia;
    float py = sin(angulo) * distancia;
    
    float particleHue = (hueVal + i * 5) % 360;
    fill(particleHue, 90, 95, 200);
    ellipse(px, py, tamaño, tamaño);
    
    fill(particleHue, 70, 100, 150);
    ellipse(px, py, tamaño * 0.6, tamaño * 0.6);
  }
  rotate(-tiempo * 0.5);
  
  // Anillo brillante central
  noFill();
  strokeWeight(4);
  stroke(hueVal, 70, 100, 220);
  ellipse(0, 0, 45, 45);
  
  strokeWeight(2);
  stroke(0, 0, 100, 200);
  ellipse(0, 0, 43, 43);
  
  // Núcleo oscuro con gradiente
  noStroke();
  for (int i = 5; i > 0; i--) {
    float alpha = map(i, 0, 5, 255, 100);
    fill(hueVal, 30, 20, (int)alpha);
    ellipse(0, 0, i * 8, i * 8);
  }
  
  fill(0, 0, 10);
  ellipse(0, 0, 30, 30);
  
  // Partículas orbitando
  for (int i = 0; i < 12; i++) {
    float angulo = tiempo * 3 + (i * TWO_PI / 12);
    float dist = 35 + sin(tiempo * 4 + i) * 5;
    float particleX = cos(angulo) * dist;
    float particleY = sin(angulo) * dist;
    
    float particleHue = (hueVal + i * 10) % 360;
    
    noStroke();
    fill(particleHue, 85, 100, 220);
    ellipse(particleX, particleY, 6, 6);
    
    fill(0, 0, 100, 180);
    ellipse(particleX, particleY, 3, 3);
  }
  
  // Destellos aleatorios
  if (frameCount % (30 + indice * 5) < 3) {
    stroke(0, 0, 100, 200);
    strokeWeight(2);
    float destello = 50;
    line(-destello, 0, destello, 0);
    line(0, -destello, 0, destello);
    
    rotate(HALF_PI / 2);
    line(-destello * 0.7, 0, destello * 0.7, 0);
    line(0, -destello * 0.7, 0, destello * 0.7);
  }
  
  colorMode(RGB, 255);
  popMatrix();
  popStyle();
}
