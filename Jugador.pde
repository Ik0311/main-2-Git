// === ESTADO DE TECLAS ===
boolean movIzq = false;
boolean movDer = false;
boolean saltar = false;

void keyPressed() {
  if (key == 'a' || key == 'A') movIzq = true;
  if (key == 'd' || key == 'D') movDer = true;
  if (key == 'w' || key == 'W') saltar = true;
   if (key == 'r' || key == 'R') {
    reiniciarNivel();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A') movIzq = false;
  if (key == 'd' || key == 'D') movDer = false;
  if (key == 'w' || key == 'W') saltar = false;
}

void moverJugador() {
  // Movimiento lateral inmediato, sin conflicto entre A y D
  if (movIzq && !movDer) vx -= acel;
  if (movDer && !movIzq) vx += acel;
  if (!movIzq && !movDer && enSuelo) vx *= fric;

  // Limitar velocidad
  vx = constrain(vx, -velMax, velMax);

  // Aplicar gravedad solo si no estás enganchado
  if (!ganchoAct) vy += grav;

  // Actualizar posición
  px += vx;
  py += vy;

  // Colisión con el suelo
  if (py > height - 50f) {
    py = height - 50f;
    vy = 0f;
    enSuelo = true;
  } else {
    enSuelo = false;
  }

  // Salto con impulso diagonal natural
  if (saltar && enSuelo) {
    vy = -10f;
    if (movIzq && !movDer) vx = -velMax * 0.7f;
    if (movDer && !movIzq) vx = velMax * 0.7f;
  }
}
