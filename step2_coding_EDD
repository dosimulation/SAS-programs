/* ---------------------------------------------------------------*/
/* this step doesn't have anything to do with CEHBS               */
/* It is only depends on EDD data                                 */
/* It creates a data set for Stata, to run dirifit command        */
/* Stata do file will generate parameters for Dirichlet dist.     */
/* for each firmsize (four categories) and each industry          */
/*----------------------------------------------------------------*/

%let path = data_from_EDD;
%let excel_filename =OES.xls; 
%let sheet_name = OES_FINAL2;

* the above four macro variables will have to be updated;
* no change is needed below, assuming the raw data is in excel format;
* and variable names are the same as in the sample data;
libname outdata "outdata";
libname edd excel "&path.\&excel_filename.";
/*1 Agri/Mining
2 Construction
3 Manufacturing
4 Tran/Util/Comm
5 Wholesale/Retail
6 Financial
7 Service/Govt
8 Healthcare
9 federal
10 state/local
*/
proc format;

value fsize 
    1-49  = '1-49'	
  50-99   = '50-99'
100-499   = '100-499'
500-high  = '500+'
other     =  'invalid size';

value fsizen
      1  = '1-49'	
      2  = '50-99'
      3  = '100-499'
      4  = '500+'
  other  =  'invalid size';

 value $indcat 
     '11', '21'             = '1' 
	   '23'                   = '2'
	   '31', '32', '33'       = '3'
     '22', '48', '49', '51' = '4'
	   '42', '44', '45'       = '5'
	   '52', '53'             = '6'
	   '54','55', '56', 
     '61', '71', '72','81'  = '7'
	   '62'                   = '8'
	   '9991'                 = '9' /*this category doesn't exist in EDD */
	   '9992', '9993'         = '10'
      other = 'Unclassified';
run;

/*create format for firm size and industry/sector in accordance with Calsim*/
data edd1;
  set  edd."&sheet_name.$"n;
  temp = substr(left(NAICS_CODE), 1, 2);
  if temp = '99' then sector = put(substr(left(NAICS_CODE), 1, 4), $indcat.);
  else sector = put(substr(left(NAICS_CODE), 1, 2), $indcat.);
  fsize = put(total, fsize.);
  array mycat(*) a -- l;
  array p_(12); /*compute the proportion in each wage bracket for each firm */
  do index = 1 to dim(mycat);
    if mycat(index) = . then mycat(index) = 0;
	total2 = sum(of a,b,c,d,e,f,g,h,i,j,k,l);
	if total2>0 then 
	p_(index) = mycat(index)/total2;
  end;
  drop index temp;
run;
* redistributing when necessary;
data edd2;
set edd1;
  p1 = sum(of p_1-p_2); /* B: $19,240 - 24,439*/
  p2 = sum(of p_3-p_5);
  p3 = sum(of p_6-p_8);
  p4= sum(of p_9-p_12);

/*shuffle people if one column among p1--p4 is a one*/
  if p1= 1 then do;
    p1= 0.95;
    p2 = (1-p1)/3;
	p3 = (1-p1)/3;
	p4 = (1-p1)/3;
  end;

  if p2 = 1 then do;
	p2 = 0.95;
    p1 = (1-p2)/3;
	p3 = (1-p2)/3;
	p4 = (1-p2)/3;
	end;


  if p3= 1 then do;
	p3= 0.95;
   p1= (1-p3)/3;
   p2 =(1-p3)/3;
   p4 =(1-p3)/3;
   end;

  if p4 = 1 then do;
   p4= 0.95;
   p3= (1-p4)/3;
   p2= (1-p4)/3;
   p1 = (1-p4)/3;
  end;

run;

 
data outdata.edd_coded_ind10;
set edd2(where= (total2>0));
/*length maxVar $32;*/
/*shuffle people around if one column among p1-p4 is zero*/

 array a_[*] p1-p4;
 array flag[*]flag1-flag4 ;
/* array arr[*] p1-p4;*/


/*	array p(*) p1-p4;*/
 maxVar = whichn(max(of a_[*]), of a_[*]);

do i = 1 to dim(a_);
  if a_(i) = 0 then do;
    a_(i)=0.01;
    flag[i] = 1;
  end;
end;

a_[maxVar] = a_[maxVar]-max(sum(of flag1-flag4)*0.01,0);
drop i flag: maxvar;
run;
proc freq data = outdata.edd_coded_ind10;
  tables sector;
run;
proc export data = outdata.edd_coded_ind10 outfile="\edd_coded_cat4.dta" replace;
run;
