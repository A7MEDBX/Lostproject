const express =require('express');
const Router = express.Router();
const userRoute=require('./user.route');
const adminRoute=require('./admin.route');
const PostRoute=require('./post.route');
const MatchingRoute = require('./matching.route');
const ContactReqRoute = require('./contactReq.route');
const ChatRoute = require('./chat.route');

Router.use('/user',userRoute);
Router.use('/admin',adminRoute);
Router.use('/post',PostRoute);
Router.use('/match', MatchingRoute);
Router.use('/contact-request', ContactReqRoute);
Router.use('/chat', ChatRoute);
Router.get('/status',(req,res)=>{
    res.status(200).send('API working correctly');
})
module.exports=Router;