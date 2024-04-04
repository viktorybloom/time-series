import numpy as np
cimport numpy as np
from scipy.stats import norm

def garchlogl(np.ndarray[np.float64_t, ndim=1] theta, np.ndarray[np.float64_t, ndim=1] rets):
    cdef double alfa, beta, gamma, phi
    cdef Py_ssize_t bigt
    cdef np.ndarray[np.float64_t, ndim=1] cvar, logl
    cdef Py_ssize_t t

    alfa = theta[0]
    beta = theta[1]
    gamma = theta[2]
    phi = theta[3]

    bigt = rets.shape[0]

    cvar = np.zeros(bigt, dtype=np.float64)
    logl = np.zeros(bigt, dtype=np.float64)

    cvar[0] = alfa / (1 - beta - gamma - 0.5 * phi)
    logl[0] = norm.pdf(rets[0], 0, np.sqrt(cvar[0]))

    for t in range(1, bigt):
        cvar[t] = alfa + beta * cvar[t-1] + gamma * rets[t-1]**2 + phi * (rets[t-1] < 0) * rets[t-1]**2
        logl[t] = norm.pdf(rets[t], 0, np.sqrt(cvar[t]))

    logl = -np.sum(np.log(logl))

    return logl
