
data phillips;
set phillips;
du = dif(u);                           * create difference;
retain date '1jan70'd;                 * date variable;
date=intnx('month',date,1);              * update dates;
format date yymmc.;                     * format for date;
year = 1970 + int((_n_-1)/12);          * year;
month = mod(_n_-1, 12) + 1;               * quarter;
run;
ods graphics on;                            * must turn ODS on;
proc autoreg data=phillips plots(unpack);
model inf = du / godfrey=1 dwprob;
output out=phillipsout r=ehat p=infhat;              * save residuals;
title 'Phillips curve with ODS graphics';
run;
proc gplot data= phillipsout;                                                                                                         
   plot  inf*date infhat*date /
      overlay 
        legend = legend2 
      name='SCAT'                                                                                                                       
      description="Plot Inflation rate and Forcasted Inflation rate"  
      haxis=axis1 hminor=4
      vaxis=axis2 vminor=4
      caxis = BLACK                                                                                                                     
      ctext = BLACK                                                                                                                    
      cframe = beige
      grid
     ;          
      run;
proc model data=phillips;
 label b1='intercept'
 b2='du';
 inf = b1 + b2*du;
 fit inf / gmm kernel=(bart,4,0);       * fit 'inf' with HAC std errors;
 title 'Phillips curve with HAC standard errors';
 run; 
 data phillips;                         * open data set;
set phillips;   * read data;
 inf1 = lag(inf);                       * lag of inf;
 inf2 = lag2(inf);
 inf3 = lag3(inf);
 inf4 = lag4(inf);
 inf5 = lag5(inf);
 inf6 = lag6(inf);
 inf7 = lag7(inf);
 inf8 = lag8(inf);
 inf9 = lag9(inf);
 inf10 = lag10(inf);
 inf11 = lag11(inf);
 inf12 = lag12(inf);
 du1 = lag(du);                         * lag of du;
 proc autoreg data=phillips;
 model inf = inf1 du du1;
 title 'Phillips Curve, ARDL(1,1) model';
 run;
/* test of nonlinear hypothesis using PROC MODEL */
proc model data=phillips; * initiate model;
label delta='intercept'
theta1='inf1'
delta0='du'
delta1='du1';
inf = delta+theta1*inf1+delta0*du+delta1*du1;
fit inf;
test delta1 = -theta1*delta0;          * test H0: d1=-theta1*d0;
title 'ARDL model with test of H0:delta1=-theta1*delta0';
run;
proc autoreg data=phillips;
 model inf = inf1 du / godfrey=5;
 title 'proc autoreg ARDL(1,0) model';
 run;
 proc autoreg data=phillips;
 model inf = inf1 inf2 inf3 inf4 inf5 inf6 inf7 inf8 inf9 inf10 inf12 du / godfrey=12;
 title 'proc autoreg ARDL(12,0) model';
 run;
%dftest(Phillips,inf,ar=1,outstat=dfout);     * Dickey-Fuller test;
proc print data=dfout;                 * print results;
title 'Dickey-Fuller test for Inflation ';
run;
%dftest(Phillips,du,ar=1,outstat=dfout);     * Dickey-Fuller test;
proc print data=dfout;                 * print results;
title 'Dickey-Fuller test for Dunemployment';
run;
