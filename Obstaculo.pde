class Obstaculo {
  PVector pos;
  float radio;

  Obstaculo(float x, float y, float r) {
    pos = new PVector(x, y);
    radio = r;
  }

  void dibujar() {
    noStroke();
    fill(255, 50, 50);
    ellipse(pos.x, pos.y, radio * 2, radio * 2);
  }
}
