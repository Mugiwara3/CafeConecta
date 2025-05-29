// Archivo: lib/ui/screens/auth/cursos/modulo_model.dart

class QuizPregunta {
  final String pregunta;
  final List<String> opciones;
  final int respuestaCorrecta;
  final bool esVerdaderoFalso;

  QuizPregunta({
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    this.esVerdaderoFalso = false,
  });
}

class Diapositiva {
  final String titulo;
  final String contenido;
  final String? imagen;
  final String? videoUrl;

  Diapositiva({
    required this.titulo,
    required this.contenido,
    this.imagen,
    this.videoUrl,
  });
}

class Modulo {
  final int id;
  final String titulo;
  final String descripcion;
  final String imagenPortada;
  final bool bloqueado;
  final List<Diapositiva> diapositivas;
  final List<QuizPregunta> quiz;

  Modulo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagenPortada,
    required this.diapositivas,
    required this.quiz,
    this.bloqueado = false,
  });
}

final List<Modulo> modulos = [
  // Módulo 1: Introducción al cultivo (completo)
  Modulo(
    id: 1,
    titulo: "Introducción al cultivo del café",
    descripcion:
        "Fundamentos históricos, variedades y condiciones para el cultivo del café",
    imagenPortada: "lib/ui/screens/assets/images/modulo1.png",
    bloqueado: false,
    diapositivas: [
      Diapositiva(
        titulo: "Historia del café",
        contenido:
            "El café tiene una historia fascinante que comienza en Etiopía, alrededor del siglo IX. Según la leyenda, un pastor llamado Kaldi notó que sus cabras se volvían más activas tras comer los frutos rojos de un arbusto. Al probarlos, Kaldi experimentó una gran energía, y un monje cercano comenzó a preparar infusiones con ellos para mantenerse despierto durante la oración.\n\n"
            "Desde Etiopía, el café se extendió a Arabia, donde en el siglo XV ya se cultivaba en Yemen. La ciudad portuaria de Moca se volvió famosa por exportarlo. Allí surgieron las primeras casas de café, llamadas qahveh khaneh, que se convirtieron en espacios de reunión social y cultural.\n\n"
            "A mediados del siglo XVII, el café llegó a Europa a través de Venecia. Aunque al principio fue visto con desconfianza, el Papa Clemente VIII lo aprobó, y rápidamente se popularizó en ciudades como Londres, París y Viena.\n\n"
            "En el siglo XVIII, las potencias europeas llevaron el café a sus colonias en América, donde encontró un clima ideal para su cultivo. Brasil, Colombia, Centroamérica y el Caribe se convirtieron en grandes productores. Desde entonces, el café ha sido una bebida esencial para millones de personas y un motor económico en muchas regiones.\n\n"
            "Hoy en día, el café es una de las bebidas más consumidas en el mundo, con una rica cultura que abarca desde tradiciones ancestrales hasta métodos modernos como el espresso y el café de especialidad.",
        imagen: "lib/ui/screens/assets/images/modulo1/historiaCafe.png",
      ),
      Diapositiva(
        titulo: "Importancia del café para la economía de Colombia",
        contenido:
            "El café es un pilar fundamental de la economía colombiana, tanto por su impacto en la producción agrícola como por su papel en las exportaciones y el empleo rural. En 2024, Colombia alcanzó una producción de aproximadamente 13,99 millones de sacos de 60 kilos, lo que representó un incremento del 23% respecto al año anterior.\n\n"
            "Este crecimiento se reflejó en las exportaciones, que aumentaron un 16,5%, pasando de 10,58 a 12,33 millones de sacos, generando ingresos estimados en \$16 billones de pesos. El café constituye alrededor del 22% del PIB agrícola del país y es una fuente vital de ingresos para más de 540.000 familias caficultoras.\n\n"
            "Además de su relevancia económica, el café colombiano es un símbolo cultural y una marca país reconocida globalmente. La imagen de Juan Valdez, creada en 1959, ha sido clave en la promoción del café colombiano en el mundo. Aunque actualmente no cuenta con un actor que lo represente tras el fallecimiento de Carlos Castañeda en 2024, la marca sigue siendo un emblema de la calidad y tradición cafetera del país.",
        imagen: "lib/ui/screens/assets/images/modulo1/importancia.png",
      ),
      Diapositiva(
        titulo: "Variedades de café en Colombia",
        contenido:
            "Variedades tradicionales:\n"
            "• Typica: Es la variedad más antigua y tradicional en Colombia. Produce una bebida suave y aromática, pero es susceptible a enfermedades como la roya.\n"
            "• Bourbon: Variedad antigua y de alta calidad en taza, con notas dulces y acidez equilibrada. Al igual que Typica, es vulnerable a plagas y enfermedades.\n\n"
            "Variedades mejoradas (resistentes a enfermedades):\n"
            "• Castillo: Desarrollada por Cenicafé para ser resistente a la roya y otras enfermedades. Mantiene excelente calidad en taza. Es la variedad más sembrada en Colombia.\n"
            "• Colombia: Primera variedad híbrida lanzada por Cenicafé en los años 80. Resistente a la roya, de buena productividad y calidad sensorial aceptable.\n"
            "• Cenicafé 1: Nueva variedad resistente a la roya, con alta productividad y buena calidad en taza, enfocada en cafés de especialidad.\n"
            "• Tabi: Combina Typica, Bourbon y Timor. Resistente a la roya y mantiene características sensoriales similares a las variedades tradicionales.\n\n"
            "Otras variedades especiales:\n"
            "• Geisha (o Gesha): De origen etíope, famosa por su perfil sensorial complejo, con notas florales, frutales y de jazmín.\n"
            "• Maragogipe: Conocida como \"el café de grano grande\" o \"grano elefante\". Produce una bebida suave y aromática.\n"
            "• Caturra: Deriva de Bourbon, es de porte bajo, fácil de manejar y ofrece buena calidad en taza.\n"
            "• Pacamara: Variedad híbrida originada de Pacas y Maragogipe. Destaca por sus notas frutales y su grano grande.",
        imagen: "lib/ui/screens/assets/images/modulo1/variedades.png",
      ),
      Diapositiva(
        titulo: "Condiciones climáticas ideales para el cultivo",
        contenido:
            "1. Altitud\n"
            "• Ideal: 1,200-1,800 msnm para café arábica\n"
            "• A mayor altitud, mejor calidad en taza\n"
            "• Por debajo de 1,000 msnm se cultivan variedades robusta\n\n"
            "2. Temperatura\n"
            "• Promedio entre 18°C y 24°C\n"
            "• Sensible a temperaturas extremas (>28°C o <15°C)\n\n"
            "3. Lluvia\n"
            "• Precipitaciones anuales entre 1,500-2,500 mm bien distribuidas\n"
            "• Periodos secos moderados importantes para floración\n\n"
            "4. Suelo\n"
            "• Ricos en materia orgánica, bien drenados\n"
            "• pH entre 5.5 y 6.5 (ligeramente ácidos)\n"
            "• Preferiblemente suelos volcánicos o andisoles\n\n"
            "5. Sombra\n"
            "• Sombra parcial ayuda a controlar temperatura y humedad\n"
            "• Sistemas agroforestales benefician la biodiversidad\n\n"
            "6. Topografía\n"
            "• Pendientes moderadas (10-30%) facilitan drenaje\n"
            "• Evitar zonas con riesgo de inundación o erosión severa",
        imagen:
            "lib/ui/screens/assets/images/modulo1/condiciones_climaticas.png",
      ),
      Diapositiva(
        titulo: "Selección de semillas y preparación de chapolas",
        contenido:
            "1. Selección de semillas\n"
            "• Calidad genética: variedades mejoradas y resistentes\n"
            "• Semillas sanas, maduras y uniformes\n"
            "• Recolectar de frutos bien maduros (color rojo/amarillo)\n\n"
            "2. Preparación de chapolas\n"
            "• Terreno limpio, bien drenado y con sombra parcial\n"
            "• Preparar suelo con materia orgánica\n"
            "• Siembra en líneas o surcos, cubriendo con capa fina de tierra\n"
            "• Riego constante sin encharcar\n"
            "• Proteger plántulas de sol fuerte y plagas\n"
            "• Trasplantar cuando alcancen 15-20 cm de altura",
        imagen: "lib/ui/screens/assets/images/modulo1/semilla.jpg",
      ),
    ],
    quiz: [
      QuizPregunta(
        pregunta: "¿Dónde se originó el cultivo del café según la leyenda?",
        opciones: ["Colombia", "Etiopía", "Yemen", "Brasil"],
        respuestaCorrecta: 1, // Etiopía
      ),
      QuizPregunta(
        pregunta:
            "¿Cuál es la variedad de café más sembrada en Colombia actualmente?",
        opciones: ["Typica", "Bourbon", "Castillo", "Geisha"],
        respuestaCorrecta: 2, // Castillo
      ),
      QuizPregunta(
        pregunta:
            "El café arábica crece mejor en altitudes superiores a 1,800 msnm.",
        opciones: ["Verdadero", "Falso"],
        respuestaCorrecta: 0, // Verdadero
        esVerdaderoFalso: true,
      ),
    ],
  ),
  // Módulo 2: Preparación del terreno (completo)
  Modulo(
    id: 2,
    titulo: "Establecimiento y manejo del cafetal",
    descripcion: "Preparación del terreno, siembra y manejo inicial",
    imagenPortada: "lib/ui/screens/assets/images/modulo2.png",
    bloqueado: true,
    diapositivas: [
      Diapositiva(
        titulo: "Preparación del terreno y diseño de la plantación",
        contenido:
            "Preparación del terreno y diseño de la plantación (surcos, sombra, densidad).\n\n"
            "1. Preparación del terreno\n"
            "Antes de sembrar café, es fundamental preparar bien el terreno para asegurar un buen desarrollo de las plantas:\n"
            "• Limpieza: Se elimina toda maleza, árboles o restos de cultivos anteriores que puedan competir por nutrientes o albergar plagas.\n"
            "• Labranza: Se realiza un arado o volteo del suelo para aflojar la tierra, mejorar la aireación y facilitar la penetración de raíces.\n"
            "• Enmiendas: Se incorporan abonos orgánicos (estiércol, compost) y, si es necesario, fertilizantes para mejorar la fertilidad del suelo.\n"
            "• Corrección del pH: Si el suelo es muy ácido o alcalino, se aplican correctores (como cal agrícola) para ajustarlo al rango ideal (5.5-6.5).\n"
            "• Drenaje: Se deben evitar zonas donde el agua se acumule, para prevenir enfermedades en las raíces.\n\n"
            "2. Diseño de la plantación\n"
            "El diseño adecuado facilita el manejo, mejora la producción y ayuda a controlar plagas y enfermedades.\n\n"
            "Surcos\n"
            "• Se hacen surcos o filas en el terreno donde se ubicarán las plantas.\n"
            "• La orientación suele ser de norte a sur para maximizar la exposición solar uniforme.\n"
            "• En pendientes, los surcos deben seguir la curva de nivel para evitar erosión.\n\n"
            "Sombra\n"
            "• La sombra parcial es beneficiosa para regular la temperatura y humedad, proteger al café de la radiación solar directa y conservar la biodiversidad.\n"
            "• Se plantan árboles sombra (como guamos, roble o matarratón) entre las filas de café.\n"
            "• La sombra debe ser moderada; un exceso puede reducir la productividad y aumentar la humedad, favoreciendo enfermedades.\n\n"
            "Densidad de siembra\n"
            "• La distancia entre plantas varía según la variedad y el sistema productivo.\n"
            "• Generalmente, se usan distancias entre 1.2 a 1.5 metros entre plantas y 2 a 3 metros entre surcos.\n"
            "• Esto significa una densidad aproximada de 4,000 a 6,000 plantas por hectárea.\n"
            "• En sistemas intensivos o de especialidad, la densidad puede ser mayor para maximizar producción y calidad.",
        imagen: "lib/ui/screens/assets/images/modulo2/preparacion_suelo.png",
      ),
      Diapositiva(
        titulo: "Siembra y trasplante de plántulas",
        contenido:
            "1. Siembra de semillas en el vivero\n"
            "• Preparación del vivero: Se elige un lugar con sombra parcial, buen drenaje y protección contra vientos fuertes. Se preparan las chapolas (campos o camas) con suelo suelto y rico en materia orgánica.\n"
            "• Siembra:\n"
            "  o Las semillas previamente seleccionadas (maduras y sanas) se siembran en líneas o en pequeños huecos, cubriéndolas con una capa ligera de tierra o arena (2-3 cm).\n"
            "  o Se riegan constantemente para mantener la humedad, pero evitando encharcar.\n"
            "• Germinación:\n"
            "  o Las semillas germinan entre 15 y 30 días.\n"
            "  o Durante esta etapa se protege del sol directo y se controla plagas y enfermedades.\n"
            "• Desarrollo:\n"
            "  o Las plántulas crecen durante aproximadamente 4 a 6 meses en el vivero, hasta que alcanzan entre 15 y 20 cm de altura, con buen desarrollo radicular y hojas sanas.\n\n"
            "2. Preparación para el trasplante\n"
            "• Endurecimiento:\n"
            "  o Antes del trasplante, se reduce el riego para que las plántulas se adapten a condiciones externas.\n"
            "  o Se reduce también la sombra para que se fortalezcan.\n"
            "• Selección:\n"
            "  o Se escogen las plántulas más fuertes, sin daños ni enfermedades.\n"
            "• Preparación del terreno definitivo:\n"
            "  o El terreno en la finca debe estar bien preparado (limpio, labrado, enmendado).\n"
            "  o Se hacen los hoyos de siembra (aprox. 30x30x30 cm), dejando suficiente espacio según el diseño de plantación.\n\n"
            "3. Trasplante de plántulas\n"
            "• Extracción:\n"
            "  o Se sacan las plántulas con cuidado para no dañar las raíces ni el sustrato que las sostiene.\n"
            "• Plantación:\n"
            "  o Se colocan en los hoyos, enterrando las raíces y el cepellón de tierra.\n"
            "  o Se cubre con tierra, compactando ligeramente para eliminar bolsas de aire.\n"
            "• Riego:\n"
            "  o Se riega inmediatamente para ayudar a asentar el suelo y evitar el estrés hídrico.\n\n"
            "4. Cuidados posteriores\n"
            "• Sombra:\n"
            "  o Mantener sombra parcial para proteger las plántulas jóvenes del sol intenso.\n"
            "• Riego:\n"
            "  o Regar regularmente, manteniendo el suelo húmedo pero sin encharcar.\n"
            "• Control de malezas y plagas:\n"
            "  o Mantener la zona limpia y monitorear la salud de las plantas.\n"
            "• Fertilización:\n"
            "  o Aplicar abonos orgánicos o fertilizantes equilibrados para promover un buen crecimiento.",
        imagen: "lib/ui/screens/assets/images/modulo2/siembraYtransplante.png",
      ),
      Diapositiva(
        titulo: "Manejo de sombra (especies arbóreas compatibles)",
        contenido:
            "Manejo de Sombra en Cultivo de Café ☕🌳\n\n"
            "Importancia de la sombra\n"
            "• Regula la temperatura del microclima, protegiendo las plantas jóvenes del sol intenso.\n"
            "• Conserva humedad en el suelo, lo que favorece el desarrollo radicular.\n"
            "• Reduce el estrés hídrico en épocas secas.\n\n"
            "Estrategias de manejo\n"
            "• La sombra debe ser moderada y bien distribuida: generalmente entre el 30% y 50% de cobertura.\n"
            "• Se puede usar sombra natural (árboles presentes en la finca) o plantada con especies seleccionadas.\n"
            "• La sombra excesiva puede aumentar la humedad y favorecer enfermedades como la roya, por eso es importante el equilibrio.\n\n"
            "Especies Arbóreas Compatibles con el Café\n"
            "Estas especies cumplen funciones de sombra, fijación de nitrógeno, protección del suelo y aporte de materia orgánica:\n\n"
            "Árboles para sombra y protección\n"
            "• Guamo (Inga spp.): Fija nitrógeno, crece rápido, excelente para sombra y mejora el suelo.\n"
            "• Roble (Quercus humboldtii): Árbol nativo que aporta sombra estable y favorece la biodiversidad.\n"
            "• Matarratón (Schefflera spp.): Crece bien en sistemas agroforestales, buena sombra y protección contra viento.\n"
            "• Algarrobo (Prosopis juliflora): Fija nitrógeno y provee sombra, aunque se debe controlar su expansión.\n"
            "• Aliso (Alnus acuminata): Árbol fijador de nitrógeno, aporta buena sombra y mejora la fertilidad.",
        imagen: "lib/ui/screens/assets/images/modulo2/manejoSombra.png",
      ),
      Diapositiva(
        titulo: "Nutrición del suelo: abonos y fertilizantes",
        contenido:
            "1. Importancia de la nutrición del suelo\n"
            "El café es un cultivo exigente en nutrientes que necesita un suelo fértil para crecer sano, producir bien y resistir plagas y enfermedades. La nutrición adecuada:\n"
            "• Mejora el crecimiento y desarrollo de la planta.\n"
            "• Incrementa la producción y calidad del café.\n"
            "• Favorece la resistencia a condiciones adversas.\n\n"
            "2. Tipos de nutrientes esenciales\n"
            "• Macronutrientes: Nitrógeno (N), Fósforo (P), Potasio (K) — los más importantes para el café.\n"
            "• Secundarios: Calcio (Ca), Magnesio (Mg), Azufre (S).\n"
            "• Micronutrientes: Hierro (Fe), Zinc (Zn), Manganeso (Mn), Boro (B), Cobre (Cu), Molibdeno (Mo).\n\n"
            "3. Abonos orgánicos\n"
            "• Compost, estiércol, vermicompost: Mejoran la estructura del suelo, aumentan la materia orgánica, la retención de agua y liberan nutrientes lentamente.\n"
            "• Ventajas: Mejoran la fertilidad a largo plazo, favorecen la actividad biológica del suelo y son sostenibles.\n"
            "• Aplicación: Se incorporan al suelo antes de la siembra o como complemento durante el cultivo.\n\n"
            "4. Fertilizantes químicos\n"
            "• Fertilizantes nitrogenados: Urea, sulfato de amonio, nitrato de amonio — para estimular el crecimiento vegetativo.\n"
            "• Fosfatados: Superfosfato simple o triple — para favorecer el desarrollo radicular y la floración.\n"
            "• Potásicos: Cloruro de potasio, sulfato de potasio — para mejorar la calidad del fruto y resistencia a enfermedades.\n\n"
            "5. Aplicación y manejo\n"
            "• Análisis de suelo: Para conocer deficiencias específicas y ajustar la fertilización.\n"
            "• Dosis: Según resultados del análisis y etapa del cultivo (siembra, crecimiento, producción).\n"
            "• Época: Aplicar fertilizantes en temporadas de crecimiento activo, evitando épocas de lluvias intensas para minimizar pérdidas.\n"
            "• Método: Puede ser en aplicaciones foliares o al suelo (en surcos o alrededor de la planta).\n\n"
            "6. Manejo integrado\n"
            "• Combinar abonos orgánicos y fertilizantes químicos para un balance nutricional óptimo.\n"
            "• Incorporar prácticas de conservación del suelo como cobertura vegetal y rotación para mantener la salud del terreno.\n"
            "• Monitorear el estado nutricional del cultivo periódicamente.",
        imagen: "lib/ui/screens/assets/images/modulo2/fertilizantes.png",
      ),
      Diapositiva(
        titulo: "Manejo integrado del cultivo joven",
        contenido:
            "1. Control de malezas (primer año):\n\n"
            "• Métodos recomendados:\n"
            "  - Manual (machete o azadón)\n"
            "  - Mecánico (cultivadoras)\n"
            "  - Mulching (cobertura orgánica)\n\n"
            "• Especies críticas a controlar:\n"
            "  - Zacate jaragua (Hyparrhenia rufa)\n"
            "  - Chipaca (Commelina spp.)\n"
            "  - Bledo (Amaranthus spp.)\n\n"
            "2. Riego de establecimiento:\n\n"
            "• Requerimientos:\n"
            "  - 3-4 litros/planta cada 3 días (sin lluvia)\n"
            "  - Durante primeros 6 meses\n"
            "  - Preferiblemente por goteo\n\n"
            "3. Poda de formación:\n\n"
            "• Objetivos:\n"
            "  - Definir estructura productiva\n"
            "  - Promover ramas laterales\n"
            "  - Facilitar labores culturales\n\n"
            "• Técnica:\n"
            "  - A los 8-10 meses\n"
            "  - Corte a 40-50 cm de altura\n"
            "  - Eliminar chupones basales\n\n"
            "4. Control fitosanitario preventivo:\n\n"
            "• Plagas comunes:\n"
            "  - Minador de la hoja\n"
            "  - Ácaros\n"
            "  - Gusano cortador\n\n"
            "• Enfermedades:\n"
            "  - Roya\n"
            "  - Cercospora\n"
            "  - Mal de hilachas\n\n"
            "5. Registro de actividades:\n\n"
            "• Cuaderno de campo con:\n"
            "  - Fechas de labores\n"
            "  - Productos aplicados\n"
            "  - Observaciones fenológicas",
        imagen: "lib/ui/screens/assets/images/modulo2/manejoIntegrado.png",
      ),
    ],
    quiz: [
      QuizPregunta(
        pregunta:
            "¿Cuál es la profundidad recomendada para el arado en la preparación inicial del terreno?",
        opciones: ["20-30 cm", "40-50 cm", "60-70 cm", "80-100 cm"],
        respuestaCorrecta: 1, // 40-50 cm
      ),
      QuizPregunta(
        pregunta:
            "En el manejo de sombra, ¿cuál de estas especies NO es recomendable para asociar con café?",
        opciones: [
          "Guamo (Inga spp.)",
          "Eucalipto",
          "Nogal cafetero",
          "Carbonero",
        ],
        respuestaCorrecta: 1, // Eucalipto
      ),
      QuizPregunta(
        pregunta:
            "La poda de formación en plantas jóvenes de café debe realizarse cuando alcanzan 1 metro de altura.",
        opciones: ["Verdadero", "Falso"],
        respuestaCorrecta: 1, // Falso (se hace a 40-50 cm)
        esVerdaderoFalso: true,
      ),
    ],
  ),

  // Módulo 3: Siembra y establecimiento (completo)
  Modulo(
    id: 3,
    titulo: "Manejo integrado de plagas y enfermedades",
    descripcion: "Identificación, prevención y control fitosanitario",
    imagenPortada: "lib/ui/screens/assets/images/modulo3.png",
    bloqueado: true,
    diapositivas: [
      Diapositiva(
        titulo: "Plagas más comunes en el cultivo de café",
        contenido:
            "1. Broca del café (Hypothenemus hampei) - Plaga clave:\n\n"
            "• Ciclo biológico: 25-35 días (huevo a adulto)\n"
            "• Daño: Perfora granos (pérdidas hasta 35%)\n"
            "• Síntomas:\n"
            "  - Orificios circulares en frutos\n"
            "  - Granos vacíos o con larvas\n"
            "  - Caída prematura de frutos afectados\n\n"
            "2. Minador de la hoja (Leucoptera coffeella):\n\n"
            "• Generaciones/año: 8-10\n"
            "• Daño: Reduce área fotosintética en 40-60%\n"
            "• Síntomas:\n"
            "  - Galerías serpentiformes en hojas\n"
            "  - Hojas amarillentas y caída prematura\n\n"
            "3. Mosca blanca (Aleurothrixus floccosus):\n\n"
            "• Reproducción: 150 huevos/hembra\n"
            "• Daño secundario: Fumagina (reduce fotosíntesis)\n"
            "• Síntomas:\n"
            "  - Melaza pegajosa en hojas\n"
            "  - Hongo negro adherido\n\n"
            "4. Cochinilla (Planococcus citri):\n\n"
            "• Colonias: 50-100 individuos/área\n"
            "• Daño: Debilitamiento progresivo\n"
            "• Síntomas:\n"
            "  - Masas algodonosas en tallos\n"
            "  - Hojas enrolladas y deformadas\n\n"
            "5. Gusano cortador (Agrotis spp.):\n\n"
            "• Hábito: Nocturno\n"
            "• Daño: Pérdida de plántulas (hasta 30%)\n"
            "• Síntomas:\n"
            "  - Tallos cortados a nivel del suelo\n"
            "  - Plantas jóvenes caídas",
        imagen: "lib/ui/screens/assets/images/modulo3/plagas.png",
      ),
      Diapositiva(
        titulo: "Estrategias para el manejo integrado de plagas (MIP)",
        contenido:
            "1. Monitoreo sistemático:\n\n"
            "• Broca:\n"
            "  - Trampas con alcohol etílico (2-3/ha)\n"
            "  - Muestreo de 100 frutos/parcela\n"
            "  - Umbral: 2-3% frutos brocados\n\n"
            "• Minador:\n"
            "  - Evaluar 10 hojas/planta (50 plantas)\n"
            "  - Umbral: 15-20% hojas minadas\n\n"
            "2. Control cultural avanzado:\n\n"
            "• Recolección oportuna (evitar frutos sobremaduros)\n"
            "• Podas de saneamiento (eliminar tejidos afectados)\n"
            "• Manejo de sombra (40-50% cobertura)\n"
            "• Fertilización balanceada (evitar exceso de N)\n\n"
            "3. Control biológico especializado:\n\n"
            "• Broca:\n"
            "  - Liberación de Cephalonomia stephanoderis (500 avispas/ha)\n"
            "  - Aplicación de Beauveria bassiana (2x10^8 esporas/ml)\n\n"
            "• Minador:\n"
            "  - Conservación de parasitoides nativos (Horismenus spp.)\n"
            "  - Uso de Bacillus thuringiensis (Bt) en épocas críticas\n\n"
            "4. Control químico racional:\n\n"
            "• Broca:\n"
            "  - Endosulfán (solo en emergencias)\n"
            "  - Aplicación dirigida a frutos\n"
            "• Minador:\n"
            "  - Spinosad (15-20 ml/bomba)\n"
            "  - Frecuencia máxima cada 21 días\n\n"
            "5. Trampeo masivo:\n\n"
            "• Broca:\n"
            "  - Trampas ETM (1 cada 20 plantas)\n"
            "  - Atrayente alcohol-metanol (3:1)\n"
            "• Mosca blanca:\n"
            "  - Trampas amarillas con pegante (8-10/ha)",
        imagen: "lib/ui/screens/assets/images/modulo3/plagas.png",
      ),
      Diapositiva(
        titulo: "Enfermedades más comunes en el café",
        contenido:
            "1. Roya del café (Hemileia vastatrix) - Enfermedad clave:\n\n"
            "• Condiciones favorables:\n"
            "  - 18-22°C\n"
            "  - >12 horas de humedad foliar\n"
            "• Síntomas:\n"
            "  - Manchas amarillas en envés\n"
            "  - Pústulas anaranjadas (esporas)\n"
            "  - Defoliación progresiva\n\n"
            "2. Fusariosis (Fusarium xylarioides):\n\n"
            "• Transmisión:\n"
            "  - Heridas de poda\n"
            "  - Suelo contaminado\n"
            "• Síntomas:\n"
            "  - Marchitez unilateral\n"
            "  - Vascularización oscura\n"
            "  - Muerte regresiva\n\n"
            "3. Phoma (Phoma costarricensis):\n\n"
            "• Factores de riesgo:\n"
            "  - Lluvias prolongadas\n"
            "  - Heridas mecánicas\n"
            "• Síntomas:\n"
            "  - Manchas concéntricas\n"
            "  - Defoliación severa\n\n"
            "4. Antracnosis (Colletotrichum gloeosporioides):\n\n"
            "• Daño principal:\n"
            "  - Pudrición de frutos\n"
            "  - Muerte descendente\n"
            "• Síntomas:\n"
            "  - Lesiones hundidas\n"
            "  - Masas rosadas de esporas\n\n"
            "5. Ojo de gallo (Mycena citricolor):\n\n"
            "• Epidemiología:\n"
            "  - Alta humedad relativa\n"
            "  - Sombra excesiva\n"
            "• Síntomas:\n"
            "  - Manchas circulares con halo\n"
            "  - Perforaciones foliares",
        imagen: "lib/ui/screens/assets/images/modulo3/enfermedades.png",
      ),
      Diapositiva(
        titulo: "Manejo integrado de enfermedades",
        contenido:
            "1. Estrategias preventivas:\n\n"
            "• Selección varietal:\n"
            "  - Resistencia genética (ej. variedad Castillo)\n"
            "  - Adaptación microclimática\n\n"
            "• Prácticas culturales:\n"
            "  - Distancias de siembra adecuadas\n"
            "  - Sistemas de drenaje eficientes\n"
            "  - Manejo óptimo de sombra\n\n"
            "2. Control químico estratégico:\n\n"
            "• Roya:\n"
            "  - Triazoles (cyproconazole 5%) - 0.5 L/ha\n"
            "  - Estrobilurinas (azoxystrobin) - 300 g/ha\n"
            "  - Frecuencia: 3-4 aplicaciones/año\n\n"
            "• Antracnosis:\n"
            "  - Clorotalonil (1.5 kg/ha)\n"
            "  - Aplicaciones pre-floración\n\n"
            "3. Control biológico avanzado:\n\n"
            "• Hongos antagonistas:\n"
            "  - Trichoderma harzianum (5 kg/ha)\n"
            "  - Aplicación al suelo y follaje\n\n"
            "• Inductores de resistencia:\n"
            "  - Acibenzolar-S-metil (ASM)\n"
            "  - Fosfitos (2-3 aplicaciones/año)\n\n"
            "4. Monitoreo epidemiológico:\n\n"
            "• Roya:\n"
            "  - Escala de incidencia (0-5)\n"
            "  - Umbral de acción: 10% hojas afectadas\n\n"
            "• Phoma:\n"
            "  - Modelos predictivos (lluvias >100 mm/mes)\n\n"
            "5. Registro y trazabilidad:\n\n"
            "• Cuaderno de aplicaciones\n"
            "• Mapeo de zonas críticas\n"
            "• Rotación de principios activos",
        imagen: "lib/ui/screens/assets/images/modulo3/enfermedades.png",
      ),
      Diapositiva(
        titulo: "Prácticas agroecológicas y biopreparados",
        contenido:
            "1. Técnicas agroecológicas avanzadas:\n\n"
            "• Bancos de conservación de enemigos naturales:\n"
            "  - Plantas nectaríferas (Crotalaria, Tagetes)\n"
            "  - Refugios para insectos benéficos\n\n"
            "• Manejo de microclima:\n"
            "  - Cortinas rompevientos\n"
            "  - Mulching orgánico\n"
            "  - Terrazas vivas\n\n"
            "2. Biopreparados técnicos:\n\n"
            "• Fungicida botánico:\n"
            "  - Extracto de cola de caballo (Equisetum spp.)\n"
            "  - Dosis: 1 kg/10 L agua (fermentado 15 días)\n\n"
            "• Insecticida microbiológico:\n"
            "  - Beauveria bassiana cepa GHA\n"
            "  - Formulación: 1x10^8 esporas/ml\n\n"
            "• Biofertilizante foliar:\n"
            "  - Fermentado de estiércol + melaza\n"
            "  - Enriquecido con ceniza\n\n"
            "3. Calendario lunar aplicado:\n\n"
            "• Podas: Luna menguante\n"
            "• Aplicaciones: Luna creciente\n"
            "• Siembras: Luna nueva\n\n"
            "4. Indicadores de salud del agroecosistema:\n\n"
            "• Presencia de aves insectívoras\n"
            "• Diversidad de artrópodos\n"
            "• Actividad microbiana en suelo\n\n"
            "5. Protocolo de transición agroecológica:\n\n"
            "• Fase 1 (año 1): Reducción 50% insumos\n"
            "• Fase 2 (año 2-3): Sistema mixto\n"
            "• Fase 3 (año 4+): Sistema certificable",
        imagen:
            "lib/ui/screens/assets/images/modulo3/practicasybiopreparados.png",
      ),
      Diapositiva(
        titulo: "Monitoreo y manejo sostenible",
        contenido:
            "1. Sistema de alerta temprana:\n\n"
            "• Estaciones meteorológicas locales\n"
            "• Modelos predictivos para:\n"
            "  - Roya (SIAR Café)\n"
            "  - Broca (Trampeo inteligente)\n\n"
            "2. Tecnologías de precisión:\n\n"
            "• Drones para:\n"
            "  - Detección térmica de estrés\n"
            "  - Aplicaciones dirigidas\n\n"
            "• Sensores IoT para:\n"
            "  - Humedad foliar\n"
            "  - Presión de plagas\n\n"
            "3. Buenas prácticas agrícolas (BPA) certificadas:\n\n"
            "• Protocolos GLOBALG.A.P.\n"
            "• Normas Rainforest Alliance\n"
            "• Certificación orgánica\n\n"
            "4. Indicadores de sostenibilidad:\n\n"
            "• Económicos:\n"
            "  - Relación beneficio/costo\n"
            "  - Valor agregado\n\n"
            "• Ambientales:\n"
            "  - Huella hídrica\n"
            "  - Secuestro de carbono\n\n"
            "• Sociales:\n"
            "  - Capacitación de trabajadores\n"
            "  - Equidad de género\n\n"
            "5. Plan de mejora continua:\n\n"
            "• Auditorías internas trimestrales\n"
            "• Grupos de aprendizaje entre pares\n"
            "• Actualización tecnológica anual",
        imagen: "lib/ui/screens/assets/images/modulo3/monitoreo.png",
      ),
    ],
    quiz: [
      QuizPregunta(
        pregunta:
            "¿Cuál es el umbral de acción recomendado para iniciar control contra la broca del café?",
        opciones: [
          "1% frutos brocados",
          "2-3% frutos brocados",
          "5-7% frutos brocados",
          "10% frutos brocados",
        ],
        respuestaCorrecta: 1,
      ),
      QuizPregunta(
        pregunta:
            "¿Cuál de estos hongos es utilizado como control biológico de enfermedades en café?",
        opciones: [
          "Trichoderma harzianum",
          "Fusarium oxysporum",
          "Aspergillus niger",
          "Penicillium chrysogenum",
        ],
        respuestaCorrecta: 0,
      ),
      QuizPregunta(
        pregunta:
            "La roya del café se desarrolla mejor en condiciones de alta humedad y temperaturas entre 18-22°C.",
        opciones: ["Verdadero", "Falso"],
        respuestaCorrecta: 0,
        esVerdaderoFalso: true,
      ),
    ],
  ),
  // Módulo 4: Manejo integrado de plagas (completo)
  Modulo(
    id: 4,
    titulo: "Cosecha y postcosecha",
    descripcion: "Técnicas de recolección, procesamiento y control de calidad",
    imagenPortada: "lib/ui/screens/assets/images/modulo4.png",
    bloqueado: true,
    diapositivas: [
      Diapositiva(
        titulo: "Punto óptimo de maduración del grano",
        contenido:
            "Características del fruto en el punto óptimo:\n\n"
            "• Color: La cereza cambia de verde a rojo intenso brillante (en variedades Arábica). Algunas variedades pueden presentar tonos amarillos o anaranjados\n"
            "• Textura: Firme pero ligeramente blando al tacto\n"
            "• Tamaño: Completo, con el grano completamente desarrollado internamente\n"
            "• Aroma: Presenta un aroma dulce y agradable, indicador de buena madurez\n\n"
            "Importancia del punto óptimo:\n\n"
            "• Garantiza granos con el mejor perfil de sabor, aroma y calidad\n"
            "• Evita la recolección de frutos verdes (que aportan sabores herbáceos) o sobremaduros (que pueden fermentar prematuramente)\n"
            "• Permite un proceso de secado y fermentación más homogéneo\n\n"
            "Cómo identificar el punto óptimo:\n\n"
            "• Observación visual: Identificar color uniforme y brillante en las cerezas\n"
            "• Prueba de tacto: La cereza debe ceder ligeramente bajo presión pero no estar blanda\n"
            "• Prueba del sabor: Al probar el grano, debe presentar dulzura característica\n"
            "• Tiempo de desarrollo: Generalmente 8-9 meses después de la floración",
        imagen: "lib/ui/screens/assets/images/modulo4/puntoDmaduracion.png",
      ),
      Diapositiva(
        titulo: "Técnicas de cosecha selectiva",
        contenido:
            "¿Qué es la cosecha selectiva?\n\n"
            "Es el proceso de recolectar únicamente los frutos que han alcanzado su punto óptimo de maduración, dejando los verdes para que maduren en siguientes pasadas. Esto garantiza máxima calidad en el café.\n\n"
            "Técnicas principales:\n\n"
            "1. Cosecha manual o a mano (selectiva pura):\n"
            "• Recolectores seleccionan visualmente solo los frutos maduros\n"
            "• Se realizan múltiples pasadas (cada 7-15 días)\n"
            "• Ventaja: Máxima calidad al procesar solo granos maduros\n"
            "• Desventaja: Requiere mucha mano de obra (hasta 3-4 veces más que otros métodos)\n\n"
            "2. Pasa única o cosecha total:\n"
            "• Se recolectan todos los frutos (maduros y verdes) en una sola pasada\n"
            "• Usado en plantaciones con poca mano de obra o variedades de maduración homogénea\n"
            "• Calidad inferior por mezcla de granos en distintos estados\n\n"
            "3. Cosecha semi-selectiva:\n"
            "• Compromiso entre calidad y costo\n"
            "• 2-3 pasadas recolectando los frutos más maduros cada vez\n\n"
            "Consejos para una buena cosecha selectiva:\n\n"
            "• Capacitar recolectores en identificación precisa de madurez\n"
            "• Usar canastas ventiladas para evitar fermentación prematura\n"
            "• Realizar cortes temprano en el día para evitar calor excesivo\n"
            "• Transportar rápidamente al beneficio para procesamiento\n"
            "• Organizar cuadrillas por zonas para uniformidad en recolección",
        imagen: "lib/ui/screens/assets/images/modulo4/cosecha_selectiva.png",
      ),
      Diapositiva(
        titulo: "Procesamiento: métodos lavado, natural y honey",
        contenido:
            "1. Método Lavado (Wet Process):\n\n"
            "Proceso detallado:\n"
            "• Despulpado: Se retira la cáscara externa con máquina despulpadora\n"
            "• Fermentación: Los granos con mucílago se sumergen en agua 12-48 horas (dependiendo de temperatura)\n"
            "• Lavado: Se elimina el mucílago fermentado con agua limpia a presión\n"
            "• Secado: Al sol (10-15 días) o mecánico (24-36 horas)\n\n"
            "Características del café:\n"
            "• Perfil limpio y brillante con acidez pronunciada\n"
            "• Sabores más definidos y menos cuerpo que otros métodos\n"
            "• Requiere 20-40 litros de agua por kg de café pergamino\n\n"
            "2. Método Natural (Dry Process):\n\n"
            "Proceso detallado:\n"
            "• Clasificación: Se separan cerezas defectuosas\n"
            "• Secado: Enteras en patios o camas africanas (15-30 días)\n"
            "• Trillado: Se retira la cáscara seca para obtener el grano\n\n"
            "Características del café:\n"
            "• Cuerpo denso y sabores complejos (frutales, dulces)\n"
            "• Menor acidez que el lavado\n"
            "• Riesgo de sabores indeseados si hay fermentación irregular\n\n"
            "3. Método Honey (Semi-Lavado):\n\n"
            "Variaciones:\n"
            "• Honey Blanco (10-15% mucílago)\n"
            "• Honey Amarillo (50-75% mucílago)\n"
            "• Honey Negro (100% mucílago)\n\n"
            "Características:\n"
            "• Balance perfecto entre dulzura (natural) y limpieza (lavado)\n"
            "• Notas florales y afrutadas más pronunciadas\n"
            "• Consumo moderado de agua (solo para despulpado)",
        imagen: "lib/ui/screens/assets/images/modulo4/lavado.png",
      ),
      Diapositiva(
        titulo: "Secado y almacenamiento del café",
        contenido:
            "Secado del café:\n\n"
            "Objetivos clave:\n"
            "• Reducir humedad del 60% al 10-12%\n"
            "• Evitar fermentaciones secundarias\n"
            "• Preservar cualidades intrínsecas del grano\n\n"
            "Métodos de secado:\n\n"
            "1. Secado solar tradicional:\n"
            "• Patios de cemento o ladrillo (volteo manual cada 2 horas)\n"
            "• Camas africanas (mejor aireación, volteo más fácil)\n"
            "• Duración: 10-30 días según condiciones climáticas\n\n"
            "2. Secadores mecánicos:\n"
            "• Tipos: Tambor rotativo, lecho fluidizado, secadores estáticos\n"
            "• Temperaturas: Máximo 40-45°C para no dañar el grano\n"
            "• Ventaja: Control preciso independiente del clima\n\n"
            "Almacenamiento del café:\n\n"
            "Condiciones ideales:\n"
            "• Humedad relativa: 50-60%\n"
            "• Temperatura: 15-20°C (evitar fluctuaciones)\n"
            "• Ventilación: Adecuada pero sin corrientes directas\n\n"
            "Envases recomendados:\n"
            "• Sacos de yute o fibra natural (permiten respiración)\n"
            "• Granel en silos con control de humedad\n"
            "• Evitar plásticos herméticos (condensación)\n\n"
            "Vida útil:\n"
            "• Óptima: 6-12 meses en condiciones controladas\n"
            "• Con atmósfera modificada: hasta 18 meses",
        imagen: "lib/ui/screens/assets/images/modulo4/secado.png",
      ),
      Diapositiva(
        titulo: "Control de calidad en postcosecha",
        contenido:
            "1. Verificación de humedad:\n\n"
            "• Puntos críticos:\n"
            " - Después de secado: 10-12%\n"
            " - Para exportación: 10.5-11.5%\n"
            "• Métodos de medición:\n"
            " - Medidores electrónicos de penetración\n"
            " - Método gravimétrico (estufa) para validación\n\n"
            "2. Clasificación por tamaño y densidad:\n\n"
            "• Tamices estándar (Screen 15 a 20)\n"
            "• Mesas densimétricas para separar por peso\n"
            "• Clasificación electrónica (scanners de color)\n\n"
            "3. Detección y eliminación de defectos:\n\n"
            "Defectos primarios:\n"
            "• Granos brocados (perforados)\n"
            "• Granos negros/vinagres (sobrefermentados)\n"
            "• Granos partidos/quebrados\n\n"
            "4. Pruebas sensoriales preliminares:\n\n"
            "• Catación para evaluar:\n"
            " - Limpieza (ausencia de defectos)\n"
            " - Dulzura\n"
            " - Acidez\n"
            " - Cuerpo\n"
            "• Prueba de infusión simple para detectar fermentaciones\n\n"
            "5. Empaque final:\n\n"
            "• Sacos de 60-70 kg (exportación)\n"
            "• Bolsas GrainPro para máxima protección\n"
            "• Almacenamiento en paletas (evitar contacto con suelo/paredes)\n"
            "• Registro de lotes con:\n"
            " - Fecha de cosecha\n"
            " - Variedad\n"
            " - Altitud\n"
            " - Método de procesamiento",
        imagen: "lib/ui/screens/assets/images/modulo4/secado.png",
      ),
    ],
    quiz: [
      QuizPregunta(
        pregunta:
            "¿Cuál es el rango de humedad ideal para el almacenamiento prolongado de café pergamino?",
        opciones: ["5-7%", "10-12%", "15-18%", "20-22%"],
        respuestaCorrecta: 1,
      ),
      QuizPregunta(
        pregunta:
            "En el método de procesamiento Honey, ¿qué factor determina la clasificación (blanco, amarillo, negro)?",
        opciones: [
          "Tiempo de fermentación",
          "Cantidad de mucílago dejado en el grano",
          "Temperatura de secado",
          "Variedad del café",
        ],
        respuestaCorrecta: 1,
      ),
      QuizPregunta(
        pregunta:
            "La cosecha selectiva manual puede requerir hasta 3-4 veces más mano de obra que la cosecha mecanizada.",
        opciones: ["Verdadero", "Falso"],
        respuestaCorrecta: 0,
        esVerdaderoFalso: true,
      ),
    ],
  ),

  // Módulo 5: Fertilización y nutrición (completo)
  Modulo(
    id: 5,
    titulo: "Beneficiado y calidad del café",
    descripcion: "Procesamiento postcosecha y estándares de calidad",
    imagenPortada: "lib/ui/screens/assets/images/modulo5.png",
    bloqueado: true,
    diapositivas: [
      Diapositiva(
        titulo: "Despulpado, fermentación y lavado",
        contenido:
            "1. Despulpado:\n"
            "• Separar la pulpa de la cereza para obtener el grano cubierto por mucílago\n"
            "• Máquinas despulpadoras presionan y retiran la pulpa sin dañar el grano\n"
            "• Primer paso después de la cosecha\n\n"
            "2. Fermentación:\n"
            "• Granos con mucílago en tanques con agua\n"
            "• Microorganismos descomponen el mucílago\n"
            "• Duración: 12-48 horas según temperatura\n"
            "• Control cuidadoso para evitar fermentaciones excesivas\n\n"
            "3. Lavado:\n"
            "• Elimina restos de mucílago y residuos\n"
            "• Canales o tanques con agua corriente\n"
            "• Mejora limpieza y calidad del grano",
        imagen: "lib/ui/screens/assets/images/modulo5/espulpado.png",
      ),
      Diapositiva(
        titulo: "Clasificación del grano (tamaño, densidad, defectos)",
        contenido:
            "1. Clasificación por tamaño:\n"
            "• Tamices con orificios específicos\n"
            "• Medida en milímetros o sistema numérico (ej. tamaño 15, 16, 17)\n"
            "• Granos grandes = mayor calidad y uniformidad\n\n"
            "2. Clasificación por densidad:\n"
            "• Granos flotantes (defectuosos) vs granos que se hunden (buena calidad)\n"
            "• Uso de agua o soluciones salinas\n"
            "• Equipos de aire para separación\n\n"
            "3. Defectos comunes:\n"
            "• Granos partidos/quebrados\n"
            "• Granos brocados (con insectos)\n"
            "• Granos fermentados/manchas negras\n"
            "• Granos verdes (inmaduros)\n"
            "• Granos quemados",
        imagen: "lib/ui/screens/assets/images/modulo5/clasificacion_grano.png",
      ),
      Diapositiva(
        titulo: "Normas de calidad (protocolos de catación, perfiles de taza)",
        contenido:
            "1. Protocolos de Catación (SCA):\n"
            "• Preparación:\n"
            "  - Granos molidos uniformemente\n"
            "  - Agua filtrada a 93-96°C\n"
            "• Evaluación:\n"
            "  - Aroma, sabor, acidez, cuerpo, balance, dulzura, retrogusto\n"
            "  - Técnica de slurping\n"
            "• Puntaje (0-100):\n"
            "  - +80 puntos = Café Especial\n\n"
            "2. Perfiles de Taza:\n"
            "• Aroma: Fragancia percibida\n"
            "• Sabor: Impresión general\n"
            "• Acidez: Sensación viva (no agria)\n"
            "• Cuerpo: Textura en boca\n"
            "• Balance: Armonía entre atributos\n"
            "• Dulzura: Sensación agradable\n"
            "• Retrogusto: Persistencia del sabor",
        imagen: "lib/ui/screens/assets/images/modulo5/calidad_catacion.png",
      ),
      Diapositiva(
        titulo: "Certificaciones (orgánico, comercio justo, etc.)",
        contenido:
            "1. Orgánico:\n"
            "• Sin pesticidas ni fertilizantes químicos\n"
            "• Protege medio ambiente y salud\n"
            "• Auditorías y normas específicas\n\n"
            "2. Comercio Justo:\n"
            "• Precio mínimo justo para productores\n"
            "• Mejora condiciones laborales\n"
            "• Apoyo a comunidades\n\n"
            "3. Rainforest Alliance:\n"
            "• Conserva biodiversidad\n"
            "• Uso sostenible de recursos\n"
            "• Derechos de trabajadores\n\n"
            "4. UTZ Certified:\n"
            "• Producción sostenible\n"
            "• Mejora calidad\n"
            "• Trazabilidad\n\n"
            "Importancia:\n"
            "• Acceso a mercados internacionales\n"
            "• Confianza del consumidor\n"
            "• Prácticas sostenibles",
        imagen: "lib/ui/screens/assets/images/modulo5/certificados.png",
      ),
    ],
    quiz: [
      QuizPregunta(
        pregunta:
            "¿Cuánto tiempo dura típicamente el proceso de fermentación del café?",
        opciones: ["2-6 horas", "12-48 horas", "3-5 días", "1 semana"],
        respuestaCorrecta: 1,
      ),
      QuizPregunta(
        pregunta:
            "¿Qué atributo NO se evalúa en una catación profesional de café?",
        opciones: ["Acidez", "Cuerpo", "Color del grano", "Aroma"],
        respuestaCorrecta: 2,
      ),
      QuizPregunta(
        pregunta:
            "La certificación orgánica permite el uso limitado de pesticidas químicos.",
        opciones: ["Verdadero", "Falso"],
        respuestaCorrecta: 1,
        esVerdaderoFalso: true,
      ),
    ],
  ),

  // Módulo 6: Cosecha y poscosecha (completo)
  Modulo(
    id: 6,
    titulo: "Comercialización y mercados",
    descripcion: "Estrategias de venta, costos y marketing para productores",
    imagenPortada: "lib/ui/screens/assets/images/modulo6.png",
    bloqueado: true,
    diapositivas: [
      Diapositiva(
        titulo: "Estrategias de venta (local, cooperativas, exportación)",
        contenido:
            "1. Venta Local\n"
            "• Mercados y tiendas locales: Venta directa a consumidores, cafeterías, restaurantes\n"
            "• Beneficios: Mayor margen, contacto directo, creación de marca\n"
            "• Estrategias:\n"
            "  - Participar en ferias locales\n"
            "  - Promover café especial o de origen\n"
            "  - Ofrecer productos diferenciados\n\n"
            "2. Venta a Cooperativas\n"
            "• Agrupación de productores para negociar mejor\n"
            "• Ventajas: Acceso a infraestructura, soporte técnico\n"
            "• Estrategias:\n"
            "  - Fortalecer calidad del café\n"
            "  - Participar en gestión cooperativa\n"
            "  - Acceder a certificaciones\n\n"
            "3. Exportación\n"
            "• Venta a mercados internacionales\n"
            "• Beneficios: Mejor precio, mayor volumen\n"
            "• Estrategias:\n"
            "  - Cumplir normativas internacionales\n"
            "  - Establecer relaciones con compradores\n"
            "  - Participar en ferias internacionales\n\n"
            "4. Venta en línea\n"
            "• Comercio electrónico directo al consumidor\n"
            "• Contar la historia del café para crear fidelidad",
        imagen: "lib/ui/screens/assets/images/modulo6/estrategias_venta.png",
      ),
      Diapositiva(
        titulo: "Elaboración de costos y rentabilidad",
        contenido:
            "1. Identificación de costos\n"
            "• Costos fijos:\n"
            "  - Terreno, infraestructura, mano de obra permanente\n"
            "• Costos variables:\n"
            "  - Insumos agrícolas, mano de obra temporal\n"
            "  - Procesamiento, transporte, certificaciones\n\n"
            "2. Cálculo de costos\n"
            "• Sumar todos los gastos del ciclo productivo\n"
            "• Dividir entre producción estimada (costo por kilo)\n\n"
            "3. Determinación de ingresos\n"
            "• Estimar volumen de café a vender\n"
            "• Definir precio de venta esperado\n\n"
            "4. Cálculo de rentabilidad\n"
            "• Ingresos - Costos = Ganancia\n"
            "• Calcular margen de beneficio porcentual\n\n"
            "5. Análisis y toma de decisiones\n"
            "• Optimizar costos altos\n"
            "• Evaluar relación precio-calidad\n"
            "• Invertir en calidad para mejores mercados",
        imagen: "lib/ui/screens/assets/images/modulo6/costos_entabilidad.png",
      ),
      Diapositiva(
        titulo: "Marketing básico para pequeños productores",
        contenido:
            "1. Conoce tu producto y público\n"
            "• Identifica qué hace único tu café\n"
            "• Define tu cliente ideal\n\n"
            "2. Construye tu marca\n"
            "• Crea nombre y logo representativo\n"
            "• Diseña etiquetas atractivas\n"
            "• Cuenta la historia de tu café\n\n"
            "3. Canales de venta\n"
            "• Venta directa en mercados locales\n"
            "• Venta digital en redes sociales\n"
            "• Red de cooperativas\n\n"
            "4. Promoción y comunicación\n"
            "• Usa redes sociales para mostrar procesos\n"
            "• Publica fotos y videos atractivos\n"
            "• Comparte testimonios de clientes\n\n"
            "5. Calidad y consistencia\n"
            "• Mantén estándares de calidad\n"
            "• Pide retroalimentación\n\n"
            "6. Precio justo y competitivo\n"
            "• Calcula bien tus costos\n"
            "• Considera valor agregado\n\n"
            "7. Alianzas estratégicas\n"
            "• Colabora con otras fincas y cafeterías\n"
            "• Participa en programas de apoyo",
        imagen: "lib/ui/screens/assets/images/modulo6/marqueting.png",
      ),
    ],
    quiz: [
      QuizPregunta(
        pregunta:
            "¿Cuál de estas NO es una ventaja de vender café a través de cooperativas?",
        opciones: [
          "Acceso a infraestructura de procesamiento",
          "Mayor margen de ganancia por venta directa",
          "Soporte técnico compartido",
          "Acceso a certificaciones grupales",
        ],
        respuestaCorrecta: 1,
      ),
      QuizPregunta(
        pregunta: "En el cálculo de rentabilidad, ¿qué fórmula es correcta?",
        opciones: [
          "Ingresos + Costos = Ganancia",
          "Ingresos - Costos = Ganancia",
          "Costos - Ingresos = Ganancia",
          "Ingresos / Costos = Ganancia",
        ],
        respuestaCorrecta: 1,
      ),
      QuizPregunta(
        pregunta:
            "Construir una marca para tu café implica solo crear un logo atractivo.",
        opciones: ["Verdadero", "Falso"],
        respuestaCorrecta: 1,
        esVerdaderoFalso: true,
      ),
    ],
  ),
];
