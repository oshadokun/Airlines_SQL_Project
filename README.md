# ✈️ Air Cargo SQL Analytics Project

## 📌 Project Overview

This project demonstrates a complete SQL-based analytical workflow using an **Air Cargo operational dataset**.  

The goal is to simulate real-world responsibilities of a **Data Analyst**, including:

- Relational database design
- Data integrity enforcement
- Revenue and passenger analysis
- Performance optimization
- Advanced SQL implementation (views, window functions, stored procedures, functions, cursors)
- Business insight generation

The project uses structured CSV datasets and transforms them into a fully relational MySQL database system.

---

# 📂 Dataset Files Used

The following CSV files were used as the raw datasets:

- `customer.csv`
- `passengers_on_flights.csv`
- `routes.csv`
- `ticket_details.csv`

Each file represents a core entity within the air cargo passenger and ticketing ecosystem.

---

# 🗃 Data Model Structure

## 1️⃣ Customer
Stores passenger demographic details.

Key fields:
- `customer_id`
- `first_name`
- `last_name`
- `date_of_birth`
- `gender`

---

## 2️⃣ Routes
Contains route-level flight metadata.

Key fields:
- `route_id`
- `flight_num`
- `origin_airport`
- `destination_airport`
- `aircraft_id`
- `distance_miles`

---

## 3️⃣ Passengers_On_Flights
Captures actual travel records.

Key fields:
- `customer_id`
- `route_id`
- `flight_num`
- `travel_date`
- `class_id`
- `seat_num`
- `depart`
- `arrival`

---

## 4️⃣ Ticket_Details
Stores ticket purchase and pricing information.

Key fields:
- `customer_id`
- `class_id`
- `brand`
- `no_of_tickets`
- `price_per_ticket`
- `aircraft_id`
- `p_date`

---

# 🏗 Database Setup

```sql
CREATE DATABASE air_cargo;
USE air_cargo;
````

---

# 🔐 Data Integrity Implementation

## Primary Keys

```sql
ALTER TABLE Customer
ADD PRIMARY KEY (customer_id);

ALTER TABLE routes
ADD PRIMARY KEY (route_id);
```

## Foreign Keys

```sql
ALTER TABLE passengers_on_flights
ADD CONSTRAINT fk_pof_customer 
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

ALTER TABLE passengers_on_flights
ADD CONSTRAINT fk_pof_route 
FOREIGN KEY (route_id) REFERENCES routes(route_id);

ALTER TABLE ticket_details
ADD CONSTRAINT fk_ticket_customer 
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);
```

This ensures referential integrity across customer, route, and ticket data.

---

# 📊 Analytical Queries Implemented

## Passengers Traveling on Routes 1–25

```sql
SELECT DISTINCT
    p.customer_id,
    c.first_name,
    c.last_name,
    p.route_id,
    p.travel_date
FROM passengers_on_flights p
JOIN Customer c 
ON p.customer_id = c.customer_id
WHERE p.route_id BETWEEN 1 AND 25;
```

---

## Business Class Revenue Analysis

```sql
SELECT 
    SUM(no_of_tickets) AS number_of_passengers,
    SUM(no_of_tickets * price_per_ticket) AS total_revenue
FROM ticket_details
WHERE class_id = 'Business';
```

---

## Full Name Construction

```sql
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM Customer;
```

---

## Customers Who Booked Tickets

```sql
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM Customer c
JOIN ticket_details t
ON c.customer_id = t.customer_id;
```

---

## Emirates Brand Customers

```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name
FROM Customer c
JOIN ticket_details t
ON c.customer_id = t.customer_id
WHERE t.brand = 'Emirates';
```

---

## Economy Plus Travelers (GROUP BY & HAVING)

```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(*) AS number_of_flights
FROM Customer c
JOIN passengers_on_flights p
ON c.customer_id = p.customer_id
WHERE p.class_id = 'Economy Plus'
GROUP BY c.customer_id, c.first_name, c.last_name;
```

---

## Revenue Threshold Check (IF Logic)

```sql
SELECT 
    SUM(no_of_tickets * price_per_ticket) AS total_revenue,
    IF(SUM(no_of_tickets * price_per_ticket) > 10000,
       'Revenue crossed 10000',
       'Revenue below threshold') AS revenue_status
FROM ticket_details;
```

---

# 🚀 Advanced SQL Features Demonstrated

## Window Function

Maximum ticket price per class:

```sql
SELECT DISTINCT
    class_id,
    MAX(price_per_ticket)
    OVER (PARTITION BY class_id) AS max_ticket_price
FROM ticket_details;
```

---

## ROLLUP Aggregation

```sql
SELECT 
    customer_id,
    aircraft_id,
    SUM(no_of_tickets * price_per_ticket) AS total_price
FROM ticket_details
GROUP BY customer_id, aircraft_id WITH ROLLUP;
```

---

# ⚡ Performance Optimization

## Index Creation

```sql
CREATE INDEX idx_route_id
ON passengers_on_flights(route_id);
```

## Execution Plan Analysis

```sql
EXPLAIN SELECT * 
FROM passengers_on_flights 
WHERE route_id = 4;
```

## Table Optimization

```sql
ANALYZE TABLE passengers_on_flights;
OPTIMIZE TABLE passengers_on_flights;
```

---

# 👁 Views

Business Class Customers Reporting View:

```sql
CREATE VIEW business_class_customers AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    t.brand,
    t.class_id
FROM Customer c
JOIN ticket_details t
ON c.customer_id = t.customer_id
WHERE t.class_id = 'Business';
```

---

# ⚙ Stored Procedures

## Dynamic Route Filter

```sql
CALL GetPassengersByRouteRange(1, 25);
```

## Long Distance Routes

```sql
CALL GetLongDistanceRoutes();
```

---

# 🧠 Stored Function

Complimentary Service Logic:

```sql
SELECT CheckComplimentaryServices('Business');
```

Business and Economy Plus classes return "Yes".

---

# 🔄 Cursor Implementation

Extract first customer whose last name ends with "Scott":

```sql
CALL GetFirstScottCustomer();
```

---

# 🔑 Access Control

```sql
CREATE USER 'new_user'@'localhost'
IDENTIFIED BY 'secure_password123';

GRANT ALL PRIVILEGES ON air_cargo.* 
TO 'new_user'@'localhost';

FLUSH PRIVILEGES;
```

---

# 📈 Business Insights Derived

* Route utilization patterns
* Revenue segmentation by class
* Premium brand customer identification
* Distance-based flight categorization
* Revenue threshold validation
* Complimentary service eligibility
* Maximum pricing analysis per class

---

# 🧩 Data Analyst Competencies Demonstrated

✔ Relational database modeling
✔ Revenue analytics
✔ Customer segmentation
✔ Window functions
✔ Performance tuning
✔ Execution plan analysis
✔ Stored procedures & functions
✔ Views for reporting
✔ Access control management
✔ Cursor handling

---

# 🏁 Conclusion

This project represents a complete SQL analytical workflow aligned with real-world **Data Analyst responsibilities** in aviation, logistics, and transportation industries.

It combines:

* Data governance
* Performance optimization
* Business analytics
* Reporting structures
* Advanced SQL logic


```
```
