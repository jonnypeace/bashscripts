#!/usr/bin/gawk -f

# searching for 46, and build 2 arrays l and a
# l contains each line which matches 46
# a contains each values for come act go

/[0-9]{1,4}/{
l[lines++]=$0
b[some++]=$1
a[more++]=$3
x="come"
y="act"
z="go"
}

END{
# loop through array a for come act go sequence.
for (i in a) {
  if (a[i] ~ /come|act|go/ ) {
    if ( a[i] == x && b[i] == b[i+1] ) {
      if ( a[i+1] == y && b[i+1] == b[i+2] ) {
	if ( a[i+2] == z && b[i] == b[i+2] ) {
	  print l[i]
	  print l[i+1]
	  print l[i+2]
	  }
        }
      }
    }
  }
}
