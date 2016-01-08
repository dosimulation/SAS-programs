global filepath \CalSIM\outdata
use "$filepath\edd_coded_cat4", clear

egen sid = group(sector), label
egen fid = group(fsize), label

mat P = J(1, 6, 0)
mat colnames P = sector fsize ln_a1 ln_a2 ln_a3 ln_a4

mat temp=J(1, 2, 0)
levelsof sid, local(sl)
levelsof fid, local(fl)

foreach s of local sl {
  foreach f of local fl {
    dirifit p1 p2 p3 p4 if sid==`s' & fid ==`f' [aweight=weight]
	            mat b = e(b)
				local t : label (sid) `s'
                mat temp[1, 1]=`t'
                mat temp[1, 2]=`f'
         	    mat t = temp,b
                mat P = P \ t 
     }
}

mat list P

svmat P
putexcel set "$filepath\stata_dir_alpha_cat4.xls", replace
putexcel A2 = matrix(P), names  

