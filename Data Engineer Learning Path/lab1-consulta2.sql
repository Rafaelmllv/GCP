SELECT airline, avg(minutes) From `JasmineJasper.triplog`
Where origin = 'LHR' AND destination = 'KUL'
GROUP BY airline ORDER BY avg(minutes) asc;