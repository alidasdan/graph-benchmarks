foreach n ( *.dot )
  echo $n
  set b = `basename $n .dot`
#  if (-e $b.ps) then
#  echo $b.ps "exists"
#  else 
  dot -Tps $n -o$b.ps
#  endif
end
