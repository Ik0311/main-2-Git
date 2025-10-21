void dibujarJugador() {
  fill(150, 255, 180);
  ellipse(px, py, 30f, 30f);
}

void dibujarSuelo() {
  fill(60, 50, 80);
  rect(camX - 100f, height - 40f, width + 200f, 50f);
}
