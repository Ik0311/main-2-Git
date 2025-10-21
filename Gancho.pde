void manejarGancho() {
  if (mousePressed && !ganchoAct) {
    PVector target = new PVector(mouseX + camX, mouseY);
    float minDist = 99999f;

    // Buscar el asteroide más cercano al click
    for (PVector a : ast) {
      float d = dist(a.x, a.y, target.x, target.y);
      if (d < 50f && d < minDist) {
        hook = a.copy();
        minDist = d;
      }
    }

    if (minDist < 99999f) {
      ganchoAct = true;
      lenCuerda = dist(px, py, hook.x, hook.y);
    }
  } else if (!mousePressed) {
    ganchoAct = false;
  }

  if (ganchoAct) {
    stroke(180, 200, 255);
    line(px, py, hook.x, hook.y);
    noStroke();

    // Vector desde el gancho hacia el jugador
    PVector dir = new PVector(px - hook.x, py - hook.y);
    float distAct = dir.mag();

    // Si supera el largo de la cuerda, aplicar tensión
    if (distAct > lenCuerda) {
      dir.normalize();
      float exc = distAct - lenCuerda;

      // Reposición suave hacia el radio permitido
      px -= dir.x * exc * tens;
      py -= dir.y * exc * tens;

      // Calcular velocidad tangencial (efecto péndulo)
      PVector vel = new PVector(vx, vy);
      PVector tang = new PVector(-dir.y, dir.x); // tangente a la cuerda
      float tangVel = vel.dot(tang);

      vx = tang.x * tangVel * 0.98f;  // amortiguación ligera
      vy = tang.y * tangVel * 0.98f;
    } else {
      // Si está dentro del radio, la gravedad sigue actuando
      vy += grav * 0.3f;
    }
  }
}
