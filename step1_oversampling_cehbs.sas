libname in "with_firms";
libname outdata "with_firms";
/* the largest number of CalSIM employees assigned to a firm */
%let maxcsemp = 100;

/* the maximum number of employees a firm can have and be considered small */
%let maxsmall = 49;

/* the number of times to sample each firm from CEHBS. each sampled firm will be downweighted */
/* by a factor of 1/nsamp */
%let nsamp = 1;

/* how many times to oversample small firms. a value of 3, for example, will result in */
%let noversamp = 3;

%let nsmallsamp = %sysevalf(&nsamp * &noversamp);
data outdata.firms2;
  set in.cehbs2013_19aug15 (where=(offer^=. & pctlowin^=. & pctlowin^=99999)); /* delete firms who didn't complete the survey */
  earnlow = pctlowin/100;  /*percentage of workforce earning $23,000 or less per year*/   
  firmid = nrid;
  firmwt = empwt;
  if firmsize >= &maxcsemp then do;
    ncsemp = &maxcsemp;
    csempwt = firmsize/&maxcsemp;
  end;
  else do;
    ncsemp = firmsize;
    csempwt = 1;
  end;

  /* sample firms, fractionating the firm weight, and creating new unique firm id's */
  /* the new id is creating by shifting the existing id by the number of digits in */
  /* the number of samples, then a sample-specific counter is added */

  /* oversample small firms */
  baseid = firmid;
  if 0 <= firmsize <= &maxsmall then do;
    do i = 1 to &nsmallsamp;
      firmid = baseid * 10 ** %sysfunc( length(&nsmallsamp) ) + i;
      firmwt = firmwt/&nsmallsamp;
	  output;
    end;
  end;
  /* sample non-small firms */
  else do i = 1 to &nsamp;
    firmid = baseid * 10 ** %sysfunc( length(&nsamp) ) + i;
    firmwt = firmwt/&nsamp;
    output;
  end;
  drop i;
run;
proc means data = outdata.firms2;
  var pctlowin earnlow;
run;

