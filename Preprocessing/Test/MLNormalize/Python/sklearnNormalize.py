from sklearn import preprocessing

X = [[4, 1, 2, 2],
     [1, 3, 9, 3],
     [5, 7, 5, 1]]

l1NormalizedX, l1Norm = preprocessing.normalize(X, 'l1' ,return_norm=True)
print('L1 Norm:', l1Norm)
print()
print('L1 Normalized Data')
print(l1NormalizedX)

print()

l2NormalizedX, l2Norm = preprocessing.normalize(X, 'l2' ,return_norm=True)
print('L2 Norm:', l2Norm)
print()
print('L2 Normalized Data')
print(l2NormalizedX)

print()

lInfNormalizedX, lInfNorm = preprocessing.normalize(X, 'max' ,return_norm=True)
print('LInfinity Norm:', lInfNorm)
print()
print('LInf Normalized Data')
print(lInfNormalizedX)
