libname egz "/home/u49823031/sasuser.v94/Exam";



proc freq data=egz.df82575;
 tables LifeSBin*Gender / relrisk; /*subscribed - y, personal_loan - x*/
run;

ods graphics on;
proc logistic data=egz.df82575 alpha=0.05 plots(only)=(effect oddsratio roc);
	class Gender (param=ref ref='1');
	model LifeSBin(event='0')= Gender / clodds=pl lackfit rsq ctable /*pprob=0.4*/;
run;


*Cumulative logit model;
proc logistic data=egz.df82575 alpha=0.05 plots(only)=(effect oddsratio roc);
	class SubHealth (param=ref ref='1') Income (param=ref ref='10') HouseWork (param=ref ref='1') Retired (param=ref ref='1') SocialActivities (param=ref ref='3');
	model LifeS = SubHealth Income HouseWork Retired SocialActivities Age YearOfEducation / expb;
	output out=out p=p;
run;