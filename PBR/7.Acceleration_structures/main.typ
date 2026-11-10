= Bounding Volume Hierarchies

Ray-object intersection is the main time-bottleneck in a ray tracer, and the run time is linear with the number of objects. 
The BVH is an acceleration structure. It serves to reduce a pretty fundamental problem in ray tracing: the sheer cost of finding the nearest intersection of a ray and a scene consisting of (potentially) millions of polygons.
#figure(image("figures/Bounding_Volume_Hierarchy.png", width: 50%))

The basic principle is easy to understand: if we have 64 polygons, we could split them into two groups of 32 polygons, each group enclosed by a bounding volume such as a box or a sphere. When intersecting the scene, we can skip 32 polygons if the ray does not intersect the enclosing volume, nearly halving the processing time. Next, we do the same to each of the two groups: split in two halves, encapsulate, recurse.
#figure(image("figures/bvh.jpg", width: 50%), caption: [Image based on A 3-Dimensional Representation for Fast Rendering of Complex Scenes])

== Axis-Aligned Bounding Boxes
With Axis-Aligned Bounding Boxes (AABBs), the box edges are mutually perpendicular and aligned with the coordinate system axes. A 3D AABB can be described by two opposite vertices of the box: 
#figure(image("figures/3dAABB.png", width: 50%))

A ray bounding volume intersection needs to be fast, and bounding volumes need to be pretty compact. Most people use the “slab” method. This is based on the observation that an n-dimensional AABB is just the intersection of $n$ axis-aligned intervals, often called slabs.

In 2D, an AABB (a rectangle) is defined by the overlap two intervals:
#figure(image("figures/2dAABB.png", width: 25%))

To determine if a ray hits one interval, we first need to figure out whether the ray hits the boundaries. For example, in 1D, ray intersection with two planes will yield the ray parameters $t_0$ and $t_1$
#figure(image("figures/ray_slab_intersection.png", width: 25%))

Recall that the ray is just defined by a function that, given a parameter $t$, returns a location $P(t)$:
$ P(t) = o + t d $

This equation applies to all three of the x/y/z coordinates. For example, $x(t) = o_x + t d_x$. This ray hits the plane $x=x_0$ at the parameter $t$ that satisfies this equation:
$ x_0 = o_x + t_0 d_x $

So $t$ at the intersection is given by:
$ t_0_X &= (x_0 - o_x) / (d_x) \ t_1_x &= (x_1 - o_x) / (d_x) $

The key observation to turn that 1D math into a 2D or 3D hit test is this: if a ray intersects the box bounded by all pairs of planes, then all $t$ intervals will overlap. For example, in 2D the green and blue overlapping only happens if the ray intersects the bounded box:
#figure(image("figures/ray_slab_t_interval_overlap.png", width: 25%), caption: [The upper ray intervals do not overlap, so we know the ray does not hit the 2D box bounded by the green and blue planes. The lower ray intervals do overlap, so we know the lower ray does hit the bounded box.])

There are some caveats. First, suppose the ray is traveling in the negative $x$ direction. The interval $(t_x_0, t_x_1)$ as computed above might be reversed. Second, the denominator $d_x$ could be zero, yielding infinite values. And if the ray origin lies on one of the slab boundaries, we can get a NaN, since both the numerator and the denominator can be zero. Also, the zero will have a $plus.minus$ sign when using IEEE floating point.

== How to build a BVH
Let’s see how a BVH can be constructed automatically. We start with the scene and its bounding box. This is going to be the root node for the hierarchy. We then recursively subdivide this node. A split plane partitions the primitives in two sets. Note that we do not split space: this might lead to primitives being split and/or assigned to both sides. The partitioning is what we need the primitive centroids for: each triangle (or disc, in the figure above) is either to the left of the split plane, or not to the left (which includes the situation where the primitive is on the split plane).
#figure(image("figures/bvhroot.jpg", width: 50%))

After the split we have two independent groups of objects, with their updated group bounds:
#figure(image("figures/bvh-childs.jpg", width: 50%))

Note that the bounding volumes of the two groups may overlap. This actually happens when we split the right group vertically:
#figure(image("figures/bvh-overlap.jpg", width: 50%))

A ray that does intersect the left group may thus miss both of its child nodes, avoiding intersection tests with seven discs.

For a BVH node we need the following data:
1. An axis-aligned bounding box, which is easy to calculate and cheap to store: just 6 floats define the AABB in 3D space. Note: a sphere would be even cheaper to store, but it is not as convenient to work with in practice.
2. References to the two child nodes (if the node is not a leaf node)
3. References to primitives (if the node is a leaf node)

For triangles we use their indices in the triangle array; for child node pointers we can do something similar if we pre-allocate all nodes that we ever need in a BVHNode pool.
the size of the BVH for $N$ triangles has an upper limit: we can never have more than 2N-1 nodes, since N primitives in N leaves have no more than $N/2$ parents, $N/4$ grandparents and so on.

The first step is the creation of the root node, which we will then recursively subdivide.
Finally, we recursively subdivide the root node. A few steps are required:
1. determine the axis and position of the split plane
2. split the group of primitives in two halves using the split plane
3. create child nodes for each half
4. recurse into each of the child nodes.

When does the recursion end? One would say: once there is one primitive left. This is sadly not true. The point is, two triangles quite often form a quad in real-world scenes. If this quad is axis-aligned, there is no way we can split it (with an axis-aligned plane) into two non-empty halves. For this reason, we typically terminate when we have 2 or less primitives in a leaf. 