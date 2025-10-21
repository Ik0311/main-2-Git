class Gema {
  PVector pos;

  Gema(float x, float y) {
    pos = new PVector(x, y);
  }

  void dibujar() {
    noStroke();
    fill(180, 80, 255);
    ellipse(pos.x, pos.y, 20, 20);
  }
}
