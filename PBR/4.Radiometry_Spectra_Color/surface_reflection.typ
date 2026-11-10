#import "@preview/gentle-clues:1.3.1": *

= Surface Reflection
When light is incident on a surface, the surface scatters the light, reflecting some of it back into the environment. There are two main effects that need to be described to model this reflection: the spectral distribution of the reflected light and its directional distribution.

The *bidirectional reflectance distribution function (BRDF)* gives a formalism for describing reflection from a surface.
We would like to know how much radiance is leaving the surface in the direction $omega_o$ toward the viewer $L_o (upright(p), omega_o)$ as a result of incident radiance along the direction $omega_i$, $L_i (upright(p), omega_i)$.

#figure(image("figures/brdf.png", width: 50%))

The BRDF is a 4D function that describes how much incident light along $omega_i$ is scattered from the surface in the direction $omega_o$.

If the direction $omega_i$ is considered as a differential cone of directions, the differential irradiance at $upright(p)$ is:

$ d E(upright(p), omega_i) = L_i (upright(p), omega_i) |cos theta_i| d omega_i $

The constant of proportionality defines the surface’s BRDF $f_r$ for the particular pair of directions:
$ f_r (upright(p), omega_o, omega_i) = (d L_o (upright(p), omega_o) ) / (L_i (upright(p), omega_i) cos theta_i d omega_i) $.

Physically based BRDFs have two important qualities:
1. $f_r (upright(p), omega_o, omega_i) = f_r (upright(p), omega_i, omega_o)$
2. Energy conservation: the total energy of light reflected is less than or equal to the energy of incident light

Two quantities that are based on the BRDF will occasionally be useful. First, the hemispherical directional reflectance is a 2D function that gives the total reflection in a given direction due to constant illumination over the hemisphere, or, equivalently, the total reflection over the hemisphere due to light from a given direction:
$  rho_(h d) (omega_o) = integral_(upright(H^2 (n))) f_r (upright(p), omega_o, omega_i) |cos theta_i| d omega_i $

The hemispherical-hemispherical reflectance of a BRDF, denoted by $rho_(h h)$ gives the fraction of incident light reflected by a surface when the incident light is the same from all directions.

A surface’s *bidirectional transmittance distribution function (BTDF)*, which describes the distribution of transmitted light, can be defined in a manner similar to that for the BRDF. The BTDF is generally denoted by $f_t$. The BTDF does not obey reciprocity as defined above.

We can combine both behaviors into a single function called the *Bidirectional Scattering Distribution Function (BSDF)*. The BSDF $f$ therefore describes the overall scattering behavior of the surface, encompassing both reflection and transmission. Conceptually:
$ f = f_r + f_t $

The general relationship becomes:
$ d L_o (upright(p), omega_o) = f(upright(p), omega_o, omega_i) L_i (upright(p), omega_i) |cos theta_i| d omega_i $

#memo(title: "Rendering Equation")[
A surface does not receive light from just one direction. It can receive light simultaneously from many directions. To obtain the total outgoing radiance towards $omega_o$ we must sum the contributions coming from all incident directions:
$ L_o (upright(p), omega_o) = integral_(S^2) f(upright(p), omega_o, omega_i) L_i (upright(p), omega_i) |cos theta_i| d omega_i $

where $S^2$ represents the sphere of possible directions around the point $upright(p)$.

]

The *Bidirectional Scattering Surface Reflectance Distribution Function (BSSRDF)* - describes scattering from materials that exhibit subsurface light transport. It is a distribution function $S(upright(p_o), omega_o, upright(p_i) omega_i)$ that describes the ratio of exitant radiance at point $upright(p_o)$ in direction $omega_o$ to the incident flux at $upright(p_i)$ from direction $omega_i$:
$ S(upright(p_o), omega_o, upright(p_i) omega_i) = (d L_o (upright(p_o), omega_o)) / (d Phi (upright(p_i), omega_i) $

#figure(
  image("figures/bssrdf.png", width: 50%),
  caption: [ _The BSSRDF generalizes the BSDF to account for light that exits the surface at a point other than where it enters._]
)

The generalization of the scattering equation for the BSSRDF requires integration over surface area and incoming direction:
$ L_o (upright(p_o), omega_o) = integral_A integral_(H^2(upright(bold(n)))) S(upright(p_o), omega_o, upright(p_i) omega_i) L_i (upright(p_i) omega_i) cos theta_i d omega_i d A $


As the distance between points $upright(p_i)$ and $upright(p_o)$ increases, the value of $S$ generally diminishes