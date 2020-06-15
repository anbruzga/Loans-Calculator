//
//  Formulas.swift
//  cwFinCalc
//
//  Created by Antanas Bruzga on 3/5/20.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import Foundation
import Darwin



precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Double, power: Double) -> Double {
	return Double(pow(Double(radix), Double(power)))
}

// compound interest
func compoundInterestLumpSum(_ P: Double, _ r:Double, _ t:Double, _ n:Double) -> Double {
	let A = P  * ((1 + r/n) ^^ (n*t))
	return A;
}

func interestRateLumpSum(_ A: Double, _ P: Double, _ t: Double, _ n : Double) -> Double{
	let r = 100 *  n * ((A/P)^^(1/(n*t)) - 1)
	return r
}

func principalAmountLumpSum (_ A: Double, _ r: Double, _ t: Double, _ n : Double) -> Double{
	let P = A/((1+r/n)^^(n*t))
	return P
}

func formulaForTimeLumpSum (_ A: Double, _ P: Double, _ r: Double, _ n : Double) -> Double{
	
	let top =  (log(A/P))
	let bottom = (n * (log(1+r/n)))
	let t = top / bottom;
	return t
	
}


func compoundInterestForAPrincipalAmountMonthsEnd (_ P: Double, _ r:Double, _ t:Double, _ n:Double) -> Double {
	
	let interest = 100 * P  * (( 1 + r/n) ^^ (n*t))
	return interest
	
}

func futureValueMonthsEnd  (_ PMT: Double, _ P: Double, _ r:Double, _ t:Double, _ n:Double) -> Double {
	
	
	//var A = PMT * (((1+r/n)^^(n*t)-1)/(r/n))
	//A = A + compoundInterestLumpSum(P, r, t, n)
		
	// Formula reference:
	// https://keisan.casio.com/exec/system/1234231998
	let FV = (P * ((1 + r/n) ^^ (n*t))) + (PMT * ((1 + r/n)^^(n*t)-1))/(r/n)
	
	
	return FV
	
}

func PMTMonthsEnd  (_ A: Double, _ r:Double, _ t:Double, _ n:Double, _ P: Double) -> Double {
	
	//Old not working
	/*
	let top = A
	let middle = (1+r/n)^^(n*t) - 1
	let bottom = (r/n)
	
	
	print(A)
	print(r)
	print(t)
	print(n)
	print(P)
	*/
	//return top/(middle/bottom)
	
	/*let b = 0.0; // b = r if begining period
	let top = P + A
	let bottom = ((1 + r) ^^ (n*t)) - 1
	var PMT = P + (top/bottom)
	let next = -r/(1+b)
	
	PMT = PMT * next

	return PMT * (-1)
	*/
	
	
	let top = A - P * ((1 + r/n) ^^ (n*t))
	print(top)
	let bottom = r/n

	print(bottom)
	let middle = (1+r/n)^^(n*t) - 1
	print (middle)
	
	let PMT = top / (middle / bottom)
	return PMT
	/*
	let i = r
	//let PMT = P * ((i * ((1 + i)^^(n*t))) / (((1+i)^^(n*t)) - 1))
	
	let top = i * ((i + 1)^^(n*t))
	let bottom = ((i + 1)^^(n*t) - 1)
	var PMT = top/bottom
	PMT = PMT * P
	
	return PMT
	*/
}

func timeToAchieveACertainFutureValueMonthsEnd (_ A: Double, _ r:Double, _ n:Double, _ PMT:Double, _ P: Double) -> Double {
	print("HERE")
	print(PMT)
	print(n)
	print(r)
	print(A)
	

	let lnTop = A * (r/n) + PMT
	let lnBottom = P * (r/n) + PMT
	let ln = log(lnTop/lnBottom)
	let nextPart = 1 / (log(1 + (r/n)))
	let t = ln * nextPart
	
	print(lnTop)
	print(lnBottom)
	print(ln)
	print(nextPart)
	print(t)
	
	return t
}


func compoundInterestForPrincipalMonthsStart(_ P: Double, _ r:Double, _ t:Double, _ n:Double) -> Double {
	let compInterest = (P * ((1  + (r/n)) ^^ (n*t)) ) * 100
	return compInterest
}

func futureValueOfASeriesMonthsStart (_ PMT: Double, _ r: Double, _ n: Double, _ t: Double, _ P: Double) -> Double{
	var A = PMT * (((1+r/n)^^(n*t)-1)/(r/n)) * (1 + r/n)
	A = A + compoundInterestLumpSum(P, r, t, n)
	return A;
	
}


func PMTOfASeriesMonthsStart (_ A: Double, _ r: Double, _ n: Double, _ t: Double) -> Double{
	let PMT = A / (((1+r/n)^^(n*t)-1)/(r/n)) * (1 + r/n)
	return PMT;
	
}

func timeOfASeriesMonthsStart (_ A: Double, _ r: Double, _ n: Double, _ PMT: Double) -> Double{
	let top = log(((A+PMT) * r + n * PMT)/PMT * (r + n))
	let bottom = n * log((r+n)/n)
	
	let t = top/bottom
	return t;
	
}


func mortgagePayments(_ P:Double, _ r: Double, _ n: Double, _ t: Double) -> Double{
	let PMT = (P * (r/n) * ((1 + r/n) ^^ (n*t))) / ((1 + r/n) ^^ (n*t) - 1)
	return PMT
}





func mortgageLengthOfTimeInYears(_ PMT: Double, _ P: Double,
								 _ t:Double, _ r:Double) -> Double {
	let top = log((-12 * PMT) / (P * r - 12 * PMT))
	let bottom = 12 * log((r + 12)/12)
	let t = top/bottom
	return t;
}





/*
func PresentValuePmtExists(_ PMT: Double, _ t: Double, _ r: Double, _ A: Double, _ n: Double) -> Double{
	
	// DOESNT WORK
	
	let i = r/n
	let nk = n*t
	
	let first = A - PMT * ((((1 + i)^^nk)-1)/i)
	let second = (1 + i) ^^ nk
	let PV = first * second
	
	//let PV = (A - PMT * (((i + 1)^^(n*t)-1)/i)) * ((1 + i)^^(n*t))
	
	return PV
	
}*/

func PresentValuePmtExists(_ PMT: Double, _ t: Double, _ r: Double, _ A: Double, _ n: Double) -> Double{
	print(t)
	
	let rDividedByN = r/n
	let e = Darwin.M_E
	
	let top = A * rDividedByN + PMT
	let bottom = e^^(t*n*log(1+rDividedByN))
	
	let P = (top/bottom - PMT) * (n/r)
	return P
	
}

func PresentValueMortgage (_ PMT: Double, _ t: Double, _ r: Double, _ n: Double) -> Double{
	print(t)
	let t = t / 12
	
	let rDividedByN = r/n
	
	
	let nt = n*t
	
	let top = PMT * (((1 + rDividedByN)^^nt) - 1)
	let bottom = rDividedByN * ((1+rDividedByN) ^^ nt)
	let PV = top/bottom
	
	return PV
	
	
}
