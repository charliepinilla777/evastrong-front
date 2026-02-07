# 🎨 Guía para Crear Feature Graphic - Eva Strong

## 📐 Especificaciones Técnicas
- **Tamaño**: 1024 x 500 px
- **Formato**: JPG o PNG (24 bits, sin transparencia)
- **Uso**: Banner principal en Google Play Store

---

## 🎨 Paleta de Colores Eva Strong

### Colores Principales
- **Rosa Vibrante**: `#FF69B4` (Hot Pink)
- **Morado Wellness**: `#800080` (Purple)
- **Rojo Cósmico**: `#D71E49` (Accent)
- **Negro Suave**: `#323335` (Texto)
- **Naranja Motivación**: `#FFA500` (Energía)

### Gradientes Recomendados
```
Gradiente 1 (Principal): #FF69B4 → #800080
Gradiente 2 (Energético): #D71E49 → #FFA500
Gradiente 3 (Profundo): #800080 → #323335
```

---

## 🤖 Opción 1: Generar con IA (DALL-E, Midjourney, Leonardo.ai)

### Prompt en Español
```
Crea un banner horizontal de 1024x500 píxeles para una aplicación de fitness femenino llamada "Eva Strong". Estilo moderno y motivacional.

Elementos:
- Mujer atlética en pose de fuerza (sentadilla, plancha o levantamiento)
- Fondo con gradiente vibrante de rosa (#FF69B4) a morado (#800080)
- Logo/texto "EVA STRONG" en tipografía bold moderna, color blanco
- Subtítulo "Tu Entrenamiento Personalizado" en texto más pequeño
- Elementos decorativos: líneas dinámicas, partículas de energía, efecto de movimiento
- Iluminación dramática con tonos rosa y morado
- Composición: mujer a la izquierda/centro, texto a la derecha
- Estilo: fotorealista mezclado con elementos gráficos modernos
- Sin transparencia, fondo sólido con gradiente
```

### Prompt en Inglés (para DALL-E/Midjourney)
```
Create a horizontal banner 1024x500px for a women's fitness app called "Eva Strong". Modern motivational style.

Elements:
- Athletic woman in strength pose (squat, plank, or lifting weights)
- Vibrant gradient background from hot pink (#FF69B4) to purple (#800080)
- "EVA STRONG" logo/text in bold modern typography, white color
- Subtitle "Your Personal Training" in smaller text
- Dynamic decorative elements: energy lines, particles, motion effect
- Dramatic lighting with pink and purple tones
- Composition: woman on left/center, text on right
- Style: photorealistic mixed with modern graphic elements
- No transparency, solid gradient background
- Professional, empowering, energetic vibe
```

---

## 🎨 Opción 2: Diseñar con Canva (Gratis)

### Paso a paso:
1. Ve a: https://www.canva.com
2. Crea diseño personalizado: **1024 x 500 px**
3. Busca plantillas: "App Banner", "Fitness Banner", "Play Store Feature Graphic"
4. Personaliza con:
   - **Fondo**: Gradiente rosa (#FF69B4) a morado (#800080)
   - **Imagen**: Busca "fitness woman silhouette" o "athlete training" en Canva
   - **Texto**: 
     - Título: "EVA STRONG" (fuente: Montserrat Bold o Bebas Neue, tamaño 80-100pt)
     - Subtítulo: "Tu Entrenamiento Personalizado" (fuente: Montserrat Regular, 30-40pt)
   - **Efectos**: Aplica sombras al texto, overlay oscuro a la imagen (30% opacidad)
5. Descarga como **JPG** (calidad alta)

---

## 💻 Opción 3: Template HTML/CSS (Rápido)

Abre este HTML en tu navegador y haz **screenshot** (1024x500):

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <style>
    body { margin: 0; padding: 0; }
    .banner {
      width: 1024px;
      height: 500px;
      background: linear-gradient(135deg, #FF69B4 0%, #800080 100%);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 60px;
      box-sizing: border-box;
      font-family: 'Arial Black', sans-serif;
      position: relative;
      overflow: hidden;
    }
    .banner::before {
      content: '';
      position: absolute;
      width: 600px;
      height: 600px;
      background: radial-gradient(circle, rgba(255,105,180,0.3) 0%, transparent 70%);
      top: -100px;
      left: -100px;
      animation: pulse 3s infinite;
    }
    @keyframes pulse {
      0%, 100% { transform: scale(1); opacity: 0.5; }
      50% { transform: scale(1.1); opacity: 0.8; }
    }
    .content {
      z-index: 2;
      color: white;
      text-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }
    .title {
      font-size: 90px;
      font-weight: 900;
      margin: 0;
      letter-spacing: 2px;
      text-transform: uppercase;
      background: linear-gradient(180deg, #FFFFFF 0%, #FFD1E8 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      filter: drop-shadow(0 2px 8px rgba(0,0,0,0.3));
    }
    .subtitle {
      font-size: 32px;
      font-weight: normal;
      margin: 10px 0 0 0;
      opacity: 0.95;
    }
    .icon {
      font-size: 200px;
      opacity: 0.15;
      position: absolute;
      right: 80px;
      top: 50%;
      transform: translateY(-50%);
    }
    .accent {
      color: #FFA500;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="banner">
    <div class="icon">💪</div>
    <div class="content">
      <h1 class="title">EVA STRONG</h1>
      <p class="subtitle">Tu Entrenamiento <span class="accent">Personalizado</span></p>
    </div>
  </div>
</body>
</html>
```

**Cómo hacer el screenshot:**
1. Copia el código en un archivo `feature_graphic.html`
2. Ábrelo en Chrome/Edge
3. Presiona `F12` → Consola
4. Pega y ejecuta:
   ```javascript
   document.body.style.zoom = 1;
   ```
5. Captura pantalla con Windows Snipping Tool (ajustada a 1024x500)
6. O usa extensión "GoFullPage" para screenshot exacto

---

## 🖼️ Opción 4: Herramientas Online Gratuitas

### Leonardo.ai (Recomendado - Gratis con límite)
1. Ve a: https://leonardo.ai
2. Crea cuenta gratuita (150 créditos diarios)
3. Usa el prompt en inglés arriba
4. Genera 4 variaciones
5. Descarga la mejor y redimensiona a 1024x500 en Canva

### Adobe Firefly (Gratis con cuenta Adobe)
1. Ve a: https://firefly.adobe.com
2. Usa "Text to Image"
3. Prompt en inglés + aspect ratio "Custom: 1024x500"
4. Genera y descarga

### Playground AI (Gratis)
1. Ve a: https://playgroundai.com
2. Mismo prompt en inglés
3. Ajusta dimensiones a 1024x500

---

## ✅ Checklist Final

Antes de subir a Play Store, verifica:
- [ ] Tamaño exacto: **1024 x 500 px**
- [ ] Formato: **JPG o PNG 24 bits**
- [ ] Sin transparencia (fondo sólido)
- [ ] Texto legible (contraste suficiente)
- [ ] Logo/nombre "Eva Strong" visible
- [ ] Colores de marca (rosa/morado) presentes
- [ ] Imagen inspiradora/motivacional
- [ ] Calidad profesional (sin pixelación)
- [ ] Peso del archivo < 1 MB

---

## 📝 Textos Alternativos para el Banner

Si quieres variar el texto:
- "EVA STRONG - Transforma Tu Cuerpo"
- "EVA STRONG - Fitness Femenino Personalizado"
- "EVA STRONG - Tu Poder Interior"
- "EVA STRONG - Entrena. Crece. Conquista"

---

## 🎯 Ejemplos de Composición

### Layout 1 (Recomendado):
```
[Imagen mujer fitness - izquierda 40%] [Texto EVA STRONG - derecha 60%]
Fondo: Gradiente rosa → morado
```

### Layout 2 (Centrado):
```
[Fondo con mujer fitness en toda la imagen con overlay oscuro]
[Texto EVA STRONG centrado, grande, con sombra]
```

### Layout 3 (Dinámico):
```
[Mujer fitness en ángulo diagonal] [Texto EVA STRONG + elementos gráficos]
Fondo: Gradiente + formas abstractas
```

---

¿Necesitas ayuda con alguna de estas opciones? Puedo generar más variaciones del código HTML o ajustar el prompt.
