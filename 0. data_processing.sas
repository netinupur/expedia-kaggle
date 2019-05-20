/* Expedia Hotel Recommendation Kaggle Competition (https://www.kaggle.com/c/expedia-hotel-recommendations)*/

/*Group 10*/

/*Group Members: Maggie Wang, Nupur Neti, YooNa Cha, Thuy Anh Nguyen*/

/*Data Pre-processing*/

%sysfunc(pathname(work));

/***************************************Handle Nulls****************************************************/

data train;
set sasuser.train;
run;

proc means data=train NMISS;
run;

/*There are three variables that have missing values.
  srch_ci has 47083 missing values.
  srch_co has 47084 missing values.
  orig_destination_distance has 13525001 missing values.
  */

/*remove observations when srch_ci or srch_co is missing. Orig_destination_distance would be dropped in the next session*/
data train;
set train;
	if srch_ci = '' | srch_co = '' then delete;
run;



/**********************************************************************************************************/
/************************Create, Re-code, and Drop Independent Vairables************************************/
/**********************************************************************************************************/


/*variables to create:
	-length_stay (numeric): difference between search check in date and search check out date
	-book_advance_day (numeric): difference between search check in date and search date
	-srch_ci_month (categorical): extract month from search check in date
    -srch_dayofweek (categorical): extract day of week from search date time
    -srch_ci_dayofweek (categorical): extract day of week from check in date
*/


/*variables to re-code:
	-user_location_id (string): assign sequential numbers to all unique combinations of user_location_region and user_location_country
	-hotel_location_id (string): assign sequential numbers to all unique combinations of hotel_continent, hotel_country and hotel_market
*/


/*variables to drop:
	srch_date, user_location_country, user_location_region, user_location_city, hotel_continent, hotel_country,
	hotel_market, site_name, posa_continent, orig_destination_distance, and is_mobile
*/

/***********************************Start Coding the Above Steps********************************************/


/*convert date time to date*/
data train;
set train;
	/*convert date time to date*/
	srch_date = datepart(date_time);
	format srch_date YYMMDD10.;
	/*Extract day of week from date time*/
	srch_dayofweek = weekday(srch_date);
run;

data train;
set train;
	/*extract month from srch_ci*/
	srch_ci_month = month(srch_ci);
	/*extract day of week from srch_ci*/
	srch_ci_dayofweek = weekday(srch_ci);
	/*calculate the length of a hotel stay*/
	length_stay = intck('day',srch_ci,srch_co);
	/*calculate how many days in advanced the user search for a hotel*/
	book_advance_day = intck('day',srch_date,srch_ci);	
run;

/* Create user_location_id table
   Our group decided to keep user location at the region level instead of city level to avoid high-cardinality.*/
data user_location_id;
set train(keep = user_location_country user_location_region);
user_location_id = 1;
run;
proc sort data=user_location_id;
by user_location_country user_location_region;
run;
proc means data=user_location_id noprint;
	var user_location_id;
	by user_location_country user_location_region;
	output out=user_location_id
	mean(user_location_id) = user_location_id;
run;
data user_location_id (drop = _TYPE_ _FREQ_);
set user_location_id;
user_location_id = _n_;
run;

/* Create hotel_location_id table
   Our group decided to keep hotel location at market level because country is too big to distinguish hotels.*/
data hotel_location_id;
set train(keep = hotel_continent hotel_country hotel_market);
hotel_location_id = 1;
run;
proc sort data=hotel_location_id;
by hotel_continent hotel_country hotel_market;
run;
proc means data=hotel_location_id noprint;
	var hotel_location_id;
	by hotel_continent hotel_country hotel_market;
	output out=hotel_location_id
	mean(hotel_location_id) = hotel_location_id;
run;
data hotel_location_id (drop = _TYPE_ _FREQ_);
set hotel_location_id;
hotel_location_id = _n_;
run;

/*Join hotel location IDs and user location IDs on the training data*/

proc sort data = train;
	by hotel_continent hotel_country hotel_market;
run;
data train;
	merge train(in=x) hotel_location_id;
	by hotel_continent hotel_country hotel_market;
	if x;
run;
proc sort data = train;
	by user_location_country user_location_region ;
run;
data train;
	merge train(in=x) user_location_id;
	by user_location_country user_location_region ;
	if x;
run;

/*Due to insufficient information regarding timezone, all rows where srch date is after srch check in date are deleted.*/
 data train;
 set train;
 if srch_date> srch_ci
 then delete;
 run;

/*Drop all variables that are not useful*/
data train;
set train(drop=srch_date user_location_country user_location_region user_location_city 
			   hotel_continent hotel_country hotel_market site_name posa_continent 
			   orig_destination_distance is_mobile);
run;

proc sort data=train;
by user_id srch_destination_id hotel_location_id srch_ci srch_co DESCENDING date_time;
run;

/*Reorder the columns*/
data train;
retain hotel_cluster user_id srch_destination_id hotel_location_id srch_ci srch_co date_time
user_location_id srch_destination_type_id channel is_package is_booking srch_ci_month srch_ci_dayofweek srch_dayofweek
srch_adults_cnt srch_children_cnt srch_rm_cnt length_stay book_advance_day cnt;
set train;
run;


/*************************************************************************************************/
/************************************Roll Up Date Set ********************************************/
/*************************************************************************************************/

/* A unique observation is identified by unque combination of user ID, srch_destination_id, hotel_location_id, srch_ci, and srch_co.
   In English, a unique observation identifies a user who search/click/book a hotel in one market in a particular city with the same
   check in and check out day.
*/

/*The data set is grouped by user_id, srch_destination_id, hotel_location_id, srch_ci, and srch_co.

  Numeric independent variables are computed in the following.
	mean(srch_adults_cnt) = srch_adults_cnt
	mean(srch_children_cnt) = srch_children_cnt
	mean(srch_rm_cnt) = srch_rm_cnt
	mean(length_stay) = length_stay
	max(book_advance_day) = book_advance_day
	sum(cnt) = cnt 

  All other categorical variables including the target variable, hotel cluster are computed by selecting the most 
  recent values of the record in each unique group. This requires proper sorting by date time.
*/

/***********************************Start Rolling Up**********************************************/

data train_numeric;
set train (keep = user_id srch_destination_id hotel_location_id srch_ci srch_co
srch_adults_cnt srch_children_cnt srch_rm_cnt length_stay book_advance_day cnt);
run;

data train_categorical;
set train (keep = hotel_cluster user_id srch_destination_id hotel_location_id srch_ci srch_co date_time
user_location_id srch_destination_type_id channel is_package is_booking srch_ci_month srch_ci_dayofweek srch_dayofweek);
run;

/*roll up data set with all numerical variables*/
proc means data=train_numeric noprint; 
	var srch_adults_cnt srch_children_cnt srch_rm_cnt length_stay book_advance_day cnt;
	by user_id srch_destination_id hotel_location_id srch_ci srch_co;
		output out = group_numeric 
		mean(srch_adults_cnt) = srch_adults_cnt
		mean(srch_children_cnt) = srch_children_cnt
		mean(srch_rm_cnt) = srch_rm_cnt
		mean(length_stay) = length_stay
		max(book_advance_day) = book_advance_day
		sum(cnt) = cnt;
run;

/*round numerical values to avoid meaningless value of any variables*/
data group_numeric (drop = _type_ _freq_);
set group_numeric;
	srch_adults_cnt = round(srch_adults_cnt);
	srch_children_cnt = round(srch_children_cnt);
	srch_rm_cnt = round(srch_rm_cnt);
	length_stay = round(length_stay);
run;

/*Note that dataset has been sorted in the previous session. The first row in each row is defined by the most recent
  date time. All categorical varaibles corresponding to this row is taken while rolling up the data.*/
data group_categorical;
set train_categorical;
	by user_id srch_destination_id hotel_location_id srch_ci srch_co;
		if first.srch_co then do;
		hotel_cluster = hotel_cluster;
		user_location_id =user_location_id;
		srch_destination_type_id=srch_destination_type_id;
		channel=channel; 
		is_package=is_package; 
		is_booking=is_booking; 
		srch_ci_month=srch_ci_month; 
		srch_ci_dayofweek=srch_ci_dayofweek; 
		srch_dayofweek=srch_dayofweek;
		output;
	end;
run;

/*put all variables back in one table*/
data cleaned_data;
	 merge group_categorical(in=a) group_numeric (in = b);
	 by user_id srch_destination_id hotel_location_id srch_ci srch_co;
	 if a and b;
 run;


/************************************************************************************************************/
/****************************Split Data into Train, Validate, and Test Data Sets*****************************/
/************************************************************************************************************/


/*The dataset is too huge to feed in NN model without crashing THE laptop. 
  Therefore, 10% of the dataset is selected randomly for modeling*/
proc surveyselect data=cleaned_data
   method=srs n=1405419 out=sample_data;
run;

/*sort data by date_time so that data can be splitted in date_time order*/
proc sort data = sample_data;
by date_time;
run;

/*The first 40% of the dataset is training data becasue they should be the least recent records.*/
data final_train;
set sample_data (obs = 562167);
run;
/*The middle 30% of the dataset is validation data.*/
data final_valid;
set sample_data (firstobs = 562168 obs=983793);
run;
/*The last 30% of the dataset is test data becasue they should be the more recent records.*/
data final_test;
set sample_data(firstobs= 983794);
run;

/*Export data into csv*/
proc export
data=final_train
outfile='C:/Users/asus/Desktop/train.csv'
dbms=csv
replace;
run;

proc export
data=final_valid
outfile='C:/Users/asus/Desktop/valid.csv'
dbms=csv
replace;
run;

proc export
data=final_test
outfile='C:/Users/asus/Desktop/test.csv'
dbms=csv
replace;
run;

/*Note that other data pre-processing steps, such as target encoing and dummy encoding were done in Python notebook.*/


/*The following code is used to randomly split data into train, validate ,and test sets.
  It has not been used in the assignment becasue data is splitted based on time steamp.*/

/*Sample (10% of entire data set) and split data into train (4%), test (3%), and validate (3%) data sets.*/

%let propTrain = 0.04;         /* proportion of trainging data */
%let propValid = 0.03;         /* proportion of validation data */
%let propTest = %sysevalf(0.1 - &propTrain - &propValid); /* remaining are used for testing */

data Train Validate Test;
	array p[2] _temporary_ (&propTrain, &propValid);
	set final;
	call streaminit(123);         /* set random number seed */
	/* RAND("table") returns 1, 2, or 3 with specified probabilities */
	_k = rand("Table", of p[*]);
	if      _k = 1 then output Train; /*least recent*/
	else if _k = 2 then output Validate;
	else                output Test; /*most recent*/
	drop _k;
run;




