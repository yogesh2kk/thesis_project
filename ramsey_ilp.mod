# data zar.txt;  # Load data from zar.txt

# Reading parameters from zar.txt
# Define parameter Z with appropriate indices
param Z{(m,n,s,t) in 1..20 cross 1..20 cross 1..20 cross 1..20}; 
# |A|=x, |B|=y
param x, integer := 24;
param y, integer := 24;
param a, integer := 6;
param b, integer := 6;



# Defining the binomial
param BINOM{i in 0..max(x,y), j in 0..max(a,b)} :=
    if (j=0) then 1
    else (if (i >= j) then (round(prod{u in {0..(j-1)}} (i-u)/(j-u)))
          else 0);

# Defining n[r,i] and m[r,i]
var n{r in 1..max(a, b), i in 0..y}, integer >= 0;
var m{r in 1..max(a, b), i in 0..x}, integer >= 0;

# Defining the variable that we want to maximize
var N, integer >= 0;

# Defining binary variables to indicate presence an r-set in A / B with degree (exact number of common neighbours) i
var p{r in 1..max(a, b), i in 0..y}, binary;
var q{r in 1..max(a, b), i in 0..x}, binary;


# Objective function: maximize the sum of n[1,i] * i
maximize MAX_N: sum{i in 0..y} n[1,i] * i;

# Constraints

s.t. OBJVAL: N = sum{i in 0..y} n[1,i] * i;

s.t. DEGREE1{r in 1..a}: sum{i in 0..y} n[r,i] = BINOM[x,r];
s.t. DEGREE2{r in 1..b}: sum{i in 0..x} m[r,i] = BINOM[y,r];
s.t. KST{s in 1..a, t in 1..b}:
    sum{i in 0..y} (n[s,i] * BINOM[i, t]) = sum{i in 0..x} (m[t,i] * BINOM[i, s]);
s.t. KAB: sum{i in 0..y} n[a,i] * BINOM[i,b] = 0;

# Zero constraints for the surplus variables
s.t. ZERO1{r in (a+1)..max(a, b), i in 0..y}: n[r,i] = 0;
s.t. ZERO2{r in (b+1)..max(a, b), i in 0..x}: m[r,i] = 0;
s.t. ZERO3{r in (a+1)..max(a, b), i in 0..y}: p[r,i] = 0;
s.t. ZERO4{r in (b+1)..max(a, b), i in 0..x}: q[r,i] = 0;

# So far, this is Irving's sharpened method. Below we implement the recursive upper bounds (sharpened version of Damásdi et al.).


/*
# Let us not use the recursive bounds.


# We want p[r,i] = 1 if and only if n[r,i] > 0, and analogously for q and m.
# Thus the value of n[r,i] should not exceed p[r,i] times BINOM[x,r], but should be at least p[r,i], and analogously.
s.t. P_Rela1{r in 1..(a-1), i in 0..y}: n[r,i] <= p[r,i] * BINOM[x,r];
s.t. P_Rela2{r in 1..(a-1), i in 0..y}: n[r,i] >= p[r,i];
s.t. Q_Rela1{r in 1..(b-1), i in 0..x}: m[r,i] <= q[r,i] * BINOM[y,r];
s.t. Q_Rela2{r in 1..(b-1), i in 0..x}: m[r,i] >= q[r,i];



# We add the upper bound constraint for recursive upper bound calculation
# UA is valid if there is an r-set in A with degree exactly i, that is, p[r,i]=1; UB is valid iff q[r,i]=1.
param UA{r in 1..(a-1), i in 1..y} :=
    if (i<y) then min(r*i + (y-i)*(r-1) + Z[x-r,i,a-r,b] + Z[x-r,y-i,a,b], r*i + (y-i)*(r-1) + Z[x-r,y,a,b]) else r*y + Z[x-r,y,a-r,b];

param UB{r in 1..(b-1), i in 1..x} :=
    if  (i<x) then min(r*i + (x-i)*(r-1) + Z[y-r,i,b-r,a] + Z[y-r,x-i,b,a], r*i + (x-i)*(r-1) + Z[y-r,x,b,a]) else r*x + Z[y-r,x,b-r,a];

# Constraints for i<x and i< y; meaningful only of p[r,i] = 1 (or q[r,i] = 1)
s.t. U_A{r in 1..(a-1), i in 1..(y-1)}:
    N <= UA[r,i] + (1 - p[r,i]) * x * y;  

s.t. U_B{r in 1..(b-1), i in 1..(x-1)}:
    N <= UB[r,i] + (1 - q[r,i]) * x * y;  

# Constraints for the case when i = y
s.t. U_A_y{r in 1..(a-1)}:
    N <= UA[r,y] + (1 - p[r,y]) * x * y;

# Constraints for the case when i = x
s.t. U_B_x{r in 1..(b-1)}:
    N <= UB[r,x] + (1 - q[r,x]) * x * y;

# Constraints if i is maximal such that p[r,i] = 1; that is, there exists no K_{r,i+1} in the graph
s.t. KrimaxA{r in 1..(a-1), i in 1..y-1}:
	N <= Z[x,y,r,i+1] + (1 - p[r,i] + (sum{j in i+1..y} p[r,j]))*x*y;

s.t. KrimaxB{r in 1..(b-1), i in 1..x-1}:
	N <= Z[y,x,r,i+1] + (1 - q[r,i] + (sum{j in i+1..x} q[r,j]))*x*y;
	
*/
	
end;
