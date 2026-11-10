= Light Emission
The motion of atomic particles that hold electrical charges causes objects to emit electromagnetic radiation over a range of wavelengths. At room temperature most of the emission is at infrared frequencies; objects need to be much warmer to emit meaningful amounts of electromagnetic radiation at visible frequencies. 

Understanding some of the physical processes involved in emission is helpful for accurately modeling light sources for rendering:
+ Incandescent lamps have a small tungsten filament. The flow of electricity through the filament heats it, which in turn causes it to emit electromagnetic radiation with a distribution of wavelengths that depends on the filament’s temperature.
+ Halogen lamps also have a tungsten filament, but the enclosure around them is filled with halogen gas.
+ A gas discharge lamp consists of a transparent container that contains a gas that is excited by applying an electrical voltage. This voltage causes ionization of the gas resulting in the emission of light. The specific gas determines the color of the light emitted. For example, neon gas produces a red-orange light, while sodium vapor emits a yellow-orange light. Mercury vapor lamps produce a bluish light.
+ Electroluminescence is a characteristic of some materials, usually semiconductors, that emit light when exposed to a certain current or a sufficiently strong electric field. LED lights are based on electroluminescence: they use materials that emit photons due to the electric current passing through them.

For all of these sources, the underlying physical process is electrons colliding with atoms.

An atom consists of a nucleus made of protons (positive electrical charges) and neutrons (no electrical charge) and of electrons (negative electrical charges) that rotate around the nucleus at a great distance, bound by the attraction exerted on them by the protons. The quantum atom is made up of a central nucleus and several layers (energy levels) in which electrons orbit. The innermost energy level (level 1), closest to the nucleus, is the lowest one. The next energy level (level 2) has a higher amount of energy than the first, and so on up to the outermost layer. The outermost energy level is the highest in energy.
#figure(
  image("figures/livelli-energetici.png", width: 25%)
)

When an atom is struck by a beam of light (electromagnetic radiation), photons of light hit the atom's electrons. The collision between photons and electrons provides energy to the electron. In practice, upon impact, the electron absorbs the energy of the photon. Having gained more energy, the excited electron moves to a more external energy level of the atom (an outward energy jump).
#figure(
  image("figures/assorbimento-fotone.png", width: 50%)
)

Over time, the excited electron loses energy due to the attractive force of the atomic nucleus and moves back to an inner energy level (an inward energy jump). The inner energy level requires less energy than the previous one. Therefore, to stabilize on the new orbital, the electron must release the excess energy in the form of a *photon*.
#figure(
  image("figures/emissione-fotone.png", width: 50%)
)

== Black Body Emitters
A _Black Body_ is a theoretical construct describing an object that absorbs all electromagnetic radiation falling onto it. In turn, no light is reflected. Black bodies will not reflect or transmit light, only heat in proportion to their temperature.
The term _Black Body Radiation_ defines the relationship between the temperature of an object and the wavelength of electromagnetic radiation it emits. The quantity of radiation a blackbody will emit is determined by the object’s temperature. The waves cold objects emit have low frequencies, whereas hot objects emit waves with higher frequencies and visible light or ultraviolet.

_Emissivity_ is the ratio of the radiation emitted from an object to the radiation emitted from a blackbody when the temperatures and wavelengths are under the same viewing conditions. Emissivity is characterized as a number between zero and one. Zero represents a perfect reflector, whereas one represents a perfect emitter. Because black bodies are perfect emitters, they have an emissivity of one. 

Planck’s law gives the radiance emitted by a blackbody as a function of wavelength $lambda$  and temperature $T$ measured in kelvins:
$ L_e (lambda, T) = (2 h c^2) / (lambda^5 (e^((h c)/(lambda k_c T)) - 1)) $

where $c$ is the speed of light in the medium, $h$ is Planck’s constant and $k_b$ is the Boltzmann constant. Blackbody emitters are perfectly diffuse; they emit radiance equally in all
directions.
#figure(
  image("figures/blackbody-emitter.png", width: 50%),
  caption: [Note that as temperature increases, more of the emitted light is in the visible frequencies (roughly 380 nm–780 nm) and that the spectral distribution shifts from reddish colors to bluish colors. The total amount of emitted energy grows quickly as temperature increases]
)

The emission of non-blackbodies is described by Kirchhoff’s law: the emitted radiance distribution at any frequency is equal to the emission of a perfect blackbody at that frequency times the fraction of incident radiance at that frequency that is absorbed by the object. The fraction of radiance absorbed is equal to 1 minus the amount reflected, and so the emitted radiance is:
$ L_e ' (T, omega, lambda) = L_e (lambda, T) (1 - rho_(h d)(omega)) $

where $rho_(h d)(omega)$ is the hemispherical directional reflectance.

The Stefan–Boltzmann law gives the radiant exitance (the outgoing irradiance) at a point $upright(p)$ for a blackbody emitter:
$ M(upright(p)) = sigma T^4 $

where $sigma$ is the Stefan–Boltzmann constant. Note that doubling the temperature of a blackbody emitter increases the total energy emitted by a factor of 16.

The blackbody emission distribution provides a useful metric for describing the emission characteristics of non blackbody emitters through the notion of color temperature. If the shape of the emitted spectral distribution of an emitter is similar to the blackbody distribution at some temperature, then we can say that the emitter has the corresponding color temperature. 
Incandescent tungsten lamps are generally around 2700 K color temperature, and tungsten halogen lamps are around 3000 K. Generally speaking, color temperatures over 5000 K are described as “cool,” while 2700–3000 K is described as “warm.”