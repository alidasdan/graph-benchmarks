foreach n ( *.d )
  echo $n
  set b = `basename $n .d`
#  if (-e $b.ps) then
#  echo $b.ps "exists"
#  else 
  conv2dot.pl --infile $n >! $b.dot
#  endif
end
