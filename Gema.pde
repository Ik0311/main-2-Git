// ============================================
// GEMA.PDE - Estrellas coleccionables (menos brillo, estilo sutil)
// ============================================

class Gema {
  PVector pos;
  float radio;          // radio de colisión/dibujo
  float rot;            // rotación actual
  float rotSpeed;       // velocidad de rotación
  float pulse;          // fase de pulso (escala)
  float pulseSpeed;     // velocidad del pulso
  color baseColor;      // color principal de la estrella
  color rimColor;       // color del borde / brillo sutil
  float twinklePhase;   // para parpadeo aleatorio (muy tenue)

  Gema(float x, float y) {
    pos = new PVector(x, y);
    radio = random(10, 16);                  // tamaño base algo más pequeño
    rot = random(TWO_PI);
    rotSpeed = random(-0.02, 0.02);
    pulse = random(TWO_PI);
    pulseSpeed = random(0.02, 0.06);
    twinklePhase = random(TWO_PI);

    // Paleta suave / apagada (menos saturada)
    int tipo = int(random(5));
    if (tipo == 0) {           // rosa suave
      baseColor = color(235, 185, 205);
      rimColor  = color(255, 220, 230, 90);
    } else if (tipo == 1) {    // azul suave
      baseColor = color(170, 205, 225);
      rimColor  = color(200, 225, 235, 90);
    } else if (tipo == 2) {    // verde menta tenue
      baseColor = color(170, 225, 195);
      rimColor  = color(200, 235, 215, 90);
    } else if (tipo == 3) {    // lavanda tenue
      baseColor = color(200, 180, 225);
      rimColor  = color(225, 205, 235, 90);
    } else {                   // amarillo muy suave
      baseColor = color(245, 225, 160);
      rimColor  = color(250, 235, 190, 90);
    }
  }

  void dibujar() {
    pushStyle();
    pushMatrix();
    translate(pos.x, pos.y);

    // animaciones muy sutiles
    rot += rotSpeed;
    pulse += pulseSpeed;
    float scalePulse = 1.0 + 0.06 * sin(pulse);        // pulso muy suave
    float tw = 0.8 + 0.2 * (0.5 + 0.5 * sin(twinklePhase + frameCount * 0.04f)); // parpadeo muy tenue
    twinklePhase += 0.02;

    rotate(rot);
    scale(scalePulse);

    noStroke();

    // Halo muy suave y pequeño (reduje tamaño y alpha)
    float haloScale = radio * 2.0f;
    fill(red(rimColor), green(rimColor), blue(rimColor), 40 * tw); // alpha muy bajo
    ellipse(0, 0, haloScale * 1.6f, haloScale * 1.6f);

    // Cuerpo principal de la estrella: estrella de 5 puntas, menos contraste
    drawStarShape(radio * 0.9f, radio * 0.45f, 5, baseColor, 220 * tw);

    // Núcleo tenue (no blanco brillante)
    fill(255, 255, 255, 110 * tw);
    ellipse(0, 0, radio * 0.6f, radio * 0.6f);

    // Destellos pequeños y sutiles (no líneas largas)
    pushMatrix();
    rotate(frameCount * 0.01f);
    stroke(255, 255, 255, 60 * tw);
    strokeWeight(1.0f);
    line(-radio * 1.1f, 0, -radio * 0.7f, 0);
    line(radio * 0.7f, 0, radio * 1.1f, 0);
    line(0, -radio * 0.9f, 0, -radio * 0.5f);
    line(0, radio * 0.5f, 0, radio * 0.9f);
    popMatrix();

    // Pequeño brillo en esquina (sutil)
    noStroke();
    fill(255, 255, 255, 80 * tw);
    ellipse(-radio * 0.25f, -radio * 0.35f, radio * 0.18f, radio * 0.18f);

    popMatrix();
    popStyle();
  }

  // Dibujar una estrella (n puntas) con color dado y alpha para suavizar
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
}
