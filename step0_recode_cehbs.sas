/* ---------------------------------------------------------------*/
/* Three new variables are added to CEHBS 2013 data               */
/* They came separatedly from Heidi, in August 2015               */
/*----------------------------------------------------------------*/
%let path = __specify your path here___;
libname in "&path";
proc sort data = in.ca_survey_2013; by nrid; run;
proc sort data = in.Ca_survey_2013_18aug15; by nrid; run;
data temp;
	merge in.CA_Survey_2013 (in=a) in.ca_survey_2013_18aug15(in=b);
	by nrid;
	if a and b then flag = 1;
	else flag = 0;
run;
proc freq data = temp;
  tables flag;
  tables industry;
run;
* recoding industry;
data in.cehbs2013_19aug15;
  set temp (rename=(industry=old_industry));
  if a10 = 2 then industry = 10; /*state and local government */
  else if old_industry = 1           then industry = 1; /*1 Agri/Mining*/
  else if old_industry = 2           then industry = 2; /*2 Construction*/
  else if old_industry = 3           then industry = 3; /*3 Manufacturing*/
  else if old_industry = 4           then industry = 4; /*4 Tran/Util/Comm*/
  else if old_industry in (5, 6)     then industry = 5; /*5 Wholesale/Retail*/
  else if old_industry = 7           then industry = 6; /*6 Financial*/
  else if old_industry = 8           then industry = 7; /*7 Service/Govt*/
  else if old_industry = 9           then industry = 8; /*8 Healthcare*/
  drop old_industry;
  firmsize = totalemp;
run;
proc freq data = in.cehbs2013_19aug15;
  tables a10;
  weight wkrwt;
run;
proc means data = in.cehbs2013_19aug15;
  var firmsize;
run;


