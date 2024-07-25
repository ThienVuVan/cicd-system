const request = require("supertest");
const app = require("../app");

describe("ProductsController", () => {
  it("should get all products", async () => {
    const response = await request(app).get("/api/products/getAllProducts");
    expect(response.status).toBe(200);
    expect(response.body).toBeInstanceOf(Array);
  });

  it("should get top selling products", async () => {
    const limit = 5;
    const response = await request(app).get(`/api/products/topSellProduct/${limit}`);
    expect(response.status).toBe(200);
    expect(response.body).toBeInstanceOf(Array);
    expect(response.body.length).toBeLessThanOrEqual(limit);
  });

  it("should get newly added products", async () => {
    const limit = 5;
    const response = await request(app).get(`/api/products/newAddProduct/${limit}`);
    expect(response.status).toBe(200);
    expect(response.body).toBeInstanceOf(Array);
    expect(response.body.length).toBeLessThanOrEqual(limit);
  });

  it("should get product sales", async () => {
    const productId = 1;
    const response = await request(app).get(`/api/products/getProductSales/${productId}`);
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("sales");
  });

  it("should get a single product by ID", async () => {
    const productId = 1;
    const response = await request(app).get(`/api/products/getProduct/${productId}`);
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("id", productId);
  });

  it("should get a product rating", async () => {
    const productId = 1;
    const response = await request(app).get(`/api/products/getProductRating/${productId}`);
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("rating");
    expect(response.body).toHaveProperty("peopleRated");
  });
});
