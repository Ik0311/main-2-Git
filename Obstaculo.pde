// ============================================
// OBSTACULO.PDE - Asteroides espaciales con colores azul-morado
// ============================================

class Obstaculo {
  PVector pos;
  float radio;
  float rotacion;
  float velocidadRotacion;
  ArrayList<PVector> vertices;
  ArrayList<PVector> crateres;
  color colBase, colOscuro, colClaro, colBrillo;
  
  Obstaculo(float x, float y, float r) {
    pos = new PVector(x, y);
    radio = r;
    rotacion = random(TWO_PI);
    velocidadRotacion = random(-0.025, 0.025);
    
    // Colores azul-morado grisáceos
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
  }
  
  void dibujar() {
    pushStyle();
    pushMatrix();
    
    translate(pos.x, pos.y);
    rotate(rotacion);
    rotacion += velocidadRotacion;
    
    // Aura de peligro (morada-rojiza)
    noStroke();
    for (int i = 4; i > 0; i--) {
      fill(200, 100, 150, 40 - i * 8);
      beginShape();
      for (PVector v : vertices) {
        vertex(v.x * (1 + i * 0.15), v.y * (1 + i * 0.15));
      }
      endShape(CLOSE);
    }
    
    // Sombra del asteroide
    fill(0, 0, 30, 80);
    beginShape();
    for (PVector v : vertices) {
      vertex(v.x + 4, v.y + 4);
    }
    endShape(CLOSE);
    
    // Cuerpo base del asteroide
    fill(colBase);
    beginShape();
    for (PVector v : vertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    
    // Gradiente de iluminación (simular luz)
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
    
    // Cráteres oscuros
    noStroke();
    for (PVector crater : crateres) {
      // Sombra del cráter
      fill(colOscuro);
      ellipse(crater.x, crater.y, crater.z, crater.z);
      
      // Borde del cráter
      fill(colBase, 150);
      ellipse(crater.x - crater.z * 0.1, crater.y - crater.z * 0.1, crater.z * 0.8, crater.z * 0.8);
      
      // Profundidad
      fill(50, 60, 100);
      ellipse(crater.x + crater.z * 0.05, crater.y + crater.z * 0.05, crater.z * 0.6, crater.z * 0.6);
    }
    
    // Detalles de superficie (manchas)
    fill(colOscuro, 120);
    for (int i = 0; i < 5; i++) {
      float angulo = random(TWO_PI);
      float dist = random(radio * 0.4);
      float tamaño = random(4, 10);
      ellipse(cos(angulo) * dist, sin(angulo) * dist, tamaño, tamaño);
    }
    
    // Highlights brillantes (simular luz espacial)
    fill(colBrillo, 200);
    ellipse(-radio * 0.3, -radio * 0.4, radio * 0.25, radio * 0.25);
    
    fill(colBrillo, 150);
    ellipse(-radio * 0.15, -radio * 0.5, radio * 0.15, radio * 0.15);
    
    fill(255, 255, 255, 180);
    ellipse(-radio * 0.25, -radio * 0.35, radio * 0.12, radio * 0.12);
    
    // Borde luminoso (edge lighting)
    noFill();
    stroke(colClaro, 100);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < vertices.size() / 3; i++) {
      PVector v = vertices.get(i);
      vertex(v.x * 0.95, v.y * 0.95);
    }
    endShape();
    
    // Partículas flotantes alrededor (polvo)
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
}
