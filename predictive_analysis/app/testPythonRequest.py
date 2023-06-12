import numpy as np
from flask import Flask, request, jsonify
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import Lasso
from sklearn.linear_model import Ridge
from sklearn.preprocessing import MinMaxScaler

# Load the trained model from the Parquet file
linear_model_df = pd.read_parquet('/Users/abdalrhman/Documents/ml/Linear/data/')
lasso_model_df = pd.read_parquet('/Users/abdalrhman/Documents/ml/Lasso/data/')
ridge_model_df = pd.read_parquet('/Users/abdalrhman/Documents/ml/Ridge/data/')
scaler_df = pd.read_parquet('/Users/abdalrhman/Documents/ml/scaler/data/')

# Extract the model parameters from the DataFrame
linear_coef = np.array(linear_model_df['coefficients.values'].values[0])
lasso_coef = np.array(lasso_model_df['coefficients.values'].values[0])
ridge_coef = np.array(ridge_model_df['coefficients.values'].values[0])

linear_intercept = linear_model_df['intercept'].values[0]
lasso_intercept = lasso_model_df['intercept'].values[0]
ridge_intercept = ridge_model_df['intercept'].values[0]

# Create a LinearRegression model object
lr_model = LinearRegression()
lr_model.coef_ = linear_coef.reshape(1, -1)
lr_model.intercept_ = linear_intercept

# Create a Lasso model object
la_model = Lasso()
la_model.coef_ = lasso_coef.reshape(1, -1)
la_model.intercept_ = lasso_intercept

# Create a Ridge model object
rg_model = Ridge()
rg_model.coef_ = ridge_coef.reshape(1, -1)
rg_model.intercept_ = ridge_intercept

scaler_min = scaler_df['originalMin.values'].values[0]
scaler_max = scaler_df['originalMax.values'].values[0]

scaler = MinMaxScaler()
scaler.fit([list(scaler_min), list(scaler_max)])

# Create a Flask app
app = Flask(__name__)

# Define a route for prediction
@app.route('/predict', methods=['POST'])
def predict():
    # Get the JSON request data from the Flutter frontend
    request_data = request.get_json()
    print(request_data)
    # Extract the features from the request data
    # Assuming the features are in the 'features' field of the JSON request
    features = request_data['features']
    print(features)

    # Convert the features to a NumPy array
    features = np.array(features)
    print(features)

    features = scaler.transform([features])
    print(features)

    # Reshape the features to have the required dimensions (1 row, n columns)
    features = features.reshape(1, -1)
    print(features)

    # Make predictions using the trained model
    lr_predictions = lr_model.predict(features)
    la_predictions = la_model.predict(features)
    rg_predictions = rg_model.predict(features)

    avg = (lr_predictions[0] + la_predictions[0] + rg_predictions[0]) / 3

    # Create a response JSON object
    response = {'prediction': avg[0]}
    print(response)

    # Return the response as JSON
    return response

if __name__ == '__main__':
    # Run the Flask app
    app.run()
