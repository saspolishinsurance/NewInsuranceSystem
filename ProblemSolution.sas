*Compiled by Sebastian Muraszewski;

*#Assigning a new library;
libname Projekt '/home/u49823031/sasuser.v94/Projekt';

*Formatting the data;
proc format;
   value $CNTRY_  
     'AT' = 'Austria';
        value $CNTRY 
     'AT' = 'Austria';
    value PRTDGCL
      1 = 'Very close'  
      2 = 'Quite close'  
      3 = 'Not close'  
      4 = 'Not at all close'  
      6 = 'Not applicable' .a = 'Not applicable'  
      7 = 'Refusal' .b = 'Refusal'  
      8 = 'Don''t know' .c = 'Don''t know'  
      9 = 'No answer' .d = 'No answer';
   	value EISCED
      0 = 'Not possible to harmonise into ES-ISCED'  
      1 = 'ES-ISCED I , less than lower secondary'  
      2 = 'ES-ISCED II, lower secondary'  
      3 = 'ES-ISCED IIIb, lower tier upper secondary'  
      4 = 'ES-ISCED IIIa, upper tier upper secondary'  
      5 = 'ES-ISCED IV, advanced vocational, sub-degree'  
      6 = 'ES-ISCED V1, lower tertiary education, BA level'  
      7 = 'ES-ISCED V2, higher tertiary education, >= MA level'  
      55 = 'Other'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer' ;
     value GNDR
      1 = 'Male'  
      2 = 'Female'  
      9 = 'No answer' .d = 'No answer' ; 
     value TRSTPRT
      0 = 'No trust at all'  
      1 = '1'  
      2 = '2'  
      3 = '3'  
      4 = '4'  
      5 = '5'  
      6 = '6'  
      7 = '7'  
      8 = '8'  
      9 = '9'  
      10 = 'Complete trust'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer'; 
     value POLINTR
      1 = 'Very interested'  
      2 = 'Quite interested'  
      3 = 'Hardly interested'  
      4 = 'Not at all interested'  
      7 = 'Refusal' .b = 'Refusal'  
      8 = 'Don''t know' .c = 'Don''t know'  
      9 = 'No answer' .d = 'No answer';
     value NWSPOL
      7777 = 'Refusal' .b = 'Refusal'  
      8888 = 'Don''t know' .c = 'Don''t know'  
      9999 = 'No answer' .d = 'No answer';    
run;

data aut01;
 length country $20;
	set Projekt.ess9at;
	country = putc(cntry,'$cntry');
	format cntry $cntry. PRTDGCL PRTDGCL. EISCED EISCED. GNDR GNDR. TRSTPRT TRSTPRT. POLINTR POLINTR. NWSPOL NWSPOL.;
run;

*Overview of answers from questions about closeness to the preferred political party;
%let Var=PRTDGCL;
proc freq data=aut01;
	table &Var. / out=f01;
run;

*Creating a histogram of the answers without "Not applicable", "Refusal", "Don't know" and "No answer" groups;
proc sgplot data=aut01;
 vbar &Var. / stat=percent;
 where &Var.<6;
run;

*Creating dichotomized variable Y based on variable PRTDGCL
0-1 - close (Y=1)
2-3 - not close (Y=0);
proc format;
   value y 
     0 = 'not close'
     1 = 'close';
run;

data aut02;
	set aut01;
	if PRTDGCL <= 2 then y = 1;
	else if 3 <= PRTDGCL <= 4 then y=0;
	else if PRTDGCL > 4 then y = .;
	format y y.;
run;

*Checking the closeness to the certain political party among young people and elder ones;
%let Var=AGEA;
proc freq data=aut02;
	table y / out=f02;
	where 18<=&Var.<=29 AND ^missing(y);
run;

proc freq data=aut02;
	table y / out=f02;
	where &Var.>=60 AND ^missing(y);
run;

*Overview of the education level of the respondents by EISCED norm;
ods graphics on;
%let Var=EISCED;
proc freq data=aut02;
	table &Var. / out=f01;
	where 1<=&Var.<=7 AND ^missing(y);
run;

*Checking the distribution of closeness to the political parties among the education groups;
proc sgpanel data=aut02;
	panelby y / columns=1;
	histogram &Var.;
	where 1<=&Var.<=7 AND ^missing(y);
run;

*Overview of the gender of the respondents;
ods graphics on;
%let Var=GNDR;
proc freq data=aut02;
	table &Var. / out=f01;
	where ^missing(y);
run;

*Checking the distribution of closeness to the political parties due to gender;
proc sgpanel data=aut02;
	panelby y / columns=1;
	histogram &Var.;
	where ^missing(y);
run;

*Overview of the trust in political parties;
ods graphics on;
%let Var=TRSTPRT;
proc freq data=aut02;
	table &Var. / out=f01;
	where ^missing(y);
run;

*Checking the distribution of closeness to the political parties due to trust in all of them;
proc sgpanel data=aut02;
	panelby y / columns=1;
	histogram &Var.;
	where 1<=&Var.<=10 AND ^missing(y);
run;

*# formatting new variable POLINTR_REV with the proper labels;
proc format;
     value POLINTR_REV
      1 = 'Not at all interested'
      2 = 'Hardly interested'
      3 = 'Quite interested'
      4 = 'Very interested'
      7 = 'Refusal' .b = 'Refusal'  
      8 = 'Don''t know' .c = 'Don''t know'  
      9 = 'No answer' .d = 'No answer';
run;

*Reversing the scale of POLINTR variable and assigning  new variable POLINTR_REV in the new dataset;
data aut03;
	set aut02;
	if POLINTR > 4 then POLINTR_REV = .; *if value is bigger than 4, then possible options are not defined as a clear opinion and will be deleted; 
	else if POLINTR <= 4 then POLINTR_REV = 5 - POLINTR;
	format POLINTR_REV POLINTR_REV.;
run;

*Checking the frequency and size of different groups in our new variable;
ods graphics on;
%let Var = POLINTR_REV;
proc freq data = aut03;
	table &Var. / out = f01;
	where ^missing(y);
run;

*Checking the distribution of closeness to the political parties due to having an interest in politics;
proc sgpanel data=aut03;
	panelby y / columns=1;
	histogram &Var.;
	where ^missing(y);
run;

*Checking the frequency of different choices to choose a cut-off point needed to create a new binary variable about the time spent to listen, read or watch news about politics and current affairs;
ods graphics on;
%let Var=NWSPOL;
proc freq data = aut03;
	table &Var. / out = f01;
	where ^missing(y);
run;

*Creating binary variable NWSPOL_NEW based on variable NWSPOL
<= 45 -> 45 minutes or less (NWSPOL_NEW  = 0)
> 45 min - more than 45 minutes (NWSPOL_NEW  = 1);
proc format;
   value NWSPOL_NEW
     0 = '45 minutes or less'
     1 = 'more than 45 minutes';
run;

data aut04;
	set aut03;
	if NWSPOL <= 45 then NWSPOL_NEW = 0;
	else if 45 <= NWSPOL < 7777 then NWSPOL_NEW = 1;
	format NWSPOL_NEW NWSPOL_NEW.;
run;


*Creating a frequency table of a new binary variable about the time spent to listen, read or watch news about politics and current affairs;
ods graphics on;
%let Var=NWSPOL_NEW;
proc freq data = aut04;
	table &Var. / out = f01;
	where ^missing(y);
run;

*Checking the distribution of closeness to the political parties due to a new variable;
proc sgpanel data=aut04;
	panelby y / columns=1;
	histogram &Var.;
	where ^missing(y) and ^missing(NWSPOL_NEW);
run;


/* *Model estimation with all needed diagnostics tools; */
/* ods graphics on; */
/* proc logistic data=aut04 alpha=0.05 plots(only)=(roc effect oddsratio); *inputting dataset and plot ROC curve; */
/*     class EISCED (param=ref ref= 'ES-ISCED I , less than lower secondary') GNDR (param=ref ref= 'Male') TRSTPRT (param=ref ref= 'No trust at all') POLINTR_REV (param=ref ref= 'Not at all interested') NWSPOL_NEW (param=ref ref= 'more than 45 minutes'); *setting reference categories to the proper variables; */
/*     model y(event='close') = AGEA|EISCED|GNDR|TRSTPRT|POLINTR_REV|NWSPOL_NEW   / expb /*model specification */
/*     	aggregate scale = none lackfit /*Assesing goodness-of-fit */
/*     	selection = backward sle = 0.2 */
/* 		influence; /*checking the influence    */
/*     ods output Influence=inf01; /*output data */
/* 	output out=p p=pred difdev=difdev difchisq=difchisq h=leverage c=c; */
/* 	where ^missing(y) and ^missing(AGEA) and ^missing(GNDR) and 1<=EISCED<=7 and ^missing(GNDR) and 0<=TRSTPRT<=10 and 1<=POLINTR_REV<=7 and ^missing(NWSPOL_NEW); */
/* run; */
/* ods graphics off; */

*Adding last category to second to the last in TRSTPRT to resolve issues with odds ratio;
data aut05;
	set aut04;
	if TRSTPRT = 10 then TRSTPRT = 9;
run;

*Model estimation with the corrections;
ods graphics on;
proc logistic data=aut05 alpha=0.1 plots(only)=(roc effect oddsratio); *inputting dataset and plot ROC curve;
    class EISCED (param=ref ref= 'ES-ISCED I , less than lower secondary') GNDR (param=ref ref= 'Male') TRSTPRT (param=ref ref= 'No trust at all') POLINTR_REV (param=ref ref= 'Not at all interested') NWSPOL_NEW (param=ref ref= 'more than 45 minutes'); *setting reference categories to the proper variables;
    model y(event='close') =  TRSTPRT POLINTR_REV agea*POLINTR_REV gndr*POLINTR_REV agea*gndr*POLINTR_REV POLINTR_REV * NWSPOL_NEW  / expb /*model specification*/
    	aggregate scale = none lackfit rsq /*Assesing goodness-of-fit*/
		influence; /*checking the influence*/   
    ods output Influence=inf01; /*output data*/
	output out=p p=pred difdev=difdev difchisq=difchisq h=leverage c=c;
	where ^missing(y) and ^missing(AGEA) and ^missing(GNDR) and 1<=EISCED<=7 and ^missing(GNDR) and 0<=TRSTPRT<=9 and 1<=POLINTR_REV<=7 and ^missing(NWSPOL_NEW);
run;
ods graphics off;




