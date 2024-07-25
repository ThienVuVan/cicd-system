module.exports = {
    port: process.env.CONTAINER_BACKEND_PORT,
    db: {
        database: process.env.DB_NAME,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        dialect: process.env.DB_DIALECT,
        host: process.env.DB_HOST,
        port: process.env.DB_PORT
    },
    authentication: {
        jwtSecret: process.env.JWT_SECRET
    }
}
