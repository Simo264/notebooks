= Radiometry
To precisely describe how light is represented and sampled to compute images, we must first establish some background in _radiometry_, the study of the propagation of electromagnetic radiation in an environment. There are four radiometric quantities that are central to rendering: flux, irradiance, intensity, and radiance. 

All of these radiometric quantities are in general _wavelength dependent_.
The variation of each is described by its _spectral distribution_ — a distribution function that gives the amount of light at each wavelength.
Of particular interest are the wavelengths ($lambda$) between approximately 380 nm and 780 nm, which account for light visible to humans.

While spectral distributions are a purely physical concept, color is related to how humans perceive spectra. 
It is important to have accurate models of color for two reasons: first, monitors expect colors rather than spectra to describe pixel values. 
Second, emission and reflection properties of objects in scenes are often specified using colors; these colors must be converted into spectra for use in rendering. 

Radiometry provides a set of ideas and mathematical tools to describe light propagation and reflection. It forms the basis of the derivation of the rendering algorithms.
There are four radiometric quantities that are central to rendering: flux, irradiance, intensity, and radiance.

== Energy
Energy is measured in joules $J$. Sources of illumination emit photons, each of which is at a particular wavelength and carries a particular amount of energy $Q$. A photon at wavelength $lambda$ carries energy: 

$ Q = (h c) / lambda $

Where $c$ is the speed of light and $h$ is Planck's constant. 

#figure(
  image("figures/Electromagnetic_spectrum.jpg", width: 70%),
  caption: [ 
    _The longer the wavelength is and the less the energy, the shorter it is and the more it carries energy. The wavelengths ($lambda$) between 380 nm and 780 nm is the visible spectrum._
    ],
)

== Flux (power)
In rendering, we almost never care how much energy is contained in a single photon. Instead, we are interested in knowing how much energy is passing at a certain moment. _Radiant flux_, also known as _power_, is the total amount of energy passing through a surface per unit time:

$ Phi = lim_(Delta t -> 0) (Delta Q) / (Delta t) $

Its units are Watts $W$ or Joule per second $J/s$. For example, if a light bulb emits $100W$ of radiant flux, it is emitting energy at a rate of $100J$ every second. 
Conversely, given flux $Phi$ as a function of time, we can integrate over a range of times to compute the total energy:

$ Q = integral_(t_0)^(t_1) Phi (t) d t $

Total emission from light sources is generally described in terms of flux $Phi$. Here, flux from a point light source is measured at spheres that surround the light.
#figure(
  image("figures/radiant-flux.svg", width: 30%),
  caption: [ 
    _Radiant flux $Phi$ measures energy passing through a surface or region of space. Here, flux from a point light source is measured at spheres that surround the light._
    ],
)

== Irradiance and Radiant Exitance
Any measurement of flux requires an area over which photons per time is being measured. Given a finite area $A$, we can define the average density of power over the area by:

$ E = Phi / A $

This quantity is irradiance $E$, the area density of flux arriving at a surface. 

A sphere of radius $r$ has area:

$ A = 4 pi r^2 $

If the point source is emitting the same amount of illumination in all directions, then for a sphere in this configuration that has radius $r$:

$ E = Phi / (4 pi r^2) $

#figure(
  image("figures/Inverse_square_law.png", width: 30%),
  caption: [ 
    _If you double the distance $r -> 2r$ the area of the sphere becomes $4A$. So the same flux is spread over four times the area. This fact explains why the amount of energy received from a light at a point falls off with the squared distance from the light._
    ],
)

In general, however, we can have any surface and we want to know how much light reaches a particular point $upright(p)$. At that point we consider an infinitesimal area $A$ around $upright(p)$:

$ E(p) = lim_(A -> 0) (Delta Phi ( upright(p) )) / (Delta A) $

We can also do the reverse reasoning. If we know the irradiance $E(upright(p))$ at every point on a surface, we can add up all the light arriving on the entire surface:

$ Phi = integral_A E(upright(p)) d A $

The irradiance equation can also help us understand the origin of Lambert’s law, which says that the amount of light energy arriving at a surface is proportional to the cosine of the angle between the light direction and the surface normal. 

#figure(
  image("figures/lambert-law.svg", width: 30%),
  caption: [ 
    _Irradiance arriving at a surface varies according to the cosine of the angle of incidence of illumination, since illumination is over a larger area at larger incident angles._
    ],
)

Consider a light source with area $A$ and flux $Phi$ that is illuminating a surface. Irradiance at any point inside $A_1$ is 

$ E_1 = Phi / A $

If the light is at an angle to the surface, the area on the surface receiving light is larger. For points inside $A_2$ the irradiance is:

$ E_2 = ( Phi cos theta ) / A $

where $theta$ is the angle between the normal $upright(n)$ and the direction towards the light.

== Intensity
Consider now an infinitesimal light source emitting photons. If we center this light source within the unit sphere, the light starts from the point and is uniformly distributed in all directions.
Instead of asking "_How much total light does the lamp emit?_", we ask ourselves "_How much light is it emitting in this particular direction?_"
Intensity $I$ is this quantity, while the radiant flux $Phi$ tells us how much light power is emitted overall. For light emitting uniformly in all directions, the total flux is distributed over the entire sphere of directions, which has solid angles $4 pi$

$ I = Phi / (4 pi) $

So, for example, if a point light emits 100W uniformly:

$ I = 100 / (4 pi) = 7.9 W / (s r) $

It means that the power density per unit of direction is 7.9. Where $s r$ means _steradian_, that is, the unit used to measure angles in space.

The general formula is:

$ I = lim_(Delta omega -> 0) (Delta Phi) / (Delta omega) $

We can integrate over a finite set of directions $Omega$ to recover the power:

$ Phi = integral_(Omega) I(omega) d omega $ 

Intensity describes the directional distribution of light, but it is only meaningful for point light sources.

== Radiance
The most important radiometric quantity is radiance $L$. Irradiance $E$ give us overall power that arrives at point $upright(p)$, but they do not distinguish the directional distribution of power. We also want to know where that light is coming from. Radiance $L$ also maintains directional information, it measures irradiance with respect to solid angles $omega$:

$ L(upright(p), omega) = lim_(Delta omega -> 0) (Delta E_omega (upright(p))) / (Delta omega) $

we have used $E_omega (upright(p))$ to denote irradiance at the surface that is perpendicular to the direction $omega$. Radiance is the flux density per unit area, per unit solid angle.
In terms of flux, it is defined by:

$ L = (upright(d)^2 Phi) / (upright(d)omega upright(d) A^perp ) $

where $upright(d) A^perp$ is is the projected area of $upright(d) A$ perpendicular to $omega$.

#figure(
  image("figures/radiance.svg", width: 30%),
  caption: [ 
    _Radiance $L$ is defined as flux per unit solid angle $upright(d)omega$ per unit projected area $upright(d) A^perp$._
    ],
)

== Incident and Exitant Radiance Functions
When light interacts with surfaces, we make a a distinction between radiance arriving at the point
(e.g., due to illumination from a light source) and radiance leaving that point (e.g., due to reflection
from a surface). 

Consider a point $upright(p)$ on the surface of an object. There is some distribution of radiance arriving at the point that can be described mathematically by a function of position and direction. This function is denoted by $L_i (upright(p), omega)$. The function that describes the outgoing reflected radiance from the surface at that point is denoted by $L_o(upright(p), omega)$.
The direction vector $omega$ is oriented to point away from $upright(p)$.

#figure(
  image("figures/radiance_functions.svg", width: 50%),
  caption: [ 
    _(a) $L_i (upright(p), omega)$ describes the distribution of radiance arriving at a point as a function of position and direction. (b) $L_o (upright(p), omega)$ gives the distribution of radiance leaving the point. For both functions, $omega$ is oriented to point away from the surface._
    ],
)

#pagebreak()

= Working with Radiometric Integrals
A frequent task in rendering is the evaluation of integrals of radiometric quantities. We will present some tricks that can make it easier to do this. Irradiance at a point $upright(p)$ with surface normal $upright(bold(n))$ due to radiance over a set of directions $Omega$ is:
$ E(upright(p), upright(bold(n))) = integral_Omega L_i (upright(p), omega)|cos theta|d omega $

where $L_i$ is the incident radiance and $theta$ is measured as the angle between $omega$ and surface normal $upright(bold(n))$

#figure(
  image("figures/irradiance-4.5.png", width: 50%),
  caption: [ 
    _Irradiance at a point $upright(p)$ is given by the integral of radiance times the cosine of the incident direction over the entire upper hemisphere above the point._
    ],
)

== Integrals over Spherical Coordinates
It is often convenient to transform integrals over solid angle into integrals over spherical coordinates $(theta, phi.alt)$. We need to be able to express the relationship between the differential area of a set of directions $d omega$ and the differential area of a $(theta, phi.alt)$ pair.
The differential area on the unit sphere: 
$ d omega = sin theta d theta d phi.alt $

#figure(
  image("figures/differential-area.png", width: 50%), 
  caption: [ 
    _The differential area $d omega$ subtended by a differential solid angle is the product of the differential lengths of the two edges $sin theta d phi.alt$ and $d theta$_
    ],
)

We can thus see that the irradiance integral over the hemisphere can equivalently be written as:
$ E(upright(p), upright(bold(n))) = integral_0^(2pi) integral_0^(pi/2) L_i (upright(p), theta, phi.alt) cos theta sin theta d theta d phi.alt $

If the radiance is the same from all directions, the equation simplifies to $E = pi L_i$.

== Integrals over Area
Consider the irradiance integral:

$ E(upright(p), upright(bold(n))) = integral_Omega L_i (upright(p), omega)|cos theta|d omega $

and imagine there is a quadrilateral with constant outgoing radiance and that we could like to compute the resulting irradiance at a point $upright(p)$. Computing this value as an integral over directions $omega$ is in general not
straightforward, since given a particular direction it is nontrivial to determine if the quadrilateral is visible in that direction.  It is much easier to compute the irradiance as an integral over the area of the quadrilateral. Differential area $d A$ on a surface is related to differential solid angle as viewed from a point $upright(p)$ by:
$ d omega = (d A cos theta) / (r^2) $

where $theta$ is the angle between the surface normal of $d A$ and the vector to $upright(p)$, and $r$ is the distance from $upright(p)$ to $d A$

#figure(
  image("figures/differential-solid-angle.png", width: 50%), 
  caption: [ 
    _The differential solid angle $d omega$ subtended by a differential area $d A$_
    ],
)

We can write the irradiance integral for the quadrilateral source as:
$ E(upright(p), upright(bold(n))) = integral_A L cos theta_i (cos theta_o d A) / (r^2) $

where $L$ is the emitted radiance from the surface of the quadrilateral, $theta_i$ is the angle between the surface normal at $upright(p)$ and the direction from $upright(p)$ to the point $upright(p')$ on the light, and $theta_o$ is the angle between the surface normal at $upright(p')$ on the light and the direction from $upright(p')$ to $upright(p)$

#figure(
  image("figures/irradiance-from-quadrilateral-source.png", width: 50%), 
  caption: [ 
    _To compute irradiance at a point $upright(p)$ from a quadrilateral source, it is easier to integrate over the surface area of the source than to integrate over the irregular set of directions that it subtends_
    ],
)

