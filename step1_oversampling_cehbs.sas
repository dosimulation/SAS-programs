libname in "\\Center.local\Net Access\Data Depository\Data\CalSIM\outdata\with_firms";
libname outdata "\\Center.local\Net Access\Data Depository\Data\CalSIM\outdata\with_firms";
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

proc format;
value fsize 
    1-49  = '1-49'	
  50-99   = '50-99'
100-499   = '100-499'
500-high  = '500+'
other     =  'invalid size';
run;
data firms_1;
  set in.cehbs2013_19aug15 (where=(empwt^=.)); /* delete firms who didn't complete the survey */
  if pctlowin = 99999 then pctlowin = .;
  if pcthigin = 99999 then pcthigin = .;
run;
proc sql;
  create table firms_2 as
  select firms_1.*, put(firmsize, fsize.) as firm_size, mean(pctlowin) as mean_pctlowin, 
         min(mean(pcthigin), 1-calculated mean_pctlowin) as mean_pcthigin
  from firms_1
  group by industry, firm_size;
quit;
data outdata.firms2;
  set firms_2;
  if pctlowin = . then pctlowin = mean_pctlowin;
  if pcthigin = . then pcthigin  = mean_pcthigin;

  earnlow = pctlowin/100;  /*percentage of workforce earning $23,000 or less per year*/   
  earnhigh = pcthigin/100;
  check = earnlow + earnhigh;
  if check >= 1 then do;
     if earnlow > .5 then earnlow = earnlow - (check-.95);
	 else if earnhigh > .5 then earnhigh = earnhigh - (check-.95);
  end;
  firmid = nrid;
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
      firmwt = empwt/&nsmallsamp;
	  output;
    end;
  end;
  /* sample non-small firms */
  else do i = 1 to &nsamp;
    firmid = baseid * 10 ** %sysfunc( length(&nsamp) ) + i;
    firmwt = empwt/&nsamp;
    output;
  end;
  drop i mean_pctlowin mean_pcthigin check nrid;
run;

