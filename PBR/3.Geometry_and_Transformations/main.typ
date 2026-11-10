= Coordinate Systems
A coordinate system that defines the origin of the space and gives three linearly independent vectors that define the $x, y, z$ axes of the space. Together, the origin and three vectors are called the *frame* that defines the coordinate system. Given an arbitrary point or direction in 3D, its $(x,y,z)$ coordinate values depend on its relationship to the frame.

#figure(image("figures/coordinate_system.png", width: 50%), caption: [Here, two coordinate systems are shown; the point might have coordinates $(3,3)$ with respect to the coordinate system with its coordinate axes drawn in solid lines but have coordinates $(2, -4)$ with respect to the coordinate system with dashed axes. In either case, the 2D point $upright(p)$ is at the same absolute position in space.])

In the general $n$-dimensional case, a frame’s origin $upright(p_o)$ and its  linearly independent basis vectors define an $n$-dimensional *affine space*. All vectors  in the space can be expressed as a linear combination of the basis vectors. Given a vector $upright(bold(v))$ and the basis vectors $upright(bold(v_i))$ there is a unique set of scalar values such that:
$ upright(bold(v)) = s_1 upright(bold(v_1)) + s_2 upright(bold(v_2)) + dots + s_n upright(bold(v_n)) $

Similarly, for all points $upright(p)$ there are unique scalars $s_i$ such that the point can be expressed in terms of the origin $upright(p_o)$ and the basis vectors:
$ upright(p) = s_1 upright(bold(v_1)) + s_2 upright(bold(v_2)) + dots + s_n upright(bold(v_n)) $

Thus, although points and vectors are both represented by $x,y,z$ coordinates in 3D, they are
distinct mathematical entities and are not freely interchangeable.
To define a frame we need a point (the origin) and a set of vectors (the basis); in three dimensions we need a _standard frame_ with origin $(0,0,0)$ and basis vectors $(1,0,0), (0,1,0), (0,0,1)$. All other frames will be defined with respect to this canonical coordinate system, which we call *world space*.

There are two different ways that the three coordinate axes can be arranged. Given perpendicular $x$ and $y$ coordinate axes, the $z$ axis can point in one of two directions. These two choices are called _left-handed_ and _right-handed_. The choice between the two is arbitrary but has a number of implications for how some of the geometric operations throughout the system are implemented.

#figure(
  image("figures/coordinate_system_handedness.png", width: 50%), caption: [(a) Left-handed coordinate system (b) right-handed system]
)

#pagebreak()

= Spherical Geometry
Geometry on the unit sphere is also frequently useful in rendering. 3D unit direction vectors can equivalently be represented as points on the unit sphere, and sets of directions can be represented as areas on the unit sphere.

In 2D, the *planar angle* is the total angle subtended by some object with respect to some position
#figure(
  image("figures/planar_angle.png", width: 50%), caption: [The planar angle of an object as seen from a point $upright(p)$ is equal to the angle it subtends as seen from  $upright(p)$ or, equivalently, as the length of the arc $s$ on the unit sphere.]
)

The *solid angle* extends the 2D unit circle to a 3D unit sphere.  The entire sphere subtends a solid angle of $4 pi$ and a hemisphere subtends $2 pi$.
#figure(
  image("figures/solid_angle.png", width: 50%), caption: [The solid angle $s$ subtended by a 3D object is computed by projecting the object onto the unit sphere and measuring the area of its projection.]
)

We will sometimes find it useful to consider the set of directions from a point to the surface of a polygon. If a regular planar polygon is projected onto the unit sphere, it forms a *spherical polygon*.
#figure(
  image("figures/spherical_polygon.png", width: 50%), caption: [A spherical polygon corresponds to the projection of a polygon onto the unit sphere. ]
)

Unlike planar triangles, the three angles of a spherical triangle do not sum to $pi$  radians; rather, their sum is $pi + A$ , where $A$ is the spherical triangle’s area. 
#figure(
  image("figures/spherical_triangle.png", width: 50%), caption: [A Spherical Triangle ]
)

Given the angles $alpha, beta, gamma$ the triangle’s surface area $A$ on the unit sphere is given by:
$ A = alpha + beta + gamma - pi $

A more efficient and accurate approach is to apply the relationship:
$ tan(1/2 A) = (a dot (c times b )) / (1 + (a dot b) + (a dot c) + (b dot c)) $

The area of a quadrilateral projected onto the unit sphere is given by:
$ A = alpha + beta + gamma + delta -2pi $

The 3D Cartesian coordinates of a point on the unit sphere are not always the most convenient representation of a direction. *Spherical coordinates* $(theta, phi)$ are a well-known parameterization of the sphere. For a general sphere of radius $r$, they are related to Cartesian coordinates by:
#columns(3)[
  $ x = r sin theta cos phi $
  #colbreak()
  $ y = r sin theta sin phi $
  #colbreak()
  $ z = r cos theta$
]

The conversion of a direction $(x,y,z)$ to spherical coordinates can be found by:
#columns(2)[
  $ theta = arccos z $
  #colbreak()
  $ y = arctan y/x $
]

#figure(
  image("figures/spherical_coordinate.png", width: 50%), caption: [A direction vector can be written in terms of spherical coordinates $(theta, phi)$]
)

Given a direction vector $omega$ it is easy to compute the cosine of the angle $theta$:
$ cos theta = ( (0,0,1) dot omega ) = w_z $

The value of $sin ^2 theta $ can be efficiently computed using the trigonometric identity: $sin^2 theta + cos^2 theta = 1$. The tangent of $theta$: $tan theta = (sin theta) / (cos theta)$.
The sine and cosine of the $phi$ angle can also be easily found from $(x,y,z)$ coordinates without using inverse trigonometric functions. In the $z=0$, the vector $omega$ has coordinates $(x,y)$:
#columns(2)[
  $ cos phi = x / (sin theta) $
  #colbreak()
  $ sin phi = y / (sin theta) $
]

In addition to bounding regions of space, it is also sometimes useful to bound a set of directions. For example, if a light source emits illumination in some directions but not others, that information can be used to cull that light source from being included in lighting calculations for points it certainly does not illuminate. 
#figure(
  image("figures/directions_with_cone.png", width: 50%), caption: [Bounding a Set of Directions with a Cone.]
)

A *direction cone* takes the central axis of the cone and the cosine of its spread angle and one that bounds a single direction. Given a DirectionCone, it is easy to check if a given direction vector is inside its bounds: the cosine of the angle between the direction and the cone’s central direction must be greater than the cosine of the cone’s spread angle. 

To determine if one cone of directions is entirely inside another:
#figure(
  image("figures/cone_inside.png", width: 50%), caption: [Given two direction cones $a, b$ their spread angles $theta_a, theta_b$ and the angle between their two central direction vectors $theta_d$ we can determine if one cone is entirely inside the other. Here, $theta_a > theta_d + theta_b$]
)

To compute the spread angle of the direction cone that bounds two others:
#figure(
  image("figures/spread_angle.png", width: 50%), caption: [If $theta_d$ is the angle between two cones’ central axes and the two cones have spread angles $theta_a$ and $theta_b$, then the total angle that the cone bounds is $theta_a + theta_d + theta_b$ and so its spread angle is half of that. ]
)

= Transformations
A transformation $upright(bold(T))$ is a mapping from points to points and from vectors to vectors:
#columns(2)[
  $ upright(p') = upright(bold(T)(p)) $
  #colbreak()
  $ upright(bold(v' = T(v))) $
]

For each $upright(p)$, $upright(bold(T))$ maps $upright(p)$ to a single unique $upright(p')$. Furthermore, there exists an inverse transform $upright(bold(T^(-1)))$ that maps $upright(p')$ back to $upright(p)$.

We will often want to take a point, vector, or normal defined with respect to one coordinate frame and find its coordinate values with respect to another frame. A $4 times 4$ suffices to express all linear transformations of points and vectors within a fixed frame, such as translation in space or rotation around a point. Therefore, there are two different (and incompatible!) ways that a matrix can be interpreted:
- Transformation within the frame: given a point, the matrix could express how to compute a new point in the same frame that represents the transformation of the original point (e.g., by translating it in some direction).
- Transformation from one frame to another: A matrix can express the coordinates of a point or vector in a new frame in terms of the coordinates in the original frame.

Given a frame defined by $(upright(p_o), v_1, v_2, v_3)$ there is ambiguity between the representation of a point $(upright(p_x), upright(p_y), upright(p_z))$  and a vector $(v_x, v_y, v_z)$ with the same  coordinates. We can write the point as $[s_1, s_2, s_3, 1][v_1, v_2, v_2, p_o]$:
$ upright(p') = upright(p_o) + s_x v_x + s_y v_y + s_z v_z $

and a vector as the inner product $[s_1, s_2, s_3, 0][v_1, v_2, v_2, p_o]$:
$ v' = s_x v_x + s_y v_y + s_z v_z $

The vector $[s_1, s_2, s_3, 0 or 1]$ is the *homogeneous* representations of the point and the vector. The fourth coordinate of the homogeneous representation is sometimes called the _weight_. For a point, its value can be any scalar other than zero, for examples: $[1,3,-2,1], [-2, -6, 4, -2]$ describe the same Cartesian point $(1,3,-2)$. Converting homogeneous points into ordinary points entails dividing the first three components by the weight:
#columns(2)[
  $ (x/w,y/w,z/w,w/w) $
  #colbreak()
  $ ((-2)/(-2), (-6)/(-2), (4)/(-2), (-2)/(-2)) = (1, 3, -2, 1) $
]

We will use these facts to see how a transformation matrix can describe how points and vectors in one frame can be mapped to another frame. A $4 times 4$ matrix $upright(bold(M))$ describes the transformation from one coordinate system to another.

One of the simplest transformations is the *translation transformation*, $upright(bold(T) (Delta x, Delta y, Delta  z))$. When applied to a point $upright(p)$ it translate $upright(p)$'s coordinates by $Delta x, Delta y, Delta  z$. For example, $upright(T)(2,2,1)(x,y,z) = (x+2, y+2, z+1)$
#figure(
  image("figures/translation.png", width: 25%), caption: [Translation in 2D.]
)

Translation has some basic properties:
$ upright(bold(T))(0,0,0) = I $
$ upright(bold(T))(x_1, y_1, z_1) upright(bold(T))(x_2, y_2, z_2) = upright(bold(T))(x_1+x_2, y_2+y_2, z_1+z_2) $ 
$ upright(bold(T))(x_1, y_1, z_1) upright(bold(T))(x_2, y_2, z_2) = upright(bold(T))(x_2, y_2, z_2) upright(bold(T)) (x_1, y_1, z_1) $
$ upright(bold(T)^(-1))(x,y,z) = upright(bold(T))(-x,-y,-z) $

Translation only affects points, leaving vectors unchanged. In matrix form, the translation transformation is:
$ upright(bold(T)) = 
mat(
  1, 0, 0, Delta x;
  0, 1, 0, Delta y;
  0, 0, 1, Delta ;
  0, 0, 0, 1) 
mat(x; y; z; 1)
= 
mat(
  x + Delta x;
  y + Delta y;
  z + Delta z;
  1
)
$

However, if we apply $upright(bold(T))$ to a vector $upright(v)$:
$ mat(
  1, 0, 0, Delta x;
  0, 1, 0, Delta y;
  0, 0, 1, Delta ;
  0, 0, 0, 1) 
mat(x; y; z; 1) = mat(x;y;z;0) $

Another basic transformation is the *scale transformation*, $upright(bold(S))(s_x, s_y, s_z)$. It has the effect
of taking a point or vector and multiplying its components by scale factors in $x,y,z$: $upright(bold(S))(2,2,1)(x,y,z) = (2x, 2y, z)$. The inverse is calculated as:
$ upright(bold(S)^(-1))(s_x, s_y, s_z) = upright(bold(S))(1/s_x, 1/s_y, 1/s_z)$

We can differentiate between uniform scaling, where all three scale factors have the same value, and nonuniform scaling, where they may have different values. The general scale matrix is:
$ upright(bold(S))(x,y,z) = mat(
  x, 0, 0, 0;
  0, y, 0, 0;
  0, 0, z, 0;
  0, 0, 0, 1;) $


Another useful type of transformation is the *rotation transformation*, $upright(bold(R))$. we can define an arbitrary axis from the origin in any direction and then rotate around that axis by a given angle. We will write these rotations as $upright(bold(R_x))(theta)$, $upright(bold(R_y))(theta)$, $upright(bold(R_z))(theta)$.
Rotations also have some basic properties:
$ R_a (0) = I $
$ R_a (theta_1) R_a (theta_2) = R_a (theta_1 + theta_2) $
$ R_a ^(-1) (theta) = R_a (-theta) = R^T (theta) $

The rotation matrices are:
#columns(3)[
  $ R_x (theta) = mat(
    1, 0, 0, 0;
    0, cos theta, -sin theta, 0;
    0, sin theta, cos theta, 0;
    0, 0, 0, 1;
  ) $

  #colbreak()

  $ R_y (theta) = mat(
    cos theta, 0, sin theta, 0;
    0, 1, 0, 0;
    -sin theta, 0, cos theta, 0;
    0, 0, 0, 1;
  ) $ 

  #colbreak()

    $ R_z (theta) = mat(
    cos theta, -sin theta, 0, 0;
    sin theta, cos theta, 0, 0;
    0, 0, 1, 0;
    0, 0, 0, 1;
  ) $ 
]

This last property, that the inverse of $upright(bold(R))$ is equal to its transpose, stems from the fact that $upright(bold(R))$ is an _orthogonal matrix_; its first three columns (or rows) are all normalized and orthogonal to each other.
#figure(
  image("figures/rotation.png", width: 50%), caption: [How rotation matrix works.]
)


The *look-at transformation* is particularly useful for placing a camera in the scene. The caller specifies the desired position of the camera, a point the camera is looking at, and an “up” vector that orients the camera along the viewing direction. All of these values are typically given in world-space coordinates; this gives a transformation from world space to camera space.
#figure(image("figures/lookat.png", width: 50%) )

== Applying Transformations
The point transformation routine takes a point $(x,y,z)$ and implicitly represents it as the homogeneous column vector $(x,y,z,1)^T$. It then transforms the point by premultiplying this vector with the transformation matrix. Finally, it divides by $w$  to convert back to a nonhomogeneous point representation. For efficiency, this method skips the division by the homogeneous weight, when $w=1$, which is common for most of the transformations that will be used for the _projective transformations_.

The transformations of vectors can be computed in a similar fashion. However, the multiplication of the matrix and the column vector is simplified since the implicit homogeneous $w$ coordinate is zero.

Normals do not transform in the same way that vectors do. Because the normal vector $upright(n)$ and any tangent vector $upright(t)$ on the surface are orthogonal by construction, we know that:
$ upright(bold(n) dot bold(t)  = bold(n)^T dot bold(t) = 0) $

#figure(
  image("figures/transform_normal.png", width: 50%), caption: [(a) Original circle, with the normal at a point indicated by an arrow, (b) When scaling the circle the normal is no longer perpendicular to the surface. (c) A properly transformed normal.]
)

When we transform a point on the surface by some matrix $upright(bold(M))$  the new tangent vector $upright(bold(t)')$ at the transformed point is $upright(bold(M t))$. The transformed normal $upright(bold(n)')$ should be equal to $upright(bold(S n))$:
$ upright(bold(S n)^T bold(M t) = bold(n^T S^T M t)) = 0 $

This condition holds if $upright(bold(S^T M = I))$, therefore $upright(bold(S^T = M^(-1)))$ and so $upright(bold(S = (M^ (-1)) ^T))$