-- Create the database
create database air_cargo;
select * from customer;
select * from passengers_on_flights;
select * from routes;
select * from ticket_details;
-- Use the air_cargo database
USE air_cargo;

-- First, add primary key to Customer table if it doesn't exist
ALTER TABLE Customer
ADD PRIMARY KEY (customer_id);

-- Add primary key to routes table if needed
ALTER TABLE routes
ADD PRIMARY KEY (route_id);

-- Now add the foreign key constraints
ALTER TABLE passengers_on_flights
ADD CONSTRAINT fk_pof_customer 
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

ALTER TABLE passengers_on_flights
ADD CONSTRAINT fk_pof_route 
FOREIGN KEY (route_id) REFERENCES routes(route_id);

ALTER TABLE ticket_details
ADD CONSTRAINT fk_ticket_customer 
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

-- Check current structure of tables
DESCRIBE Customer;
DESCRIBE routes;
DESCRIBE passengers_on_flights;
DESCRIBE ticket_details;

-- Check for existing keys
SHOW KEYS FROM Customer;
SHOW KEYS FROM routes;

-- Check for duplicate customer_ids
SELECT customer_id, COUNT(*) 
FROM Customer 
GROUP BY customer_id 
HAVING COUNT(*) > 1;

-- Check for duplicate route_ids
SELECT route_id, COUNT(*) 
FROM routes 
GROUP BY route_id 
HAVING COUNT(*) > 1;

-- Check existing foreign keys on passengers_on_flights
SELECT 
    CONSTRAINT_NAME, 
    TABLE_NAME, 
    COLUMN_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'passengers_on_flights' 
AND TABLE_SCHEMA = 'air_cargo'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Check existing foreign keys on ticket_details
SELECT 
    CONSTRAINT_NAME, 
    TABLE_NAME, 
    COLUMN_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'ticket_details' 
AND TABLE_SCHEMA = 'air_cargo'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Try adding foreign key for passengers_on_flights to Customer (if missing)
ALTER TABLE passengers_on_flights
ADD CONSTRAINT fk_passengers_customer 
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

-- Try adding foreign key for passengers_on_flights to routes (if missing)
ALTER TABLE passengers_on_flights
ADD CONSTRAINT fk_passengers_route 
FOREIGN KEY (route_id) REFERENCES routes(route_id);

-- See all foreign keys in your database
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME, 
    COLUMN_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'air_cargo'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;

-- Sample query: Get customer travel details with route information
SELECT 
    c.first_name, 
    c.last_name, 
    p.travel_date, 
    r.origin_airport, 
    r.destination_airport,
    p.class_id
FROM Customer c
JOIN passengers_on_flights p ON c.customer_id = p.customer_id
JOIN routes r ON p.route_id = r.route_id
LIMIT 10;

-- Check how much data you have
SELECT 'Customers' as table_name, COUNT(*) as row_count FROM Customer
UNION ALL
SELECT 'Routes', COUNT(*) FROM routes
UNION ALL
SELECT 'Passengers on Flights', COUNT(*) FROM passengers_on_flights
UNION ALL
SELECT 'Ticket Details', COUNT(*) FROM ticket_details;

-- Check date ranges
SELECT 
    MIN(travel_date) as earliest_flight,
    MAX(travel_date) as latest_flight
FROM passengers_on_flights;

CREATE TABLE route_details (
    route_id INT NOT NULL,
    flight_num VARCHAR(20) NOT NULL,
    origin_airport VARCHAR(50) NOT NULL,
    destination_airport VARCHAR(50) NOT NULL,
    aircraft_id VARCHAR(20) NOT NULL,
    distance_miles INT NOT NULL,
    
    -- Constraints
    CONSTRAINT pk_route_id PRIMARY KEY (route_id),
    CONSTRAINT uq_route_id UNIQUE (route_id),
    CONSTRAINT chk_flight_num CHECK (flight_num IS NOT NULL AND flight_num != ''),
    CONSTRAINT chk_distance_miles CHECK (distance_miles > 0)
);

/*3.	Write a query to display all the passengers (customers) 
who have travelled in routes 01 to 25. 
Take data from the passengers_on_flights table.*/

SELECT DISTINCT
    p.customer_id,
    c.first_name,
    c.last_name,
    p.route_id,
    p.flight_num,
    p.travel_date,
    p.depart,
    p.arrival,
    p.seat_num,
    p.class_id
FROM passengers_on_flights p
JOIN Customer c ON p.customer_id = c.customer_id
WHERE p.route_id BETWEEN 1 AND 25
ORDER BY p.route_id, p.customer_id;

/*4.	Write a query to identify the number of passengers 
and total revenue in business class from the ticket_details table.*/
SELECT 
    SUM(no_of_tickets) AS number_of_passengers,
    SUM(no_of_tickets * price_per_ticket) AS total_revenue
FROM ticket_details
WHERE class_id = 'Bussiness';

/*5.	Write a query to display the full name of the customer
 by extracting the first name and last name from the customer table.*/
 
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM Customer;

/*6.	Write a query to extract the customers who have registered and booked a 
ticket. Use data from the customer and ticket_details tables.*/
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.date_of_birth,
    c.gender
FROM Customer c
INNER JOIN ticket_details t ON c.customer_id = t.customer_id;
/*7.	Write a query to identify the customer’s 
first name and last name based on their customer ID and brand 
(Emirates) from the ticket_details table.*/
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    t.brand
FROM Customer c
INNER JOIN ticket_details t ON c.customer_id = t.customer_id
WHERE t.brand = 'Emirates';
/*8.	Write a query to identify the customers who have travelled by Economy 
Plus class using Group By and Having clause on the passengers_on_flights table. */
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(*) AS number_of_flights
FROM Customer c
INNER JOIN passengers_on_flights p ON c.customer_id = p.customer_id
WHERE p.class_id = 'Economy Plus'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(*) > 0;
/*9.	Write a query to identify whether the revenue has 
crossed 10000 using the IF clause on the ticket_details table.*/
SELECT 
    SUM(no_of_tickets * price_per_ticket) AS total_revenue,
    IF(SUM(no_of_tickets * price_per_ticket) > 10000, 
       'Yes, Revenue crossed 10000', 
       'No, Revenue has not crossed 10000') AS revenue_status
FROM ticket_details;
/*10.	Write a query to create and 
grant access to a new user to perform operations on a database..*/
-- Create a new user
CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'secure_password123';

-- Grant all privileges on the air_cargo database to the new user
GRANT ALL PRIVILEGES ON air_cargo.* TO 'new_user'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;
/*11.	Write a query to find the maximum ticket price for each class using 
window functions on the ticket_details table. */
SELECT DISTINCT
    class_id,
    MAX(price_per_ticket) OVER (PARTITION BY class_id) AS max_ticket_price
FROM ticket_details
ORDER BY class_id;
/*12.	Write a query to extract the passengers whose route ID is 
4 by improving the speed and performance of the passengers_on_flights table. */
-- Create index on route_id to improve query speed
CREATE INDEX idx_route_id ON passengers_on_flights(route_id);

-- Now run the optimized query
SELECT *
FROM passengers_on_flights
WHERE route_id = 4;
SHOW INDEX FROM passengers_on_flights;
-- Check execution plan (shows if index is being used)
EXPLAIN SELECT * 
FROM passengers_on_flights 
WHERE route_id = 4;
-- Analyze table to update statistics
ANALYZE TABLE passengers_on_flights;

-- Optimize table to defragment and reclaim space
OPTIMIZE TABLE passengers_on_flights;
/*For the route ID 4, write a query to view the 
execution plan of the passengers_on_flights table.*/
EXPLAIN SELECT * 
FROM passengers_on_flights 
WHERE route_id = 4;
/*14.	Write a query to calculate the total price of all tickets 
booked by a customer across different aircraft IDs using rollup function. */
SELECT 
    customer_id,
    aircraft_id,
    SUM(no_of_tickets * price_per_ticket) AS total_price
FROM ticket_details
GROUP BY customer_id, aircraft_id WITH ROLLUP;

/*15.	Write a query to create a view with only 
business class customers along with the brand of airlines. */
CREATE VIEW business_class_customers AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.date_of_birth,
    c.gender,
    t.brand,
    t.class_id,
    t.price_per_ticket,
    t.no_of_tickets,
    t.p_date
FROM Customer c
INNER JOIN ticket_details t ON c.customer_id = t.customer_id
WHERE t.class_id = 'Bussiness';
/*16.	Write a query to create a stored procedure to get 
the details of all passengers flying between a range of routes defined in run time. 
Also, return an error message if the table doesn't exist.*/
DELIMITER $$

CREATE PROCEDURE GetPassengersByRouteRange(
    IN start_route INT,
    IN end_route INT
)
BEGIN
    -- Declare variables for error handling
    DECLARE table_exists INT DEFAULT 0;
    
    -- Check if the passengers_on_flights table exists
    SELECT COUNT(*) INTO table_exists
    FROM information_schema.tables 
    WHERE table_schema = 'air_cargo' 
    AND table_name = 'passengers_on_flights';
    
    -- If table doesn't exist, return error message
    IF table_exists = 0 THEN
        SELECT 'Error: passengers_on_flights table does not exist' AS error_message;
    ELSE
        -- Table exists, execute the query
        SELECT 
            p.customer_id,
            c.first_name,
            c.last_name,
            p.route_id,
            p.flight_num,
            p.aircraft_id,
            p.depart,
            p.arrival,
            p.seat_num,
            p.class_id,
            p.travel_date,
            r.origin_airport,
            r.destination_airport,
            r.distance_miles
        FROM passengers_on_flights p
        INNER JOIN Customer c ON p.customer_id = c.customer_id
        INNER JOIN routes r ON p.route_id = r.route_id
        WHERE p.route_id BETWEEN start_route AND end_route
        ORDER BY p.route_id, p.travel_date;
    END IF;
END$$

DELIMITER ;

-- Get passengers for routes 1 to 25
CALL GetPassengersByRouteRange(1, 25);

-- Get passengers for routes 10 to 50
CALL GetPassengersByRouteRange(10, 50);

-- Get passengers for a specific route
CALL GetPassengersByRouteRange(4, 4);
/*17.	Write a query to create a stored procedure that extracts 
all the details from the
routes table where the travelled distance is more than 2000 miles.*/
DROP PROCEDURE IF EXISTS GetLongDistanceRoutes;

DELIMITER $$

CREATE PROCEDURE GetLongDistanceRoutes()
BEGIN
    SELECT 
        route_id,
        flight_num,
        origin_airport,
        destination_airport,
        aircraft_id,
        distance_miles
    FROM routes
    WHERE distance_miles > 2000
    ORDER BY distance_miles DESC;
END$$

DELIMITER ;

-- Call it
CALL GetLongDistanceRoutes();
/*18.	Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel
 (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500.*/
-- Drop if exists
DROP PROCEDURE IF EXISTS CategorizeFlightsByDistance;

-- Create the procedure (copy one of the versions above)
DELIMITER $$
CREATE PROCEDURE CategorizeFlightsByDistance()
BEGIN
    -- procedure code here
END$$
DELIMITER ;

-- Call it
CALL CategorizeFlightsByDistance();

SELECT COUNT(*) FROM routes;
SELECT * FROM routes LIMIT 10;
SELECT 
    MIN(distance_miles) AS min_distance,
    MAX(distance_miles) AS max_distance,
    COUNT(*) AS total_routes
FROM routes;
/*20.	Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the specific class using a stored function in stored procedure on the ticket_details table. 
Condition: 
●	If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No
*/
DELIMITER $$

CREATE FUNCTION CheckComplimentaryServices(class_type VARCHAR(50))
RETURNS VARCHAR(3)
DETERMINISTIC
BEGIN
    DECLARE service VARCHAR(3);
    
    IF class_type IN ('Business', 'Bussiness', 'Economy Plus') THEN
        SET service = 'Yes';
    ELSE
        SET service = 'No';
    END IF;
    
    RETURN service;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE GetTicketComplimentaryServices()
BEGIN
    SELECT 
        p_date AS ticket_purchase_date,
        customer_id,
        class_id,
        CheckComplimentaryServices(class_id) AS complimentary_services
    FROM ticket_details
    ORDER BY p_date, customer_id;
END$$

DELIMITER ;

CALL GetTicketComplimentaryServices();

SELECT DISTINCT class_id FROM ticket_details;

-- Test the function directly
SELECT CheckComplimentaryServices('Business') AS result;
SELECT CheckComplimentaryServices('Economy Plus') AS result;
SELECT CheckComplimentaryServices('Economy') AS result;

-- Call the procedure
CALL GetTicketComplimentaryServices();

/*20.	Write a query to extract the first record of the customer whose 
last name ends with Scott using a cursor from the customer table.*/
-- Drop the existing procedure
DROP PROCEDURE IF EXISTS GetFirstScottCustomer;

-- Now create the new one
DELIMITER $$

CREATE PROCEDURE GetFirstScottCustomer()
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_first_name VARCHAR(50);
    DECLARE v_last_name VARCHAR(50);
    DECLARE v_date_of_birth VARCHAR(50);  -- Changed to VARCHAR to handle any format
    DECLARE v_gender VARCHAR(10);
    DECLARE done INT DEFAULT 0;
    
    DECLARE customer_cursor CURSOR FOR
        SELECT customer_id, first_name, last_name, date_of_birth, gender
        FROM Customer
        WHERE last_name LIKE '%Scott'
        ORDER BY customer_id
        LIMIT 1;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN customer_cursor;
    
    FETCH customer_cursor INTO v_customer_id, v_first_name, v_last_name, v_date_of_birth, v_gender;
    
    IF done = 0 THEN
        SELECT 
            v_customer_id AS customer_id,
            v_first_name AS first_name,
            v_last_name AS last_name,
            v_date_of_birth AS date_of_birth,
            v_gender AS gender;
    ELSE
        SELECT 'No customer found with last name ending in Scott' AS message;
    END IF;
    
    CLOSE customer_cursor;
END$$

DELIMITER ;

-- Call the procedure
CALL GetFirstScottCustomer();