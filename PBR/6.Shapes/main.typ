#underline[For many operations, it is useful to have a 3D _bounding volume_ that encloses an object. For example, if a ray does not pass through a particular bounding volume, we can avoid processing all the objects inside of it for that ray. *Axis-aligned bounding boxes* are a convenient bounding volume, as they require only six floating-point values to store. ]

= Ray–Bounds Intersections
Instead of treating the bounding box as a complex object, we can think of it more simply as the intersection of three sides (slabs) aligned with the axes: one for $x$, one for $y$, and one for $z$. For example, for the planes along $x$, we will have one side at $x_{min}$ and the other at $x_{max}$.

The ray has a typical interval of $[0, infinity]$, which represents the portion of the ray that interests you. For each axis, we must have two points of intersection and therefore two values of $t$. These two values define an interval $[t_0, t_1]$.
#figure(image("figures/intersecting_ray_AABB.png", width: 50%))

Calculating the two $t$ values for each side is straightforward because the planes are axis-aligned. The general equation of a plane in three dimensions is:
$ a x + b y + c z + d = 0 $

where $d$ represents the distance from the origin.

Suppose we want to find the intersection of two planes lying on the $x$-axis, one at $x_0$ and the other at $x_1$. To find the intersection with the first plane, we must solve:
$ 1 x + 0 + 0 - x_0 = 0 $

To find the point where the ray $o + t d$ intersects this line means to solve the equation:
$ 1(o_x + t_0 d_x) + 0 + 0 -x_0 &= 0 \ o_x + t_0 d_x &= x_0 \ t_0 d_x &= x_0 - o_x \ t_0 &= (x_0 - o_x) / (d_x) $

For the plane at $x_1$, we calculate $t_1$ in the same way:
$ t_1 = (x_1 - o_x) / (d_x) $

The same reasoning applies to planes along the $y$ and $z$ axes. For each axis, the interval during which the ray is inside that slab is $[t_0, t_1]$. If we end up with a NON-empty interval, it means that the ray completely intersects the box. The key optimization lies precisely in the fact that the boxes are aligned with the axes, allowing us to consider only the $x$-component, only the $y$-component, and only the $z$-component.

= Spheres
Many surfaces can be described in one of two main ways: in _implicit form_ and in _parametric form_. An implicit function describes a 3D surface as:
$ f(x,y,z) = 0 $

The set of all points $(x,y,z)$  that fulfill this condition defines the surface. If a sphere is centered at the origin with radius $r$, its implicit representation is
$ x^2 + y^2 + z^2 -r^2 = 0 $

For a unit sphere at the origin, the familiar implicit equation is $x^2 + y^2 + z^2 - 1 = 0$. Only the set of points one unit from the origin satisfies this constraint, giving the unit sphere’s surface.

Many surfaces can also be described parametrically using a function to map 2D points to 3D points on the surface. A complete sphere can be described by two angles:  $theta in [0, pi]$ (from the North to the South), and $phi in [0, 2pi]$ (a full rotation around the $z$-axis).
The 3D coordinates of a point on the sphere are:
$ x &= r sin theta cos phi \ y &= r sin theta sin phi \ z &= r cos theta $ 
#figure(image("figures/sphere_shape.png", width: 50%))

For texture mapping, it is convenient to work with normalized coordinates $(u,v)$ in $[0,1]^2$. We therefore define:
$ phi &= u phi_max \ theta &= theta_min + v(theta_max - theta_min) $

If you want a complete sphere, set: $phi_max = 2pi, theta_max = pi, theta_min = 0$
#figure(image("figures/two_spheres.png", width: 50%))

== Ray-sphere intersection
The equation for a sphere of radius $r$ that is centered at the origin is an important mathematical equation:
$ x^2 + y^2 + z^2 = r^2 $

You can also think of this as saying that if a given point $(x,y,z)$ is on the surface of the sphere, then $x^2 + y^2 + z^2 = r^2$. If a given point $(x,y,z)$ is inside the sphere, then $x^2 + y^2 + z^2 < r^2$, and if a given point $(x,y,z)$ is outside the sphere, then $x^2 + y^2 + z^2 > r^2$.

If we want to allow the sphere center to be at an arbitrary point $C = (C_x, C_y, C_z)$ then the equation becomes:
$ upright( (C_x - x)^2 + (C_y - y)^2 + (C_z - z)^2 = r^2) $

The vector from point $upright(P)$ to center $upright(C)$ is: $upright((C-P))$. 
The norm of a vector $v$ is defined as $||v|| = sqrt(v dot v)$, and therefore:
$ upright(||(C-P)|| = sqrt((C-P) dot (C-P)) ) = r $.

Instead of working with the square root, which is computationally expensive, we square both sides:
$ upright( || C-P||^2 = (C-P) dot (C-P) = r^2 ) $

which becomes:
$ upright((C - P) dot (C - P) = (C_x - x)^2 + (C_y - y)^2 + (C_z - z)^2 = r^2) $ 

A ray is parameterized as:
$ upright( P(t) = o + t d ) $

and we want to find a value of $t$ such that the radius touches the sphere:
$ upright( ||C-P(t)||^2 &= r^2  \ (C - (o + t d)) dot (C - (o + t d)) &= r^2 ) $

Expanding on these terms, we arrive at:
$ upright(t^2 (d dot d) - 2 t (d dot (C-o)) + (C-o) dot (C-o) - r^2) = 0 $

This equation is quadratic. You can solve for a quadratic equation $a x^2 + b x + c = 0$ by using the quadratic formula:
$ upright(t = (-b plus.minus sqrt(b^2 -4a c)) / (2a)) $

where:
$ upright( a &= d dot d \ b &= -2d dot (C-o) \ c &= (C-o) dot (C-o) - r^2 ) $

The square root part can be either positive (meaning two real solutions), negative (meaning no real solutions), or zero (meaning one real solution)

#figure(image("figures/ray-sphere-intersection-results.png", width: 50%))

For a sphere, the outward *normal* is in the direction of the hit point minus the center:
#figure(image("figures/sphere_normals.png", width: 50%))

#pagebreak()

= Plane
A plane is characterized by a center point $p_0$, indicating its distance from the world's origin, and a normal $n$, which defines the plane's orientation. We can derive a vector on the plane from any point $p$ on it by subtracting $p_0$. Since this resultant vector lies within the plane, it is perpendicular to the plane's normal.
Leveraging the property that the dot product of two perpendicular vectors equals:
$ (p - p_0) dot n = 0 $

This implies we can pinpoint any position along the ray using the ray's origin, its direction, and the scalar $t$, a positive real number signifying the parametric distance from the ray's origin to the point of interest. If the ray intersects the plane, they share a point $p$ at the intersection:
$ p &= o + d t space -> space (o + d t - p_0) dot n &= 0 $

Solving for we obtain:
$ t = ((p_0 - l_0) dot n) / (l dot n) $

#figure(image("figures/plane.png", width: 25%))

#pagebreak()

= Disk
Typically, a disk is defined by its position $p_0$ (the center of the disk), a normal $n$, and a radius $r$. 
The initial step involves checking if the ray intersects the plane where the disk resides. For this ray-plane intersection phase, we can employ the code developed for the ray-plane intersection test. If there's an intersection with the plane, the next step is to calculate the intersection point and measure the distance from this point to the disk's center.

The ray intersects the disk if this distance is less than or equal to the disk's radius. As an optimization, instead of directly calculating the distance, you can compare the square of the distance against the square of the disk's radius. This squared distance can be derived from the dot product of vector with itself. for efficiency, we can compare the dot product result directly against the square of the radius, thereby avoiding the costly square root operation.

#figure(image("figures/disk.png", width: 25%))


#pagebreak()

= Triangle mesh
The triangle is one of the most commonly used shapes in computer graphics; complex scenes may be modeled using millions of triangles to achieve great detail.

While a natural representation would be to have a _Triangle_ shape implementation where each triangle stores the informations of its three vertices, a more memory-efficient representation is to separately store entire triangle meshes with an array of vertices where each individual triangle just stores three offsets into this array for its three vertices.

In addition to the mesh vertex positions and vertex indices, per-vertex normals $upright(bold(n))$, tangent vectors $upright(bold(s))$, and texture coordinates $upright(bold(u v))$ may be provided. 

Different TriangleMeshes could potentially point to the same arrays in memory in the case that they were both given the same values for some. This offers capabilities for object instancing, where multiple copies of the same geometry can be placed in the scene with different transformation matrices. 

The Buffer class handles the details of storing a single unique copy of each buffer provided to it.

Unlike the other shapes that leave the shape description in object space and then transform incoming rays from rendering space to object space, triangle meshes transform the shape into rendering space and thus save the work of transforming incoming rays into object space and the work of transforming the intersection’s geometric representation out to rendering space.

Because complex scenes may have billions of triangles, it is important to minimize the amount of memory that each triangle uses. We can store references to all the TriangleMeshes for the scene in a vector, which allows each triangle to be represented using just two integers: one to record which mesh it is a part of and another to record which triangle in the mesh it represents. With 4-byte int s, each Triangle uses just 8 bytes of memory.

== Ray–triangle intersection
A 3D ray has an origin $o$ and a direction $d$, whilst a triangle has three vertices at arbitrary positions. Testing directly whether they intersect is complex and prone to errors. The idea behind the algorithm is to reverse the perspective: if I adopt the ray’s reference frame, how does the triangle appear to me? I can assume that the ray starts at the point $(0,0)$ and extends in the $+z$ direction; this is therefore equivalent to checking whether a point lies inside the triangle. This is much easier to verify.

There are three steps to computing the transformation from rendering space to the ray–triangle intersection coordinate space:
1. The translation that places the ray origin at the origin of the coordinate system is:
$ upright(bold(T)) = mat(1,0,0,-o_x; 0,1,0,-o_y; 0,0,1,-o_z; 0,0,0,1) $
We will apply this transformation to the three triangle vertices.
2. The three dimensions of the space are permuted:
$ upright(bold(P)) = mat(0,1,0,0; 0,0,1,0; 1,0,0,0; 0,0,0,1) $
3. Finally, a shear transformation aligns the ray direction with the $+z$:
$ upright(bold(S)) = mat(1,0, -d_x/d_z, 0; 0,1, -d_y/d_z,0; 0,0, 1/d_z, 0; 0,0,0,1) $

Rather than computing explicit transformation matrices for each of these and then computing an aggregate transformation matrix $upright(bold(M = S P T))$.

Note that the calculations for the coordinate permutation and the shear coefficients only depend on the given ray; they are independent of the triangle. In a high-performance ray tracer, it may be worthwhile to compute these values once and store them in the Ray class, rather than recomputing them for each triangle the ray is intersected with.

Once we have the triangle in 2D space with vertices $p_0, p_1, p_2$, we need to check whether the point $(0,0)$ lies inside it or not. 
#figure(image("figures/ray_triangle_intersection.png", width: 50%))

The method used is that of *edge functions*. For each side of the triangle, define a function $e(p)$ which, given a point $p$, returns a value whose sign indicates on which side of the line $p$ lies:
$ e(p) = (p_1_x - p_0_x)(p_y - p_0_y) - (p_x - p_0_x)(p_1_y - p_0_y) $
#figure(image("figures/edge_function.png", width: 50%))

The area of a triangle with two edges given by vectors $v_1$ and $v_2$ is one-half of the area of the parallelogram shown here. The parallelogram area is given by the length of the cross product of $v_1$ and $v_2$.
#figure(image("figures/area_of_triangle.png", width: 50%))

A point lies inside the triangle only if it lies on the same side as all three sides; this means that the three edge functions evaluated at $p$ all have the same sign.

Thanks to the coordinate system transformation, the point $p$ that we are testing has coordinates $(0,0)$. This simplifies the edge function expressions. For example, for the edge $e_0$ from $p_1, p_2$:
$ e_o (p) = p_1_x p_2_y - p_2_x p_1_y $

Given the values of the three edge functions, we have our first two opportunities to determine that there is no intersection: 
1. if the signs of the edge function values differ, then the point is not on the same side of all three edges and therefore is outside the triangle; 
2. if the sum of the three edge function values is zero, then the ray is approaching the triangle edge-on, and we report no intersection.

== Barycentric coordinates
A 2D triangle with vertices $a, b, c$ can be used to set up a nonorthogonal coordinate system with origin a and basis vectors $(b-a)$ and $(c-a)$. A point is then represented by an ordered pair $(beta, gamma)$, with the constraint:
$ beta + gamma = 1 $

The coordinate origin is $a$ and the vectors from $a$ to $b$ and $c$ are the basis vectors. ith that origin and those basis vectors, any point $p$ can be written as:
$ p = a + beta(b-a) + gamma(c-a) $
#figure(image("figures/barycentric_coordinates.png", width: 50%))

The barycentric coordinates of the intersection point in the triangle can be used to interpolate them across the triangle. They are given by dividing each edge function value by the sum of edge function values:
$ b_i = e_i / (e_0 + e_1 + e_2) $

To find the parameter $t$ of the point of intersection along the radius, you could first calculate the terms $b_i$ and then interpolate $z$:
$ z = b_0 z_0 + b_1 z_1 + b_2 z_2 $

But there is a cleverer way. Since the ray points in the $+z$ direction starting from $z=0$, the value of $t$ is directly related to the $z$-coordinate. Instead of carrying out the division straight away, we can first calculate the weighted sum:
$ z = e_0 z_0 + e_1 z_1 + e_2 z_2 $

and then note that $t = z / d$. You can check the sign: if $d$ and $z$ have opposite signs, then $t$ will be negative and you can discard it straight away without wasting a division. Only if the signs are the same should you proceed to calculate $t$ and $b_i$.

To generate consistent *tangent vectors* over triangle meshes, it is necessary to compute the partial derivatives $(partial p) / (partial u), (partial p) / (partial v)$ using the parametric $(u,v)$ values at the triangle vertices, if provided.

The geometric normal is the actual normal of the triangle; it is unique to each triangle, does not depend on the point of contact, and is calculated as the normalised vector product of the two sides:
$ n = ((P_2 - P_0) times (P_1 - P_0)) / (|| (P_2 - P_0) times (P_1 - P_0) ||) $