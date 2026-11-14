#import "@preview/gentle-clues:1.3.1": *

= Dielectric BSDF
A dielectric, such as glass or water, has two possible outcomes for a ray hitting its smooth surface: specular reflection and transmission.
Therefore, the full scattering function is a BSDF which includes both BRDF and BTDF.

For a smooth dielectric, each component is a delta distribution: there is exactly one reflected direction and exactly one refracted direction, rather than a range of directions.

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
We will now extend the microfacet to the case of rough dielectrics: rough glass, water, plastic, and similar translucent materials. 

A rough dielectric is made of tiny, smooth surfaces. Each tiny surface can either reflect light or refract it. The challenge is to determine which tiny surface interacts with the light, which event occurs, and how likely the resulting direction is.

#notify[The microfacet itself is still assumed to be perfectly smooth. Its roughness comes from the fact that the surface is made of many microfacets with different orientations.]

For reflection we use the half-vector:
$ omega_m = "normalize"(omega_i+omega_o) $

For transmission, the incoming and outgoing directions are related by Snell's law instead:
$ eta_o sin theta_o = eta_i sin theta_i #h(1cm) phi_o = phi_i + pi $

Unlike reflection, the two directions $omega_i, omega_o$ are not symmetric: the refractive indices affect their relationship. The generalized half-vector accounts for this:
$ omega_m = (eta_i omega_i + eta_o omega_o)/(|| eta_i omega_i + eta_o omega_o ||) = (eta omega_i + eta_o omega_o)/(||eta omega_i + eta_o omega_o||) $

We can interpret this as: _given an incoming and an outgoing direction, this vector tells us which microfacet orientation could have produced the transmission between them_.

This half-vector has a particular orientation: it points toward the denser medium. However, we want all microfacet normals to follow a consistent orientation relative to the macroscopic surface normal. In local coordinates, the macroscopic normal is $n=(0,0,1)$, therefore $omega_m dot n > 0$

The microfacet distribution $D$, the masking-shadowing function $G$ and the sampling routines all rely on a consistent normal orientation:
$ omega_m = "sign"(omega_m dot n > 0)omega_m $

For example, if $omega_m dot n > 0$ we keep it, otherwise if $omega_m dot n < 0$ we reverse it.

After reconstructing $omega_m$, the renderer checks whether the microfacet is consistent with both directions. For reflection, both directions are on the same side of the interface, so both must face the microfacet:
$ omega_i dot omega_m > 0 #h(1cm) omega_o dot omega_m > 0 $

For transmission, the directions are on opposite sides of the interface. This rejects microfacets that could not physically connect the two given directions.

Once we have a valid microfacet normal, we can calculate the Fresnel reflectance. Fresnel tells us how much light is reflected and how much is transmitted at a smooth dielectric interface:
$ P("reflection")=F #h(1cm) P("transmission")=1-F $
There is also an important exception: total internal reflection. In that case: $F=1$.

Finally we must calculate the PDF. Remember that VNDF sampling does not directly generate an incoming direction $omega_i$, instead it generates a microfacet normal: 
$ omega_m &approx D_omega_o (omega_m) \ 
p(omega_m) &= D_omega_o (omega_m)
$
We need the probability of sampling the direction $omega_i$ and not the normal $omega_m$. 

#question(title: "How do we calculate the PDF?")[
For reflection:
$ p_("reflection")(omega_i) = D_omega_o (omega_m) 1 / (4 |omega_o dot omega_m|) R/(R+T) $

For transmission:
$ p_("transmit")(omega_i) = D_omega_o (omega_m) (|omega_i dot omega_m|)/((omega_i dot omega_m) + ((omega_o dot omega_m)/eta))^2 T/(R+T) $
] 

BSDF evaluation is similarly split into reflective and transmissive components.
#info(title: "Rough Dielectric BSDF")[
The reflection component (BRDF) follows the approach used for conductors:
$ f_r (p, omega_o, omega_i) = (D(omega_m) F(omega_o dot omega_m)G(omega_i, omega_o))/(4 cos theta_i cos theta_o) $
  
The BTDF:
$ f_t (p, omega_o, omega_i) = (D(omega_m) (1-F(omega_o dot omega_m))G(omega_i, omega_o)) / ((omega_i dot omega_m) + ((omega_o dot omega_m)/eta))^2 (|omega_i dot omega_m| |omega_o dot omega_m|) / (|cos theta_i| |cos theta_o|) $
]

Sampling proceeds by drawing a microfacet normal from the visible normal distribution VNDF, computing the Fresnel term, and stochastically selecting between reflection and transmission.

Handling of the reflection component is straightforward and mostly matches the case for conductors except for extra factors that arise due to the discrete choice between reflection and transmission components.

The transmission case invokes refract() to determine $omega_i$

