// =========================================
// TAB MENU 
// =========================================

// Estados del menú
boolean enPantallaCreditos = false;
boolean enPantallaTutorial = false;

// Font personalizado
PFont fuenteMenu;

// Sistema de animación de botones
class BotonAnimado {
  String nombre;
  float x, y, w, h;
  float escala = 1.0;
  float brillo = 200;
  boolean mouseEncima = false;
  color colorBoton;
  
  BotonAnimado(String n, float px, float py, float ancho, float alto, color col) {
    nombre = n;
    x = px;
    y = py;
    w = ancho;
    h = alto;
    colorBoton = col;
  }
  
  void actualizar() {
    mouseEncima = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
    
    if (mouseEncima) {
      escala = lerp(escala, 1.1, 0.2);
      brillo = lerp(brillo, 255, 0.2);
    } else {
      escala = lerp(escala, 1.0, 0.2);
      brillo = lerp(brillo, 200, 0.2);
    }
  }
  
  void dibujar() {
    pushMatrix();
    translate(x + w/2, y + h/2);
    scale(escala);
    
    // Glow exterior
    if (mouseEncima) {
      noFill();
      strokeWeight(3);
      stroke(red(colorBoton), green(colorBoton), blue(colorBoton), 100);
      rect(-w/2 - 5, -h/2 - 5, w + 10, h + 10, 10);
      
      strokeWeight(2);
      stroke(red(colorBoton), green(colorBoton), blue(colorBoton), 150);
      rect(-w/2 - 3, -h/2 - 3, w + 6, h + 6, 8);
      
      // Partículas flotantes
      for (int i = 0; i < 5; i++) {
        float angulo = (TWO_PI / 5) * i + millis() * 0.003;
        float dist = 35 + sin(millis() * 0.005 + i) * 5;
        float px = cos(angulo) * dist;
        float py = sin(angulo) * dist;
        
        noStroke();
        fill(255, 200, 255, 150);
        ellipse(px, py, 4, 4);
      }
    }
    
    // Fondo del botón
    noStroke();
    fill(red(colorBoton), green(colorBoton), blue(colorBoton), 200);
    rect(-w/2, -h/2, w, h, 8);
    
    // Borde brillante
    noFill();
    strokeWeight(2);
    stroke(255, brillo);
    rect(-w/2, -h/2, w, h, 8);
    
    // Texto del botón
    fill(255);
    textFont(fuenteMenu);
    textSize(28);
    textAlign(CENTER, CENTER);
    text(nombre, 0, 2);
    
    popMatrix();
  }
  
  boolean estaSiendoClicado() {
    return mouseEncima && mousePressed;
  }
}

ArrayList<BotonAnimado> botonesAnimados;

// Slider de gravedad manual
class SliderGravedad {
  float x, y, w, h;
  float valor = 0.5;
  boolean arrastrando = false;
  
  SliderGravedad(float px, float py, float ancho, float alto) {
    x = px;
    y = py;
    w = ancho;
    h = alto;
  }
  
  void actualizar() {
    if (mousePressed && mouseX > x && mouseX < x + w && mouseY > y - 10 && mouseY < y + h + 10) {
      arrastrando = true;
    }
    
    if (!mousePressed) {
      arrastrando = false;
    }
    
    if (arrastrando) {
      valor = constrain(map(mouseX, x, x + w, 0.1, 1.0), 0.1, 1.0);
      grav = valor;
    }
  }
  
  void dibujar() {
    pushStyle();
    
    // Barra de fondo
    noStroke();
    fill(60, 60, 80);
    rect(x, y, w, h, h/2);
    
    // Barra de progreso
    fill(100, 100, 150);
    float progreso = map(valor, 0.1, 1.0, 0, w);
    rect(x, y, progreso, h, h/2);
    
    // Perilla
    float perillaPosX = map(valor, 0.1, 1.0, x, x + w);
    fill(120, 120, 200);
    ellipse(perillaPosX, y + h/2, h * 2, h * 2);
    
    fill(180, 180, 255);
    ellipse(perillaPosX, y + h/2, h * 1.5, h * 1.5);
    
    popStyle();
  }
}

SliderGravedad sliderGrav;

// Partículas de fondo
ArrayList<ParticulaGalaxia> particulasGalaxia;

class ParticulaGalaxia {
  float x, y, vx, vy, tam, brillo, velocidadBrillo;
  
  ParticulaGalaxia() {
    x = random(width);
    y = random(height);
    vx = random(-0.3, 0.3);
    vy = random(-0.3, 0.3);
    tam = random(1, 4);
    brillo = random(100, 255);
    velocidadBrillo = random(0.5, 2);
  }
  
  void actualizar() {
    x += vx;
    y += vy;
    
    if (x < 0) x = width;
    if (x > width) x = 0;
    if (y < 0) y = height;
    if (y > height) y = 0;
    
    brillo += velocidadBrillo;
    if (brillo > 255 || brillo < 100) velocidadBrillo *= -1;
  }
  
  void display() {
    noStroke();
    fill(brillo, brillo * 0.8, brillo);
    ellipse(x, y, tam, tam);
  }
}

void configurarBotonesMenu() {
  // Inicializar partículas de galaxia
  if (particulasGalaxia == null) {
    particulasGalaxia = new ArrayList<ParticulaGalaxia>();
    for (int i = 0; i < 150; i++) {
      particulasGalaxia.add(new ParticulaGalaxia());
    }
  }
  
  // Cargar fuente personalizada
  if (fuenteMenu == null) {
    try {
      fuenteMenu = createFont("antistar.ttf", 28);
    } catch (Exception e) {
      println("Fuente antistar.ttf no encontrada, usando Arial");
      fuenteMenu = createFont("Arial", 28);
    }
  }
  
  // Inicializar botones animados
  botonesAnimados = new ArrayList<BotonAnimado>();
  botonesAnimados.add(new BotonAnimado("JUGAR", width/2 - 100, 515, 200, 50, color(100, 50, 200)));
  botonesAnimados.add(new BotonAnimado("TUTORIAL", width/2 - 100, 595, 200, 50, color(50, 100, 200)));
  botonesAnimados.add(new BotonAnimado("CREDITOS", width/2 - 100, 675, 200, 50, color(200, 100, 50)));
  botonesAnimados.add(new BotonAnimado("SALIR", width/2 - 100, 755, 200, 50, color(200, 50, 50)));
  
  // Inicializar slider
  sliderGrav = new SliderGravedad(50, 810, 150, 15);
  
  // Limpiar todos los controles de ControlP5
  if (ui != null) {
    for (ControllerInterface<?> c : ui.getAll()) {
      ui.remove(c.getName());
    }
  }
}

void mostrarMenuPrincipal() {
  // Fondo gradiente
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    int c = lerpColor(color(10, 0, 30), color(25, 0, 50), inter);
    stroke(c);
    line(0, i, width, i);
  }
  
  // Partículas de galaxia
  if (particulasGalaxia != null) {
    for (ParticulaGalaxia p : particulasGalaxia) {
      p.actualizar();
      p.display();
    }
  }
  
  // Nebulosas de fondo
  dibujarNebulosasFondo();
  
  // Ovnis flotantes
  dibujarOvnisMenu();
  
  // Título
  pushStyle();
  textFont(fuenteMenu);
  textAlign(CENTER);
  
  float tiempo = millis() * 0.001;
  
  if (imgTitulo != null) {
    imageMode(CENTER);
    float escala = 0.5 + sin(tiempo) * 0.02;
    image(imgTitulo, width/2, 250, imgTitulo.width * escala, imgTitulo.height * escala);
  } else {
    textSize(82);
    fill(100, 50, 200, 80);
    text("SPACE RUNNER", width/2 + 4, 250 + 4);
    
    textSize(80);
    fill(255, 215, 0);
    text("SPACE RUNNER", width/2, 250);
  }
  popStyle();
  
  // Actualizar y dibujar botones
  for (BotonAnimado btn : botonesAnimados) {
    btn.actualizar();
    btn.dibujar();
  }
  
  // Etiqueta y slider de gravedad
  pushStyle();
  fill(255);
  textAlign(LEFT);
  textSize(18);
  text("Gravedad:", 50, 805);
  
  sliderGrav.actualizar();
  sliderGrav.dibujar();
  
  // Mostrar valor de gravedad
  textSize(14);
  fill(200, 200, 255);
  text(nf(grav, 1, 2), 210, 820);
  popStyle();
}

void manejarClicsMenu() {
  if (mousePressed && frameCount % 10 == 0) { 
    for (int i = 0; i < botonesAnimados.size(); i++) {
      BotonAnimado btn = botonesAnimados.get(i);
      
      if (btn.estaSiendoClicado()) {
        switch(i) {
          case 0: // JUGAR
            println("Iniciando juego...");
            enMenu = false;
            enPantallaCreditos = false;
            enPantallaTutorial = false;
            iniciarJuego();
            break;
          case 1: // TUTORIAL
            println("Abriendo tutorial...");
            enPantallaTutorial = true;
            enPantallaCreditos = false;
            break;
          case 2: // CREDITOS
            println("Abriendo créditos...");
            enPantallaCreditos = true;
            enPantallaTutorial = false;
            break;
          case 3: // SALIR
            println("Saliendo del juego...");
            exit();
            break;
        }
        break;
      }
    }
  }
}

void dibujarNebulosasFondo() {
  pushStyle();
  noStroke();
  for (int i = 0; i < 3; i++) {
    float x = width * (0.2 + i * 0.3);
    float y = height * 0.4 + sin(millis() * 0.0005 + i) * 50;
    float tam = 300 + sin(millis() * 0.0003 + i * 2) * 50;
    
    fill(100, 50, 150, 30);
    ellipse(x, y, tam, tam * 0.8);
    fill(150, 100, 200, 20);
    ellipse(x, y, tam * 0.7, tam * 0.5);
  }
  popStyle();
}

void dibujarOvnisMenu() {
  pushStyle();
  float tiempo = millis() * 0.001;
  
  float x1 = width * 0.2 + sin(tiempo * 0.5) * 50;
  float y1 = 350 + cos(tiempo * 0.7) * 30;
  dibujarOvni(x1, y1, 40, color(100, 200, 255));
  
  float x2 = width * 0.8 + cos(tiempo * 0.6) * 60;
  float y2 = 450 + sin(tiempo * 0.8) * 40;
  dibujarOvni(x2, y2, 35, color(255, 150, 200));
  
  popStyle();
}

void dibujarOvni(float x, float y, float tam, color col) {
  pushMatrix();
  translate(x, y);
  
  float tiempo = millis() * 0.001;
  rotate(sin(tiempo * 2) * 0.1);
  
  noStroke();
  fill(col, 180);
  ellipse(0, -tam * 0.3, tam * 0.8, tam * 0.6);
  
  fill(col, 220);
  ellipse(0, -tam * 0.3, tam * 0.5, tam * 0.4);
  
  fill(col);
  ellipse(0, 0, tam * 1.5, tam * 0.5);
  
  fill(red(col) + 30, green(col) + 30, blue(col) + 30);
  ellipse(0, 0, tam * 1.2, tam * 0.4);
  
  for (int i = 0; i < 5; i++) {
    float angulo = (TWO_PI / 5) * i;
    float lx = cos(angulo + tiempo * 2) * tam * 0.5;
    float ly = tam * 0.2;
    
    fill(255, 255, 100, 200);
    ellipse(lx, ly, 6, 6);
    
    noStroke();
    fill(255, 255, 150, 50);
    beginShape();
    vertex(lx - 3, ly);
    vertex(lx + 3, ly);
    vertex(lx + 8, ly + 60);
    vertex(lx - 8, ly + 60);
    endShape(CLOSE);
  }
  
  popMatrix();
}

// ✅ PANTALLA DE CRÉDITOS MEJORADA
void mostrarPantallaCreditos() {
  background(10, 20, 35);
  
  dibujarFondoGalacticoCreditos();
  
  pushStyle();
  textFont(fuenteMenu);
  
  fill(255, 215, 0, 220);
  textAlign(CENTER);
  textSize(70);
  text("CRÉDITOS", width/2 + 3, 150 + 3);
  
  fill(255, 215, 0);
  textSize(68);
  text("CRÉDITOS", width/2, 150);
  
  fill(200, 220, 255);
  textSize(32);
  text("Desarrollado por:", width/2, 250);
  
  fill(255);
  textSize(28);
  text("Maria Fernanda Peña", width/2, 320);
  text("Ivan Eduardo Rivas Guzman", width/2, 360);

  textSize(24);
  fill(180, 200, 240);
  text("Motor de juego: Processing", width/2, 420);
  text("Librería UI: ControlP5", width/2, 460);
  text("Año: 2025", width/2, 500);
  
  fill(200, 220, 255);
  textSize(28);
  text("Música de fondo:", width/2, 580);
  
  fill(255);
  textSize(20);
  text("Meta Knight's Revenge", width/2, 620);
  text("Super Smash Bros Ultimate / Nintendo", width/2, 650);
  
  float brillo = 200 + sin(millis() * 0.003) * 55;
  fill(255, 180, 100, brillo);
  textSize(24);
  text("Presiona ESC para volver al menú", width/2, height - 80);
  
  popStyle();
  
  dibujarOvniCreditos();
}

void dibujarFondoGalacticoCreditos() {
  pushStyle();
  float tiempo = millis() * 0.0002;
  
  for (int i = 0; i < 3; i++) {
    float offsetX = sin(tiempo + i) * 100;
    float offsetY = cos(tiempo * 0.7 + i) * 50;
    
    noStroke();
    fill(150, 50, 200, 15);
    ellipse(width * 0.3 + offsetX, height * 0.3 + offsetY, 400 + i * 100, 300 + i * 80);
  }
  
  for (int i = 0; i < 50; i++) {
    float x = random(width);
    float y = random(height);
    float tam = random(2, 6);
    float brillo = 150 + sin(millis() * 0.001 + i) * 105;
    
    noStroke();
    fill(255, brillo);
    ellipse(x, y, tam, tam);
  }
  popStyle();
}

void dibujarOvniCreditos() {
  float tiempo = millis() * 0.001;
  float x = width/2 + sin(tiempo * 0.5) * 200;
  float y = 150 + sin(tiempo * 0.8) * 50;
  
  dibujarOvni(x, y, 50, color(255, 200, 100));
}

// ✅ PANTALLA DE TUTORIAL MEJORADA
void mostrarPantallaTutorial() {
  background(10, 20, 35);
  
  dibujarFondoGalacticoCreditos();
  
  pushStyle();
  textFont(fuenteMenu);
  
  fill(100, 200, 255, 220);
  textAlign(CENTER);
  textSize(70);
  text("TUTORIAL", width/2 + 3, 120 + 3);
  
  fill(100, 200, 255);
  textSize(68);
  text("TUTORIAL", width/2, 120);
  
  fill(255, 215, 0);
  textSize(36);
  text("CONTROLES", width/2, 200);
  
  fill(255);
  textAlign(LEFT);
  textSize(24);
  
  float xBase = width/2 - 300;
  float yBase = 260;
  
  fill(150, 200, 255);
  textSize(28);
  text("MOVIMIENTO:", xBase, yBase);
  fill(255);
  textSize(22);
  text("• A / ← : Mover a la izquierda", xBase + 20, yBase + 40);
  text("• D / → : Mover a la derecha", xBase + 20, yBase + 75);
  text("• W / ↑ : Saltar", xBase + 20, yBase + 110);
  
  yBase += 180;
  fill(255, 180, 100);
  textSize(28);
  text("GANCHO:", xBase, yBase);
  fill(255);
  textSize(22);
  text("• ESPACIO: Lanzar/Soltar gancho", xBase + 20, yBase + 40);
  text("  Apunta con el mouse", xBase + 20, yBase + 75);
  
  yBase += 150;
  fill(100, 255, 150);
  textSize(28);
  text("OBJETIVO:", xBase, yBase);
  fill(255);
  textSize(22);
  text("• Recolecta estrellas!", xBase + 20, yBase + 40);
  text("• Evita los asteroides", xBase + 20, yBase + 75);
  text("• Llega al portal", xBase + 20, yBase + 110);
  text("• Derrota al jefe final!", xBase + 20, yBase + 145);
  
  float brillo = 200 + sin(millis() * 0.003) * 55;
  fill(255, 180, 100, brillo);
  textAlign(CENTER);
  textSize(24);
  text("Presiona ESC para volver al menú", width/2, height - 80);
  
  popStyle();
  
  dibujarIconosTutorial();
}

void dibujarIconosTutorial() {
  pushStyle();
  float tiempo = millis() * 0.001;
  
  float x = width - 150;
  float y = 200 + sin(tiempo * 2) * 10;
  
  pushMatrix();
  translate(x, y);
  rotate(tiempo);
  
  fill(100, 255, 200, 200);
  noStroke();
  beginShape();
  for (int i = 0; i < 6; i++) {
    float angulo = TWO_PI / 6 * i;
    float r = (i % 2 == 0) ? 25 : 15;
    vertex(cos(angulo) * r, sin(angulo) * r);
  }
  endShape(CLOSE);
  
  fill(150, 255, 220, 150);
  ellipse(0, 0, 20, 20);
  popMatrix();
  
  x = 150;
  y = 400 + cos(tiempo * 2) * 8;
  
  pushMatrix();
  translate(x, y);
  scale(3);
  
  fill(255, 100, 150);
  beginShape();
  vertex(0, 2);
  bezierVertex(-5, -3, -10, 0, 0, 10);
  vertex(0, 2);
  bezierVertex(5, -3, 10, 0, 0, 10);
  endShape(CLOSE);
  popMatrix();
  
  dibujarOvni(width - 200, 500, 30, color(200, 150, 255));
  
  popStyle();
}

void manejarTeclaEscMenu() {
  if (enPantallaCreditos || enPantallaTutorial) {
    enPantallaCreditos = false;
    enPantallaTutorial = false;
  }
}
