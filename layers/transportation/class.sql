CREATE OR REPLACE FUNCTION brunnel(is_bridge BOOL, is_tunnel BOOL, is_ford BOOL) RETURNS TEXT AS $$
    SELECT CASE
        WHEN is_bridge THEN 'bridge'
        WHEN is_tunnel THEN 'tunnel'
        WHEN is_ford THEN 'ford'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- The classes for highways are derived from the classes used in ClearTables
-- https://github.com/ClearTables/ClearTables/blob/master/transportation.lua
CREATE OR REPLACE FUNCTION highway_class(highway TEXT, public_transport TEXT, tags HSTORE = null) RETURNS TEXT AS $$
    SELECT CASE
        WHEN tags->'icn' IN ('yes') THEN 'cycleway'
        WHEN tags->'ncn' IN ('yes') THEN 'cycleway'
        WHEN tags->'rcn' IN ('yes') THEN 'cycleway'
        WHEN tags->'lcn' IN ('yes') THEN 'cycleway'
        WHEN tags->'bicycle' IN ('designated', 'mtb') THEN 'cycleway'
        WHEN tags->'bicycle' IN ('yes', 'permissive') AND highway IN ('pedestrian', 'path', 'footway', 'steps', 'bridleway', 'corridor', 'track') THEN 'cycleway'
        WHEN tags->'cycleway' IN ('lane', 'opposite_lane', 'opposite', 'shared_lane', 'share_bussway', 'shared', 'track', 'opposite_track') THEN 'cycleway'
        WHEN tags->'cycleway:left' IN ('lane', 'opposite_lane', 'opposite', 'shared_lane', 'share_bussway', 'shared', 'track', 'opposite_track') THEN 'cycleway'
        WHEN tags->'cycleway:right' IN ('lane', 'opposite_lane', 'opposite', 'shared_lane', 'share_bussway', 'shared', 'track', 'opposite_track') THEN 'cycleway'
        WHEN tags->'cycleway:both' IN ('lane', 'opposite_lane', 'opposite', 'shared_lane', 'share_bussway', 'shared', 'track', 'opposite_track') THEN 'cycleway'
        WHEN highway IN ('service', 'track', 'cycleway') THEN highway
        WHEN highway IN ('motorway', 'motorway_link') THEN 'motorway'
        WHEN highway IN ('trunk', 'trunk_link') THEN 'trunk'
        WHEN highway IN ('primary', 'primary_link') THEN 'primary'
        WHEN highway IN ('secondary', 'secondary_link') THEN 'secondary'
        WHEN highway IN ('tertiary', 'tertiary_link') THEN 'tertiary'
        WHEN highway IN ('unclassified', 'residential', 'living_street', 'road') THEN 'minor'
        WHEN highway IN ('pedestrian', 'path', 'footway', 'steps', 'bridleway', 'corridor') OR public_transport IN ('platform') THEN 'path'
        WHEN highway = 'raceway' THEN 'raceway'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION cycleway_subclass(highway TEXT, tags HSTORE = null) RETURNS TEXT AS $$
    SELECT CASE
        WHEN tags->'surface' IN ('unpaved', 'compacted', 'fine_gravel', 'gravel', 'pebblestone', 'dirt', 'earth', 'grass', 'gravel_turf', 'ground', 'mud', 'sand', 'woodchips', 'snow', 'ice') THEN 'unpaved'
        WHEN tags->'surface' IN ('paved', 'asphalt', 'concrete', 'concrete:lanes', 'concrete:plates', 'paving_stones', 'sett', 'metal', 'wood') THEN 'paved'
        WHEN tags->'bicycle' IN ('mtb') THEN 'unpaved'
        WHEN tags->'hiking' IN ('yes', 'designated', 'permissive') THEN 'unpaved'
        WHEN highway IN ('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified', 'residential', 'service', 'motorway_link', 'trunk_link', 'primary_link', 'secondary_link', 'tertiary_link', 'raceway', 'road', 'steps', 'cycleway') THEN 'paved'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE;

-- The classes for railways are derived from the classes used in ClearTables
-- https://github.com/ClearTables/ClearTables/blob/master/transportation.lua
CREATE OR REPLACE FUNCTION railway_class(railway TEXT) RETURNS TEXT AS $$
    SELECT CASE
        WHEN railway IN ('rail', 'narrow_gauge', 'preserved', 'funicular') THEN 'rail'
        WHEN railway IN ('subway', 'light_rail', 'monorail', 'tram') THEN 'transit'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Limit service to only the most important values to ensure
-- we always know the values of service
CREATE OR REPLACE FUNCTION service_value(service TEXT) RETURNS TEXT AS $$
    SELECT CASE
        WHEN service IN ('spur', 'yard', 'siding', 'crossover', 'driveway', 'alley', 'parking_aisle') THEN service
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Limit surface to only the most important values to ensure
-- we always know the values of surface
CREATE OR REPLACE FUNCTION surface_value(surface TEXT) RETURNS TEXT AS $$
    SELECT CASE
        WHEN surface IN ('paved', 'asphalt', 'cobblestone', 'concrete', 'concrete:lanes', 'concrete:plates', 'metal', 'paving_stones', 'sett', 'unhewn_cobblestone', 'wood') THEN 'paved'
        WHEN surface IN ('unpaved', 'compacted', 'dirt', 'earth', 'fine_gravel', 'grass', 'grass_paver', 'gravel', 'gravel_turf', 'ground', 'ice', 'mud', 'pebblestone', 'salt', 'sand', 'snow', 'woodchips') THEN 'unpaved'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;
