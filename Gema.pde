// ============================================
// GEMA.PDE -
// ============================================
class Gema {
  PVector pos;
  float radio;
  float rot;
  float rotSpeed;
  float pulse;
  float pulseSpeed;
  color baseColor;
  color rimColor;
  color glowColor;
  float twinklePhase;
  ArrayList<Particula> particulas;
  
  Gema(float x, float y) {
    pos = new PVector(x, y);
    radio = random(14, 20);
    rot = random(TWO_PI);
    rotSpeed = random(-0.05, 0.05);
    pulse = random(TWO_PI);
    pulseSpeed = random(0.08, 0.12);
    twinklePhase = random(TWO_PI);
    particulas = new ArrayList<Particula>();
    
    // Colores 
    int tipo = int(random(6));
    if (tipo == 0) {           // Rosa neón brillante
      baseColor = color(255, 50, 150);
      rimColor  = color(255, 100, 200, 200);
      glowColor = color(255, 150, 220);
    } else if (tipo == 1) {    // Azul eléctrico
      baseColor = color(0, 150, 255);
      rimColor  = color(100, 200, 255, 200);
      glowColor = color(150, 220, 255);
    } else if (tipo == 2) {    // Verde neón
      baseColor = color(50, 255, 100);
      rimColor  = color(100, 255, 150, 200);
      glowColor = color(150, 255, 200);
    } else if (tipo == 3) {    // Púrpura brillante
      baseColor = color(200, 50, 255);
      rimColor  = color(220, 100, 255, 200);
      glowColor = color(235, 150, 255);
    } else if (tipo == 4) {    // Amarillo dorado
      baseColor = color(255, 220, 0);
      rimColor  = color(255, 240, 100, 200);
      glowColor = color(255, 250, 150);
    } else {                   // Naranja ardiente
      baseColor = color(255, 100, 0);
      rimColor  = color(255, 150, 50, 200);
      glowColor = color(255, 200, 100);
    }
    
    // Crear partículas orbitantes
    for (int i = 0; i < 8; i++) {
      particulas.add(new Particula(i));
    }
  }
  
  void dibujar() {
    pushStyle();
    pushMatrix();
    translate(pos.x, pos.y);
    
    rot += rotSpeed;
    pulse += pulseSpeed;
    float scalePulse = 1.0 + 0.25 * sin(pulse);
    float tw = 0.7 + 0.3 * (0.5 + 0.5 * sin(twinklePhase + frameCount * 0.08f));
    twinklePhase += 0.05;
    
    noStroke();
    for (int i = 5; i > 0; i--) {
      float haloSize = radio * (3.5 - i * 0.4) * scalePulse;
      float alpha = map(i, 1, 5, 20, 100) * tw;
      fill(red(glowColor), green(glowColor), blue(glowColor), alpha);
      ellipse(0, 0, haloSize, haloSize);
    }
    
    pushMatrix();
    rotate(frameCount * 0.03f);
    noFill();
    strokeWeight(3);
    stroke(red(rimColor), green(rimColor), blue(rimColor), 180 * tw);
    ellipse(0, 0, radio * 2.2 * scalePulse, radio * 2.2 * scalePulse);
    
    strokeWeight(2);
    stroke(255, 255, 255, 200 * tw);
    ellipse(0, 0, radio * 2.4 * scalePulse, radio * 2.4 * scalePulse);
    popMatrix();
    
    for (Particula p : particulas) {
      p.actualizar();
      p.dibujar(scalePulse, tw);
    }
    
    rotate(rot);
    scale(scalePulse);
    
    drawStarShape(radio * 1.1f, radio * 0.5f, 5, glowColor, 150 * tw);
    
    drawStarShape(radio, radio * 0.45f, 5, baseColor, 255 * tw);
    
    // Borde luminoso
    noFill();
    strokeWeight(2);
    stroke(255, 255, 255, 220 * tw);
    drawStarOutline(radio, radio * 0.45f, 5);
    
    // Núcleo ultra brillante
    noStroke();
    fill(255, 255, 255, 250 * tw);
    ellipse(0, 0, radio * 0.7f, radio * 0.7f);
    
    fill(red(baseColor), green(baseColor), blue(baseColor), 200 * tw);
    ellipse(0, 0, radio * 0.5f, radio * 0.5f);
    
    fill(255, 255, 255, 255 * tw);
    ellipse(0, 0, radio * 0.3f, radio * 0.3f);
    
    pushMatrix();
    rotate(frameCount * 0.02f);
    strokeWeight(3);
    stroke(255, 255, 255, 200 * tw);
    
    line(-radio * 1.8f, 0, radio * 1.8f, 0);
    line(0, -radio * 1.8f, 0, radio * 1.8f);
    
    strokeWeight(2);
    stroke(red(rimColor), green(rimColor), blue(rimColor), 180 * tw);
    rotate(PI/4);
    line(-radio * 1.4f, 0, radio * 1.4f, 0);
    line(0, -radio * 1.4f, 0, radio * 1.4f);
    popMatrix();
    
    pushMatrix();
    rotate(-frameCount * 0.025f);
    noStroke();
    for (int i = 0; i < 6; i++) {
      pushMatrix();
      rotate(TWO_PI / 6 * i);
      translate(radio * 0.6f, 0);
      fill(255, 255, 255, 220 * tw);
      ellipse(0, 0, 6, 6);
      fill(red(glowColor), green(glowColor), blue(glowColor), 180 * tw);
      ellipse(0, 0, 4, 4);
      popMatrix();
    }
    popMatrix();
    
    noStroke();
    fill(255, 255, 255, 230 * tw);
    ellipse(-radio * 0.3f, -radio * 0.4f, radio * 0.4f, radio * 0.4f);
    fill(red(glowColor), green(glowColor), blue(glowColor), 200 * tw);
    ellipse(-radio * 0.3f, -radio * 0.4f, radio * 0.25f, radio * 0.25f);
    
    popMatrix();
    popStyle();
  }
  
  void drawStarShape(float outerR, float innerR, int points, color c, float alphaVal) {
    color cAlpha = color(red(c), green(c), blue(c), alphaVal);
    fill(cAlpha);
    noStroke();
    beginShape();
    for (int i = 0; i < points * 2; i++) {
      float ang = PI * i / points;
      float r = (i % 2 == 0) ? outerR : innerR;
      float x = cos(ang) * r;
      float y = sin(ang) * r;
      vertex(x, y);
    }
    endShape(CLOSE);
  }
  
  void drawStarOutline(float outerR, float innerR, int points) {
    beginShape();
    for (int i = 0; i < points * 2; i++) {
      float ang = PI * i / points;
      float r = (i % 2 == 0) ? outerR : innerR;
      float x = cos(ang) * r;
      float y = sin(ang) * r;
      vertex(x, y);
    }
    endShape(CLOSE);
  }
  
  class Particula {
    float angulo;
    float velocidad;
    float distancia;
    
    Particula(int index) {
      angulo = TWO_PI / 8 * index;
      velocidad = random(0.02, 0.04);
      distancia = radio * 1.5f;
    }
    
    void actualizar() {
      angulo += velocidad;
    }
    
    void dibujar(float escala, float tw) {
      pushMatrix();
      rotate(angulo);
      translate(distancia * escala, 0);
      
      noStroke();
      fill(red(rimColor), green(rimColor), blue(rimColor), 200 * tw);
      ellipse(0, 0, 8, 8);
      
      fill(255, 255, 255, 250 * tw);
      ellipse(0, 0, 5, 5);
      
      popMatrix();
    }
  }
}
