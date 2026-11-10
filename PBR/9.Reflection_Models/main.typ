#import "@preview/gentle-clues:1.3.1": *

We now introduce basic terminology for describing reflection from surfaces. To compare the resulting visual appearance, we will classify reflection into the following four broad categories: _diffuse_, _glossy specular_, _perfect specular_, and _retroreflective_.
Diffuse surfaces scatter light equally in all directions (Although a perfectly diffuse surface is not physically realizable). 
Glossy specular surfaces such as plastic or high-gloss paint scatter light preferentially in a set of reflected directions, they show blurry reflections of other objects. 
Perfect specular surfaces scatter incident light in a single outgoing direction. Mirrors and glass are examples of perfect specular surfaces.
#figure(image("figures/reflections.png", width: 75%), caption: [(a) diffuse, (b) glossy specular, (c) nearly perfect specular, and (d) retroreflective distributions.])

Reflection computations are performed in a shading coordinate system. The *shading coordinate system* is defined by the orthonormal basis vectors $upright(bold((s,t,n)))$. We will orient these vectors such that they lie along the $x,y,z$ axes in this coordinate system. Direction vectors $omega$ are transformed into the shading coordinate system before any of the BRDF or BTDF methods are called. In contrast, rendering algorithms operate in rendering space. hence a transformation between these two spaces must be performed somewhere.
#figure(image("figures/BSDF_Coordinate_Setting.png", width: 50%))

#pagebreak()

= Diffuse (Lambertian) Reflection
One of the simplest BRDFs is the Lambertian model, which describes a perfect diffuse surface that scatters incident illumination equally in all directions. 
#figure(image("figures/perfect_diffuse_reflection.jpg", width: 50%))

#info(title: "The Reflection Distribution Function BRDF")[
Recall what BRDF means: if light arrives from direction $omega_i$, the reflection distribution function gives us how much of light is reflected toward direction $omega_o$.

For a Lambertian surface, the answer is the same for every outgoing direction in the upper hemisphere:
$ f_r (p, omega_i, omega_o) = R/pi $
]

So a matte white wall reflects light in all directions equally. That is why its appearance does not strongly depend on the viewing direction.
$R$ is the surface’s reflectance: the fraction of incoming light energy it reflects:
- $R=0$: perfectly black surface
- $R=1$: perfectly white surface
- $R=0.8$: reflects 80% of incoming light.

The BRDF cannot simply be $R$, because the BRDF is integrated over the hemisphere with a cosine factor. Recall the _reflection equation_:
$ L_o(p, omega_o) = integral_(upright(H^2(n))) f_r (p, omega_i, omega_o) L_i(p, omega_i) |cos theta_i| d omega_i $

For a constant BRDF $c$, the integral is:
$ integral_(upright(H^2(n))) c cos theta d omega = c pi $

To make the total reflected energy equal $R$, we need:
$ R = c pi #h(0.5cm) -> #h(0.5cm) c = R/pi $

#info(title: "The role of PDF")[
The PDF is not a property of the surface. It is a property of the renderer’s random sampling procedure. 

If I generate a random output direction $omega_i$, the PDF tells me how likely that direction is to be chosen. For a Lambertian BSDF, a better approach is tu uses *cosine-weighted hemisphere sampling*:
$ p (omega) = (cos theta) / pi $

where $theta$ is the angle between the sampled direction and the surface normal. So directions near the normal are sampled more often than directions near the horizon. Let's see:
- $theta=0$ above the surface, so $p (omega) = 1 / pi$
- $theta=pi/2$ at the horizon, so $p (omega) = 0 / pi=0$
]

With uniform sampling, the PDF $p(omega) = 1 / (2 pi)$. Every direction on the hemisphere is equally likely. This is simple, but many samples land near the horizon, where $cos theta$  is small and the contribution is weak. Those samples are less useful. 
Instead, with cosine-weighted sampling, more samples go near the normal, where the cosine factor is large. Fewer samples go near the horizon, where the cosine factor is small, reducing the MSE.

#pagebreak()

= Specular Reflection and Transmission
A specular material reflects light in a small, well-defined set of directions rather than scattering it everywhere. A perfect mirror is the extreme case: light coming from one direction leaves in exactly one reflected direction.

When light strikes a material, it excites electrons in the material, and the material responds by re-emitting waves. Depending on the material and wavelength, the net result is that some light is:
1. *Reflection*: some energy leaves the surface
2. *Transmission*: the wave continues propagating through the material at a different speed and direction.
3. *Absorption*: the material converts some energy into heat

The large class of _dielectrics_ includes any substance (whether gaseous, liquid, or solid) including glass, water, mineral oil, and air. In such materials, the oscillating electrons are firmly bound to their atoms.
The second class of electric _conductors_ includes metals, metal alloys, and semi-metals like graphite. Some of the electrons can freely move within their atomic lattice. At the same time, migration through the lattice dissipates some of the incident energy in the form of heat, causing rapid absorption of the light wave as it travels deeper into the material.
A third class of _semiconductors_, such as silicon or germanium, exhibits properties of both dielectrics and conductors.

#info(title: "Index Of Refraction")[
The *index of refraction (IOR) $eta$* measures how much slower light travels inside a material compared with vacuum. For example, if a material has IOR 2, light travels through it at half its vacuum speed:
$ eta = c / v $
where $c$ is the speed of light in vacuum, and $v$ is its speed in the material.

#table(
  columns: 2,
  table.header([Medium], [Index of refraction $eta$]),
  [Vacuum], [1\.0],
  [Air at sea level], [1\.00029],
  [Ice], [1\.31],
  [Water (C)], [1\.333],
  [Fused quartz], [1\.46],
  [Glass], [1\.5--1.6],
  [Sapphire], [1\.77],
  [Diamond], [2\.42],
)
]

We can see a transparent object such as glass mainly because its IOR differs from the surrounding air. Some light reflects and some changes direction as it enters the material. A larger jump in IOR generally produces stronger reflection:
- Air to glass: IOR changes from 1.0 to about 1.5.
- Air to diamond: IOR changes from 1.0 to 2.42.
That is one reason diamond has such a bright, sparkly appearance: its boundary reflects a relatively large fraction of incoming light.

IOR applies to opaque materials too, including metals. For those materials, a complex refractive index is used:
$ tilde(n) = n + i k $

where the imaginary part $k$ describes absorption: how quickly the wave dies out inside the material. For metals, $k$ is large which means that the Light penetrates only an extremely short distance before being absorbed, which is why metals look opaque. Their surfaces can still reflect strongly. A material’s IOR can also vary with wavelength; this is why dispersion can split white light into colors.

#memo(title: "The Law of Specular Reflection")[
Given incident light from a direction $(theta_i, phi_i)$, the single reflected direction $(theta_r, phi_r)$ following an interaction with a perfect specular surface is easy to characterize: it makes the same angle with the normal as the incoming direction and is rotated around it by 180°:
$ theta_r = theta_i #h(1cm) phi_r = phi_i + pi $
]

== The Snell's Law
At a specular interface, incident light with direction $(theta_i, phi_i)$ about the surface normal refracts into a single transmitted direction $(theta_r, phi_r)$ located on the opposite side of the interface. 

#info[
Imagine light traveling from air into glass. At the boundary, it changes direction. Snell’s law gives the new direction:
$ eta_i sin theta_i = eta_t sin theta_t $
]

Here, $theta_i$ is the angle between the incoming ray and the surface normal; $theta_t$ is the angle between the transmitted ray and the normal on the other side; $eta_i$ and $eta_t$ are the IORs of the two materials.

The Snell's law technically does not depend on the precise values of $eta_i, eta_t$ but rather on their ratio. The law can be rewritten as:
$ sin theta_i = eta sin theta_t $ 
where
$ eta = eta_t / eta_i $
This $eta$ is called the *relative IOR*. It compares the two materials directly, rather than requiring their absolute IOR values.

#question(title: "Which way does it bend?")[
If light goes from a low-IOR material into a higher-IOR material, such as air into glass:
$ eta_t > eta_i $

then, the transmitted ray bends toward the normal. Intuitively, light slows down in the denser optical medium, so its path changes direction.
#figure(image("figures/refraction-of-light-in-water.webp", width: 50%))

If light goes the other way, such as glass into air, then:
$ eta_t < eta_i $
The transmitted ray bends away from the normal.
]

When light travels from a denser material to a less dense one, such as glass to air, there is a limit. If the incoming angle is too large, no transmitted ray is possible. This is *total internal reflection*. All of the light is reflected back inside the denser material. It occurs when:
$ theta_i > theta_c $
where the _critical angle_ is:
$ theta_c = sin^(-1) (1 / eta) $

#figure(image("figures/Total-Internal-Reflection.webp", width: 50%))

== The Fresnel Equations
Snell’s law tells you the transmitted direction, but not how much energy goes there. Light is normally both reflected and transmitted at the boundary between two materials with a different index of refraction, though the transmission rapidly decays in the case of conductors.

#memo(title: "Fresnel Reflectance")[
At a glass surface, for example, some light reflects and most transmits. The Fresnel equations calculate the reflected fraction, called the *Fresnel reflectance*.
$ F_r = 1/2 (r^2_parallel + r^2_bot) $

Where:
$ r_parallel = (eta cos theta_i - cos theta_t)/(eta cos theta_i + cos theta_t), 
#h(1cm)
r_bot = (cos theta_i - eta cos theta_t)/(cos theta_i + eta cos theta_t)
$
]

$F_r$ is simply the fraction of incoming light energy that is reflected:
- $F_r = 0$: no reflection
- $F_r = 1$: complete reflection
- $F_r = 0.04$: 4% of the light is reflected; the remaining 96% is transmitted (ignoring absorption).

The Fresnel reflectance depends strongly on the incoming angle:
- looking straight at glass: the reflection is low, around 4%
- looking at glass at a shallow angle: reflection increases sharply
- at grazing angles: almost everything reflects

For dielectrics such as glass and water, the IOR is usually treated as a real number. For conductors such as metals, the IOR becomes a *complex number*:
$ tilde(eta) = eta - i k $
where $eta$ is the usual refractive part, controlling phase velocity and refraction; and $k$ the absorption coefficient, controlling how rapidly light decays inside the material. 

In a metal, $k$ is large: light penetrates only a tiny distance before being absorbed, so metals are effectively opaque. #underline[But the complex IOR still strongly affects the reflected light], which is why gold, silver, copper, and aluminum have different colors and reflection behavior.

#info[The same Fresnel equations work for dielectrics, conductors, and semiconductors. For metals, you simply plug in complex numbers instead of ordinary real numbers.]

#pagebreak()
#include "conductors.typ"
#pagebreak()
#include "dielectrics.typ"
#pagebreak()
#include "microfacet_theory.typ"