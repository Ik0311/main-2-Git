// ============================================
// PLATAFORMA.PDE 
// ============================================

class Plataforma {
  float x, y, w, h;
  int tipo; // 0: roca espacial, 1: fragmento planeta, 2: cometa congelado, 3: cristal
  color col1, col2, col3, colBorde;
  ArrayList<PVector> detalles;
  float animacion;
  
  Plataforma(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.tipo = int(random(4));
    this.animacion = random(TWO_PI);
    this.detalles = new ArrayList<PVector>();
    
    // Colores según el tipo
    if (tipo == 0) { // Roca espacial gris-morada
      col1 = color(120, 100, 140);
      col2 = color(90, 80, 110);
      col3 = color(70, 60, 90);
      colBorde = color(80, 70, 100);
    } else if (tipo == 1) { // Fragmento rosa-morado
      col1 = color(180, 120, 160);
      col2 = color(150, 100, 140);
      col3 = color(120, 80, 120);
      colBorde = color(140, 90, 130);
    } else if (tipo == 2) { // Cometa azul-cyan
      col1 = color(120, 180, 200);
      col2 = color(90, 150, 180);
      col3 = color(70, 120, 160);
      colBorde = color(80, 140, 170);
    } else { // Cristal morado brillante
      col1 = color(160, 120, 180);
      col2 = color(130, 100, 160);
      col3 = color(100, 80, 140);
      colBorde = color(120, 90, 150);
    }
    
    // Generar detalles (manchas, cristales, cráteres)
    for (int i = 0; i < int(random(3, 8)); i++) {
      detalles.add(new PVector(random(w * 0.1, w * 0.9), random(h * 0.2, h * 0.8), random(5, 15)));
    }
  }
  
  void dibujar() {
    pushStyle();
    pushMatrix();
    
    translate(x, y);
    animacion += 0.01;
    
    // Sombra de la plataforma
    noStroke();
    fill(0, 0, 0, 80);
    rect(5, 5, w, h, 8);
    
    if (tipo == 0) {
      dibujarRocaEspacial();
    } else if (tipo == 1) {
      dibujarFragmentoPlaneta();
    } else if (tipo == 2) {
      dibujarCometaCongelado();
    } else {
      dibujarCristal();
    }
    
    popMatrix();
    popStyle();
  }
  
  void dibujarRocaEspacial() {
    // Base oscura
    noStroke();
    fill(col3);
    rect(0, 0, w, h, 8);
    
    // Capa media
    fill(col2);
    rect(0, 0, w, h * 0.85, 8);
    
    // Capa superior
    fill(col1);
    rect(0, 0, w, h * 0.7, 8);
    
    // Grietas y detalles
    stroke(col3);
    strokeWeight(3);
    line(w * 0.2, 0, w * 0.25, h);
    line(w * 0.6, 0, w * 0.55, h);
    line(w * 0.8, h * 0.3, w * 0.75, h);
    
    strokeWeight(2);
    stroke(col2);
    line(w * 0.4, 0, w * 0.42, h * 0.6);
    
    // Manchas oscuras (cráteres)
    noStroke();
    for (PVector d : detalles) {
      fill(col3, 200);
      ellipse(d.x, d.y, d.z, d.z * 0.8);
      
      fill(col2, 150);
      ellipse(d.x - 2, d.y - 2, d.z * 0.6, d.z * 0.5);
    }
    
    // Highlights de luz
    fill(200, 200, 220, 100);
    rect(w * 0.1, h * 0.1, w * 0.3, h * 0.15, 4);
    rect(w * 0.6, h * 0.2, w * 0.2, h * 0.12, 4);
    
    // Borde superior
    stroke(colBorde);
    strokeWeight(4);
    line(0, 0, w, 0);
    
    noStroke();
    fill(colBorde, 150);
    rect(0, 0, w, 3);
  }
  
  void dibujarFragmentoPlaneta() {
    // Base con textura de planeta
    noStroke();
    fill(col3);
    rect(0, 0, w, h, 8);
    
    // Capas de colores (como capas geológicas)
    fill(col2);
    rect(0, 0, w, h * 0.8, 8);
    
    fill(col1);
    rect(0, 0, w, h * 0.65, 8);
    
    // Patrón de superficie planetaria
    fill(col2, 150);
    for (int i = 0; i < w; i += 30) {
      float altura = h * 0.5 + sin(animacion + i * 0.1) * h * 0.1;
      rect(i, 0, 25, altura, 4);
    }
    
    // Cráteres/formaciones
    for (PVector d : detalles) {
      fill(col3, 180);
      ellipse(d.x, d.y, d.z * 1.5, d.z);
      
      fill(col1, 120);
      ellipse(d.x - 3, d.y - 2, d.z * 0.8, d.z * 0.6);
    }
    
    // Cristales incrustados
    fill(180, 150, 200, 200);
    triangle(w * 0.3, h * 0.3, w * 0.35, h * 0.5, w * 0.25, h * 0.5);
    triangle(w * 0.7, h * 0.4, w * 0.75, h * 0.55, w * 0.68, h * 0.55);
    
    // Brillo atmosférico
    fill(255, 200, 230, 80);
    rect(0, 0, w, h * 0.3, 8);
    
    // Borde definido
    stroke(colBorde);
    strokeWeight(4);
    noFill();
    rect(0, 0, w, h, 8);
  }
  
  void dibujarCometaCongelado() {
    // Base helada
    noStroke();
    fill(col3);
    rect(0, 0, w, h, 8);
    
    // Capa de hielo
    fill(col2);
    rect(0, 0, w, h * 0.85, 8);
    
    fill(col1);
    rect(0, 0, w, h * 0.7, 8);
    
    // Efecto de hielo cristalizado
    fill(200, 230, 255, 120);
    for (int i = 0; i < 5; i++) {
      float offset = sin(animacion + i) * 3;
      rect(i * w/5, 0 + offset, w/5 - 5, h * 0.6, 4);
    }
    
    // Cristales de hielo
    fill(220, 240, 255, 180);
    for (PVector d : detalles) {
      pushMatrix();
      translate(d.x, d.y);
      rotate(animacion + d.z);
      
      beginShape();
      vertex(0, -d.z * 0.5);
      vertex(d.z * 0.3, 0);
      vertex(0, d.z * 0.5);
      vertex(-d.z * 0.3, 0);
      endShape(CLOSE);
      
      popMatrix();
    }
    
    // Escarcha brillante
    fill(255, 255, 255, 200);
    rect(w * 0.2, h * 0.1, w * 0.15, h * 0.15, 3);
    rect(w * 0.6, h * 0.2, w * 0.12, h * 0.12, 3);
    ellipse(w * 0.8, h * 0.35, 8, 8);
    
    // Partículas de nieve flotando
    for (int i = 0; i < 10; i++) {
      float px = (i / 10.0) * w;
      float py = (sin(animacion * 2 + i) + 1) * h * 0.3;
      fill(255, 255, 255, 180);
      ellipse(px, py, 4, 4);
    }
    
    // Borde helado
    stroke(150, 200, 230);
    strokeWeight(4);
    noFill();
    rect(0, 0, w, h, 8);
    
    stroke(200, 230, 255, 200);
    strokeWeight(2);
    line(0, 0, w, 0);
  }
  
  void dibujarCristal() {
    // Base cristalina
    noStroke();
    fill(col3);
    rect(0, 0, w, h, 8);
    
    // Capas de cristal
    fill(col2);
    rect(0, 0, w, h * 0.85, 8);
    
    fill(col1);
    rect(0, 0, w, h * 0.7, 8);
    
    // Facetas de cristal
    fill(col1, 200);
    for (int i = 0; i < w; i += 40) {
      beginShape();
      vertex(i, 0);
      vertex(i + 20, h * 0.3);
      vertex(i + 40, 0);
      endShape(CLOSE);
    }
    
    // Cristales grandes sobresaliendo
    fill(180, 140, 200, 220);
    triangle(w * 0.25, h * 0.6, w * 0.3, h * 0.1, w * 0.35, h * 0.6);
    triangle(w * 0.6, h * 0.5, w * 0.65, 0, w * 0.7, h * 0.5);
    
    fill(200, 160, 220, 180);
    triangle(w * 0.45, h * 0.55, w * 0.48, h * 0.2, w * 0.52, h * 0.55);
    
    // Detalles cristalinos
    for (PVector d : detalles) {
      fill(col1, 150);
      rect(d.x, d.y, d.z * 0.6, d.z, 2);
      
      fill(220, 200, 240, 180);
      rect(d.x + 2, d.y - 2, d.z * 0.4, d.z * 0.7, 2);
    }
    
    // Brillos y reflejos
    fill(255, 255, 255, 150);
    rect(w * 0.15, h * 0.15, w * 0.2, h * 0.1, 4);
    rect(w * 0.55, h * 0.25, w * 0.15, h * 0.08, 4);
    
    // Pulso de luz
    float pulsoBrillo = sin(animacion * 3) * 50 + 150;
    fill(200, 180, 255, pulsoBrillo);
    rect(0, 0, w, h * 0.4, 8);
    
    // Borde cristalino brillante
    stroke(180, 160, 220);
    strokeWeight(4);
    noFill();
    rect(0, 0, w, h, 8);
    
    stroke(220, 200, 255, 200);
    strokeWeight(2);
    line(0, 0, w, 0);
  }
}
