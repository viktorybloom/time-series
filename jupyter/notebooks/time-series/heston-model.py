#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import matplotlib.pyplot as plt


# In[2]:


# Parameters
S0 = 100        # Initial stock price
mu = 0.05       # Drift
v0 = 0.10        # Initial volatility
kappa = 3.0     # Mean reversion speed
theta = 0.1     # Long-term mean volatility
sigma = 0.2     # Volatility of volatility
rho = -0.5      # Correlation between stock price and volatility
T = 1           # Time horizon
N = 252         # Number of time steps
dt = T / N      # Time increment


# In[3]:


# Generate random numbers for the stock price and volatility
np.random.seed()  # for reproducibility
W1 = np.random.standard_normal(size=N)
W2 = rho * W1 + np.sqrt(1 - rho ** 2) * np.random.standard_normal(size=N)


# In[4]:


# Initialize arrays to store simulated stock prices and volatilities
S = np.zeros(N+1)
v = np.zeros(N+1)
S[0] = S0
v[0] = v0

# Simulate the Heston model using Euler discretization
for t in range(1, N+1):
    v[t] = np.maximum(v[t - 1] + kappa * (theta - v[t - 1]) * dt +
                      sigma * np.sqrt(v[t - 1] * dt) * W2[t - 1], 0)
    S[t] = S[t - 1] * np.exp((mu - 0.5 * v[t - 1]) * dt +
                             np.sqrt(v[t - 1] * dt) * W1[t - 1])


# In[5]:


# Plot the simulated stock prices and volatilities
plt.figure(figsize=(10, 6))
plt.subplot(2, 1, 1)
plt.plot(S, label='Stock Price')
plt.title('Monte Carlo Simulation - Stochastic Volatility Model')
plt.xlabel('Time Steps')
plt.ylabel('Price')
plt.legend()


# In[6]:


plt.subplot(2, 1, 2)
plt.plot(v, label='Volatility')
plt.xlabel('Time Steps')
plt.ylabel('Volatility')
plt.legend()
plt.tight_layout()
plt.show()

