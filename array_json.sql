-- Problem on same concept - https://platform.stratascratch.com/coding/9633-city-with-most-amenities?code_type=1

CREATE TABLE arrayTable (
    id SERIAL PRIMARY KEY,
    city VARCHAR(255),
    array_values TEXT
);


INSERT INTO arrayTable (city, array_values)
VALUES 
('New York', '{TV,"Wireless Internet","Air conditioning","Smoke detector","Carbon monoxide detector",Essentials,"Lock on bedroom door",Hangers,Iron}'),
('San Francisco', '{TV,"Wireless Internet","Air conditioning"}'),
('Los Angeles', '{TV,"Wireless Internet","Air conditioning","Smoke detector"}'),
('Chicago', '{TV,"Wireless Internet","Air conditioning","Smoke detector","Carbon monoxide detector","Lock on bedroom door"}'),
('Miami', '{TV,"Wireless Internet","Air conditioning","Smoke detector","Carbon monoxide detector",Essentials,"Lock on bedroom door",Hangers,Iron,"First aid kit"}'),
('Austin', '{TV,"Wireless Internet","Air conditioning","Carbon monoxide detector",Essentials,"Lock on bedroom door",Hangers,Iron}'),
('Seattle', '{TV,"Air conditioning","Smoke detector","Carbon monoxide detector",Essentials,"Lock on bedroom door",Hangers}'),
('Boston', '{TV,"Wireless Internet","Air conditioning","Smoke detector","Carbon monoxide detector",Essentials,Hangers,Iron,"First aid kit"}'),
('Denver', '{TV,"Wireless Internet","Air conditioning","Smoke detector","Carbon monoxide detector",Essentials}'),
('Atlanta', '{TV,"Wireless Internet","Air conditioning","Smoke detector","Carbon monoxide detector",Essentials,"Lock on bedroom door",Hangers,Iron,"Fire extinguisher"}');


-- Convert a comma-separated string into an array using string_to_array.
SELECT string_to_array('TV,Wireless Internet,Air conditioning', ',') AS amenities_array;


-- Count array length of column values
SELECT city, array_length(string_to_array(array_values, ','), 1) AS number_of_amenities
FROM arrayTable;

-- Count the number of unique values in array_values column across all entries.
SELECT COUNT(DISTINCT unnest(string_to_array(array_values, ','))) AS unique_amenities_count
FROM arrayTable;


-- JSON

CREATE TABLE airbnb_search_details_json (
    id SERIAL PRIMARY KEY,
    city VARCHAR(255),
    amenities JSONB
);

INSERT INTO airbnb_search_details_json (city, amenities)
VALUES 
('New York', '["TV", "Wireless Internet", "Air conditioning", "Smoke detector", "Carbon monoxide detector", "Essentials", "Lock on bedroom door", "Hangers", "Iron"]'::jsonb),
('San Francisco', '["TV", "Wireless Internet", "Air conditioning"]'::jsonb);

-- Querying the JSON data
SELECT city, jsonb_array_length(amenities) AS number_of_amenities
FROM airbnb_search_details_json;
