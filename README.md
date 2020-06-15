# Loans/Mortage/Savings-Calculator

Iphone app for calculations related to mortage, loans and savings.    

## The calculations in Savings View:
1. Principal amount (aka present value, initial deposit, PV), with and without PMT  
2. Interest rate, when no PMT is given  
3. PMT (aka Payment, Monthly Payment)  
4. Total amount of payments, with and without PMT.  
5. Future Value, with and without PMT.  

## The calculations in Mortgage view:  
1. Time in years to pay off the mortgage  
2. PMT to pay off the mortgage  
3. Loan amount  

## The calculations in Loan View:  
1. Time in months to pay off the loan  
2. PMT to pay off the loan  
3. Loan amount  

## Instructions:
If all fields are not empty, the calculator will calculate the field which has the blinking cursor.  
Alternatively, the calculator will try to find a void value which seems logical to calculate.  
Though, this will not work in Savings View as PMT is optional. In short, the calculator will count everything, excluding interest rate when PMT is given. 
* Yellow colour text field means that the answer is NOT coherent. For example, if it is with minus where it should not be.
* Red colour means that some input is missing
* Green colour highlights the field that just got calculated

## Additional info on maths behind.
1. Compounding period is always monthly  
2. PMT is made at the end of month  
3. PMT period is always monthly  
4. Interest rate is annual.  
5. The formulas used are to be reused with care, as in some places the time accepted should be years, in some other - months. The same applies for functions returning time.
