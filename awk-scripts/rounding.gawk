#!/usr/bin/gawk -f

# run in terminal with ./script x r 
# x = value which needs rounding
# r = number of decimal points

BEGIN {
x = ARGV[1]
r = ARGV[2]
y = x * 10^(r+1)					# backup for .5
i = int(y)						# backup for .5
c=index(x, ".")						# indexing the decimal point
z=substr(x,1,c-1)					# left of decimal
a=substr(x,c+1)						# right of decimal
con2 = z a						# concatenate left and right of decimal
mod = con2 % 5						# checking concatenated number has no remainder
lc2 = substr(x,c+r,2)					# last 2 numbers as declared with r
print "lc2 is " lc2 					# checking for bugs
print "i is " i " mod is " mod
	if ( lc2 == ".5" ) {				# if .5 use integer
		lc2 = i
		print "new lc2 "lc2
	}
	if ( lc2 ~ /[13579][5]/ && mod == 0 ) {		# looking for 15 35 etc in last 2 numbers
		d = y + 5
		e = d / 10^(r+1)
		printf ("%."r"f\n", e)
	        print "first"	
	} else if ( lc2 ~ /[02468][5]/ && mod == 0 ) {	# looking for 25 45 etc in last 2 numbers
		d = y - 5
		e = d / 10^(r+1)
		printf ("%."r"f\n", e) 
		print "second"
	} else {					# normal rounding
		printf ("%."r"f\n", x)
	        print "last"	
	}
}
