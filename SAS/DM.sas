**************************************************************************
Program Name : DM.sas
Study Name : NMC-Cryo2
Author : Kato Kiroku
Date : 2019-03-18
SAS version : 9.4
**************************************************************************;


proc datasets library=work kill nolist; quit;

options mprint mlogic symbolgen minoperator;


*^^^^^^^^^^^^^^^^^^^^Current Working Directories^^^^^^^^^^^^^^^^^^^^;

*Find the current working directory;
%macro FIND_WD;

    %local _fullpath _path;
    %let _fullpath=;
    %let _path=;

    %if %length(%sysfunc(getoption(sysin)))=0 %then
      %let _fullpath=%sysget(sas_execfilepath);
    %else
      %let _fullpath=%sysfunc(getoption(sysin));

    %let _path=%substr(&_fullpath., 1, %length(&_fullpath.)
                       -%length(%scan(&_fullpath., -1, '\'))
                       -%length(%scan(&_fullpath., -2, '\')) -2);
    &_path.

%mend FIND_WD;

%let cwd=%FIND_WD;
%put &cwd.;

%inc "&cwd.\program\macro\libname.sas";


proc import datafile="&raw.\�Ǘ�o�^�[.csv"
                    out=baseline
                    dbms=csv replace;
run;
data baseline_2;
    set baseline;
    if _N_=1 then delete;
run;
proc sort data=baseline_2; by subjid; run;

proc import datafile="&raw.\����.csv"
                    out=treatment
                    dbms=csv replace;
run;
data treatment_2;
    set treatment;
    if _N_=1 then delete;
    keep subjid treat_date;
run;
proc sort data=treatment_2; by subjid; run;

data baseline_3;
    merge baseline_2(in=a) treatment_2;
    by subjid;
    if a;
    if treat_date='����';
run;


%macro COUNT (name, var, title, raw);

    proc freq data=&raw noprint;
        tables &var / out=&name;
    run;

    proc sort data=&name; by &var; run;

    data &name._2;
        format Category $12. Count Percent best12.;
        set &name;
        Category=&var;
        if &var=' ' then Category='MISSING';
        percent=round(percent, 0.1);
        drop &var;
    run;

    data &name._2;
        format Item $60. Category $12. Count Percent best12.;
        set &name._2;
        if _N_=1 then do; item="&title"; end;
    run;

    proc summary data=&name._2;
        var count percent;
        output out=&name._total sum=;
    run;

    data &name._total_2;
        format Item $60. Category $12. Count Percent best12.;
        set &name._total;
        item=' ';
        category='���v';
        keep Item Category Count Percent;
    run;

    data x_&name;
        format Item $60. Category $12. Count Percent best12.;
        set &name._2 &name._total_2;
    run;

%mend COUNT;


%macro IQR (name, var, title, rdata);

    data &rdata._2;
        set &rdata;
        c=input(&var., best12.);
        if c=-1 then delete;
        keep c;
        rename c=&var.;
    run;

    proc means data=&rdata._2 noprint;
        var &var;
        output out=&name n=n mean=mean std=std median=median q1=q1 q3=q3 min=min max=max;
    run;

    data &name._frame;
        format Item $60. Category $12. Count Percent best12.;
        Item=' ';
        Category=' ';
        count=0;
        percent=0;
        output;
    run;

    proc transpose data=&name out=&name._2;
        var n mean std median q1 q3 min max;
    run;

    data x_&name;
        merge &name._frame &name._2;
        if _N_=1 then Item="&title.";
        Category=upcase(_NAME_);
        count=round(col1, 0.1);
        call missing(percent);
        keep Item Category Count Percent;
    run;

%mend IQR;


*�N��;
    data age_baseline;
        set baseline_3;
        current=(input(ic_date, YYMMDD10.));
        birth=(input(birthday, YYMMDD10.));
        age=intck('YEAR', birth, current);
        if (month(current) < month(birth)) then age=age - 1;
        else if (month(current) = month(birth)) and day(current) < day(birth) then age=age - 1;
    run;
    %IQR (age, age, �N��, age_baseline);

*����;
    %COUNT (sex, sex, ����, baseline_3);

*���a_�������x����_�B��;
    %COUNT (disease, disease, ���a_�������x����_�B��, baseline_3);

*���a_�������x����_�G����炪��;
    %COUNT (VAR6, VAR6, ���a_�������x����_�G����炪��, baseline_3);

*���a_�������x����_���זE����;
    %COUNT (VAR7, VAR7, ���a_�������x����_���זE����, baseline_3);

*���a_�������x����_���̑�;
    %COUNT (VAR8, VAR8, ���a_�������x����_���̑�, baseline_3);

*�������x����_���̑��ڍ�;
    data bb_baseline;
        set baseline_3;
        if VAR8='�Y������';
        if disease_t1 NE ' ';
    run;
    data x_disease_t1;
        format Item $60. Category $12. Count Percent best12.;
        set bb_baseline;
        if _N_=1 then Item='�������x����_���̑��ڍ�';
        Category=disease_t1;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*���a_�]�ڐ��x����;
    %COUNT (VAR9, VAR9, ���a_�]�ڐ��x����, baseline_3);

*�]�ڐ��x����̌�����;
    data cc_baseline;
        set baseline_3;
        if VAR9='�Y������';
        if disease_t3 NE ' ';
    run;
    data x_disease_t3;
        format Item $60. Category $12. Count Percent best12.;
        set cc_baseline;
        if _N_=1 then Item='�]�ڐ��x����̌�����';
        Category=disease_t3;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*���a_�����p��;
    %COUNT (VAR10, VAR10, ���a_�����p��, baseline_3);

*���a_���̑��̈������;
    %COUNT (VAR11, VAR11, ���a_���̑��̈������, baseline_3);

*���̑��̈������_���̑��ڍ�;
    data dd_baseline;
        set baseline_3;
        if VAR11='�Y������';
        if disease_t2 NE ' ';
    run;
    data x_disease_t2;
        format Item $60. Category $12. Count Percent best12.;
        set dd_baseline;
        if _N_=1 then Item='���̑��̈������_���̑��ڍ�';
        Category=disease_t2;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*�o���X��;
    %COUNT (bleeding, bleeding, �o���X��, baseline_3);

*�o���X������̏ꍇ_�ڍ�;
    data bleeding_baseline;
        set baseline_3;
        if bleeding='����';
    run;
    data x_bleeding_t1;
        format Item $60. Category $12. Count Percent best12.;
        set bleeding_baseline;
        Item='�o���X������̏ꍇ_�ڍ�';
        Category=bleeding_t1;
        count=.;
        percent=.;
        keep Item Category Count Percent;
    run;

*�R�ÌŖ�̓��^;
    %COUNT (anticoagulation, anticoagulation, �R�ÌŖ�̓��^, baseline_3);

*PS;
    %COUNT (PS, PS, PS (ECOG), baseline_3);

*�ؒo�ɖ�g�p;
    %COUNT (muscle_relax, muscle_relax, �ؒo�ɖ�g�p, baseline_3);

*�_�f���^;
    %COUNT (oxygen, oxygen, �_�f���^, baseline_3);

*�o���X������̏ꍇ_�ڍ�;
    data oxy_baseline;
        set baseline_3;
        if oxygen='����';
    run;
    %IQR (oxygen_L, oxygen_L, �_�f���^����̏ꍇ_�_�f���^��_L_��, oxy_baseline);

*SpO2;
    %IQR (Sp02, Sp02, SpO2, baseline_3);



data DM;
    set x_age x_sex x_disease x_VAR6 x_var7 x_var8 x_disease_t1 x_var9 x_disease_t3 x_var10 x_var11 x_disease_t2
    x_bleeding x_bleeding_t1 x_anticoagulation x_PS x_muscle_relax x_oxygen x_oxygen_L x_Sp02;
run;

%ds2csv (data=DM, runmode=b, csvfile=&out.\SAS\DM.csv, labels=N);
