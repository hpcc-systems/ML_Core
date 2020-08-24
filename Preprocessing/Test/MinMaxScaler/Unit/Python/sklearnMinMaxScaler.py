from sklearn.preprocessing import MinMaxScaler

data = [[0, -100.5, -500], 
        [1, -200.5, -250], 
        [2, -300.5,    0], 
        [3, -400.5, 1000]]
        
scaler = MinMaxScaler()
scaler.fit(data)
print('maxs:', scaler.data_max_)
print('mins:', scaler.data_min_)

print()
scaledData = scaler.transform(data)
print('scaled data')
print(scaledData)

print()
print('unscaled data')
unscaledData = scaler.inverse_transform(scaledData)
print(unscaledData)