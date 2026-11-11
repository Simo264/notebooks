#import "@preview/gentle-clues:1.3.1": *

= Roughness Using Microfacet Theory
So far we only considered the perfect specular case, where the interface between materials was assumed to be ideally smooth and devoid of any roughness or other surface imperfections. However, many real-world materials are rough at a microscopic scale, which affects the way in which they reflect or transmit light.

The *microfacet theory* models rough surfaces as a collection of small surface patches denoted as _microfacets_. These microfacets are assumed to be individually very small so that they cannot be resolved by the camera. They can have a profound impact on the angular distribution of scattered light. 

Microfacet surface models are often described by a function that gives the distribution of microfacet normals $omega_m$ with respect to the surface normal $n$. The greater the variation of microfacet normals, the rougher the surface is. Smooth surfaces have relatively little variation of microfacet normals.
#figure(image("figures/microfacet-model.png", width: 50%))

#question(title: "Why not use real geometry?")[
You could model roughness by making an extremely detailed mesh and treating every tiny triangle as a perfect mirror. But that has two major problems:
1. Storage and ray tracing: millions or billions of microscopic triangles would be needed.
2. Monte Carlo sampling: perfect specular BRDFs use Dirac delta distributions, so they cannot be evaluated at arbitrary directions so their distribution function is zero. This prevents useful light-sampling strategies

Microfacet theory solves both problems by treating the microgeometry statistically. It replaces infinitely sharp delta peaks with smooth distributions that can be sampled and evaluated efficiently.
]

#notify(title: "Masking, Shadowing and Interreflection")[
Several factors related to the geometry of the microfacets affect how they scatter light:
- _masking_: the microfacet of interest is not visible to the viewer due to occlusion by another microfacet
- _shadowing_: analogously, light does not reach the microfacet.
- _interreflection_: light bounces among the microfacets before reaching the viewer
#figure(image("figures/geometric_effects.png", width: 75%), caption: [(a) Masking (b) Shadowing (c) Interreflection])
]

== The Microfacet Distribution $D(omega_m)$
Microgeometry principally affects scattering via variation of the surface normal (which is a consequence of the central role of the surface normal in Snell’s law and the law of specular reflection). 

#idea(title: "The projected-area idea")[
Let us denote a small region of a macrosurface as $d A$. Above it is a bumpy microsurface with total area $d A_mu$. The key condition is:
$ upright(integral_(d A_mu) (omega_m (p) dot n) d p = d A) $
which means that perpendicular projection of the microsurface exactly covers the macrosurface, where $omega_m (p)$ specifies the microfacet normal at $p$.
]

The *Normal Distribution Function (NDF)* $D$ gives the relative differential area of microfacets with the surface normal $omega_m$:
- $D(omega_m) = 1$: all microscopic facets face that direction
- $D(omega_m) = 0.5$: half the microscopic facets face that direction
- $D(omega_m) = 0$: none microscopic facets face that direction

#info[
The microfacet distribution must satisfy:
$ upright(integral_(H^2(n)) D(omega_m) cos theta_m d omega_m = 1 ) $

Given a differential area on a surface $d A$, the microfacet normal distribution function $D(omega_m)$ must be normalized such that the projected surface area of the microfacets above the area is equal to $d A$.
#figure(image("figures/microfacet_distribution.png", width: 50%))
]

The most common type of microfacet distribution is *isotropic*: the local scattering behavior of an isotropic BSDF does not change when the surface is rotated about the macroscopic surface normal. Aspherical coordinate parameterization $omega_m = (theta_m, phi_m)$ yields a distribution that only depends on the $theta_m$ angle.

In contrast, an *anisotropic* microfacet distribution also depends on the azimuth $phi_m$ to capture directional variation in the surface roughness. Many real-world materials are anisotropic: for example, rolled or milled steel surfaces. Brushed metal is an extreme case: its microfacet distribution varies from almost a single direction to almost uniform over the hemisphere.

#memo(title: "GGX / Trowbridge–Reitz")[
Many functional representations of microfacet distributions have been proposed over the years. One of the most widely used distribution is *Trowbridge-Reitz (GGX)*. 

Its anisotropic form is:
$ upright( D(omega_m) = 1 / (pi alpha_x alpha_y cos^4 theta_m (1 + tan^2 theta_m ( (cos^2 phi_m)/(alpha_x^2) + (sin^2 phi_m)/(alpha_y^2) )))^2 ) $

- $alpha_x$ is roughness along one tangent direction
- $alpha_y$ is roughness along the perpendicular tangent direction
- $theta_m$ is tilt of the microfacet normal
- $phi_m$ is direction of that tilt around the surface
]

When $alpha_x, alpha_y approx 0$ the ellipsoid has been stretched to such a degree that it essentially collapses into a flat surface, and the aggregate BSDF approximates a perfect specular material. For larger values ($alpha_x, alpha_y approx 0.3$) the ellipsoidal bumps introduce significant normal variation that blurs the directional distribution of reflected and transmitted light. When $alpha_x=alpha_y$ the azimuth dependence drops out, and the model becomes isotropic.

#tip[$D(omega_m)$ is a statistical map of the microscopic slopes of a surface. Smooth surfaces concentrate their microfacet normals near the macrosurface normal; rough surfaces spread them out. GGX is one particular mathematical shape for that map.]

== The Masking Function $G$
A microfacet distribution $D$ alone is not enough to construct a valid energy-conserving BSDF. Microfacets may be masked because they are backfacing, or due to occlusion by other microfacets.

The *masking function* $G_1(omega,omega_m)$ specifies the fraction of microfacets with normal $omega_m$ that are visible from direction $omega$, so its value lies between 0 and 1.For example, a value of 0.6 means that 60% of the area with that orientation is visible, on average.
#underline[Without this visibility correction, the model can count hidden microfacets as contributing light and produce nonphysical energy gains.]

#info[A Normal Distribution Function $D(omega_m)$ tells you how many microfacets face toward a specific direction $omega_m$; the masking function $G_1(omega, omega_m)$ ​tells you how much of them you can actually see from a particular direction.
]

Previously, we learned that projecting the microsurface straight down onto the macrosurface gives the same area as the macrosurface patch. Now imagine looking from an oblique direction: a flat patch of area $d A$ appears smaller, with projected area $d A cos theta$. The visible microscopic surface must fill that same projected footprint, not more, because hidden facets do not add extra visible area. This gives the constraint:
$ upright(integral_(H^2(n)) D(omega_m) G_1(omega, omega_m) max(0,omega dot omega_m) d omega_m = omega dot n = cos theta) $
#figure(image("figures/masking_function.png", width: 50%))

Knowing the distribution of normals does not tell you exactly how the facets are arranged in space. Different arrangements can have the same $D$ but different visibility, so $D$ alone cannot uniquely determine the general masking function.

#idea(title: "Smith' approximation")[
If the height and normals of different points on the surface are assumed to be statistically independent, the masking factor for front-facing microfacets no longer depends on their individual normal $omega_m$. We can therefore use the simpler function $G_1(omega)$  and move it outside the integral.
This does not mean orientation becomes irrelevant: a facet must still face the viewing direction, which is enforced by $max(0,omega dot omega_m)$. The simplification concerns the statistical occlusion factor.
$ upright(G_1(omega) = integral_(H^2(n)) D(omega_m) max(0,omega dot omega_m) d omega_m = cos theta) $
becomes:
$ upright(G_1(omega) = (cos theta) / (integral_(H^2(n)) D(omega_m) max(0,omega dot omega_m) d omega_m)) $
]

For GGX, that integral has an analytic solution, conveniently expressed as:
$ upright(G_1(omega) &= 1/(1 + Lambda(omega))) \
Lambda(omega) &= (sqrt(1 + alpha^2 tan^2 theta) - 1)/2
$

here $theta$ is the viewing direction’s angle to the macrosurface normal; and $alpha$ denotes the isotropic surface roughness.
For anisotropic roughness, the amount of masking also depends on which direction around the surface you look from. The model computes an effective roughness using the viewing direction’s azimuth $phi$:
$ alpha = sqrt(alpha_x^2 cos^2 phi + alpha_y^2 sin^2 phi) $

#figure(image("figures/anisotropic_vs_isotropic.png", width: 50%), caption: [Spheres rendered with (left) an anisotropic microfacet distribution and (right) an isotropic distribution])

== The Masking-Shadowing Function
The BSDF is a function of two directional arguments, and each is subject to occlusion effects caused by the surface microstructure. For viewing and lighting directions, these are respectively denoted as masking (the facet is hidden from the viewer) and shadowing (the facet does not receive light). 
#idea[A facet must be both unmasked from the viewing direction and unshadowed from the lighting direction to contribute to the BSDF.]

To handle both cases, the masking function $G_1$ must be generalized into a *masking-shadowing function* $G$ that gives the fraction of microfacets in a differential area that are simultaneously visible from both directions $omega_o, omega_i$.

#question(title: "Why G1 is not enough?")[
$G_1(omega_o)$ gives the fraction visible from the viewer, while $G_1(omega_i)$ gives the fraction visible from the light. 

#underline[But a facet visible to the viewer may still be shadowed from the light, and vice versa.] The simplest assumption is that these two events are independent:
$ G(omega_o, omega_i) = G_1(omega_o) G_1(omega_i) $

This means: the probability of being visible to both is the product of the two individual visibility probabilities.
]

The independence assumption is too pessimistic. It imagines that a facet visible to the viewer and a facet visible to the light are unrelated events, but in reality they are correlated. A microfacet that is higher relative to the macrosurface is more likely to be visible from both directions. The independent product therefore removes too much energy, producing overly dark regions, especially at grazing angles.

#idea(title: "Smith height-correlated masking-shadowing function")[
We instead rely on an approximation that accounts for the property that a microfacet with a higher amount of elevation relative to the macrosurface is more likely to be observed from both $omega_i,omega_o$:
$ G(omega_o, omega_i) = 1/(1 + Lambda(omega_o) + Lambda(omega_i)) $
]

== Sampling the Distribution of Visible Normals
Instead of tracing rays against microscopic bumps, we sample a microfacet normal from the distribution of visible normals. 

#info(title: "Difference between NDF and VNDF")[
The Normal Distribution Function $D(omega_m)$ describes the normal distribution of microfacets. In other words, it tells us what percentage of normal vectors point in the direction of $omega_m$, but it does not account for visibility. 

The *Distribution of Visible Normals* $D_omega (omega_m)$ tells us, on the other hand, which normals we are most likely to encounter when looking at the surface from the direction $omega_m$.
]

Recall the normalization condition:
$ upright(integral_(H^2(n)) D(omega_m)G_1(omega)max(0,omega dot omega_m) = cos theta) $

Where the product:
$ D(omega_m)G_1(omega)max(0,omega dot omega_m) $
represents the contribution of the visible microfaces, weighted by their projected area. To obtain a probability distribution, we need to normalise it, so we divide by $cos theta$:
$ upright(D_omega (omega_m) = (G_1(omega) D(omega_m) max(0,omega dot omega_m))/(cos theta)) $

This distinction is very useful. Imagine you want to sample a normal microfacet to calculate a reflection. If we extract a normal using the NDF distribution, the microfacet we have just extracted may be occluded by another microfacet. With the VNDF distribution, on the other hand, we can be sure that that microfacet is visible.
This is an example of *importance sampling*.

#question(title: "What exactly are we trying to sample?")[
We want to sample the GGX Visible Normal Distribution Function (VNDF). We don't explicitly construct milions of tiny microfacets in our renderer. Instead, we use a statistical model to describe their distribution. Then VNDF is what we want to sample.

Suppose we have an incoming direction $omega_o$, what is the probability that a ray encounters a microfacet with normal $omega_m$?
That probability is described by the VNDF $D_omega(omega_m)$.
So, when we sample the VNDF, we are effectively choosing a microfacet normal according to its probability of being visible to the incoming ray.
#underline[We are not sampling a reflection direction directly]. We are sampling a microfacet normal, which we can subsequently use to calculate the reflected direction.
]

The GGX distribution is the normal distribution function (NDF) of an *ellipsoid*, i.e., it measures the density of a given normal orientation on the surface of the ellipsoid. 
Sampling the GGX distribution of visible normals (VNDF) is equivalent to sampling the projected area of an ellipsoid, which can be mapped to sampling the projected area of a hemisphere.
#figure(image("figures/ggx_ellipsoid.png", width: 50%))

The GGX distribution uses only the upper part of the ellipsoid; the ellipsoid is described by two scaling (or roughness) parameters $alpha_x, alpha_y$. The key observation is that sampling the GGX distribution can be done exactly by sampling the projected area of the associated ellipsoid.

#tip[
Imagine shining many parallel rays from direction $omega$ onto a microscopic GGX ellipsoid. Each ray that hits the ellipsoid lands at a point. If you collect all those hit points and their normals, the frequency of each normal is exactly the VNDF.

So, the statement "sampling the projected area" means: _choose a point on the ellipsoid in proportion to the area it presents toward the incoming rays; then take the normal at that point._
]

Anisotropic GGX is harder to sample directly. But there is a useful simplification: apply a linear transformation that stretches or squeezes space according $1/alpha_x,1/alpha_y$. In that transformed space, the anisotropic ellipsoid becomes a unit hemisphere. We sample a visible normal on that simple hemisphere. Finally, apply the inverse transformation to return the sample to the original anisotropic space.

#question(title: "Why transform an ellipsoid into a hemisphere?")[
For isotropic GGX with $alpha=1$ the associated ellipsoid becomes a unit hemisphere. In that special case, sampling the VNDF is exactly the same as sampling the projected area of a hemisphere. A hemisphere is easier to sample: pick a random point in a disk and project that point vertically onto the hemisphere. The resulting point’s coordinates are also its normal.

The anisotropic GGX ellipsoid is harder to sample directly. But a linear transformation can convert it into the simple unit-hemisphere case. The transformation stretches or squeezes space by $1/alpha_x, 1/alpha_y$. After this transformation, the anisotropic ellipsoid becomes a unit hemisphere. You sample the hemisphere using the simple method above. You apply the inverse transformation to get a normal in the original anisotropic GGX space.

#figure(image("figures/ellipsoid_hemisphere_ transformation.png", width: 50%))
]

== The Torrance–Sparrow Model
How conductors handle rough microstructures via a BRDF model due to Torrance and Sparrow. To describe the directional reflectance characteristics of a specularly reflecting rough surface, Torrance and Sparrow (1967) developed a bidirectional reflectance distribution function (BRDF) model based on geometrical optics.

#question(title: "What problem is Torrance–Sparrow trying to solve?")[
Imagine a perfectly smooth mirror. When light hits it, the reflection direction is completely deterministic:
$ omega_r = -omega_o + 2(omega_m dot omega_o)omega_m $
There is only one possible reflection direction. Now imagine that instead of a perfectly smooth mirror, we have a rough metallic surface.
#figure(image("figures/diagram_roughness.png"))
]

The model assumes that the rough surface is made of many tiny, individually smooth mirrors:
- each microfacet reflects like a perfect mirror, each has its own normal $omega_m$
- the distribution $D(omega_m)$ describes how many facets have each orientation
- Fresnel determines how much light each facet reflects
- masking/shadowing $G$ determines how much of each facet is actually visible.
#figure(image("figures/diagram_micro_vs_macro.png", width: 50%))

#question(title: "How can we mathematically describe the reflection produced by a collection of microscopic mirror-like surfaces with different orientations?")[By constructing a BRDF using geometrical optics and statistical distributions of microfacet orientations.]

The fundamental assumption: #underline[every microfacet is a tiny mirror]. This is the most important assumption of the model. Let's consider a single microfacet. We have:
- an incoming light direction $omega_i$
- an outgoing light direction $omega_o$
- a microfacet normal $omega_m$

#idea(title: "The half-vector idea")[
For the microfacet to reflect light from the incoming direction towards the viewer, it must satisfy the law of specular reflection. The microfacet normal must bisect the angle between the incoming and outgoing directions.
$ omega_m = "normalize"(omega_i + omega_o) $
This is the *halfway vector*.

#figure(image("figures/diagram_macrosurface.png", width: 50%))
]

Because once we know the incoming and outgoing directions, #underline[we know exactly which microfacet orientation could produce that reflection. We don't have to consider every possible microfacet normal.]

#question(title: "But how many microfacets have that orientation?")[
This is where the NDF comes in:
$ D(omega_m) $

It tells you how many tiny mirrors are oriented to support a given reflection.
]

However a microfacet might be hidden behind another microfacet. We therefore need to account for masking from the viewing direction:
$ G_1 (omega_m) $
As before, a microfacet might be visible from the viewer but shadowed from the light. We must account for both masking and shadowing:
$ G(omega_i, omega_o) = G_1(omega_i)G_1(omega_o) $

Finally, even if the microfacet receives light and reflects it towards us, the amount of reflected light depends on the material. This is described by the Fresnel term:
$ F(omega_i, omega_m) $

#memo(title: "The Torrance–Sparrow BRDF")[
$ f_r(p,omega_o,omega_i) = (D(omega_m)F(omega_i, omega_m)G(omega_i, omega_o))/(4 |cos theta_i| |cos theta_o|) $
]

#memo(title: "Torrance–Sparrow PDF")[
$ p(omega_i) = D_omega_o (omega_m) (d omega_m)/(d omega_i) = (D_omega_o (omega_m)) / (4(omega_o dot omega_m)) $

The single-sample Monte Carlo estimator:
$ L_o (p, omega_o) &= integral_(H^2(n)) f_r (p, omega_o, omega_i) L_i (p, omega_i) |cos theta_i| d omega_i \ 
&approx (f_r (p, omega_o, omega_i) L_i (p, omega_i) |cos theta_i|) / p(omega_i)
$
]

The sampling procedure follows the sequence of steps outlined at the beginning of this subsection. We must to find a microfacet orientation and reflects the outgoing direction about the microfacet’s normal to find $omega_i$ before evaluating the BRDF and density function.

A curious situation arises when the sampled microfacet normal leads to a computed direction that lies below the macroscopic surface. In a real microstructure, this would mean that light travels deeper into a crevice, to be scattered a second or third time.
For now, We only simulate a single interaction and thus mark such samples as invalid. This reveals one of the main flaws of the presented model: objects with significant roughness may appear too dark due to this lack of multiple scattering.

Visible normal sampling is still a relatively new development: for several decades, microfacet models relied on sampling $omega_i$ directly proportional to the microfacet distribution, which tends to produce noisier renderings.
