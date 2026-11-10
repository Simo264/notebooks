= Camera Coordinate Spaces
Before we start to describe the implementation of camera models, we will define some of the coordinate spaces that they use:
- _Object space_: local coordinates are the coordinates of your object relative to its local origin. Let's consider a simple cube created with Blender; the origin of your cube is probably at (0,0,0) even though your cube may end up at a different location in your final application. All the vertices of your model are therefore in local space, they are all local to your object. For example: (-0.5, 0.5, 0.0).
- _World space_: the coordinates of your object are transformed from local to world space. This is the standard frame that all other spaces are defined in terms of. 
- _Camera space_: we transform the world coordinates to view-space coordinates in such a way that each coordinate is as seen from the camera or viewer's point of view. A camera is placed in the scene at some world space point with a particular viewing direction and orientation. This camera defines a new coordinate system with its origin at the camera’s location.
- _Rendering space_: This is the coordinate system into which the scene is transformed for the purposes of rendering. It may be world space, camera space, or camera-world space.

Many ray tracers render in world space: they transform those rays from camera space to world space where ray intersection and shading calculations are performed. A problem with that approach stems from the fact that floating-point numbers have more precision close to the origin than far away from it. If the camera is placed far from the origin, there may be insufficient precision to accurately represent the part of the scene that it is looking at.

Rendering in camera space provides the most floating-point precision for the objects closest to the camera. You transform the entire scene with the complete view matrix (translation + rotation), so the camera is at the origin and looks along a fixed axis. The problem is that the AABBs in the scene are also rotated and become less effective, worsening acceleration performance.

Rendering using camera-world space gives the best of both worlds. Let's apply only a translation that moves the camera to the origin, without rotating the scene. This way, the camera is located at the origin, and the scene's AABBs remain aligned with the global axes.

= Projective Camera Models
One of the fundamental issues in 3D computer graphics is how to project a 3D scene onto a 2D image for display. The orthographic and perspective projections both require the specification of two planes: _near_ and _far_. When rasterization is used for rendering, objects that are not between those two planes are culled and not included in the final image. In a ray tracer, the projection matrices are used purely to determine rays leaving the camera.
Three more coordinate systems are useful:
- _Screen space_: is defined on the film plane. Although this is called “screen” space, it is still a 3D coordinate system since $z$ values are meaningful. The camera projects objects in camera space onto the film plane. Points at the near plane are mapped to depth $z=0$, and points at the far plane are mapped at $z=1$.
- _Normalized device coordinate (NDC) space_: this is the coordinate system for the actual image being rendered, where $x$ and $y$ range from (0,0) to (1,1) with (0,0) being the upper left corner of the image.
- _Raster space_: this is almost the same as NDC space, except the $x,y$ range from (0,0) to the resolution of the image.

#figure(
  image("figures/camera_projection.png", width: 50%), caption: [Objects in rendering space are viewed by the camera. Objects between the near and far planes are projected onto the film plane at $z=n$ in camera space. The film plane is at $z=0$ in raster space. NDC space normalize raster space so that $x$ and $y$ range from (0,0) to (1,1)]
)

The orthographic camera is based on *orthographic projection*, which takes a rectangular region of the scene and flattens it onto the front face of the parallelepiped that bounds it, without introducing any perspective effects. This transformation leaves the $x$ and $y$ coordinates unchanged and simply remaps the $z$ coordinate so that the near plane $n$ aligns with $z=0$, and the far plane $f$ with $z=1$. To achieve this, the scene is first translated along the $z$-axis so that the near plane coincides with $z=0$, and then a simple linear scaling is applied to $z$ to normalize the interval $[n, f]$ to $[0,1]$.

From the perspective of rays, orthographic projection generates a set of rays that are all parallel to one another: the direction is the same for every pixel (typically along the camera’s $+z$ viewing axis), while only the point of origin on the film plane changes, which corresponds to the pixel’s position in screen space.

#figure(image("figures/orthographic.png", width: 50%))

*Perspective projection*, on the other hand, introduces the effect of foreshortening: objects farther away appear smaller than objects of the same size that are closer to the camera. Unlike orthographic projection, this transformation preserves neither distances nor angles, and parallel lines in the 3D world do not remain parallel after projection; the lines converge toward vanishing points.

Mathematically, the perspective transformation projects points in camera space onto the near plane. The $x$ and $y$ coordinates of the projected point are obtained by dividing by the depth $z$:
$ x' = x/z #h(1cm) y' = y/z $

This division by $z$ is precisely what causes more distant objects to appear smaller. The projected depth coordinate $z'$ is then calculated so that points on the near plane lie at $z'=0$ and those on the far plane at $z'=1$:
$ z' = (f(z-n)) / (z(f-n)) $

All of this computation can be encoded in a $4 times 4$ matrix:
$
mat(
  1, 0, 0, 0;
  0, 1, 0, 0;
  0, 0, f/(f-n), -(f n)/(f-n) ;
  0, 0, 1, 0;
)
$

From the perspective of rays, in perspective projection all rays originate from the same point—namely, the optical center of the camera (the origin of the camera space)—but each has a different direction, determined by the position of the pixel on the film plane, creating the cone of view characteristic of perspective.
#figure(image("figures/ortho-persp.png", width: 50%))


You can calculate the cosine of the maximum allowed angle between the camera's viewing vector and a vector pointing toward one of the corners of the image; this value defines an approximate cone of visibility. Any direction that forms a larger angle can be considered outside the field of view and, in some contexts, quickly discarded without constructing the full radius.
#figure(image("figures/cos_of_persp_camera_max_view_angle.png", width: 50%), caption: [Computing the Cosine of the Perspective Camera’s Maximum View Angle. ])

= The Thin Lens Model and Depth of Field
In a real camera, light passes through an aperture of finite size (the diaphragm) and is focused by a lens system onto the film plane (sensor). Because of this finite aperture, the camera cannot perfectly focus on every point in the scene: it can focus precisely on only one plane, called the *focal plane* (or _plane of focus_).
Points lying on that plane are projected onto the film as ideal points; points located in front of or behind that plane, on the other hand, are projected as small, out-of-focus disks. This disk is precisely the *circle of confusion*.

To model this behavior, the _thin-lens approximation_ is often used: we imagine a single lens that collects rays parallel to the optical axis and causes them to converge at a single point, the *focal point*. The distance between the lens and this point is the *focal length* $f$. If the film plane is positioned exactly at a distance of $f$, then points at infinity (which arrive as parallel rays) are focused at a single point on the film.
#figure(image("figures/focal_length.png", width: 50%))

For objects at a finite distance $z$ from the lens, the relationship between the object–lens distance and the lens–image distance is given by the thin-lens equation (_Gaussian lens equation_):
$ 1/(z') - 1/z  = 1/f $

where $z$ is the distance of the object from the lens and $z'$ is the distance from the lens to the focal plane. As $z -> infinity$ we obtain $z' = f$ which corresponds to the case where points at infinity converge at the focal point.

When you want to focus the lens on a specific plane in the scene at a distance $z_f$, you use the same equation to calculate the distance $z'$:
$ z' = (f z) / (f+z) $

#figure(image("figures/focal_distance.png", width: 50%))

Focusing, therefore, means adjusting the distance between the lens and the film plane so that it coincides with this $z'$ for the desired depth of field. All points that lie exactly on that focal plane are projected as points onto the film; all others, which are closer or farther away, do not converge at a single point but form a small disk. The circle of confusion is the image of a point in the scene when that point does not lie on the focal plane. Its radius depends on three main factors: the diameter of the aperture (how large the lens is), the chosen focal length, and the distance of the object from the lens.

The radius of the circle of confusion is exactly zero only at a single depth; for a range of depths close to the focal depth, the radius is so small that the eye (or the sensor) cannot perceive any difference, and the object still appears in focus. This range of depths that appears acceptably sharp is what is called *depth of field*.

As the aperture diameter increases, the depth of field decreases, and out-of-focus objects become more noticeably blurred. Conversely, closing the aperture (smaller opening) increases the depth of field.
#figure(image("figures/circle_of_confusion.png", width: 50%), caption: [Cirlce of confusion])

In photography, instead of referring directly to diameter, the f-number $n$ is often used, which expresses the diameter of the aperture as a fraction of the focal length:
$ d= f/n $

For example, a 50mm lens with an aperture of 25 mm has an f-number of $n=2$ ($f/2$). At a given focal length, for example $z_f = 1m$, the blur is not symmetric with respect to the focal plane: it increases more rapidly for objects in front of the focal plane than for those behind it. This is a typical effect of real lenses and is reflected in the way the radius of the circle of confusion varies with depth.


To model a thin lens with depth of field, you need to change the way you generate the rays relative to the ideal camera.
In the ideal camera, each pixel corresponds to a single ray: the origin is fixed (the center of the lens) and the direction is determined by the pixel’s position. With a finite aperture, however, for each pixel we first sample a point on the lens disk (the aperture), and then construct a ray that starts from that point on the lens and passes through a specific point on the focal plane. All rays contributing to the same pixel must meet at the same point on that plane, so that objects lying there appear sharp, while those closer or farther away appear out of focus because their rays do not converge.

We start with the ray you would have generated using the ideal camera model for that pixel: this ray originates at the center of the lens and is directed toward the point on the film. We intersect the ray with the focal plane, and the point of intersection is exactly where the rays associated with that pixel converge. Once this point is found, the new ray for the sample on the lens:
- originates at the sampled point on the lens disk;
- is directed by the vector going from that point on the lens to the point of intersection on the focal plane

In this way, the ray always passes through the same point on the focal plane, ensuring that the focal plane is in focus.
#figure(image("figures/modelling_thin_lens.png", width: 50%))

The formula for the parameter $t$ of the intersection between the ray originating at the center of the lens and the focal plane is
$ t = f / d_z $

Two additional parameters are needed to model a perspective camera with depth of field:
+ the aperture diameter (or f-number)
+ the focal length $f$