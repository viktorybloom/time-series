import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm, t

# +

# Load data
data = pd.read_csv("data/spxvix.csv")

# +

# Get data types of each column
data_types = data.dtypes
print(data_types)

print(data.head())

# +

# Summarise returns series
mean_return = data['rets'].mean()
n = data['rets'].count()

# +

# Parametric VaR on returns, normal distribution
mu = mean_return
sigma = data['rets'].std()
VaR95 = norm.ppf(0.05, mu, sigma)
VaR97 = norm.ppf(0.03, mu, sigma)
VaR99 = norm.ppf(0.01, mu, sigma)

# +

# Parametric VaR on returns, student's t distribution
t_df = 5  # Degrees of freedom
VaR95_t = t.ppf(0.05, t_df, mu, sigma)
VaR97_t = t.ppf(0.03, t_df, mu, sigma)
VaR99_t = t.ppf(0.01, t_df, mu, sigma)

# +

# EWMA for VaR
lambda_ = 0.95
data['r2'] = data['rets'] ** 2
ewma = data['r2'].ewm(alpha=lambda_, adjust=False).mean()
data['VaRewma95'] = mean_return + np.sqrt(ewma) * norm.ppf(0.05)
data['VaRewma97'] = mean_return + np.sqrt(ewma) * norm.ppf(0.03)
data['VaRewma99'] = mean_return + np.sqrt(ewma) * norm.ppf(0.01)

# +

# GARCH(1,1) volatility model
omega = 0.01
alpha = 0.1
beta = 0.8

conditional_volatility = [0]
for i in range(1, len(data)):
    conditional_volatility.append(np.sqrt(omega + alpha * data['rets'].iloc[i-1]**2 + beta * conditional_volatility[-1]**2))

# +

data['conditional_volatility'] = conditional_volatility
data['VaRgarch95'] = mean_return + data['conditional_volatility'] * norm.ppf(0.05)
data['VaRgarch97'] = mean_return + data['conditional_volatility'] * norm.ppf(0.03)
data['VaRgarch99'] = mean_return + data['conditional_volatility'] * norm.ppf(0.01)

# +

# Plotting
plt.figure(figsize=(10, 6))
plt.plot(data['rets'], label='Returns', color='black')
plt.plot(data['VaRewma95'], label='VaR EWMA 95%', linestyle='--')
plt.plot(data['VaRewma97'], label='VaR EWMA 97%', linestyle='--')
plt.plot(data['VaRewma99'], label='VaR EWMA 99%', linestyle='--')
plt.legend()
plt.show()

# +

plt.figure(figsize=(10, 6))
plt.plot(data['rets'], label='Returns', color='black')
plt.plot(data['VaRgarch95'], label='VaR GARCH 95%', linestyle='--')
plt.plot(data['VaRgarch97'], label='VaR GARCH 97%', linestyle='--')
plt.plot(data['VaRgarch99'], label='VaR GARCH 99%', linestyle='--')
plt.legend()
plt.show()

# +

# Compute VaR standard errors
data['residuals'] = data['rets'] / data['conditional_volatility']
data['VaR_SE'] = np.sqrt((omega + alpha * data['residuals'].shift(1) ** 2 + beta * data['conditional_volatility'].shift(1)) * (data['conditional_volatility'] ** 2))

data['VaRplusSE'] = data['VaRgarch95'] + data['VaR_SE']
data['VaRminusSE'] = data['VaRgarch95'] - data['VaR_SE']

# +

# Plot VaR standard errors
plt.figure(figsize=(10, 6))
plt.plot(data['rets'], label='Returns', color='black')
plt.plot(data['VaRgarch95'], label='VaR GARCH 95%', linestyle='--')
plt.plot(data['VaRplusSE'], label='VaR + SE', linestyle='--')
plt.plot(data['VaRminusSE'], label='VaR - SE', linestyle='--')
plt.legend()
plt.show()

# +

# Expected Shortfall
ES95 = norm.pdf(norm.ppf(1 - 0.95)) / (1 - 0.95)
ES97 = norm.pdf(norm.ppf(1 - 0.97)) / (1 - 0.97)
ES99 = norm.pdf(norm.ppf(1 - 0.99)) / (1 - 0.99)
print("Expected Shortfall (95%):", ES95)
print("Expected Shortfall (97%):", ES97)
print("Expected Shortfall (99%):", ES99)
