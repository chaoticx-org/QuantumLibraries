// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Math {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Computes the base-2 logarithm of a number.
    ///
    /// # Input
    /// ## input
    /// A real number $x$.
    ///
    /// # Output
    /// The base-2 logarithm $y = \log_2(x)$ such that $x = 2^y$.
    function Lg (input : Double) : Double {
        return Log(input) / LogOf2();
    }

    /// # Summary
    /// Given an array of integers, returns the largest element.
    ///
    /// # Input
    /// ## values
    /// An array to take the maximum of.
    ///
    /// # Output
    /// The largest element of `values`.
    function Max (values : Int[]) : Int {
        mutable max = values[0];
        let nTerms = Length(values);

        for (idx in 0 .. nTerms - 1) {
            if (values[idx] > max) {
                set max = values[idx];
            }
        }

        return max;
    }

    /// # Summary
    /// Given an array of integers, returns the smallest element.
    ///
    /// # Input
    /// ## values
    /// An array to take the minimum of.
    ///
    /// # Output
    /// The smallest element of `values`.
    function Min (values : Int[]) : Int {
        mutable min = values[0];
        let nTerms = Length(values);

        for (idx in 0 .. nTerms - 1) {
            if (values[idx] < min) {
                set min = values[idx];
            }
        }

        return min;
    }


    /// # Summary
    /// Computes the modulus between two real numbers.
    ///
    /// # Input
    /// ## value
    /// A real number $x$ to take the modulus of.
    /// ## modulo
    /// A real number to take the modulus of $x$ with respect to.
    /// ## minValue
    /// The smallest value to be returned by this function.
    ///
    /// # Remarks
    /// This function computes the real modulus by wrapping the real
    /// line about the unit circle, then finding the angle on the
    /// unit circle corresponding to the input.
    /// The `minValue` input then effectively specifies where to cut the
    /// unit circle.
    ///
    /// ## Example
    /// ```qsharp
    ///     // Returns 3 π / 2.
    ///     let y = RealMod(5.5 * PI(), 2.0 * PI(), 0.0);
    ///     // Returns -1.2, since +3.6 and -1.2 are 4.8 apart on the real line,
    ///     // which is a multiple of 2.4.
    ///     let z = RealMod(3.6, 2.4, -1.2);
    /// ```
    function RealMod(value : Double, modulo : Double, minValue : Double) : Double
    {
        let fractionalValue = (2.0 * PI()) * ((value - minValue) / modulo - 0.5);
        let cosFracValue = Cos(fractionalValue);
        let sinFracValue = Sin(fractionalValue);
        let moduloValue = 0.5 + ArcTan2(sinFracValue, cosFracValue) / (2.0 * PI());
        let output = moduloValue * modulo + minValue;
        return output;
    }


    // NB: .NET's Math library does not provide hyperbolic arcfunctions.

    /// # Summary
    /// Computes the inverse hyperbolic cosine of a number.
    ///
    /// # Input
    /// ## x
    /// A real number $x\geq 1$.
    ///
    /// # Output
    /// A real number $y$ such that $x = \cosh(y)$.
    function ArcCosh (x : Double) : Double {
        return Log(x + Sqrt(x * x - 1.0));
    }


    /// # Summary
    /// Computes the inverse hyperbolic sine of a number.
    ///
    /// # Input
    /// ## x
    /// A real number $x$.
    ///
    /// # Output
    /// A real number $y$ such that $x = \operatorname{sinh}(y)$.
    function ArcSinh (x : Double) : Double
    {
        return Log(x + Sqrt(x * x + 1.0));
    }


    /// # Summary
    /// Computes the inverse hyperbolic tangent of a number.
    ///
    /// # Input
    /// ## x
    /// A real number $x$.
    ///
    /// # Output
    /// A real number $y$ such that $x = \tanh(y)$.
    function ArcTanh (x : Double) : Double
    {
        return Log((1.0 + x) / (1.0 - x)) * 0.5;
    }


    /// # Summary
    /// Computes the canonical residue of `value` modulo `modulus`.
    /// # Input
    /// ## value
    /// The value of which residue is computed
    /// ## modulus
    /// The modulus by which residues are take, must be positive
    /// # Output
    /// Integer $r$ between 0 and `modulus - 1` such that `value - r` is divisible by modulus
    ///
    /// # Remarks
    /// This function behaves different to how the operator `%` behaves in C# and Q# as in the result
    /// is always a non-negative integer between 0 and `modulus - 1`, even if value is negative.
    function ModulusI(value : Int, modulus : Int) : Int {
        Fact(modulus > 0, $"`modulus` must be positive");
        let r = value % modulus;
        return (r < 0) ? (r + modulus) | r;
    }

    /// # Summary
    /// Computes the canonical residue of `value` modulo `modulus`.
    /// # Input
    /// ## value
    /// The value of which residue is computed
    /// ## modulus
    /// The modulus by which residues are take, must be positive
    /// # Output
    /// Integer $r$ between 0 and `modulus - 1` such that `value - r` is divisible by modulus
    ///
    /// # Remarks
    /// This function behaves different to how the operator `%` behaves in C# and Q# as in the result
    /// is always a non-negative integer between 0 and `modulus - 1`, even if value is negative.
    function ModulusL(value : BigInt, modulus : BigInt) : BigInt {
        Fact(modulus > 0L, $"`modulus` must be positive");
        let r = value % modulus;
        return (r < 0L) ? (r + modulus) | r;
    }


    /// # Summary
    /// Returns an integer raised to a given power, with respect to a given
    /// modulus.
    ///
    /// # Description
    /// Let us denote expBase by $x$, power by $p$ and modulus by $N$.
    /// The function returns $x^p \operatorname{mod} N$.
    ///
    /// We assume that $N$, $x$ are positive and power is non-negative.
    ///
    /// # Remarks
    /// Takes time proportional to the number of bits in `power`, not the `power` itself.
    function ExpModI(expBase : Int, power : Int, modulus : Int) : Int {
        Fact(power >= 0, $"`power` must be non-negative");
        Fact(modulus > 0, $"`modulus` must be positive");
        Fact(expBase > 0, $"`expBase` must be positive");
        mutable res = 1;
        mutable expPow2mod = expBase;

        // express p as bit-string pₙ … p₀
        let powerBitExpansion = IntAsBoolArray(power, BitSizeI(power));
        let expBaseMod = expBase % modulus;

        for (k in IndexRange(powerBitExpansion))
        {
            if (powerBitExpansion[k])
            {
                // if bit pₖ is 1, multiply res by expBase^(2ᵏ) (mod `modulus`)
                set res = (res * expPow2mod) % modulus;
            }

            // update value of expBase^(2ᵏ) (mod `modulus`)
            set expPow2mod = (expPow2mod * expPow2mod) % modulus;
        }

        return res;
    }

    /// # Summary
    /// Returns an integer raised to a given power, with respect to a given
    /// modulus.
    ///
    /// # Description
    /// Let us denote expBase by $x$, power by $p$ and modulus by $N$.
    /// The function returns $x^p \operatorname{mod} N$.
    ///
    /// We assume that $N$, $x$ are positive and power is non-negative.
    ///
    /// # Remarks
    /// Takes time proportional to the number of bits in `power`, not the `power` itself.
    function ExpModL(expBase : BigInt, power : BigInt, modulus : BigInt) : BigInt {
        Fact(power >= 0L, $"`power` must be non-negative");
        Fact(modulus > 0L, $"`modulus` must be positive");
        Fact(expBase > 0L, $"`expBase` must be positive");
        mutable res = 1L;
        mutable expPow2mod = expBase;

        // express p as bit-string pₙ … p₀
        let powerBitExpansion = BigIntAsBoolArray(power);
        let expBaseMod = expBase % modulus;

        for (k in IndexRange(powerBitExpansion)) {
            if (powerBitExpansion[k]) {
                // if bit pₖ is 1, multiply res by expBase^(2ᵏ) (mod `modulus`)
                set res = (res * expPow2mod) % modulus;
            }

            // update value of expBase^(2ᵏ) (mod `modulus`)
            set expPow2mod = (expPow2mod * expPow2mod) % modulus;
        }

        return res;
    }

    /// # Summary
    /// Internal recursive call to calculate the GCD.
    function _ExtendedGreatestCommonDivisorI(signA : Int, signB : Int, r : (Int, Int), s : (Int, Int), t : (Int, Int)) : (Int, Int) {
        if (Snd(r) == 0) {
            return (Fst(s) * signA, Fst(t) * signB);
        }

        let quotient = Fst(r) / Snd(r);
        let r_ = (Snd(r), Fst(r) - quotient * Snd(r));
        let s_ = (Snd(s), Fst(s) - quotient * Snd(s));
        let t_ = (Snd(t), Fst(t) - quotient * Snd(t));
        return _ExtendedGreatestCommonDivisorI(signA, signB, r_, s_, t_);
    }


    /// # Summary
    /// Computes a tuple $(u,v)$ such that $u \cdot a + v \cdot b = \operatorname{GCD}(a, b)$,
    /// where $\operatorname{GCD}$ is $a$
    /// greatest common divisor of $a$ and $b$. The GCD is always positive.
    ///
    /// # Input
    /// ## a
    /// the first number of which extended greatest common divisor is being computed
    /// ## b
    /// the second number of which extended greatest common divisor is being computed
    ///
    /// # Output
    /// Tuple $(u,v)$ with the property $u \cdot a + v \cdot b = \operatorname{GCD}(a, b)$.
    ///
    /// # References
    /// - This implementation is according to https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
    function ExtendedGreatestCommonDivisorI(a : Int, b : Int) : (Int, Int) {
        let signA = SignI(a);
        let signB = SignI(b);
        let s = (1, 0);
        let t = (0, 1);
        let r = (a * signA, b * signB);
        return _ExtendedGreatestCommonDivisorI(signA, signB, r, s, t);
    }

    /// # Summary
    /// Internal recursive call to calculate the GCD.
    function _ExtendedGreatestCommonDivisorL(signA : Int, signB : Int, r : (BigInt, BigInt), s : (BigInt, BigInt), t : (BigInt, BigInt)) : (BigInt, BigInt) {
        if (Snd(r) == 0L) {
            return (Fst(s) * IntAsBigInt(signA), Fst(t) * IntAsBigInt(signB));
        }

        let quotient = Fst(r) / Snd(r);
        let r_ = (Snd(r), Fst(r) - quotient * Snd(r));
        let s_ = (Snd(s), Fst(s) - quotient * Snd(s));
        let t_ = (Snd(t), Fst(t) - quotient * Snd(t));
        return _ExtendedGreatestCommonDivisorL(signA, signB, r_, s_, t_);
    }


    /// # Summary
    /// Computes a tuple $(u,v)$ such that $u \cdot a + v \cdot b = \operatorname{GCD}(a, b)$,
    /// where $\operatorname{GCD}$ is $a$
    /// greatest common divisor of $a$ and $b$. The GCD is always positive.
    ///
    /// # Input
    /// ## a
    /// the first number of which extended greatest common divisor is being computed
    /// ## b
    /// the second number of which extended greatest common divisor is being computed
    ///
    /// # Output
    /// Tuple $(u,v)$ with the property $u \cdot a + v \cdot b = \operatorname{GCD}(a, b)$.
    ///
    /// # References
    /// - This implementation is according to https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
    function ExtendedGreatestCommonDivisorL(a : BigInt, b : BigInt) : (BigInt, BigInt) {
        let signA = SignL(a);
        let signB = SignL(b);
        let s = (1l, 0L);
        let t = (0l, 1L);
        let r = (a * IntAsBigInt(signA), b * IntAsBigInt(signB));
        return _ExtendedGreatestCommonDivisorL(signA, signB, r, s, t);
    }


    /// # Summary
    /// Computes the greatest common divisor of $a$ and $b$. The GCD is always positive.
    ///
    /// # Input
    /// ## a
    /// the first number of which extended greatest common divisor is being computed
    /// ## b
    /// the second number of which extended greatest common divisor is being computed
    ///
    /// # Output
    /// Greatest common divisor of $a$ and $b$
    function GreatestCommonDivisorI(a : Int, b : Int) : Int {
        let (u, v) = ExtendedGreatestCommonDivisorI(a, b);
        return u * a + v * b;
    }

    /// # Summary
    /// Computes the greatest common divisor of $a$ and $b$. The GCD is always positive.
    ///
    /// # Input
    /// ## a
    /// the first number of which extended greatest common divisor is being computed
    /// ## b
    /// the second number of which extended greatest common divisor is being computed
    ///
    /// # Output
    /// Greatest common divisor of $a$ and $b$
    function GreatestCommonDivisorL(a : BigInt, b : BigInt) : BigInt {
        let (u, v) = ExtendedGreatestCommonDivisorL(a, b);
        return u * a + v * b;
    }


    /// # Summary
    /// Internal recursive call to calculate the GCD with a bound
    function _ContinuedFractionConvergentI(signA : Int, signB : Int, r : (Int, Int), s : (Int, Int), t : (Int, Int), denominatorBound : Int) : Fraction
    {
        if (Snd(r) == 0 or AbsI(Snd(s)) > denominatorBound) {
            return (Snd(r) == 0 and AbsI(Snd(s)) <= denominatorBound)
                   ? Fraction(-Snd(t) * signB, Snd(s) * signA)
                   | Fraction(-Fst(t) * signB, Fst(s) * signA);
        }

        let quotient = Fst(r) / Snd(r);
        let r_ = (Snd(r), Fst(r) - quotient * Snd(r));
        let s_ = (Snd(s), Fst(s) - quotient * Snd(s));
        let t_ = (Snd(t), Fst(t) - quotient * Snd(t));
        return _ContinuedFractionConvergentI(signA, signB, r_, s_, t_, denominatorBound);
    }


    /// # Summary
    /// Finds the continued fraction convergent closest to `fraction`
    /// with the denominator less or equal to `denominatorBound`
    ///
    /// # Input
    ///
    ///
    /// # Output
    /// Continued fraction closest to `fraction`
    /// with the denominator less or equal to `denominatorBound`
    function ContinuedFractionConvergentI(fraction : Fraction, denominatorBound : Int)
    : Fraction {
        Fact(denominatorBound > 0, $"Denominator bound must be positive");
        let (a, b) = fraction!;
        let signA = SignI(a);
        let signB = SignI(b);
        let s = (1, 0);
        let t = (0, 1);
        let r = (a * signA, b * signB);
        return _ContinuedFractionConvergentI(signA, signB, r, s, t, denominatorBound);
    }

    /// # Summary
    /// Internal recursive call to calculate the GCD with a bound
    function _ContinuedFractionConvergentL(signA : Int, signB : Int, r : (BigInt, BigInt), s : (BigInt, BigInt), t : (BigInt, BigInt), denominatorBound : BigInt) : BigFraction
    {
        if (Snd(r) == 0L or AbsL(Snd(s)) > denominatorBound) {
            return (Snd(r) == 0L and AbsL(Snd(s)) <= denominatorBound)
                   ? BigFraction(-Snd(t) * IntAsBigInt(signB), Snd(s) * IntAsBigInt(signA))
                   | BigFraction(-Fst(t) * IntAsBigInt(signB), Fst(s) * IntAsBigInt(signA));
        }

        let quotient = Fst(r) / Snd(r);
        let r_ = (Snd(r), Fst(r) - quotient * Snd(r));
        let s_ = (Snd(s), Fst(s) - quotient * Snd(s));
        let t_ = (Snd(t), Fst(t) - quotient * Snd(t));
        return _ContinuedFractionConvergentL(signA, signB, r_, s_, t_, denominatorBound);
    }


    /// # Summary
    /// Finds the continued fraction convergent closest to `fraction`
    /// with the denominator less or equal to `denominatorBound`
    ///
    /// # Input
    ///
    ///
    /// # Output
    /// Continued fraction closest to `fraction`
    /// with the denominator less or equal to `denominatorBound`
    function ContinuedFractionConvergentL(fraction : BigFraction, denominatorBound : BigInt)
    : BigFraction {
        Fact(denominatorBound > 0L, $"Denominator bound must be positive");
        let (a, b) = fraction!;
        let signA = SignL(a);
        let signB = SignL(b);
        let s = (1L, 0L);
        let t = (0L, 1L);
        let r = (a * IntAsBigInt(signA), b * IntAsBigInt(signB));
        return _ContinuedFractionConvergentL(signA, signB, r, s, t, denominatorBound);
    }

    /// # Summary
    /// Returns true if $a$ and $b$ are co-prime and false otherwise.
    ///
    /// # Input
    /// ## a
    /// the first number of which co-primality is being tested
    /// ## b
    /// the second number of which co-primality is being tested
    ///
    /// # Output
    /// True, if $a$ and $b$ are co-prime (e.g. their greatest common divisor is 1 ),
    /// and false otherwise
    function IsCoprimeI(a : Int, b : Int) : Bool {
        let (u, v) = ExtendedGreatestCommonDivisorI(a, b);
        return u * a + v * b == 1;
    }

    /// # Summary
    /// Returns true if $a$ and $b$ are co-prime and false otherwise.
    ///
    /// # Input
    /// ## a
    /// the first number of which co-primality is being tested
    /// ## b
    /// the second number of which co-primality is being tested
    ///
    /// # Output
    /// True, if $a$ and $b$ are co-prime (e.g. their greatest common divisor is 1 ),
    /// and false otherwise
    function IsCoprimeL(a : BigInt, b : BigInt) : Bool {
        let (u, v) = ExtendedGreatestCommonDivisorL(a, b);
        return u * a + v * b == 1L;
    }

    /// # Summary
    /// Returns $b$ such that $a \cdot b = 1 (\operatorname{mod} \texttt{modulus})$.
    ///
    /// # Input
    /// ## a
    /// The number being inverted
    /// ## modulus
    /// The modulus according to which the numbers are inverted
    ///
    /// # Output
    /// Integer $b$ such that $a \cdot b = 1 (\operatorname{mod} \texttt{modulus})$.
    function InverseModI(a : Int, modulus : Int) : Int
    {
        let (u, v) = ExtendedGreatestCommonDivisorI(a, modulus);
        let gcd = u * a + v * modulus;
        EqualityFactI(gcd, 1, $"`a` and `modulus` must be co-prime");
        return ModulusI(u, modulus);
    }

    /// # Summary
    /// Returns $b$ such that $a \cdot b = 1 (\operatorname{mod} \texttt{modulus})$.
    ///
    /// # Input
    /// ## a
    /// The number being inverted
    /// ## modulus
    /// The modulus according to which the numbers are inverted
    ///
    /// # Output
    /// Integer $b$ such that $a \cdot b = 1 (\operatorname{mod} \texttt{modulus})$.
    function InverseModL(a : BigInt, modulus : BigInt) : BigInt {
        let (u, v) = ExtendedGreatestCommonDivisorL(a, modulus);
        let gcd = u * a + v * modulus;
        EqualityFactL(gcd, 1L, $"`a` and `modulus` must be co-prime");
        return ModulusL(u, modulus);
    }


    /// # Summary
    /// Helper function used to recursively calculate the bitsize of a value.
    internal function AccumulatedBitsizeI(val : Int, bitsize : Int) : Int {
        return val == 0 ? bitsize | AccumulatedBitsizeI(val / 2, bitsize + 1);
    }


    /// # Summary
    /// For a non-negative integer `a`, returns the number of bits required to represent `a`.
    ///
    /// That is, returns the smallest $n$ such
    /// that $a < 2^n$.
    ///
    /// # Input
    /// ## a
    /// The integer whose bit-size is to be computed.
    ///
    /// # Output
    /// The bit-size of `a`.
    function BitSizeI(a : Int) : Int {
        Fact(a >= 0, $"`a` must be non-negative");
        return AccumulatedBitsizeI(a, 0);
    }


    /// # Summary
    /// For a non-negative integer `a`, returns the number of bits required to represent `a`.
    ///
    /// That is, returns the smallest $n$ such
    /// that $a < 2^n$.
    ///
    /// # Input
    /// ## a
    /// The integer whose bit-size is to be computed.
    ///
    /// # Output
    /// The bit-size of `a`.
    function BitSizeL(a : BigInt) : Int {
        Fact(a >= 0L, $"`a` must be non-negative");
        mutable bitsize = 0;
        mutable val = a;
        while (val != 0L) {
            set bitsize += 1;
            set val /= 2L;
        } 
        return bitsize;
    }


    /// # Summary
    /// Returns the `L(p)` norm of a vector of `Double`s.
    ///
    /// That is, given an array $x$ of type `Double[]`, this returns the $p$-norm
    /// $\|x\|\_p= (\sum_{j}|x_j|^{p})^{1/p}$.
    ///
    /// # Input
    /// ## p
    /// The exponent $p$ in the $p$-norm.
    ///
    /// # Output
    /// The $p$-norm $\|x\|_p$.
    function PNorm (p : Double, array : Double[]) : Double {
        if (p < 1.0) {
            fail $"PNorm failed. `p` must be >= 1.0";
        }

        mutable norm = 0.0;

        for (element in array) {
            set norm = norm + PowD(AbsD(element), p);
        }

        return PowD(norm, 1.0 / p);
    }


    /// # Summary
    /// Returns the squared 2-norm of a vector.
    ///
    /// # Description
    /// Returns the squared 2-norm of a vector; that is, given an input
    /// $\vec{x}$, returns $\sum_i x_i^2$.
    ///
    /// # Input
    /// ## array
    /// The vector whose squared 2-norm is to be returned.
    ///
    /// # Output
    /// The squared 2-norm of `array`.
    function SquaredNorm(array : Double[]) : Double {
        mutable ret = 0.0;
        for (element in array) {
            set ret += element * element;
        }
        return ret;
    }


    /// # Summary
    /// Normalizes a vector of `Double`s in the `L(p)` norm.
    ///
    /// # Description
    /// That is, given an array $x$ of type `Double[]`, this returns an array where
    /// all elements are divided by the $p$-norm $\|x\|_p$.
    ///
    /// # Input
    /// ## p
    /// The exponent $p$ in the $p$-norm.
    ///
    /// # Output
    /// The array $x$ normalized by the $p$-norm $\|x\|_p$.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.PNorm
    function PNormalized(p : Double, array : Double[]) : Double[] {
        let nElements = Length(array);
        let norm = PNorm(p, array);

        if (norm == 0.0) {
            return array;
        } else {
            mutable output = new Double[nElements];

            for (idx in 0 .. nElements - 1) {
                set output w/= idx <- array[idx] / norm;
            }

            return output;
        }
    }
 
 
    /// # Summary
    /// Returns a factorial of a given number.
    ///
    /// # Description
    /// Returns the factorial as Integer, given an input of $n$ as an Integer.
    /// Maximum input is |20| to return as Int. For inputs greater than 20, use FactorialL(n).
    ///
    /// # Input
    /// ## $n$
    /// An Int between -20, 20.
    ///
    /// # Output
    /// The factorial of the provided input with the datatype Int.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.FactorialL
    function FactorialI (n : Int) : Int
    {
        mutable an = 1;
        mutable x = 1;
        if n < 0 {
            set an = AbsI(n);
            set x = -1;
        }
        elif n == 0 {
            return x;
        } elif n >= 21 {
            fail "Largest factorial an Int can hold is 20!. Use FactorialL or FactorialD";
        } else {
            set an = n;
        }
        for i in  1 .. an {
            set x = x * i;
        }
       return x;
    }


    /// # Summary
    /// Returns a factorial of a given number.
    ///
    /// # Description
    /// Returns the factorial as 'Double', given an input of $n$ as a 'Double'.
    /// The domain of inputs for this function is 20.0 < n < 170.0.
    /// Function uses the Ramanujan Approxomation with a relative error to the order of 1/n^5
    ///
    /// # Input
    /// ## $n$
    /// A 'Double' between 20.0 < n < 170.0.
    /// Negatives are accepted.
    ///
    /// # Output
    /// The factorial of the provided input with the datatype 'Double'.
    /// Large numbers are returned in scientific notation. Example: '8.320987112732955E+81'
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.FactorialL
    function FactorialD(n : Double) : Double
    {
        let GivenInt = AbsD(n);
        mutable Direction = 1.0;
        mutable TradLoop = 1.0;
        mutable ans = 1.0;
        
        if n < 0.0 {
            set Direction = -1.0;
        }
        if GivenInt <= 30.0{
            fail "FactorialD uses aproxomation. It is recommended to use FactorialI for factorials less than 20";
        }
        elif GivenInt >= 170.0{
            fail "FactorialD will return infinity for numbers larger than 170! Recommend using FactorialL";
        }
        else{
        let a = Sqrt(2.0*PI()*GivenInt);
        let b = ((GivenInt /E())^GivenInt);
        let c = (E()^((1.0/(12.0*GivenInt)) - (1.0 /(360.0*(GivenInt^3.0)))));
        set ans = a*b*c*Direction;
        }
       return ans;
   }


   
    /// # Summary
    /// Given an 'Int', this function returns a factorial as a 'BigInt'.
    ///
    /// # Description
    /// Returns the factorial as Big Integer, given an input of $n$ as an Integer.
    /// This function does not use approximation. If speed is required, use 'FactorialD'
    ///
    /// # Input
    /// ## $n$
    /// A whole number of any size, positive or negative.
    ///
    /// # Output
    /// The factorial of the provided input with the type BigInt
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.FactorialD
    function FactorialL(n : Int) : BigInt
    { 
        mutable Direction = 1L;
        mutable Ans = 1L;
        let GivenValue = AbsI(n);

        if n < 0{
            set Direction = -1L;
        }
        if GivenValue == 0{
            return 1L;
        }
        elif GivenValue == 1{
            return 1L;
        }
        else{
            let Eve = EveFactorialL(GivenValue);
            let Odd = OddFactorialL(GivenValue);
            set Ans = Eve * Odd * Direction;
        }
        return Ans;
    }

    internal function OddFactorialL(n : Int) : BigInt
    {
     mutable acc = 1L;
     for i in 1..2..n {
          set acc *= IntAsBigInt(i);
    }
     return acc;
    }

    internal function EveFactorialL(n : Int) : BigInt
    {
     mutable acc = 1L;
     for i in 2..2..n {
        set acc *= IntAsBigInt(i);
    }
     return acc;
    }



}
