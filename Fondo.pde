// ============================================
// FONDO.PDE 
// ============================================

ArrayList<Particula> particulas;
ArrayList<Cometa> cometas;
float offsetNebulosa = 0;

float fondoCamX = 0;

void inicializarGalaxia() {
  estrellas = new ArrayList<Estrella>();
  nebulosas = new ArrayList<Nebulosa>();
  particulas = new ArrayList<Particula>();
  cometas = new ArrayList<Cometa>();
  
  for (int i = 0; i < 300; i++) {
    estrellas.add(new Estrella());
  }
  
  // Crear nebulosas
  for (int i = 0; i < 15; i++) {
    nebulosas.add(new Nebulosa());
  }
  
  // Crear partículas flotantes
  for (int i = 0; i < 100; i++) {
    particulas.add(new Particula());
  }
  
  // Crear cometas ocasionales
  for (int i = 0; i < 3; i++) {
    cometas.add(new Cometa());
  }
}

// ✅ FUNCIÓN PARA DIBUJAR LA GALAXIA
void dibujarGalaxia() {
  // Sincronizar la cámara del fondo con la del juego
  fondoCamX = camX;
  
  pushMatrix();
  
  // Gradiente de fondo animado (cambia sutilmente con el tiempo)
  float t = millis() * 0.0005;
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    
    // Colores que cambian con el tiempo
    color c1 = lerpColor(color(20, 10, 40), color(40, 10, 60), sin(t) * 0.5 + 0.5);
    color c2 = lerpColor(color(10, 20, 50), color(10, 30, 70), cos(t * 0.8) * 0.5 + 0.5);
    
    int c = lerpColor(c1, c2, inter);
    stroke(c);
    line(0, i, width, i);
  }
  
  // Dibujar partículas flotantes (polvo estelar)
  for (Particula p : particulas) {
    p.actualizar();
    p.dibujar();
  }
  
  // Dibujar nebulosas con efecto de ondulación
  offsetNebulosa += 0.01;
  for (Nebulosa n : nebulosas) {
    n.actualizar();
    n.dibujar();
  }
  
  // Dibujar cometas
  for (int i = cometas.size() - 1; i >= 0; i--) {
    Cometa c = cometas.get(i);
    c.actualizar();
    c.dibujar();
    
    // Si el cometa salió de la pantalla, crear uno nuevo
    if (c.terminado) {
      cometas.remove(i);
      if (random(1) < 0.3) {
        cometas.add(new Cometa());
      }
    }
  }
  
  // Dibujar estrellas (encima de todo)
  for (Estrella e : estrellas) {
    e.actualizar();
    e.dibujar();
  }
  
  popMatrix();
}

// ✅ CLASE ESTRELLA 
class Estrella {
  float x, y;
  float brillo;
  float velocidadBrillo;
  float tamaño;
  float profundidad;
  color col;
  float offsetInicial; 
  
  Estrella() {
    // Distribuir estrellas en un rango más amplio
    offsetInicial = random(-width * 2, width * 2);
    x = offsetInicial;
    y = random(height);
    brillo = random(100, 255);
    velocidadBrillo = random(0.5, 3);
    tamaño = random(1, 5);
    profundidad = random(0.2, 1);
    
    // Algunas estrellas tienen color
    if (random(1) < 0.1) {
      int tipo = int(random(3));
      if (tipo == 0) col = color(255, 200, 150); // Amarilla
      else if (tipo == 1) col = color(150, 200, 255); // Azul
      else col = color(255, 150, 200); // Rosa
    } else {
      col = color(255); // Blanca
    }
  }
  
  void actualizar() {
    // Animación de brillo
    brillo += velocidadBrillo;
    if (brillo > 255 || brillo < 100) {
      velocidadBrillo *= -1;
    }
    
    // Calcular posición con parallax
    float parallaxX = x - (fondoCamX * profundidad);
    
    float rangoVisible = width * 3;
    float centro = fondoCamX;
    
    // Si está muy a la izquierda, moverla a la derecha
    if (parallaxX < centro - rangoVisible) {
      x += rangoVisible * 2;
    }
    // Si está muy a la derecha, moverla a la izquierda
    else if (parallaxX > centro + rangoVisible) {
      x -= rangoVisible * 2;
    }
  }
  
  void dibujar() {
    pushStyle();
    noStroke();
    fill(col, brillo);
    
    float parallaxX = x - (fondoCamX * profundidad);
    ellipse(parallaxX, y, tamaño, tamaño);
    
    // Brillo extra para estrellas grandes
    if (tamaño > 2.5) {
      fill(col, brillo * 0.4);
      ellipse(parallaxX, y, tamaño * 2.5, tamaño * 2.5);
      
      // Destello en cruz para estrellas muy grandes
      if (tamaño > 3.5) {
        strokeWeight(1);
        stroke(col, brillo * 0.6);
        line(parallaxX - tamaño * 2, y, parallaxX + tamaño * 2, y);
        line(parallaxX, y - tamaño * 2, parallaxX, y + tamaño * 2);
      }
    }
    popStyle();
  }
}

class Nebulosa {
  float x, y;
  float tamaño;
  color col1, col2, col3;
  float anguloRotacion;
  float velocidadRotacion;
  float profundidad;
  float tiempoOffset;
  float offsetInicial;
  
  Nebulosa() {
    offsetInicial = random(-width * 2, width * 2);
    x = offsetInicial;
    y = random(height);
    tamaño = random(200, 500);
    profundidad = random(0.05, 0.3);
    tiempoOffset = random(1000);
    
    // Colores de nebulosa más variados
    int tipo = int(random(5));
    if (tipo == 0) {
      col1 = color(150, 50, 200, 40);
      col2 = color(100, 30, 180, 15);
      col3 = color(180, 80, 220, 25);
    } else if (tipo == 1) {
      col1 = color(50, 100, 200, 40);
      col2 = color(30, 70, 150, 15);
      col3 = color(80, 130, 220, 25);
    } else if (tipo == 2) {
      col1 = color(200, 50, 100, 40);
      col2 = color(150, 30, 80, 15);
      col3 = color(220, 80, 130, 25);
    } else if (tipo == 3) {
      col1 = color(100, 200, 150, 40);
      col2 = color(50, 150, 100, 15);
      col3 = color(130, 220, 180, 25);
    } else {
      col1 = color(200, 150, 50, 40);
      col2 = color(150, 100, 30, 15);
      col3 = color(220, 180, 80, 25);
    }
    
    anguloRotacion = random(TWO_PI);
    velocidadRotacion = random(-0.003, 0.003);
  }
  
  void actualizar() {
    anguloRotacion += velocidadRotacion;
    
    // Cambio muy sutil de color con el tiempo
    float t = (millis() + tiempoOffset) * 0.0001;
    float cambio = sin(t) * 0.02;
    col1 = lerpColor(col1, color(random(80, 220), random(30, 200), random(100, 255), 40), cambio);
    
    float parallaxX = x - (fondoCamX * profundidad);
    
    // Sistema de wrapping infinito
    float rangoVisible = width * 3;
    float centro = fondoCamX;
    
    if (parallaxX < centro - rangoVisible - tamaño) {
      x += rangoVisible * 2;
    } else if (parallaxX > centro + rangoVisible + tamaño) {
      x -= rangoVisible * 2;
    }
  }
  
  void dibujar() {
    pushStyle();
    pushMatrix();
    
    float parallaxX = x - (fondoCamX * profundidad);
    
    translate(parallaxX, y);
    rotate(anguloRotacion);
    
    noStroke();
    
    // Efecto de ondulación
    float onda = sin(offsetNebulosa + anguloRotacion) * 0.1 + 1;
    
    // Dibujar múltiples capas de nebulosa con ondulación
    for (int i = 4; i > 0; i--) {
      float factor = i / 4.0;
      fill(lerpColor(col1, col2, 1 - factor));
      ellipse(0, 0, tamaño * factor * onda, tamaño * factor * 0.6 * onda);
    }
    
    // Capa adicional con tercer color
    fill(col3);
    ellipse(tamaño * 0.2, -tamaño * 0.1, tamaño * 0.4 * onda, tamaño * 0.3 * onda);
    
    popMatrix();
    popStyle();
  }
}

class Particula {
  float x, y;
  float vx, vy;
  float tamaño;
  float profundidad;
  float alpha;
  float offsetInicial;
  
  Particula() {
    offsetInicial = random(-width * 2, width * 2);
    x = offsetInicial;
    y = random(height);
    vx = random(-0.3, 0.3);
    vy = random(-0.2, 0.2);
    tamaño = random(1, 3);
    profundidad = random(0.3, 0.8);
    alpha = random(50, 150);
  }
  
  void actualizar() {
    x += vx;
    y += vy;
    
    // Movimiento ondulante
    y += sin(millis() * 0.001 + x * 0.01) * 0.1;
    
    float parallaxX = x - (fondoCamX * profundidad);
    
    // Sistema de wrapping infinito
    float rangoVisible = width * 3;
    float centro = fondoCamX;
    
    if (parallaxX < centro - rangoVisible) {
      x += rangoVisible * 2;
      y = random(height);
    } else if (parallaxX > centro + rangoVisible) {
      x -= rangoVisible * 2;
      y = random(height);
    }
    
    // Loop vertical
    if (y < 0) y = height;
    if (y > height) y = 0;
  }
  
  void dibujar() {
    pushStyle();
    noStroke();
    fill(200, 220, 255, alpha);
    
    float parallaxX = x - (fondoCamX * profundidad);
    ellipse(parallaxX, y, tamaño, tamaño);
    popStyle();
  }
}

// ✅ CLASE COMETA (estrella fugaz)
class Cometa {
  float x, y;
  float vx, vy;
  ArrayList<PVector> trail;
  boolean terminado;
  float vida;
  
  Cometa() {
    x = random(fondoCamX + width * 0.5, fondoCamX + width * 2);
    y = random(height * 0.3);
    vx = random(-8, -4);
    vy = random(2, 5);
    trail = new ArrayList<PVector>();
    terminado = false;
    vida = 255;
  }
  
  void actualizar() {
    x += vx;
    y += vy;
    
    trail.add(new PVector(x, y));
    if (trail.size() > 20) {
      trail.remove(0);
    }
    
    vida -= 2;
    
    if (x < fondoCamX - 100 || y > height + 100 || vida <= 0) {
      terminado = true;
    }
  }
  
  void dibujar() {
    pushStyle();
    noFill();
    
    // Dibujar estela
    for (int i = 0; i < trail.size(); i++) {
      PVector p = trail.get(i);
      float alpha = map(i, 0, trail.size(), 0, vida);
      stroke(255, 255, 200, alpha);
      strokeWeight(map(i, 0, trail.size(), 1, 4));
      point(p.x, p.y);
    }
    
    // Dibujar cabeza del cometa
    noStroke();
    fill(255, 255, 220, vida);
    ellipse(x, y, 6, 6);
    fill(255, 255, 200, vida * 0.5);
    ellipse(x, y, 12, 12);
    
    popStyle();
  }
}
