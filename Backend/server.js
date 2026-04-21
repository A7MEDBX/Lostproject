const express = require('express');
const logger = require('morgan');
const app = express();
require('dotenv').config();
const http = require('node:http');
require('./loaders/sys_req');
const routes = require('./Routes/app.route');
const server = http.createServer(app);
const port = process.env.PORT || 3500;
const { Server} = require('socket.io');
const io = new Server(server,{
    cors:{
        origin: '*'
}});


io.on('connection',(socket)=>{
    console.log('a user connected:', socket.id);
});

app.use(express.json());
app.use(logger('dev'))
app.get('/',(req,res)=>{
    res.send('Welcome to Finder App Backend');
});
app.use('/api/v1', routes);
server.listen(port,()=>{

    console.log(`backend running on port ${port}`);
})
