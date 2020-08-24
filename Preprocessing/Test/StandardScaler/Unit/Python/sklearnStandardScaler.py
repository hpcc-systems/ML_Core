from sklearn.preprocessing import StandardScaler

data = [[0, -100.5, -500], 
        [1, -200.5, -250], 
        [2, -300.5,    0], 
        [3, -400.5, 1000]]
        
scaler = StandardScaler()
scaler.fit(data)
print('mean:', scaler.mean_)
print('std:', scaler.scale_)

print()
scaledData = scaler.transform(data)
print('scaled data')
print(scaledData)

print()
print('unscaled data')
unscaledData = scaler.inverse_transform(scaledData)
print(unscaledData)