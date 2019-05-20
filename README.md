# expedia-kaggle


## Project Description

The goal of the project(https://www.kaggle.com/c/expedia-hotel-recommendations) is to build a model that better
recommend hotel clusters (Expedia groups hotels into 100 different clusters.) to customers according to their
searching criteria. The given variables provide information regarding when, what, where, and how does a customer
search for a hotel and ultimately if they ended up booking.


| Contents |
|---|
| [Section 00: Data Preparation](0_Data_Preparation/README.md) |
| [Section 01: GBM Model](1_GBM_Model/README.md) |
| [Section 02: Neural Networks Model](2_Neural_Networks_Model/README.md) |

## Conclusion

In conclusion, we ended up using the neural networks as our champion model. When considering the model has to
take into account multi-class target variables, and numerous predictors, it makes sense that neural networks model
was the most competent.

However, through the GBM we were able to see the variable importance, which we reflected in the neural networks
model for better accuracy. We were able to see that search criteria in booking rooms, such as how many people are
staying or how many people are staying in were not important in deciding which clusters it belongs to. Rather,
variables such as where people are going and how early they are booking, which provides more insight into what
kind of this trip is, were important in the model.
