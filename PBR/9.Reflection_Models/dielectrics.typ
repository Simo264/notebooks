#import "@preview/gentle-clues:1.3.1": *

= Dielectric BSDF
A dielectric, such as glass or water, has two possible outcomes for a ray hitting its smooth surface: specular reflection and transmission.
Therefore, the full scattering function is a BSDF which includes both BRDF and BTDF.

#info[For a smooth dielectric, each component is a delta distribution: there is exactly one reflected direction and exactly one refracted direction, rather than a range of directions.]

An interface is *index-matched* when the IOR is the same on both sides: $eta=1$. In that case, there is no optical boundary; all light is transmitted and continues in the same direction.

#idea[For a smooth interface, the BSDF uses delta distributions. For a rough interface, it uses the microfacet model instead.]

At each interaction, the renderer must choose one path between reflect the ray or refract it. It could choose each with probability 0.5, but that is inefficient. Fresnel says the true energy split is:
$ R = F_r #h(1cm) T = 1 - F_r $

So the correct probability is:
$ P("Reflect") = R #h(1cm) P("Transmit") = 1 - F_r $

This is called *sampling proportional to contribution*.

#question(title: "Why this reduces noise?")[
If you used a 50/50 choice, many rays would enter the weaker component. For example, if reflection is only 8%, half of your samples would follow the weak reflection path. Those samples contribute little, so they increase image noise.

With _Fresnel-based sampling_, weak components receive fewer paths. The renderer spends its limited samples where they are more likely to matter.
]

For reflection, the reflected direction is simply the mirror direction:
$ omega_i = (-omega_o_x, omega_o_y, omega_o_z) $
The returned BRDF value is:
$ f_r = R/(|cos theta_r|) $
The returned sampling probability is:
$ p("reflect")= R/(R+T) $
When both reflection and transmission are allowed, $R+T=1$,  so this is simply $R$.

For transmission, the refracted direction $omega_i$ is given by applying the Snell's law:
$ eta_i sin theta_i = eta_t sin theta_t $
The returned BTDF value is:
$ f_t = T/(|cos theta_t|) $
The returned probability is:
$ p("transmit")= T/(R+T) $
When both branches are allowed, this is simply $T$.

For a smooth dielectric, the distribution function is zero. This is because a delta BSDF cannot be evaluated at an arbitrary direction. The probability of randomly choosing the exact reflected or refracted direction from a continuous domain is zero. Likewise, the PDF method returns zero for a smooth interface.

#question(title: "Why transmission needs an extra correction?")[
Refraction changes the angular spread of light. Radiance is energy per unit solid angle. Therefore, if the solid angle changes, the radiance must be rescaled to conserve energy:
$ L_o = L_i (eta_o^2) / (eta_i^2) $
So, when transporting radiance across a refractive boundary:
$ f_t = f_t / sqrt(eta_p) $
This does not create or destroy energy. It accounts for the fact that the same power is distributed over a different solid angle after refraction.
]

Total internal reflection occurs when light tries to leave a higher-IOR medium at too large an angle, such as glass to air. In that case, Snell’s law has no valid refracted solution. The Fresnel transmittance $T$ becomes zero at and beyond the critical angle. Therefore, the sampler should choose reflection with probability 1 and transmission with probability 0.

== Rough Dielectric BSDF
We will now extend the microfacet to the case of rough dielectrics. So it models rough glass, water, plastic, and similar translucent materials. The key difference from a rough conductor is that each microfacet uses Snell’s law, not just mirror reflection.

A rough dielectric has many microscopic interfaces with different normals. Therefore, reflection becomes a blurry lobe around the mirror direction, and transmission becomes a blurry lobe around the refracted direction. The rough dielectric BSDF describes both blurred lobes statistically







We first start with the density evaluation:
- Evaluate sampling PDF of rough dielectric BSDF
- compute generalized half vector $omega_m$
- discard backfacing microfactes
- determine Fresnel reflactance
- compute probabilities density for sampling reflection and transmission

We now turn to the generalized half-direction vector whose discussion requires a closer look at Snell’s law:
$ eta_o sin theta_o = eta_i sin theta_i #h(1cm) phi_o = phi_i + pi $

Since the refraction takes place at the level of the microgeometry, all of these angles are to be understood within a coordinate frame aligned with the microfacet normal $omega_m$. A generalized half-direction vector:
$ omega_m = (eta_i omega_i + eta_o omega_o)/(| eta_i omega_i + eta_o omega_o |) = (eta omega_i + eta_o omega_o)/(|eta omega_i + eta_o omega_o|) $

$omega_m$ always points toward the denser medium, whereas pbrt uses the convention that micro and macro normal are consistently oriented, $omega_m dot n > 0$. In practice, we therefore compute the following modified half-direction vector, where $n = (0,0,1)$ in local coordinates:
$ omega_m = "sign"(omega_m dot n > 0)omega_m $

Next, microfacets that are backfacing with respect to either the incident or outgoing direction do not contribute and must be discarded.
Given $omega_m$ we can evaluate the Fresnel reflection and transmission terms using the specialized dielectric evaluation of the Fresnel equations.

We now have the values necessary to compute the PDF for $omega_i$ which depends on whether it reflects or transmits at the surface.
$ p(omega_i) = D_omega_o (omega_m) = (d omega_m)/(d omega_i) = (D_omega_o (omega_m)|omega_o dot omega_m|)/((omega_i dot omega_m) + ((omega_o dot omega_m)/eta))^2 $
