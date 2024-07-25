const express = require("express");
const serveStatic = require("serve-static");
const history = require("connect-history-api-fallback");
const enforce = require("express-sslify");

const app = express();

app.use(serveStatic(__dirname + "/dist"));
app.use(history());
app.use(enforce.HTTPS({ trustProtoHeader: true }));

app.listen(process.env.CONTAINER_FRONTEND_PORT);