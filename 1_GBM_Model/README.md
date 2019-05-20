## Gradient Boosting Machine Model

Gradient Boosting Machine was used to firstly conduct a multi-class classification. Because this was initial
modeling on the data, Grid Search was used in order not to constrain the parameters unnecessarily and let the search
do the model selection.

#### Pre-processing and building the GBM model

- H2O was used for GBM because the dataset has a combination of numerical and categorical data in the
predictors.

- The target variable was converted into categorical variables to ensure that the values in the target
variables(numbers) were not mistakenly read as numerical variables in the model.

#### Accuracy

- The mean per-class error for the training model was 0.8939 and for the test model was 0.9853, thus
implying that the model was overfitted.
- Although the model was run multiple times with different combinations of hyperparameters, the overfitting
issue was not resolved.

#### Variable Importance

- Through the GBM analysis, the following variables were ranked with the top relative variable importance.
It is notable that the location of the trip destination, and how early the person is booking a room for the trip
has the highest importance. Especially the high importance of book_advance_day implies that there are
unique differences in what kind of hotels or even trips people go on depending on how early they book.
