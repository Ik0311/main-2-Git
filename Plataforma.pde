class Plataforma {
  float x, y, w, h;

  Plataforma(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void dibujar() {
    fill(100, 150, 255);
    noStroke();
    rect(x, y, w, h);
  }
}
