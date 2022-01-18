/*1. What is the company’s revenue per month? Compare each month value with the average revenue per month. */

select strftime('%m', p.payment_date) as month, 
    sum(p.amount) as revenue_per_month, 
    count (distinct customer_id) as nbr_customers,
    count (distinct payment_id) as nbr_transactions,
    case when sum(p.amount) < avg_revenue_per_month then 'below'
        when sum(p.amount) = avg_revenue_per_month then 'equal'
        else 'higher' end as compare_with_average
from payment p, 
    (select sum(p.amount)/count(distinct strftime('%m', p.payment_date)) as avg_revenue_per_month 
    from payment p)
group by 1
order by 1;

/*2. How many customers do we have?*/

select 'Total: ' as Notes, count(*) as Number_of_customers
from customer
union
select 'Active customers: ', count(*) 
from customer
where active = 1
union
select 'Non-active customers: ', count(*) 
from customer
where active = 0;

/*3: Create a new column  "types_of_customers" to categorize the customers.*/
/*If the time of purchases of a customer is greater than the average purchases per customer, then the customer is regular, else the customer is non-regular. */
/*How may customer in its type? Calculate average purchases per type.*/

select frequency, count(*) as nbr_customers, sum(number_of_purchases)/count(frequency) as avg_number_of_purchases
from (select p.customer_id, 
    count(*) as number_of_purchases,
    case when count(*) > avg_total_purchases and active = 1 then 'regular'
    else 'non-regular' end as frequency       
    from payment p, customer cr,
    (select count(*)/count(distinct p.customer_id) as avg_total_purchases
    from payment p) 
where p.customer_id = cr.customer_id
group by 1)
group by 1;

/* 4.Create a new column called loyalty to divide customers into three groups based on how long the customers have been with the company (rely on ‘2016-01-01’ and the first payment date of each customer).*/
/* If the tenure is less than eight months and the customer still rents DVD, then the customer is new; if the term is greater than eight months and the customer still rents DVDs, the customer is loyal.*/
/* . If the customer is no longer rents DVDs, then the customer is disloyal. Show the number of customers for each type of loyalty and tenure.*/

select loyalty, tenure, count(distinct customer_id) as nuber_of_customers
from (select p.customer_id, active,
    (strftime('%m', '2006-01-01') - min(strftime('%m',p.payment_date))+ 12) as tenure,
    case when (strftime('%m', '2006-01-01') - min(strftime('%m',p.payment_date))+ 12) <= 8  and cr.active = 1 then 'new'
        when (strftime('%m', '2006-01-01') - min(strftime('%m',p.payment_date))+ 12) > 8  and cr.active = 1 then 'loyal'
        else 'disloyal' end as loyalty
        from payment p, customer cr
        where p.customer_id = cr.customer_id
        group by 1)
group by 1, 2;

/*5. What is the total revenue, number of customers and average revenue for each country. Order the total revenue descending*/

select c.country, sum(p.amount) as revenue_per_country, 
        count (distinct p.customer_id) as nbr_customers, 
        sum(p.amount)/total as pct_of_revenue
from payment p, customer cr, address a, city cy, country c,
    (select sum(p.amount) as total from payment p)
where p.customer_id = cr.customer_id and
    cr.address_id = a.address_id and
    a.city_id = cy.city_id and
    cy.country_id = c.country_id
group by 1
order by 2 desc
limit 10;

/*6. What is the total revenue, number of customers, average revenue, and percentage of revenue of each market? Order the result by total revenue in descending.*/

/***Create a new table continent***/
create table continent(
    continent_id text primary key,
    continent_name text not null
);

insert into continent(continent_id, continent_name)
values
        ('AF', 'Africa'),
        ('AS', 'Asia'),
        ('EU', 'Europe'),
        ('NA', 'North America'),
        ('SA', 'South America'),
        ('OC', 'Oceania'),
        ('AN', 'Antarctica');
        
/***Create a new table market***/        
create table market(
    country_id  SMALLINT     NOT NULL primary key,
    country     VARCHAR (50) NOT NULL,
    continent_code text
);


insert into market(country_id, country, continent_code)
values
    (1, 'Afghanistan', 'AS'), (2, 'Algeria', 'AF'), 
    (3, 'American Samoa', 'OC'), (4, 'Angola', 'AF'), 
    (5, 'Anguilla', 'NA'), (6, 'Argentina', 'SA'), 
    (7, 'Armenia', 'AS'), (8, 'Australia', 'OC'), 
    (9, 'Austria', 'EU'), (10, 'Azerbaijan', 'AS'), 
    (11, 'Bahrain', 'AS'), (12, 'Bangladesh', 'AS'), 
    (13, 'Belarus', 'EU'), (14, 'Bolivia', 'SA'), 
    (15, 'Brazil', 'SA'), (16, 'Brunei', 'AS'), 
    (17, 'Bulgaria', 'EU'), (18, 'Cambodia', 'AS'), 
    (19, 'Cameroon', 'AF'), (20, 'Canada', 'NA'), 
    (21, 'Chad', 'AF'), (22, 'Chile', 'SA'), 
    (23, 'China', 'AS'), (24, 'Colombia', 'SA'), 
    (25, 'Congo', 'AF'), (26, 'Czech Republic', 'EU'), 
    (27, 'Dominican Republic', 'NA'),(28, 'Ecuador', 'SA'), 
    (29, 'Egypt', 'AF'), (30, 'Estonia', 'EU'), 
    (31, 'Ethiopia', 'AF'), (32, 'Faroe Islands', 'EU'), 
    (33, 'Finland', 'EU'), (34, 'France', 'EU'), 
    (35, 'French Guiana', 'SA'), (36, 'French Polynesia', 'OC'), 
    (37, 'Gambia', 'AF'), (38, 'Germany', 'EU'), 
    (39, 'Greece', 'EU'), (40, 'Greenland', 'NA'), 
    (41, 'Holy See (Vatican City State)', 'EU'), (42, 'Hong Kong', 'AS'), 
    (43, 'Hungary', 'EU'), (44, 'India', 'AS'), 
    (45, 'Indonesia', 'AS'), (46, 'Iran', 'AS'), 
    (47, 'Iraq', 'AS'), (48, 'Israel', 'AS'), 
    (49, 'Italy', 'EU'), (50, 'Japan', 'AS'), 
    (51, 'Kazakstan', 'AS'), (52, 'Kenya', 'AF'), 
    (53, 'Kuwait', 'AS'), (54, 'Latvia', 'EU'),
    (55, 'Liechtenstein', 'EU'), (56, 'Lithuania', 'EU'), 
    (57, 'Madagascar', 'AF'), (58, 'Malawi', 'AF'), 
    (59, 'Malaysia', 'AS'), (60, 'Mexico', 'NA'), 
    (61, 'Moldova', 'EU'), (62, 'Morocco','AF'), 
    (63, 'Mozambique', 'AF'), (64, 'Myanmar', 'AS'), 
    (65, 'Nauru', 'OC'), (66, 'Nepal', 'AF'), 
    (67, 'Netherlands', 'EU'), (68, 'New Zealand', 'OC'), 
    (69, 'Nigeria', 'AF'), (70, 'North Korea', 'AS'), 
    (71, 'Oman', 'AS'), (72, 'Pakistan', 'AS'), 
    (73, 'Paraguay', 'SA'), (74, 'Peru', 'SA'), 
    (75, 'Philippines', 'AS'), (76, 'Poland', 'EU'), 
    (77, 'Puerto Rico', 'NA'), (78, 'Romania', 'EU'), 
    (79, 'Runion', 'AF'), (80, 'Russian Federation', 'EU'), 
    (81, 'Saint Vincent and the Grenadines', 'NA'),(82, 'Saudi Arabia', 'AS'), 
    (83, 'Senegal', 'AF'), (84, 'Slovakia', 'EU'), 
    (85, 'South Africa', 'AF'), (86, 'South Korea', 'AS'), 
    (87, 'Spain', 'EU'), (88, 'Sri Lanka', 'AS'), 
    (89, 'Sudan', 'AF'), (90, 'Sweden', 'EU'), 
    (91, 'Switzerland', 'EU'), (92, 'Taiwan', 'AS'), 
    (93, 'Tanzania', 'AF'), (94, 'Thailand', 'AS'), 
    (95, 'Tonga', 'OC'), (96, 'Tunisia', 'AF'), 
    (97, 'Turkey', 'AS'), (98, 'Turkmenistan', 'AS'), 
    (99, 'Tuvalu', 'OC'), (100, 'Ukraine', 'EU'), 
    (101, 'United Arab Emirates', 'AS'), (102, 'United Kingdom', 'EU'), 
    (103, 'United States', 'NA'), (104, 'Venezuela', 'SA'), 
    (105, 'Vietnam', 'AS'), (106, 'Virgin Islands', 'NA'), 
    (107, 'Yemen', 'AS'), (108, 'Yugoslavia', 'EU'), 
    (109, 'Zambia', 'AF');

select co.continent_name, sum(p.amount) as revenue_per_market, count (distinct p.customer_id) as nbr_customers, 
        sum(p.amount)/count(distinct p.customer_id) as avg_revenue_per_customer,
        sum(p.amount)/total as pct_of_revenue
from payment p, customer cr, address a, city cy,
    continent co, market m,
    (select sum(p.amount) as total from payment p)
where p.customer_id = cr.customer_id and
    cr.address_id = a.address_id and
    a.city_id = cy.city_id and
    cy.country_id = m.country_id and
    m.continent_code = co.continent_id    
group by 1
order by 2 desc;

/*7.What is the total sales of the most selling film category and the least selling film category?*/

select 'The most selling film category: ' || category as Category, max(total_sales) as sales
from (SELECT c.name AS category, SUM(p.amount) AS total_sales
    FROM payment p, rental r, inventory i, film f, film_category fc, category c
    where p.rental_id = r.rental_id  and
    r.inventory_id = i.inventory_id and
    i.film_id = f.film_id and
    f.film_id = fc.film_id and
    fc.category_id = c.category_id
group by c.name)
union
select 'The least selling film category: ' || category as Category, min(total_sales)
from (SELECT c.name AS category, SUM(p.amount) AS total_sales
    FROM payment p, rental r, inventory i, film f, film_category fc, category c
    where p.rental_id = r.rental_id  and
    r.inventory_id = i.inventory_id and
    i.film_id = f.film_id and
    f.film_id = fc.film_id and
    fc.category_id = c.category_id
group by c.name);

/*8.What are the total sales for each rating of the month that has the highest sales?*/

select f.rating, SUM(p.amount) AS total_sales
    from payment p, rental r, inventory i, film f
    where p.rental_id = r.rental_id  and
    r.inventory_id = i.inventory_id and
    i.film_id = f.film_id 
group by 1
having strftime('%m', p.payment_date) = (select month
                                        from(select strftime('%m', p.payment_date) as month, 
                                            sum(p.amount) as revenue_per_month
                                            from payment p
                                            group by month
                                            order by 2 desc
                                            limit 1));

/*9. Categorize actor based on the ratio between total sales per actor and the average sales per actor. */
/*If the ratio greater than 1 then the actor has good performing, if the ratio equals 1 then the actor has average performing, else the actor has low performing. */
/*Calculate the number of actors per each type.*/

select performing, count(*) as nbr_actors
from (select a.actor_id, a.first_name || ' ' || a.last_name as actor, sum(p.amount) as total_sales,
    case when round(sum(p.amount)/avg_sales_per_actor, 1) > 1 then 'good'
        when  round(sum(p.amount)/avg_sales_per_actor, 1) = 1 then 'average'
        else 'low' end as performing
from payment p, rental r, inventory i, film f, film_actor fa, actor a,
(select sum(p.amount)/count(distinct a.actor_id) as avg_sales_per_actor
    from payment p, rental r, inventory i, film f, film_actor fa, actor a
    where p.rental_id = r.rental_id  and
    r.inventory_id = i.inventory_id and
    i.film_id = f.film_id and
    f.film_id = fa.film_id and
    fa.actor_id = a.actor_id) as a
    where p.rental_id = r.rental_id  and
    r.inventory_id = i.inventory_id and
    i.film_id = f.film_id and
    f.film_id = fa.film_id and
    fa.actor_id = a.actor_id
group by 1)
group by 1
order by 2 desc;

/*10.Are there movies that have no sales? Are there any characteristics related to these movies?*/

SELECT f.title, f.rating, c.name as category, l.name as language, a.first_name || ' ' || a.last_name as actor
FROM film f
LEFT JOIN inventory i on f.film_id = i.film_id
LEFT JOIN rental r on i.inventory_id = r.inventory_id
LEFT JOIN payment p on r.rental_id = p.rental_id
INNER JOIN film_category fc on f.film_id = fc.film_id
INNER JOIN category c on fc.category_id = c.category_id
INNER JOIN language l on f.language_id = l.language_id
INNER JOIN film_actor fa on f.film_id = fa.film_id
INNER JOIN actor a on a.actor_id = fa.actor_id
GROUP BY 1
HAVING sum(p.amount) IS NULL;

/* 11.Calculate the total sales for each store. The result should include store_id, store city and store country, manager name and total sales.*/

SELECT s.store_id,
    c.city||', '||cy.country AS store,
    sf.first_name||' '||sf.last_name AS manager,
    sum(p.amount) AS total_sales 
FROM payment p, rental r, inventory i, store s, address a, city c, country cy, staff sf
where p.rental_id = r.rental_id and
    r.inventory_id = i.inventory_id and
    i.store_id = s.store_id and
    s.address_id = a.address_id and
    a.city_id = c.city_id and
    c.country_id = cy.country_id and
    s.manager_staff_id = sf.staff_id
GROUP BY  1, 2, 3;


                                                            
                                








