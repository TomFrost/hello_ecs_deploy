const express = require('express')

const app = express()

app.get('/', (req, res) => {
  res.send('Hey world!')
})

app.listen(8081)

