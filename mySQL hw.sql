use sakila;

-- 1a. Display the first and last names of all actors from the table actor. 

select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
ALTER TABLE actor ADD COLUMN actor_name VARCHAR(50);
UPDATE actor SET actor_name = CONCAT(first_name, ' ', last_name);
select actor_name from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you only know the first name, "Joe." What is one query would you use to obtain this information? 


select actor_id, first_name, last_name
from actor
where first_name like 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN: 

select actor_name
from actor
where last_name like  '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order. 

select last_name, first_name
from actor 
where last_name like '%li%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id, and country columns of the following countries: Afghanistan, Bangladesh, and China 

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type. 

ALTER TABLE actor
  ADD middle_name VARCHAR(45)
	after first_name;


-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs. 

ALTER TABLE actor
MODIFY COLUMN middle_name blob; 


-- 3c. Now delete the middle_name column.alter
ALTER TABLE actor
DROP COLUMN middle_name;


-- 4a. List the last names of actors, as well as how many actors have that last name. 
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name but only for names that are shared by at least two actors 

SELECT last_name, 
COUNT(*) c  
FROM actor 
GROUP BY last_name 
HAVING c > 1;

-- 4c. Oh, no! The actor Harpo Williams was accidentally entered in the actor table as Groucho Williams, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record. 

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_name = 'Groucho Williams';

-- 4d. Perhaps we were too hastly in changing Groucho to Harpo. It turns out that Groucho was the correct name after all! In a single query, if the first name of the actor is currrently Harpo, change it to Groucho. Otherwise, change the first name to Mucho Groucho, as that is exactly what the actor will be with the grevious error. Be careful not to change the first name of every acto mucho grouch, however! (Hint: update the record using a unique identifier.) 


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? 
show create table address; 
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. Use JOIN to display the first and last names, as well ast he address, of each staff member. Use tables staff and payment. 

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
address.address_id = staff.address_id;

select * from staff;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 

select staff.first_name, staff.last_name, sum(payment.amount)
from staff 
join payment on staff.staff_id = (payment.staff_id)
where month(payment.payment_date) = 08 and year(payment.payment_date) = 2005
group by first_name;

      
 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join. 
select film.film_id, film_actor.actor_id, film.title, count(actor_id)
from film 
inner join film_actor on 
film.film_id = film_actor.film_id
group by film.title;


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name. 
select customer.first_name, customer.last_name, sum(amount)
from customer
inner join payment
on customer.customer_id = payment.customer_id
group by first_name
order by last_name asc; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 

select title, (SELECT name FROM language WHERE name like 'English') as 'Language' 
from film
where title like 'K%' or title like 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip. 

select * from actor
where actor_id in
	(select actor_id from film_actor
    where film_id =
		(select film_id from film
        where title = 'Alone Trip')
        );

-- 7c.  You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information. 


SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer 
INNER JOIN 
address ON customer.address_id = address.address_id
Inner join 
city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id  and country = 'Canada';  
     
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies catagorized as family films. 

select film.title, category.name
from category 
inner join
film_category on category.category_id = film_category.category_id
inner join film on film_category.film_id = film.film_id and name = 'Family';

-- 7e. Display the most frequently rented movies in descending order. 

select film.title, count(title) as 'Number of Rentals' 
from film 
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by title
order by count(title) desc; 


-- 7f. Write a query to display how much business, in dollars, each store brought in. 
select store.store_id, sum(amount) as 'Store Revenue'
from store 
join staff on store.store_id = staff.store_id
join payment on staff.staff_id = payment.staff_id
group by store_id; 

-- 7g. Write a query to display for each store its Store ID, city, and country.alter
select store.store_id, city, country
from store 
join address on store.address_id = address.address_id
join city on city.city_id = address.city_id
join country on country.country_id = city.country_id;

-- 7h. List the top 5 genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) 
select category.name, sum(amount) as 'Gross Revenue'
from category 
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
group by category.name 
order by sum(amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view. 

CREATE VIEW top_five_genres
as 
	select category.name, sum(amount) as 'Gross Revenue'
from category 
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
group by category.name 
order by sum(amount) desc
limit 5;

-- 8b. How would you display the view you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it. 
drop view top_five_genres; 

