void generarAsteroidesIniciales() {
  for (int i = 0; i < 8; i++) {
    ast.add(new PVector(i * astDist + 400f, random(150f, 350f)));
    ultAstX = ast.get(ast.size() - 1).x;
  }
}

void generarAsteroidesProcedural() {
  if (px + width > ultAstX) {
    for (int i = 0; i < 4; i++) {
      ast.add(new PVector(ultAstX + astDist, random(150f, 350f)));
      ultAstX += astDist;
    }
  }
}

void dibujarAsteroides() {
  fill(90, 180, 255);
  noStroke();
  for (PVector a : ast) {
    ellipse(a.x, a.y, 40f, 40f);
  }
}
