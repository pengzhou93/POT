"""Tests for module utils for timing and parallel computation """

# Author: Remi Flamary <remi.flamary@unice.fr>
#
# License: MIT License


import ot
import numpy as np


def test_parmap():

    n = 100

    def f(i):
        return 1.0 * i * i

    a = np.arange(n)

    l1 = list(map(f, a))

    l2 = list(ot.utils.parmap(f, a))

    np.testing.assert_allclose(l1, l2)


def test_tic_toc():

    import time

    ot.tic()
    time.sleep(0.5)
    t = ot.toc()
    t2 = ot.toq()

    # test timing
    np.testing.assert_allclose(0.5, t, rtol=1e-2, atol=1e-2)

    # test toc vs toq
    np.testing.assert_allclose(t, t2, rtol=1e-2, atol=1e-2)


def test_kernel():

    n = 100

    x = np.random.randn(n, 2)

    K = ot.utils.kernel(x, x)

    # gaussian kernel  has ones on the diagonal
    np.testing.assert_allclose(np.diag(K), np.ones(n))


def test_unif():

    n = 100

    u = ot.unif(n)

    np.testing.assert_allclose(1, np.sum(u))


def test_dist():

    n = 100

    x = np.random.randn(n, 2)

    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            D[i, j] = np.sum(np.square(x[i, :] - x[j, :]))

    D2 = ot.dist(x, x)
    D3 = ot.dist(x)

    # dist shoul return squared euclidean
    np.testing.assert_allclose(D, D2)
    np.testing.assert_allclose(D, D3)


def test_dist0():

    n = 100
    M = ot.utils.dist0(n, method='lin_square')

    # dist0 default to linear sampling with quadratic loss
    np.testing.assert_allclose(M[0, -1], (n - 1) * (n - 1))


def test_dots():

    n1, n2, n3, n4 = 100, 50, 200, 100

    A = np.random.randn(n1, n2)
    B = np.random.randn(n2, n3)
    C = np.random.randn(n3, n4)

    X1 = ot.utils.dots(A, B, C)

    X2 = A.dot(B.dot(C))

    np.testing.assert_allclose(X1, X2)


def test_clean_zeros():

    n = 100
    nz = 50
    nz2 = 20
    u1 = ot.unif(n)
    u1[:nz] = 0
    u1 = u1 / u1.sum()
    u2 = ot.unif(n)
    u2[:nz2] = 0
    u2 = u2 / u2.sum()

    M = ot.utils.dist0(n)

    a, b, M2 = ot.utils.clean_zeros(u1, u2, M)

    assert len(a) == n - nz
    assert len(b) == n - nz2


def test_gpu_fun():

    n = 100

    A = np.ones((n, n))
