extends RefCounted


const RELATOS := {
	"ares_pathfinder": {
		"intro": "4 de julio de 1997. Mars Pathfinder llega a Ares Vallis, un antiguo cauce por el que corrió una gran inundación. Dentro lleva Sojourner, el primer rover que rueda por Marte: pesa 10 kilos y es del tamaño de un horno pequeño. Se mueve muy despacio y no se aleja del módulo.",
		"cierre": "Sojourner analizó rocas y halló guijarros redondeados, señal de que el agua los rodó durante mucho tiempo. La misión estaba pensada para una semana y duró casi tres meses. Abrió el camino a Spirit, Opportunity, Curiosity y Perseverance.",
	},
	"llanura_utopia": {
		"intro": "25 de mayo de 2008. Phoenix aterriza cerca del polo norte de Marte, en una llanura helada. Es un módulo fijo con un brazo robótico de más de dos metros. Su misión: excavar el suelo y comprobar si hay hielo de agua y si el terreno pudo ser habitable.",
		"cierre": "Phoenix cavó una zanja y dejó al aire hielo de agua bajo el polvo: trozos blancos que se evaporaron en pocos días. También halló percloratos en el suelo y vio caer nieve desde las nubes. Trabajó hasta noviembre de 2008, cuando el invierno polar le quitó la luz.",
	},
	"gale_curiosity": {
		"intro": "6 de agosto de 2012. Curiosity baja colgado de una grúa aérea al cráter Gale, de unos 154 kilómetros de ancho, con una montaña de unos 5 kilómetros en el centro. Es un rover del tamaño de un coche pequeño, con un generador nuclear. Va a leer las capas de la montaña como un libro de geología.",
		"cierre": "En Yellowknife Bay halló arcillas y sulfatos: el fondo de un lago antiguo de agua dulce, con ingredientes de la vida. Su estación REMS mide cada día el tiempo en Marte. Más de una década después, sigue subiendo la montaña.",
	},
	"zhurong_utopia": {
		"intro": "14 de mayo de 2021. Zhurong, de la misión china Tianwen-1, aterriza en Utopia Planitia, una gran llanura del norte. Es un rover con paneles solares que se abren como alas de mariposa. Recorre dunas y rocas en busca de agua escondida.",
		"cierre": "Zhurong recorrió casi dos kilómetros y estudió las dunas. En su costra halló minerales con agua atrapada, señal de humedad relativamente reciente. Entró en reposo en mayo de 2022. Fue el primer rover de China en Marte.",
	},
	"chryse_viking": {
		"intro": "20 de julio de 1976. Tras casi un año de viaje, el módulo Viking 1 se posa en Chryse Planitia y se convierte en la primera sonda que trabaja durante años sobre la superficie de Marte. Sus cámaras envían las primeras imágenes en color del paisaje y sus instrumentos van a analizar el suelo con una pregunta enorme en mente: ¿puede haber vida en Marte?\n\nTu robot recolector hace de ayudante del módulo. Rastrea el regolito, el polvo fino que cubre casi todo el planeta, y llévalo a la base B, donde se analizará como lo hicieron los instrumentos de Viking.",
		"cierre": "Viking aplicó tres experimentos biológicos al regolito. Uno dio un resultado que parecía positivo, pero el análisis químico no encontró moléculas orgánicas, y casi todos los científicos concluyeron que fue una reacción química del suelo y no vida. Esas muestras revelaron un suelo oxidado, rico en hierro, y dejaron abierta la pregunta que las misiones siguientes todavía persiguen: ¿hubo alguna vez vida en Marte?",
	},
	"pancam_husband": {
		"intro": "2005. Spirit lleva más de un año en Gusev y ya subió a las Colinas Columbia. Además de tomar muestras, su gran herramienta es la Pancam, un par de cámaras panorámicas montadas en un mástil a 1,5 metros del suelo, con filtros de colores para distinguir minerales. Cada foto que envía a la Tierra tarda unos minutos en llegar y ayuda a decidir hacia dónde ir.\n\nHoy tu robot es el fotógrafo: tienes 14 disparos de memoria y cinco blancos. Abre el visor con F, orienta la cámara, acércate con la rueda del ratón y dispara con ESPACIO. Al llegar a la base B, las fotos se transmiten y la memoria queda libre.",
		"cierre": "Las fotos son la forma en que los científicos \"estuvieron\" en Marte. Con la Pancam se estudiaron las capas de las rocas, se midió la velocidad del viento siguiendo remolinos de polvo y se vigiló el cielo, donde también aparecieron la Tierra y las lunas Fobos y Deimos. Una buena foto necesita tres cosas: el blanco bien centrado, bien enfocado y a la distancia justa. Tú acabas de practicar las tres.",
	},
	"polar_lander": {
		"intro": "3 de diciembre de 1999. El Mars Polar Lander de la NASA entra en la atmósfera sobre el polo sur de Marte y nunca vuelve a comunicarse. Iba a cavar con su brazo en busca de hielo bajo la superficie. Nadie ha encontrado sus restos: unas imágenes de 2000 parecieron mostrarlos, pero en 2005 se descartó.\n\nEsta misión es una suposición. Imagina que tu robot recolector llega al lugar donde pudo caer. Recoge las patas y el motor de descenso y llévalos a la base B: con ellos se puede entender qué falló en los últimos metros.",
		"cierre": "La investigación oficial concluyó que lo más probable fue un error de programa: al desplegarse las patas, un sensor notó una sacudida y la nave creyó que ya había aterrizado, así que apagó el motor cuando aún estaba a unos 40 metros de altura. Una lección para las misiones siguientes: probar cada sensor en las condiciones reales del descenso. El misterio sigue abierto, porque la nave nunca se ha encontrado.",
	},
	"jezero_perseverance": {
		"intro": "18 de febrero de 2021. Perseverance aterriza en el cráter Jezero, que hace más de 3.000 millones de años fue un lago alimentado por un río y aún conserva su delta. Su misión es buscar señales de vida antigua y guardar muestras de roca en tubos sellados. Lleva consigo un pequeño helicóptero, Ingenuity.\n\nTu robot recolector busca núcleos de roca y olivino. Llévalos a la base B.",
		"cierre": "Los núcleos de roca son la parte más valiosa de la misión: sellados en tubos, conservan intacta la historia del delta. Perseverance e Ingenuity, que hizo el primer vuelo con motor en otro planeta, mostraron cómo se explorará Marte en el futuro: con rovers que recogen y helicópteros que reconocen el terreno. Si esas muestras llegan a un laboratorio, podrían ayudar a responder si hubo vida.",
	},
	"endeavour_opportunity": {
		"intro": "Agosto de 2011. Tras casi tres años cruzando la llanura, Opportunity llega al borde del cráter Endeavour, de 22 kilómetros de ancho: rocas mucho más antiguas que las de Meridiani. Desde la órbita se habían detectado allí arcillas, un mineral que se forma con agua suave.\n\nTu robot recolector busca vetas de yeso y arcillas en el borde. Llévalas a la base B.",
		"cierre": "En diciembre de 2011 Opportunity encontró una veta brillante de yeso, llamada Homestake: un sulfato que dejó agua corriendo por una grieta. Más tarde halló arcillas, que se forman con agua de pH casi neutro, mucho más amable para la vida que el agua ácida de Meridiani. Fueron algunos de los hallazgos más importantes de su larguísima vida.",
	},
	"insight_elysium": {
		"intro": "26 de noviembre de 2018. InSight aterriza en Elysium Planitia, una llanura lisa y casi sin rocas, y no se mueve nunca: su misión es escuchar. Con un brazo coloca un sismómetro sobre el suelo y espera los temblores de Marte para saber qué hay dentro del planeta.\n\nTu robot recolector hará de ayudante: recoge regolito y recupera un sismómetro, y llévalos a la base B.",
		"cierre": "El sismómetro de InSight registró más de mil temblores. Con sus ondas se midió el núcleo, que es líquido y de unos 1.800 km de radio, y el grosor de la corteza. También oyó impactos de meteoritos. Su sonda térmica no logró enterrarse, pero la misión enseñó más sobre el interior de Marte que todas las anteriores. Terminó en diciembre de 2022, cuando el polvo cubrió sus paneles.",
	},
}


const CURIOSIDADES := {
	"ares_pathfinder": [
		{"cat": "Misión", "t": "Aterrizar rebotando",
		 "x": "Pathfinder cayó protegido por airbags y rebotó como una pelota varias veces antes de detenerse. Después los airbags se desinflaron y el módulo se abrió como una flor."},
		{"cat": "Ingeniería", "t": "Un rover pequeño y paciente",
		 "x": "Sojourner tenía seis ruedas y nunca se alejó más de unos doce metros del módulo. Aun así, probó que un rover podía analizar rocas marcianas."},
		{"cat": "Geología", "t": "Guijarros de río",
		 "x": "Las rocas con guijarros redondos se llaman conglomerados. Solo se forman cuando una corriente de agua rueda las piedras durante mucho tiempo."},
	],
	"llanura_utopia": [
		{"cat": "Clima", "t": "Nieve en Marte",
		 "x": "Phoenix vio caer nieve desde las nubes sobre el polo norte. Los copos se evaporaban antes de llegar al suelo."},
		{"cat": "Química", "t": "Una sal con dos caras",
		 "x": "El perclorato absorbe agua y puede mantener líquida el agua salada a bajas temperaturas. Pero es tóxico para las personas, así que una base tendría que filtrarlo."},
		{"cat": "Misión", "t": "Zanjas con nombre de cuento",
		 "x": "Phoenix cavó zanjas a las que llamó Dodo-Goldilocks y Snow White, nombres de cuentos infantiles."},
	],
	"gale_curiosity": [
		{"cat": "Ingeniería", "t": "Una grúa en el cielo",
		 "x": "Curiosity no aterrizó con airbags: una grúa aérea con cohetes lo bajó colgado de cables y lo dejó sobre sus ruedas."},
		{"cat": "Instrumentos", "t": "Un láser para leer rocas",
		 "x": "Curiosity dispara un láser a las rocas y analiza la luz de la chispa para saber de qué están hechas."},
		{"cat": "Curiosidad", "t": "Un cumpleaños en Marte",
		 "x": "En agosto de 2013 Curiosity cantó «Cumpleaños feliz» a sí mismo, haciendo vibrar una herramienta con la melodía."},
	],
	"zhurong_utopia": [
		{"cat": "Nombre", "t": "Un dios del fuego",
		 "x": "Zhurong lleva el nombre de un dios del fuego de la mitología china, por el color rojo de Marte."},
		{"cat": "Misión", "t": "Todo en un solo viaje",
		 "x": "Tianwen-1 fue la primera misión en llegar a Marte, ponerse en órbita y aterrizar un rover en un único intento."},
		{"cat": "Instrumentos", "t": "Un radar bajo el suelo",
		 "x": "Zhurong llevaba un radar que miraba bajo la superficie para buscar capas de roca y posible hielo."},
	],
	"chryse_viking": [
		{"cat": "Historia", "t": "Un cielo que no era azul",
		 "x": "La primera imagen en color de Viking 1 mostraba un cielo azul por un error de calibración. Al corregirla, el cielo salió rosado y anaranjado: el color del polvo que flota en el aire."},
		{"cat": "Misterio", "t": "La cara de Cydonia",
		 "x": "En 1976 un orbitador Viking fotografió una colina que parecía un rostro. Con imágenes mucho mejores en 1998 y 2001 se vio que era solo una colina natural: un efecto de luz y sombra."},
		{"cat": "Misión", "t": "Pensada para 90 días",
		 "x": "El módulo Viking 1 estaba previsto para trabajar unos 90 días. Siguió enviando datos hasta noviembre de 1982, más de seis años después de aterrizar."},
	],
	"polar_lander": [
		{"cat": "Misión", "t": "Dos microsondas más",
		 "x": "El Mars Polar Lander llevaba dos pequeñas sondas, Deep Space 2, que debían chocar contra el suelo para penetrarlo. Tampoco enviaron ninguna señal."},
		{"cat": "Geología", "t": "Hielo en los polos",
		 "x": "Los polos de Marte tienen casquetes de hielo de agua cubiertos en invierno por una capa de hielo seco: dióxido de carbono congelado."},
		{"cat": "Misterio", "t": "¿Dónde cayó?",
		 "x": "Unas imágenes de la sonda Mars Global Surveyor de 2000 parecían mostrar la nave y su paracaídas, pero en 2005 otras mejores descartaron que fueran ellos."},
	],
	"pancam_husband": [
		{"cat": "Ingeniería", "t": "Ojos en un mástil",
		 "x": "La Pancam va en un mástil a unos 1,5 metros del suelo, casi a la altura de los ojos de una persona. Las dos cámaras miran como un par de ojos y permiten medir distancias."},
		{"cat": "Homenaje", "t": "La colina Husband",
		 "x": "La colina Husband lleva el nombre de Rick Husband, comandante del transbordador Columbia, perdido en 2003. Spirit llegó a su cima en 2005 y fotografió un gran panorama."},
		{"cat": "Cielo", "t": "Dos lunas diminutas",
		 "x": "Marte tiene dos lunas, Fobos y Deimos, mucho más pequeñas que nuestra Luna. Parecen estrellas grandes o papas en el cielo, y no siempre se ven redondas."},
	],
	"jezero_perseverance": [
		{"cat": "Aviación", "t": "El primer vuelo en otro planeta",
		 "x": "Ingenuity despegó el 19 de abril de 2021: 39 segundos y tres metros de altura. Fue el primer vuelo con motor en otro planeta y realizó 72 vuelos hasta 2024."},
		{"cat": "Ingeniería", "t": "Oxígeno de la nada",
		 "x": "El instrumento MOXIE de Perseverance fabricó oxígeno a partir del dióxido de carbono del aire marciano, unos 122 gramos en total. Es un ensayo para cohetes y astronautas del futuro."},
		{"cat": "Misión", "t": "Tubos de titanio",
		 "x": "Las muestras se guardan en tubos sellados de titanio. Algunos se dejaron en el suelo, en un \"depósito\", para poder recogerlos más adelante."},
	],
	"endeavour_opportunity": [
		{"cat": "Misión", "t": "Tres años de camino",
		 "x": "Opportunity tardó casi tres años y unos 21 km en llegar desde el cráter Victoria hasta el borde de Endeavour, que se veía a lo lejos como una cresta."},
		{"cat": "Geología", "t": "La veta Homestake",
		 "x": "Homestake es una veta de yeso de pocos centímetros de ancho. Se formó cuando agua rica en calcio corrió por una grieta y dejó un sulfato brillante."},
		{"cat": "Energía", "t": "El viento limpiapaneles",
		 "x": "A veces el viento o un remolino limpiaba el polvo de los paneles solares de Opportunity y le devolvía energía sin que nadie hiciera nada."},
	],
	"insight_elysium": [
		{"cat": "Instrumentos", "t": "Escuchando Marte",
		 "x": "InSight registró más de mil temblores. La mayoría eran pequeños, pero algunos eran lo bastante fuertes como para viajar por todo el planeta."},
		{"cat": "Meteoritos", "t": "Impactos que suenan",
		 "x": "El sismómetro oyó impactos de meteoritos. Algunos dejaron cráteres nuevos que la sonda MRO pudo fotografiar desde la órbita."},
		{"cat": "Misión", "t": "El topo que no pudo",
		 "x": "La sonda térmica de InSight, apodada «el topo», debía excavar cinco metros. El suelo se pegaba a su punta y no logró enterrarse."},
	],
}


const GENERALES := [
	{"cat": "Tiempo", "t": "Un día marciano",
	 "x": "Un día en Marte, llamado sol, dura 24 horas y 39 minutos. Los equipos de las misiones viven con la hora de Marte y su horario se desfasa cada día."},
	{"cat": "Física", "t": "Pesarías menos",
	 "x": "La gravedad de Marte es el 38 % de la terrestre. Una persona de 70 kg pesaría allí unos 27 kg y saltaría unas 2,6 veces más alto."},
	{"cat": "Atmósfera", "t": "Aire casi vacío",
	 "x": "La atmósfera de Marte es 95 % dióxido de carbono y su presión es menos del 1 % de la de la Tierra. Sin traje presurizado no se podría vivir."},
	{"cat": "Cielo", "t": "Atardeceres azules",
	 "x": "En la Tierra los atardeceres son rojos; en Marte, el polvo dispersa la luz y alrededor del Sol el cielo se ve azulado. De día el cielo es color caramelo."},
	{"cat": "Geografía", "t": "El volcán más alto",
	 "x": "Olympus Mons mide unos 22 km de altura, casi tres veces el Everest, y su base tiene unos 600 km de ancho. Es el volcán más grande conocido del sistema solar."},
	{"cat": "Geografía", "t": "El gran cañón",
	 "x": "Valles Marineris se extiende unos 4.000 km y alcanza unos 7 km de profundidad. El Gran Cañón de la Tierra cabría en él muchas veces."},
	{"cat": "Lunas", "t": "Miedo y Terror",
	 "x": "Marte tiene dos lunas pequeñas con forma de patata: Fobos y Deimos, nombres que significan miedo y terror. Fobos se acerca unos dos metros por siglo y dentro de decenas de millones de años se romperá."},
	{"cat": "Tiempo", "t": "Un año larguísimo",
	 "x": "Marte tarda 687 días terrestres en dar una vuelta al Sol, casi el doble que la Tierra, así que sus estaciones duran aproximadamente el doble."},
	{"cat": "Clima", "t": "Frío extremo",
	 "x": "La temperatura media es de unos −63 °C. En verano puede llegar a unos 20 °C a mediodía en el ecuador y en invierno polar bajar hasta unos −140 °C."},
	{"cat": "Geología", "t": "Por qué es rojo",
	 "x": "Su polvo contiene óxido de hierro, el mismo compuesto que el óxido de los clavos. Por eso Marte se ve rojizo hasta desde la Tierra."},
	{"cat": "Clima", "t": "Tormentas de polvo",
	 "x": "Algunas tormentas cubren todo el planeta durante semanas. Pero el aire es tan tenue que, aunque el viento sea veloz, apenas lo notarías como una brisa suave."},
	{"cat": "Sonido", "t": "Un planeta silencioso",
	 "x": "El micrófono de Perseverance registró que el sonido viaja más lento en Marte, unos 240 m/s frente a 343 en la Tierra, y que los tonos agudos viajan algo más rápido que los graves."},
	{"cat": "Comunicación", "t": "Retraso de radio",
	 "x": "Una señal de radio tarda entre 3 y 22 minutos en viajar entre la Tierra y Marte, según dónde esté cada planeta. Por eso los rovers toman solos muchas decisiones."},
	{"cat": "Atmósfera", "t": "Sin escudo magnético",
	 "x": "Hace unos 4.000 millones de años Marte perdió su campo magnético global y con él gran parte de su atmósfera. Hoy su superficie recibe más radiación que la de la Tierra."},
	{"cat": "Agua", "t": "Agua de ayer y de hoy",
	 "x": "Hay hielo de agua en los polos y bajo el suelo, y en el pasado hubo lagos y ríos. Hoy el agua líquida no puede mantenerse en la superficie porque la presión es demasiado baja."},
	{"cat": "Clima", "t": "Hielo seco",
	 "x": "En invierno, parte del dióxido de carbono del aire se congela sobre los polos como hielo seco y en verano vuelve a la atmósfera."},
	{"cat": "Clima", "t": "Torbellinos de polvo",
	 "x": "Los remolinos de polvo pueden medir varios kilómetros de alto. Algunos limpiaron por casualidad los paneles solares de Spirit y Opportunity."},
	{"cat": "Tamaño", "t": "Mitad de ancho, igual de tierra",
	 "x": "Marte mide unos 6.800 km de diámetro, algo más de la mitad que la Tierra. Pero como no tiene océanos, su superficie equivale más o menos a toda la tierra firme terrestre."},
]


static func relato(id: String) -> Dictionary:
	if RELATOS.has(id):
		return RELATOS[id]
	return {"intro": "", "cierre": ""}


static func curiosidades(id: String, n: int, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var propios: Array = CURIOSIDADES.get(id, [])
	var pool: Array = GENERALES.duplicate()
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Dictionary = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var res: Array[Dictionary] = []
	var ip := 0
	var ig := 0

	while res.size() < n and (ip < propios.size() or ig < pool.size()):
		var tocan_propios := res.size() % 2 == 0
		if tocan_propios and ip < propios.size():
			res.append(propios[ip])
			ip += 1
		elif ig < pool.size():
			res.append(pool[ig])
			ig += 1
		elif ip < propios.size():
			res.append(propios[ip])
			ip += 1
	return res
