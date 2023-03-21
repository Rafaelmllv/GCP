SELECT airline, avg(minutes) From `JasmineJasper.triplog`
Where origin = 'FRA' AND destination = 'KUL'
GROUP BY airline;