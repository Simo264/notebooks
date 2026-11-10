#import "@preview/gentle-clues:1.3.1": *

= Conductor BRDF
We initially focus on the smooth case, a polished metal surface and later generalize the implementation to rough interfaces using the Microfacet Theory.

For a perfectly smooth conductor, such as polished metal, light does not scatter in many directions. Every incoming ray has exactly one reflected direction, and Fresnel determines how much energy goes there. The rest enters the metal and is absorbed almost immediately.

#idea(title: "The physical model")[
A conductor has two behaviors at its surface:
- specular reflection: the ray leaves in the mirror direction
- absorption: whatever is not reflected enters the metal and rapidly becomes heat.

For rendering, we usually do not trace the tiny penetration depth into the metal. We simply say: the reflected portion is $F_r$, and the rest is absorbed.
]

The Fresnel reflectance $F_r$ depends on the angle between the ray and the surface normal. For a perfect mirror reflection, the incoming and outgoing rays make the same angle with the normal:
$ theta_r = theta_o $

Therefore:
$ F_r (omega_r) = F_r (omega_o) $

So the Fresnel factor can be evaluated using either direction.

#question(title: "Why Dirac delta?")[
A *Dirac delta distribution* represents something concentrated at exactly one point, with infinite height but finite total area.

For a perfect mirror, the BRDF must be zero for almost every incident direction and nonzero only at the exact mirror direction. That is precisely what a delta distribution represents:
$ delta (omega_i - omega_r) $

It means: “the only incident direction that contributes is $omega_r$, the mirror-reflected direction.
]

The correct BRDF is:
$ f_r (upright(p), omega_o, omega_i) = (F_r (omega_r) delta (omega_i - omega_r)) / (|cos theta_r|) $

For a smooth conductor, the renderer does not randomly choose among many directions. It deterministically computes the one mirror direction:
$ w_i = "Reflect"(omega_o, n) $

In the shading coordinate system, the surface normal $n$ is (0,0,1). Therefore reflection only requires negating the $x,y$ components. The $z$ component stays the same because the ray remains on the same side of the surface.

For a smooth specular BRDF the probability of randomly choosing the exact mirror direction from a continuous set of directions is zero. This is why delta BRDFs need special handling: you cannot evaluate them at arbitrary directions; you must sample their peak directly.

#question(title: "Why the PDF is 1?")[
For a delta-distribution BRDF, the PDF is set to 1. This is a convention, not a literal probability density in the usual continuous sense. The sampled direction is deterministic, so the renderer does not need to divide by a PDF in the ordinary Monte Carlo way.
]

== The Fresnel Equations for Conductors
Characterizing the reflection behavior of conductors involves an additional twist: the IOR turns into a complex number!
For a dielectric, the IOR is usually a real number:
$ eta $
For a conductor, it is written:
$ eta - i k $

Its real component $eta$ describes the decrease in the speed of light. The newly added imaginary component $k$ models the decay of light as it travels deeper into the material. This decay occurs so rapidly that it also has a significant effect on the reflection component.
A larger $k>0$ means the light dies out over a shorter distance. For metals, this decay is extremely fast.

#underline[So the complex IOR is a compact mathematical way to represent two physical effects at once: propagation and absorption.] 

#question(title: "Why absorption affects reflection? If I only care about reflected light, why does absorption inside the metal matter?")[
The answer is that reflection is not just a geometric bounce. It emerges from the material’s electromagnetic response: electrons in the metal move in response to the incoming wave and re-emit waves. How strongly and with what phase they respond depends on both $eta$ and $k$.
]

Therefore, even though almost no light survives inside a metal, the absorption coefficient $k$ strongly changes the amount and color of the reflected light. This is why gold, copper, silver, and aluminum have visibly different colors.

#idea(title: "Same Fresnel equations")[
The Fresnel formulas retain the same form:
$ F_r = 1/2 (r^2_parallel + r^2_bot) $

Where:
$ r_parallel = (eta cos theta_i - cos theta_t)/(eta cos theta_i + cos theta_t), 
#h(1cm)
r_bot = (cos theta_i - eta cos theta_t)/(cos theta_i + eta cos theta_t)
$

The only major change is that $eta, cos theta_t,r_parallel,r_bot$ may now be complex numbers. The renderer then computes the squared magnitude of each complex amplitude:
$ |r^2| = ("real" r)^2 + ("im" r)^2 $

This gives the reflected power for each polarization component. Averaging the two squared magnitudes gives the unpolarized Fresnel reflectance.
]

For conductors, the relative IOR is still a ratio: 
$ eta = (tilde(eta_t) / eta_i) $
But because $tilde(eta_t)$ is complex, the result is generally complex too. The incident medium’s IOR, often air, is usually real; the metal’s IOR is complex.

For example, if light travels from air into gold:
$ eta = (tilde(eta)_"gold" / eta_("air")) $
since $eta_("air") approx 1$, the relative IOR is approximately the gold IOR itself.

#question(title: "Why metals have color?")[
The complex IOR varies with wavelength. Therefore $F_r$ also varies with wavelength. For example, gold reflects red and yellow wavelengths strongly, while absorbing more blue light.
This wavelength dependence is why metals cannot be accurately represented by a single scalar reflectance value; they need spectral IOR
]