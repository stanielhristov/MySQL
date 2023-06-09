CREATE DATABASE online_stores;
USE online_stores;

#1
CREATE TABLE brands(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE reviews(
id INT PRIMARY KEY AUTO_INCREMENT,
content TEXT,
rating DECIMAL(10,2) NOT NULL,
picture_url VARCHAR(80) NOT NULL,
published_at DATETIME NOT NULL
);

CREATE TABLE products(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
price DECIMAL(19,2) NOT NULL,
quantity_in_stock INT,
description TEXT,
brand_id INT NOT NULL,
category_id INT NOT NULL,
review_id INT,
CONSTRAINT fk_products_brands
FOREIGN KEY (brand_id)
REFERENCES brands(id),
CONSTRAINT fk_products_categories
FOREIGN KEY (category_id)
REFERENCES categories(id),
CONSTRAINT fk_products_reviews
FOREIGN KEY (review_id)
REFERENCES reviews(id)
);

CREATE TABLE customers(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
phone VARCHAR(30) NOT NULL UNIQUE,
address VARCHAR(60) NOT NULL,
discount_card BIT NOT NULL DEFAULT 0
);

CREATE TABLE orders(
id INT PRIMARY KEY AUTO_INCREMENT,
order_datetime DATETIME NOT NULL,
customer_id INT NOT NULL,
CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(id)
);

CREATE TABLE orders_products(
order_id INT,
product_id INT,
CONSTRAINT fk_orders_products_orders
FOREIGN KEY (order_id)
REFERENCES orders(id),
CONSTRAINT fk_orders_products_products
FOREIGN KEY (product_id)
REFERENCES products(id)
);

#2
INSERT INTO reviews(content, picture_url, published_at,rating)
SELECT LEFT(p.description, 15), REVERSE(p.name), DATE('2010/10/10'), p.price / 8
FROM products p
WHERE p.id >= 5;

#3
UPDATE products
SET quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock BETWEEN 60 AND 70;

#4
DELETE c FROM customers AS c
LEFT JOIN orders AS o ON c.id = o.customer_id 
WHERE o.customer_id IS NULL;

#5
SELECT * FROM categories
ORDER BY name DESC;

#6
SELECT p.id, p.brand_id, p.name, p.quantity_in_stock 
FROM products as p
WHERE p.price > 1000 AND p.quantity_in_stock < 30
ORDER BY p.quantity_in_stock, p.id;

#7
SELECT * FROM reviews 
WHERE (SELECT content LIKE 'My%') AND LENGTH(content) > 61
ORDER BY rating DESC ;

#8
SELECT CONCAT(c.first_name, ' ', c.last_name) as full_name, c.address, o.order_datetime
FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id
WHERE YEAR(o.order_datetime) <= 2018
ORDER BY full_name DESC;

#9
SELECT COUNT(c.id) AS items_count, c.name, sum(p.quantity_in_stock) AS total_quantity 
FROM  categories AS c 
JOIN products AS p ON c.id = p.category_id
GROUP BY c.id
ORDER BY items_count DESC, total_quantity ASC
LIMIT 5;

#10
DELIMITER $$

CREATE FUNCTION udf_customer_products_count(name VARCHAR(30)) 
RETURNS INT
DETERMINISTIC
BEGIN
DECLARE products_count INT;
SET products_count := (
  SELECT COUNT(c.id) FROM customers AS c
  JOIN orders AS o on c.id = o.customer_id
  JOIN orders_products op ON o.id = op.order_id
  WHERE c.first_name = name);
  RETURN products_count;
END$$

DELIMITER ;

SELECT c.first_name, c.last_name, udf_customer_products_count('Shirley') AS total_products FROM customers AS c
WHERE c.first_name = 'Shirley';

#11
DELIMITER $$
CREATE PROCEDURE udp_reduce_price(category_name VARCHAR(50))
BEGIN
UPDATE products AS p
 JOIN reviews AS r on r.id = p.review_id
 JOIN categories AS c on c.id = p.category_id
 SET p.price = price * 0.70
 WHERE c.name = category_name
 AND r.rating < 4;
END $$
DELIMITER ;

CALL udp_reduce_price('Phones and tablets');









