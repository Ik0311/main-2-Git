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
  // Movimiento lateral fixed
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

   // Colisión con el suelo (daño si cae demasiado)
  if (py > height - 20f) {
    if (!invulnerable) {
      vida--;
      invulnerable = true;
      ultimoHit = millis();
    }
  py = height - 50f; // lo reposiciona
  vy = 0f;
  enSuelo = true;
} else {
  enSuelo = false;
}

// Desactivar invulnerabilidad tras un tiempo
if (invulnerable && millis() - ultimoHit > tiempoInvul) {
  invulnerable = false;
}

  
// Colisión con plataformas
boolean tocandoPlataforma = false;
for (Plataforma p : plataformas) {
  if (px > p.x && px < p.x + p.w && py + 15 > p.y && py + 15 < p.y + p.h) {
    py = p.y - 15;
    vy = 0;
    enSuelo = true;
    tocandoPlataforma = true;
  }
}
if (!tocandoPlataforma && py < height - 50f) {
  enSuelo = false;
}


  // Salto con impulso diagonal natural
  if (saltar && enSuelo) {
    vy = -10f;
    if (movIzq && !movDer) vx = -velMax * 0.7f;
    if (movDer && !movIzq) vx = velMax * 0.7f;
  }
}
