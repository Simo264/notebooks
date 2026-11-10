= Spectral power distribution and color
A *spectral power distribution (SPD)* is a graph of the energy levels of a light source through a range of wavelengths of light. The spectral power distribution is the true fingerprint of a light source, as it is the key to how the light source renders colors.
#figure(
  image("figures/blackbody-spectral-curve.gif", width: 50%), caption: [The image shows the SPD of an ideal blackbody light radiator. The colored range represents its energy levels in the visible light spectrum.]
)

A spectral distribution is a purely physical concept, while color is closely connected to the physiology of the human visual system and the brain’s processing of visual stimulus. The bottom and middle SPDs in Figure are completely different yet are perceived as the exact same color (white).

Humans can distinguish about 10 million different colors. For *color perception*, the eye works by having three different types of cone receptors in the retina, with each type of receptor responding differently to various wavelengths. So, for a given SPD, our brain receives only three different signals from these receptors. This is why just three numbers can be used to precisely represent any color stimulus.

*Color-matching functions* are functions of wavelength that can be used to compute a tristimulus representation of a spectral distribution. What these functions give is a way to convert a spectral power distribution to three values. 

The spectral matching functions are three curves (functions), $m_1(lambda), m_2(lambda), m_3(lambda)$, that model this precise process. The idea is this: to get the first value $v_1$ take all the light in the spectrum $S(lambda)$ and weight each wavelength based on how much that specific wavelength $lambda$ contributes to the first chromatic response type. Then, you sum all of these contributions. This is equivalent to calculating the integral:
$ v_1 = integral_400^700 S(lambda) m_1(lambda) d lambda $

By repeating the process with $m_2$ and $m_3$, these three values ($v_1, v_2, v_3$) are the tristimulus representation of the perceived color for that spectrum. The fact that three numbers are enough derives directly from the physiology of the eye: the three types of cones have different spectral responses, so the brain receives only three aggregated signals. The matching functions are constructed in such a way to as to replicate, in mathematical terms, this compression from a continuos spectrum to three channels.

Finally, the matching functions define a color space, meaning that the three stimulus values form a three-dimensional vector space with two key properties: if you add two spectra together, their tristimulus values also add up; if you multiply a spectrum by a constant (for instance, doubling the light intensity), the three tristimulus values are multiplied by that same constant. 

#underline[Important]: two differents SPDs can produce exactly the same three values and thus be indistinguishable from the point of view of the color perceived by the model

== XYZ Color
Lo spazio CIE XYZ è costruito a partire da tre curve di matching standardizzate $tilde(x)(lambda), tilde(y)(lambda), tilde(z)(lambda)$ che permettono di trasformare qualsiasi distribuzione spettrale in tre coordinate X, Y, Z tramite integrazione del prodotto tra lo spettro e ciascuna curva:
#columns(3, gutter: 0pt)[
  $ X = integral_400^700 S(lambda) tilde(x)(lambda) d lambda $
  #colbreak()
  $ Y = integral_400^700 S(lambda) tilde(y)(lambda) d lambda $
  #colbreak()
  $ Z = integral_400^700 S(lambda) tilde(z)(lambda) d lambda $
]

#figure(
  image("figures/xyz_color_space.png", width: 50%), caption: [The XYZ Color Matching Curves.]
)

Quindi XYZ è semplicemente un particolare sistema di coordinate con cui rappresentare lo stimolo cromatico prodotto da uno spettro. 
Queste tre coordinate rappresentano il colore in modo _device-independent_, cioè senza legarlo alle caratteristiche di uno schermo specifico.

Dalle coordinate X,Y,Z è possibile separare la luminosità (legata soprattutto a Y) dalla cromaticità (chroma), che descrive “che colore è” rispetto al bianco; per quantificare la cromaticità si usano le coordinate normalizzate:
#columns(3, gutter: 0pt)[
  $ x = (X) / (X + Y + Z) $
  #colbreak()
  $ y = (Y) / (X + Y + Z) $
  #colbreak()
  $ z = 1-x-y $
]

Dato che $x+y+z=1$ è sufficiente conoscere $x, y$ due coordinate per determinare $z$.
#figure(
  image("figures/xyz_chroma.png", width: 50%), caption: [$x y$ Chromaticity Diagram. All valid colors lie inside the shaded region.]
)

== RGB Color
RGB, invece, è lo spazio più usato in rendering e grafica, ma a differenza di XYZ non ha un significato fisico di per sé: la tripla RGB ha senso solo rispetto a uno specifico spazio RGB, definito dalle curve spettrali di emissione dei suoi tre canali.
Per capire meglio pensiamo ad un monitor che mostra il colore RGB (0.6, 0.3, 0.2), in pratica stiamo dicendo di utilizzare una certa quantità della sua emissione rossa, una certa quantità della sua emissione verde e una certa quantità della sua emissione blu. La SPD $S(lambda)$ risultante sarà quindi:
$ S(lambda) = 0.6 E_R (lambda) + 0.3 E_G (lambda) + 0.2E_B (lambda) $

Il problema è che display diversi (LCD, LED, OLED, ecc.) hanno curve di emissione diverse e la stessa tripletta RGB produce spettri fisici diversi, di conseguenza colori percepiti diversi se non si tiene conto dello spazio RGB di riferimento.
#figure(
  image("figures/rgb_emission_curves.png", width: 50%), caption: [Red, Green, and Blue Emission Curves for an LCD Display and an LED Display. These two displays have quite different emission profiles.]
)

#figure(
  image("figures/Spectral_Distributions_from_Displaying_RGB.png", width: 50%), caption: [Spectral Distributions from Displaying the RGB Color (0.6, 0.3, 0.2) on LED (red) and LCD (blue) Displays. The resulting emitted distributions are remarkably different, even given the same RGB values, due to the different emission curves]
)

If a display’s $R(lambda), G(lambda), B(lambda)$ curves are known, the RGB coefficients for displaying a spectral distribution $S(lambda)$ on that display can be found by integrating $S(lambda)$ with each curve:
$ r = integral_400^700 R(lambda) S(lambda) d lambda $

and so forth. Alternatively, if we already have the $(x_lambda, y_lambda, z_lambda)$ representation of $S(lambda)$ it is possible to convert the XYZ coefficients directly to corresponding RGB coefficients. 

Per definire uno spazio colore non servono necessariamente le curve di risposta spettrale complete dei tre canali: basta specificare le coordinate di cromaticità $x,y$ dei tre primari (rosso, verde, blu) e il whitepoint, cioè il colore che il sistema considera “bianco”. Da queste informazioni si possono ricavare matrici di conversione tra XYZ e quello spazio RGB, perché XYZ funge da riferimento device-independent.
I tre primari determinano il *gamut* dello spazio, ossia l’insieme dei colori rappresentabili con valori RGB. Geometricamente, nel diagramma di cromaticità, il gamut è il triangolo i cui vertici sono le coordinate dei tre primari.
Il whitepoint è necessario perché il colore bianco non corrisponde ad uno spettro piatto a tutte le lunghezze d’onda: gli spettri che gli esseri umani considerano bianchi tendono ad avere più energia nelle lunghezze d’onda blu-verdi e meno nelle arancio-rosse. Standard diversi adottano whitepoint diversi.
#figure(
  image("figures/illuminant-D65.png", width: 50%), caption: [Plot of the CIE Standard D65 Illuminant Spectral Distribution as a Function of Wavelength in nm. This illuminant represents noontime daylight at European latitudes and is commonly used to define the whitepoint of color spaces]
)

== Standard Color Spaces
Gli spazi colore standard più usati sono scelti in base al compromesso tra compatibilità, gamma di colori rappresentabili e ambito di applicazione:
- sRGB è stato a lungo lo spazio dominante per monitor e web
- DCI-P3, which was developed for digital film projection and covers a wider gamut than sRGB.
- Rec2020, which covers an even wider gamut, and is used in the UHDTV television standard.
- ACES2065, which has primaries that are outside of the representable colors and are placed
so that all colors can be represented by it.
#figure(
  image("figures/gamut_color_spaces.png", width: 50%), caption: [The gamuts of the sRGB, DCI-P3, Rec2020, and ACES2065-1 color spaces]
)


== Why Spectral Rendering?
Because color spaces are vector spaces, addition of two colors in the same color space gives the same color as adding the underlying spectra and then finding the resulting spectrum’s color. That is not so for multiplication. La moltiplicazione componente per componente dei valori RGB non corrisponde in generale alla moltiplicazione delle SPD fisiche, e il risultato dipende fortemente dallo spazio colore. 

Quando in rendering si calcola la luce riflessa da una superficie, il modello fisico corretto è moltiplicare la SPD della luce incidente per la SPD di riflettanza del materiale:
$ L_o (lambda) = R(lambda) L_i (lambda) $

Se invece si lavora direttamente in RGB e si moltiplicano i valori (R,G,B), si sta facendo un’operazione algebrica comoda ma fisicamente sbagliata. Supponiamo di avere una superficie verde e una luce verde, RGB = (0, 1, 0). In sRGB, moltiplicare (0,1,0) per (0,1,0) dà ancora (0,1,0), quindi sembra che la riflettanza non cambi né intensità né saturazione. Se però utilizziamo uno spazio più ampio come ACES2065-1, il verde non è più (0, 1, 0) ma bensì sarà (0.38, 0.82, 0.12): 
$(0.38, 0.82, 0.12) * (0.38, 0.82, 0.12) = (0.14, 0.67, 0.01)$ 

Abbiamo ottenuto un colore più scuro e molto più saturo semplicemente perché abbiamo cambiato color space. Questo non dovrebbe succedere. Se una superficie e una luce hanno determinati spettri, il risultato fisico della loro interazione non dovrebbe dipendere dallo spazio colore scelto. Il motivo è che #underline[RGB non rappresenta direttamente lo spettro], moltiplicando due valori RGB non stiamo facendo la moltiplicazione degli spettri che avviene nella realtà. Nello spazio ACES diventa più scuro e più saturo perché la trasformazione da spettro a RGB ha compresso lo spettro in tre numeri, e la moltiplicazione di quei tre numeri non conserva le proprietà dello spettro originale.

Per questo motivo, per avere un risultato più fisicamente corretto pur producendo alla fine un’immagine RGB, si preferisce lavorare internamente con rappresentazioni spettrali (campioni di SPD). In questo modo prodotti tra luci e materiali sono fisicamente corretti e indipendenti da convenzioni di spazio colore, e solo al termine si converte in RGB per la visualizzazione. 