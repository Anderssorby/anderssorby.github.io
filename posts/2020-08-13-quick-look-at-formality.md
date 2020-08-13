---
layout: default
title:  "A quick look at the Formality language"
date:   2020-07-14 14:14:04 +0200
categories: functional-programming formality
---

After reading [this article](https://medium.com/@maiavictor/thoughts-about-formality-69aa730df481)
I got excited. Apparently it is possible to create a proof language that is both performant, total
and reliable. This is one of the things that drew me to Haskell - the idea that the language and compiler
should be able to enforce strict rules of correctness. It does not support dependent types though and therefore
cannot prove most theorems. Dependent types allows for value level computations at compile time and makes it
possible to constrain types arbitrarily. This is because there is no native types and types are at the same
level as values and can be used as values.

I have to admit this language and theory is hard for me to grasp. For example positive integers can be defined like this:

```formality
// A non-negative integer
T Nat
| zero;
| succ(pred: Nat);

zero: Nat
  <P> (z) (s) z

succ: Nat -> Nat
  (n) <P> (z) (s) s(n)
```

It is based on [Calculus of Constructions (CoC)](https://en.wikipedia.org/wiki/Calculus_of_constructions) which
is s higher order typed lambda calculus, initially developed by Thierry Coquand.

I'm hoping I can do things to help this language come further, but it seems like a lot of work and effort.

In other news I have registered for fun as a Brave Creator and it is now possible to donate to my site.
