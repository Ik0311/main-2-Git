// ============================================
// OBSTACULO.PDE
// ============================================

class Obstaculo {
  PVector pos;
  PVector vel;
  float radio;
  float rotacion;
  float velocidadRotacion;
  boolean esOvni;
  boolean cayendoDelCielo;
  ArrayList<PVector> vertices;
  ArrayList<PVector> crateres;
  color colBase, colOscuro, colClaro, colBrillo;
  float animacionLuces;
  
  Obstaculo(float x, float y, float r) {
    pos = new PVector(x, y);
    radio = r;
    rotacion = random(TWO_PI);
    velocidadRotacion = random(-0.025, 0.025);
    animacionLuces = random(TWO_PI);
    
    //  probabilidad de ser ovni
    esOvni = random(1) < 0.2;
    
    //  probabilidad de caer del cielo
    cayendoDelCielo = random(1) < 0.2;
    
    if (cayendoDelCielo) {
      pos.y = -50; 
      vel = new PVector(random(-1, 1), random(2, 5));
    } else {
      vel = new PVector(0, 0);
    }
    
    if (!esOvni) {
      // Colores para asteroide
      colBase = color(140, 150, 180);
      colOscuro = color(90, 100, 140);
      colClaro = color(180, 190, 220);
      colBrillo = color(220, 230, 255);
      
      // Generar forma irregular
      vertices = new ArrayList<PVector>();
      int numVertices = int(random(10, 14));
      for (int i = 0; i < numVertices; i++) {
        float angulo = map(i, 0, numVertices, 0, TWO_PI);
        float radioVertice = radio * random(0.8, 1.3);
        vertices.add(new PVector(cos(angulo) * radioVertice, sin(angulo) * radioVertice));
      }
      
      // Generar cráteres
      crateres = new ArrayList<PVector>();
      for (int i = 0; i < int(random(3, 6)); i++) {
        float angulo = random(TWO_PI);
        float dist = random(radio * 0.3, radio * 0.7);
        float tamaño = random(radio * 0.15, radio * 0.35);
        crateres.add(new PVector(cos(angulo) * dist, sin(angulo) * dist, tamaño));
      }
    } else {
      // Colores para ovni
      int tipoColor = int(random(3));
      if (tipoColor == 0) {
        colBase = color(150, 255, 200);
        colOscuro = color(100, 200, 150);
        colClaro = color(200, 255, 220);
      } else if (tipoColor == 1) {
        colBase = color(255, 150, 200);
        colOscuro = color(200, 100, 150);
        colClaro = color(255, 200, 220);
      } else {
        colBase = color(150, 200, 255);
        colOscuro = color(100, 150, 200);
        colClaro = color(200, 220, 255);
      }
      colBrillo = color(255, 255, 100);
    }
  }
  
  void actualizar() {
    if (cayendoDelCielo) {
      pos.add(vel);
      rotacion += velocidadRotacion;
    }
    animacionLuces += 0.1;
  }
  
  void dibujar() {
    actualizar();
    
    if (esOvni) {
      dibujarOvni();
    } else {
      dibujarAsteroide();
    }
  }
  
  void dibujarOvni() {
    pushStyle();
    pushMatrix();
    
    translate(pos.x, pos.y);
    rotate(sin(animacionLuces * 0.5) * 0.2);
    
    float tam = radio * 2;
    
    // Aura de peligro
    noStroke();
    for (int i = 3; i > 0; i--) {
      fill(red(colBase), green(colBase), blue(colBase), 30);
      ellipse(0, 0, tam * (1 + i * 0.2), tam * 0.6 * (1 + i * 0.2));
    }
    
    // Rayo tractor (si está cayendo)
    if (cayendoDelCielo) {
      noStroke();
      for (int i = 0; i < 3; i++) {
        fill(colBrillo, 60 - i * 15);
        beginShape();
        vertex(-tam * 0.2 + i * 3, tam * 0.3);
        vertex(tam * 0.2 - i * 3, tam * 0.3);
        vertex(tam * 0.4 - i * 5, tam * 0.3 + 80);
        vertex(-tam * 0.4 + i * 5, tam * 0.3 + 80);
        endShape(CLOSE);
      }
    }
    
    // Sombra
    fill(0, 0, 30, 80);
    ellipse(3, 3, tam * 1.2, tam * 0.4);
    
    // Cúpula superior
    noStroke();
    fill(colBase, 180);
    ellipse(0, -tam * 0.3, tam * 0.7, tam * 0.5);
    
    fill(colBase, 220);
    ellipse(0, -tam * 0.3, tam * 0.5, tam * 0.4);
    
    // Brillo de la cúpula
    fill(colClaro, 200);
    ellipse(-tam * 0.1, -tam * 0.35, tam * 0.3, tam * 0.2);
    
    fill(255, 255, 255, 180);
    ellipse(-tam * 0.08, -tam * 0.37, tam * 0.15, tam * 0.1);
    
    // Cuerpo principal
    fill(colBase);
    ellipse(0, 0, tam * 1.3, tam * 0.45);
    
    fill(colClaro);
    ellipse(0, -tam * 0.05, tam * 1.1, tam * 0.35);
    
    // Detalles metálicos
    stroke(colOscuro, 150);
    strokeWeight(2);
    noFill();
    ellipse(0, 0, tam * 1.2, tam * 0.4);
    ellipse(0, 0, tam * 0.9, tam * 0.3);
    
    // Luces parpadeantes
    noStroke();
    for (int i = 0; i < 6; i++) {
      float angulo = (TWO_PI / 6) * i;
      float distLuz = tam * 0.6;
      float lx = cos(angulo) * distLuz;
      float ly = sin(angulo) * distLuz * 0.3;
      
      float brillo = 150 + sin(animacionLuces + i) * 105;
      fill(colBrillo, brillo);
      ellipse(lx, ly, 8, 8);
      
      fill(colBrillo, brillo * 0.5);
      ellipse(lx, ly, 14, 14);
    }
    
    // Antena/sensor
    stroke(colOscuro);
    strokeWeight(2);
    line(0, -tam * 0.5, 0, -tam * 0.65);
    
    noStroke();
    fill(colBrillo, 200);
    ellipse(0, -tam * 0.68, 6, 6);
    
    fill(255, 255, 255, 220);
    ellipse(0, -tam * 0.68, 3, 3);
    
    // Símbolo alienígena (opcional)
    noFill();
    stroke(colOscuro, 150);
    strokeWeight(2);
    beginShape();
    vertex(-tam * 0.15, -tam * 0.05);
    vertex(-tam * 0.1, -tam * 0.15);
    vertex(tam * 0.1, -tam * 0.15);
    vertex(tam * 0.15, -tam * 0.05);
    endShape();
    
    popMatrix();
    popStyle();
  }
  
  void dibujarAsteroide() {
    pushStyle();
    pushMatrix();
    
    translate(pos.x, pos.y);
    rotate(rotacion);
    
    if (cayendoDelCielo) {
      rotacion += velocidadRotacion * 2;
      
      // Estela de fuego
      noStroke();
      for (int i = 0; i < 5; i++) {
        float tam = radio * (1.5 + i * 0.3);
        fill(255, 150 - i * 30, 0, 100 - i * 20);
        ellipse(0, -radio - i * 8, tam, tam);
      }
    } else {
      rotacion += velocidadRotacion;
    }
    
    // Aura de peligro
    noStroke();
    for (int i = 4; i > 0; i--) {
      fill(200, 100, 150, 40 - i * 8);
      beginShape();
      for (PVector v : vertices) {
        vertex(v.x * (1 + i * 0.15), v.y * (1 + i * 0.15));
      }
      endShape(CLOSE);
    }
    
    // Sombra
    fill(0, 0, 30, 80);
    beginShape();
    for (PVector v : vertices) {
      vertex(v.x + 4, v.y + 4);
    }
    endShape(CLOSE);
    
    // Cuerpo base
    fill(colBase);
    beginShape();
    for (PVector v : vertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    
    // Gradiente de iluminación
    for (int capa = 0; capa < 3; capa++) {
      fill(colClaro, 80 - capa * 25);
      beginShape();
      for (int i = 0; i < vertices.size() / 2; i++) {
        PVector v = vertices.get(i);
        float factor = 0.9 - capa * 0.1;
        vertex(v.x * factor, v.y * factor);
      }
      endShape();
    }
    
    // Cráteres
    noStroke();
    for (PVector crater : crateres) {
      fill(colOscuro);
      ellipse(crater.x, crater.y, crater.z, crater.z);
      
      fill(colBase, 150);
      ellipse(crater.x - crater.z * 0.1, crater.y - crater.z * 0.1, crater.z * 0.8, crater.z * 0.8);
      
      fill(50, 60, 100);
      ellipse(crater.x + crater.z * 0.05, crater.y + crater.z * 0.05, crater.z * 0.6, crater.z * 0.6);
    }
    
    // Manchas
    fill(colOscuro, 120);
    for (int i = 0; i < 5; i++) {
      float angulo = random(TWO_PI);
      float dist = random(radio * 0.4);
      float tamaño = random(4, 10);
      ellipse(cos(angulo) * dist, sin(angulo) * dist, tamaño, tamaño);
    }
    
    // Highlights
    fill(colBrillo, 200);
    ellipse(-radio * 0.3, -radio * 0.4, radio * 0.25, radio * 0.25);
    
    fill(colBrillo, 150);
    ellipse(-radio * 0.15, -radio * 0.5, radio * 0.15, radio * 0.15);
    
    fill(255, 255, 255, 180);
    ellipse(-radio * 0.25, -radio * 0.35, radio * 0.12, radio * 0.12);
    
    // Borde luminoso
    noFill();
    stroke(colClaro, 100);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < vertices.size() / 3; i++) {
      PVector v = vertices.get(i);
      vertex(v.x * 0.95, v.y * 0.95);
    }
    endShape();
    
    // Partículas flotantes
    noStroke();
    for (int i = 0; i < 8; i++) {
      float angulo = millis() * 0.001 + i * 0.8;
      float dist = radio * 1.5 + sin(angulo * 2) * 5;
      float px = cos(angulo) * dist;
      float py = sin(angulo) * dist;
      
      fill(colClaro, 150);
      ellipse(px, py, 3, 3);
    }
    
    popMatrix();
    popStyle();
  }
  
  boolean fueraDePantalla(float camX) {
    return cayendoDelCielo && pos.y > height + 100;
  }
}
