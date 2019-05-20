A neural network was used to represent the non-linear nature of the relationship between the hotel clusters and the
independent variables and to handle the complexity of classifying into 100 classes.

-Pre-processing for Neural Network

● The target variables cluster labels were converted to numeric levels using the LabelEncoder from
scikit-learn. This does not create an ordered list, however, it assigns a number to each level of the target
variable.
● The x variables were standardized to values between 0 and 1 using the StandardScaler package.

-Building the model

● After multiple iterations, the following model was found to result in the best accuracy metrics on both
training and the test data:
● The 2-layer Neural Network of 200 hidden units each was built using the MLPClassifier.
● The default rectified linear unit function was used as the activation function as it found to be applicable for
a multi-class problem apart from its usual use in binary classification problems.
● Since this function does not take a separate dataset as a validation dataset, training and validation dataset
were combined and the neural network was modeled to use 30% of the combined dataset as a validation
frame and to stop when the validation score was not improving.

Since the target had 100 levels, the probability of being correct by randomly assigning a cluster to a row is 1%, our
accuracy rates were fair. Our evaluation metrics were not too different between the training data and the test data.
Thus, we can be reasonably sure that we have not over-fitted/under-fitted on the training data.

-Picking the top 5 clusters

● Since the problem statement asked for a recommendation of the top 5 most probable hotel clusters, we
extract the labels with the top 5 probabilities for each observation row. We calculate the Mean Average
Precision (MAP@5) for our test data, which calculates a higher score if the correct cluster is predicted
earlier on in the top 5 choices. The MAP@5 on our test data was found to be 0.1284. The Random Guess
Benchmark on the score data on Kaggle was 0.02259.
