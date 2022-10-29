/*===================================================================================*/
/*AVG SALARY IN POLAND*/
/*https://bdl.stat.gov.pl/api/v1/data/by-unit/000000000000?var-id=64428	*/
/*===================================================================================*/

/*===================================================================================*/
/*AVG USD/PLN*/
/*https://api.nbp.pl/api/exchangerates/rates/c/usd/2002-01-02/?format=json*/
/*===================================================================================*/

/*clean work*/
proc datasets library=work kill nolist;quit;

/*get avg salary poland ~ JSON*/
filename tpavgpln temp;
proc http
url='https://bdl.stat.gov.pl/api/v1/data/by-unit/000000000000?var-id=64428&format=json'
method="get" out=tpavgpln;
run;

libname pol_sal JSON fileref=tpavgpln;
 
data tab_salary_poland_pln;
set pol_sal.results_values;
keep ordinal_values year val;
run;

/*USD exchange rate PLN ~ JSON*/

data tab_loop_control_var;
retain id 0;
format date yymmdd10.;
do i = "01JAN2002"d to date();
	date = i;
	id = id + 1;
	output;
end;
drop i;
run;

%macro get_exch_rate;

proc sql noprint;
select max(id) into: var_max_id from tab_loop_control_var
;quit;

%do i = 1 %to &var_max_id;
	
	%put LOOP NUMBER: &i;
	
	proc sql noprint;
	select 
		cats('https://api.nbp.pl/api/exchangerates/rates/c/usd/', put(date, yymmdd10.), '/?format=json') 
		into: var_json_path 
	from tab_loop_control_var where id = &i
	;quit;
	
	filename tpusdpln temp;
	proc http
	url="&var_json_path"
	method="get" out=tpusdpln;
	run;
	
	data tab_html_code_tmp;
	infile tpusdpln length=len;
	input line $varying32767. len;
	line=strip(line);
	run;
	
	data tab_404_error;
	set tab_html_code_tmp;
	where upcase(line) contains('404 NOTFOUND');
	run;
	
	proc sql noprint;
	select count(*) into: var_check_404 from tab_404_error
	;quit;
	
	%macro check_404_err;
	%if &var_check_404 eq 0 %then %do;
		libname exchrate JSON fileref=tpusdpln;
		 
		data tab_exchange_usd_pln_tmp;
		set exchrate.rates;
		keep effectiveDate bid ask;
		run;
		
		proc contents noprint data=work._ALL_ out=tab_in_work;
		run;
		
		proc sql noprint;
		select
			count(*) into: var_check_tab_exch_exist
		from tab_in_work
		where
			lowcase(memname) = 'tab_exchange_usd_pln'
		;quit;
		
		%if &var_check_tab_exch_exist eq 0 %then %do;
			data tab_exchange_usd_pln;
			set tab_exchange_usd_pln_tmp;
			run;
		%end;
		%else %do;
			data tab_exchange_usd_pln;
			set tab_exchange_usd_pln tab_exchange_usd_pln_tmp;
			run;		
		%end;
		
		%put Data was correctly downloaded;
	%end;
	%else %do;
		%put Found error404;
	%end;
	%mend;
	
	%check_404_err;
%end;
%mend;

%get_exch_rate;

/*stats - salary in POLAND in USD year by year*/
proc sql;
create table tab_mean_exchrate_tmp as
select
	year(input(a.effectiveDate, yymmdd10.)) format=best12. as year
	,round((a.bid + a.ask)/2, .0001) as avg_exch_rate
from tab_exchange_usd_pln a
;quit;

proc sql;
create table tab_mean_exchrate as
select
	year
	,round(mean(avg_exch_rate), .0001) as avg_exch_rate_year
from tab_mean_exchrate_tmp
group by year
;quit;

proc sql;
create table tab_salary_poland_USD as
select
	a.ordinal_values as id
	,input(a.year, best12.) as year
	,b.avg_exch_rate_year as exch_rate_avg_usd_pln
	,a.val format=NLNUMI32.2 as salary_PLN
	,round(a.val/b.avg_exch_rate_year, .01) format=NLNUMI32.2 as salary_USD
from tab_salary_poland_pln a
left join tab_mean_exchrate b on input(a.year, best12.) = b.year
;quit;

/*eksport fin img to locate*/

/*tab*/
title color="#00008B" "Salary in Poland (PLN | USD)";
ods graphics on / imagefmt=jpg imagemap=on imagename="SALARY_POLAND_USD" border=off;
options printerpath=png nodate nonumber;
ods printer file="/home/u45585517/sasuser.v94/ZAROBKI_W_POLSCE/IMG/SALARY_POLAND_USD.jpg" style=barrettsblue;
proc print data=tab_salary_poland_USD(drop=id) noobs;
run;
ods printer close;

/*chart*/
ods graphics on /reset=index imagename='SALARY_POLAND_USD_CHART' imagefmt=jpg;
ods listing gpath="/home/u45585517/sasuser.v94/ZAROBKI_W_POLSCE/IMG";
title color="#00008B" "Salary in Poland (PLN | USD)";
proc sgplot data = tab_salary_poland_USD noautolegend;
vbar year/response=salary_PLN datalabel dataskin=crisp fillattrs=(color="#ccf5ff");
vline year/response=salary_USD lineattrs=(color=red pattern=dash) markers markerattrs=(color=red symbol=circlefilled);
yaxis grid display=(nolabel);
run;
ods graphics off;
ods listing close;