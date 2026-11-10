#import "@preview/gentle-clues:1.3.1": *

Rendering is full of integration problems. These integral equations generally do not have analytic solutions, so we must turn to numerical methods. Monte Carlo integration techniques provide one solution to this problem. They use random sampling to evaluate integrals with a convergence rate that is independent of the dimensionality of the integrand.

#info(title: "Las Vegas vs Monte Carlo")[
Randomized algorithms fall broadly into two classes. _Las Vegas_ algorithms are those that use randomness but always give the same result in the end (e.g., choosing a random array entry as the pivot element in Quicksort). _Monte Carlo_ algorithms, on the other hand, give different results depending on the particular random numbers used along the way but give the right answer on average.
]

= Background and Probability Review
 *Random variables* can be either _discrete_ (e.g. a fixed, finite set of possibilities) or _continuous_ (e.g. the real numbers $R$). Applying a function $f$ to a random variable $X$ results in a new random variable $Y = f(X)$.

For example, the result of a roll of a die is a discrete random variable sampled from the set of events $X_i in {1,2,3,4,5,6}$, each probability $p_i = 1/6$ and the sum of probabilities is one $sum p_i = 1$. A random variable like this that has the same probability for all potential values, is called _uniform_.
A function $p(X)$ that gives a discrete random variable’s probability is termed a *probability mass function (PMF)*, and so we could equivalently write $p(X) = 1/6$ in this case.

#info(title: "Independent vs Dependent random variables")[
Two random variables are independent if the probability of one does not affect the probability of the other:
$ P(X,Y) = p(X)p(Y) $

For dependent random variables, one’s probability affects the other’s. Consider a bag filled with $n$ black balls and $m$ white balls. If we randomly choose two balls from the bag, the probability of the second ball being white is affected by the color of the first ball since its choice changes the number of balls of one type left in the bag. We will say that the second ball’s probability is _conditioned_ on the choice of the first one:
$ P(X,Y) = p(X)p(Y|X) $
where $p(X)p(Y|X)$ is the conditional probability of $Y$ given a value of $X$.
]

A particularly important random variable is the *canonical uniform random variable $xi$*, which takes on all values in its domain $[0,1)$ with uniform probability. This particular variable is important for two reasons. First, it is easy to generate a variable with this distribution in software; and second we can take the canonical uniform random variable $xi$ and map it to a discrete random variable.
For lighting applications, we might want to define the probability of sampling illumination from each light in the scene based on its power $Phi_i$ relative to the total power from all sources:
$ p_i = (Phi_i) / (sum_j Phi_j) $

Given such per-light probabilities, $xi$ could be used to select a light source from which to sample illumination.

The *cumulative distribution function (CDF)*, denoted as $P(x)$ of a random variable is the probability that a value from the variable’s distribution is less than or equal to some value $x$:
#memo(title: "Cumulative Distribution Function (CDF)")[
$ P(x) = Pr {X <= x} $
]

For the die example, $P(2) = 1/6 + 1/6 = 1/3$ since two of the six possibilities are less than or equal to 2.

*Continuous random variables* take on values over ranges of continuous domains (e.g., directions on the unit sphere, or the surfaces of shapes in the scene). Another example of a continuous random variable is the random variable that ranges over the real numbers between 0 and 2. For a continuous variable, the probability of landing on one exact number is zero:
$ Pr(X=x) = 0 $
it makes sense: there are infinitely many possible real numbers between 0 and 2. The *probability density function (PDF)* answers to the question: "_what is the probability that a random variable falls within the interval [a, b]?_"
The probability that $X$ lies in $[a, b]$ is the area under the curve:
#memo(title: "Probability Density Function (PDF)")[
$ Pr(a <= X <= b) = integral_a^b p(x) d x = P(b) - P(a) $
]

For example, if $P(x=0)=1, P(x=0)=0.5, P(x=2)=0$ the density is indeed twice as high at 0 as at 1, and it falls linearly to zero at 2:
$ Pr (0 <= X <= 1) = P(1) - P(0) = 1- 1/4 = 0.75 $
So 75% of samples fall between 0 and 1, while only 25% fall between 1 and 2.

#underline[The PDF does not give the probability of one exact value]; it gives a density of probability. You integrate it over an interval to get an actual probability. To make it a valid PDF, the total area must be 1.
#figure(image("figures/Probability_Density_Function.jpg", width: 25%))

For a uniform random variable on [0,1), every tiny interval of the same length has the same probability. Therefore the PDF must be constant:
$ p(x) = cases(
1  #h(1cm) x in [0,1),
0  #h(1cm) "otherwise"
) $
Its total area is 1: 
$ integral_0^1 1 d x = 1 $

The *expected value* $E_p[f(x)]$ of a function $f$ is defined as the average value of the function over some distribution of values $p(x)$ over its domain D:
#memo(title: "Expected Value")[
$ E_p [f(x)] = integral_D f(x) p(x) d x $
]

As an example, consider finding the expected value of the cosine function between $[0,pi]$ where $p$ is uniform. Because the PDF $p(x)$ must integrate to 1 over the domain, $p(x) = 1/pi$ so:
$ E[cos x] = integral_0^pi (cos pi) / (pi) d x = 1/pi (sin pi - sin 0) = 0 $

which is precisely the expected result.
#figure(image("figures/graph_cosx_over_0_pi.png", width: 25%))

The expected value has a few useful properties that follow from its definition:
$ E[alpha f(x)] &= alpha E[f(x)] \ E[ sum_(i=1)^n f(X_i)] &= sum_(i=1)^n E[f(X_i)] $

#pagebreak()

= The Monte Carlo Estimator
The Monte Carlo estimator is a way to estimate an integral using random samples instead of evaluating the function everywhere. Its core promise is: if you average enough correctly weighted random samples, the average approaches the true integral. Suppose you want to compute:
$ integral_a^b f(x) d x $

Instead of solving it analytically, you:
- pick random points $X_i$ inside $[a,b]$
- evaluate $f(X_i)$ at each point
- average those values
- scale by the width of the interval $b-a$

That gives:
#memo(title: "Monte Carlo Estimator")[
$ F_n = (b-a)/n sum_(i=1)^n f(X_i) $
]

If $X_i$ is uniformly chosen from [a,b], its PDF is $p(x)=1/(b-a)$ because a uniform PDF must have constant height and total area 1.
The expected value $E[F_n]$ is equal to the integral:
$ E[f_n] 
  &= E[(b-a)/n sum_(i=1)^n f(X_i)] \
  &= (b-a)/n sum_(i=1)^n E[f(X_i)] \
  &= (b-a)/n sum_(i=1)^n integral_a^b f(x) p(x) d x \
  &= 1/n sum_(i=1)^n integral_a^b f(x) d x \
  &= integral_a^b f(x) d x $

Uniform sampling is simple, but often inefficient. You can instead sample from any PDF $p(x)$ as long as $p(x)>0$ wherever $f(x) != 0$:
#memo(title: "General estimator with any PDF")[
$ F_n = 1/n sum_i^n f(X_i)/p(X_i) $

The expected value of this estimator is the integral of $f$:
$ E[f_n] = E[1/n sum_i^n f(X_i)/p(X_i)] = integral_a^b f(x) d x $
]

= Error in Monte Carlo Estimators
#question(title: "How noisy is a Monte Carlo estimate?")[
Variance measures how far an estimator typically moves away from its own average value:
$ V[F] = E[ (F- E[F])^2 ] $

Where $E[F]$ is the average result if you repeated the whole estimation many times; $F- E[F]$ is the error of one particular run. Squaring it makes negative and positive errors both count positively. Taking the expected value gives the average squared error around the mean.]

#underline[High variance means individual runs can be very different from one another. In rendering, high variance appears as grainy noise in an image.]

A Monte Carlo estimator averages $n$ independent samples. For independent random variables, variances add: 
$ V[sum_(i=1)^n X_i ] = sum_(i=1)^n V[X_i] $
But the Monte Carlo estimator divides the sum by $n$. Since variance scales with the square of any constant multiplier:
$ V[alpha F] = alpha^2 V[F] $

dividing by $n$ reduces variance by a factor of $n$. So variance falls linearly as you add samples.

#question(title: "Why error falls slowly?")[
Variance is a squared error quantity. The more intuitive measure of visible error is its square root, the standard deviation:
$ sigma = sqrt(V[F_n]) approx 1 / sqrt(n) $
]

To make the error half as large, you need four times as many samples. To make it one-tenth as large, you need 100 times as many samples. This characteristic of Monte Carlo’s rate of error reduction is apparent when watching a progressive rendering of a scene where additional samples are incrementally taken in all pixels. 

An estimator with lower variance is not automatically better. Consider two estimators, where the second has half the variance of the first but takes three times as long to compute an estimate; which of the two is better? In that case, the first is preferable: it could take three times as many samples in the time consumed by the second, in which case it would achieve a $3 times$ variance reduction This is captured by *efficiency*:
$ epsilon[F] = 1/(V[F] T[F]) $
where $V$ is its variance and $T$ is the running time to compute its value. #underline[Higher efficiency means lower variance per unit of computation time.]

The *mean squared error (MSE)* measures distance from the true integral
$ "MSE"[F] = E[(F - integral f(x) d x)^2] = V[F] $

In practice, you usually do not know the true variance. You estimate it from the samples themselves. First compute the sample mean:
$ tilde(X) = (1/n)sum_(i=1)^n X_i $

Then compute the *sample variance*:
$ 1/(n-1) sum_(i=1)^n (X_i - tilde(X))^2 $

The sample variance is itself random. With few samples, it can badly underestimate the true variance. For example, imagine a variable equal to 1 with 99.99% probability and 1,000,000 with 0.01% probability. If you take only ten samples and all happen to be 1, the sample variance is zero, even though the true variance is enormous.

= Improving Efficiency
If we have an unacceptably noisy rendered image, increasing the number of samples will reduce error in a predictable way, and an image of sufficient quality can be generated. However, computation takes time, and often there is not enough of it. Given the  onsequentially limited number of samples, the only option for variance reduction is to find ways to make more of the samples that can be taken. Fortunately, a variety of techniques have been developed to improve the basic Monte Carlo estimator by making the most of the samples that are taken.
