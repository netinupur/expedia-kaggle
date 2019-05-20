## Data Preparation


#### 1. Handle Null Values

There are three variables (srch_in, srch_co, and orig_destination_distance) that have missing values. 
All rows with missing “srch_ci” or “srch_co” were dropped because there is no way to populate this information and we do not
want our model to handle nulls. The column “orig_destination_distance” was dropped because it makes no sense to
remove 13MM rows from the data set.

#### 2. Create Date/Time Related Variables
Based on time related variables available in the data set, we created the following new variables that we thought
would be relevant to the model.
- length_stay (numeric): the dif erence between search check-in date and search check out date
- book_advance_day (numeric): the dif erence between search check-in date and search date
- srch_ci_month (categorical): extract month from search check-in date
- Srch_dayofweek (categorical): extract days of the week from search date time
- Srch_ci_dayofweek (categorical): extract days of the week from check-in date

#### 3. Re-code User Location Related Variables and Hotel Location Related Variables
Unique combinations of the user location related variables (user location country and region) and hotel location
(hotel continent, country, and market) related variables were each given a new ID called ‘user_location_id’ and
‘hotel_location_id’, which were later encoded according to ‘is_booking’. We kept user location at the regional level
instead of city level to avoid high-cardinality. 

We kept the hotel location related variables at the market level because the country is too big to distinguish hotels.

#### 4. Drop Incorrect or Unnecessary Data
All rows where the search date is after search check-in date was deleted due to insufficient information regarding
time zone.
All unnecessary variables in the following were dropped. (Variables are dropped in SAS)
*Srch_date, user_location_country, user_location_region, user_location_city, hotel_continent,
hotel_country, hotel_market, site_nam,e posa_continent, orig_destination_distance, is_mobile,
srch_destination_id, user_id, is_booking*

#### 5. Roll Up Data
A unique observation is identified by unique combination of user ID, srch_destination_id, hotel_location_id,
srch_ci, and srch_co. In English, a unique observation identifies a user who search/click/book a hotel in one market
in a particular city with the same check-in and check-out day.
When rolling up the data, numeric independent variables were computed in the following.

- Mean: srch_adults_cnt, srch_children_cnt, srch_rm_cnt, length_stay
- Max: book_advance_day
- Sum: cnt(count)

All other categorical variables including the target variable, hotel cluster are computed by selecting the most recent
values of the record in each unique group.

#### 6. Target Encoding
After rolling up the data, two of the fields, ‘user_location_id’ and ‘hotel_location_id’ were found to have over 2000
levels. In order to avoid the problems of a high-cardinality predictor, we target-encoded these two columns. Since
our target had 100 levels, a Leave-one-out encoding or Dummy-encoding would not have been suitable thus we
decided to encode these two columns using the ‘is_booking’ column as a target. The target encoder was fit on the
training data, then it was used to transform the train, validation, and test data.

#### 7. Dummy Encoding
Since we decided to use the python package scikit-learn to build our neural network and scikit-learn accepts only
numerical inputs, we had to create dummy variables for the categorical variables ‘channel’ and
‘srch_destination_type_id’ each of which was a low-cardinality variable and hence we felt comfortable that dummy
encoding them would not create a sparse matrix.

**Our final 29 independent variables are :**
['is_package', 'is_booking', 'srch_adults_cnt', 'srch_children_cnt', 'srch_rm_cnt', 'length_stay', 'book_advance_day',
'cnt', 'hotel_location_id_te', 'user_location_id_te', 'srch_destination_type_id'(8 variables), 'channel’(11 variables)]

*Note that through running some initial models that are not provided in this report, we dropped some variables that
didn’t assist in increasing the accuracy scores to decrease the dimensionality, such as days of weeks.*

#### 8. Create Train, Validate, and Test Data
Due to insufficient computer power, 10% of the dataset was selected randomly for modeling. Data was split into
train, validate, and test data according to the date-time order of each observation. The least recent 40% of the
randomly selected data went into training data. The middle 30% of the randomly selected data went into validate
data. The most recent 30% of the randomly selected data went into test data.

*Note that train, validate, and test data had been created before target encoding and dummy encoding was performed so that laptops would not crash when processing huge dataset.*
