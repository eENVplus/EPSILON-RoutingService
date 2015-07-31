﻿-- Function: public.pgr_fromatobwithbarriers(double precision, double precision, double precision, double precision)

-- DROP FUNCTION public.pgr_fromatobwithbarriers(double precision, double precision, double precision, double precision);

CREATE OR REPLACE FUNCTION public.pgr_fromatobwithbarriers(IN x1 double precision, IN y1 double precision, IN x2 double precision, IN y2 double precision, OUT seq integer, OUT gid1 integer, OUT name text, OUT heading double precision, OUT cost double precision, OUT geom geometry)
  RETURNS SETOF record AS
$BODY$
DECLARE
        sql     text;
        rec     record;
        source	integer;
        target	integer;
        point	integer;
        --m 	text;
        
BEGIN
	-- Find nearest node
	EXECUTE 'SELECT id::integer FROM public."ways_vertices_pgr" 
			ORDER BY the_geom <-> ST_GeometryFromText(''POINT(' 
			|| x1 || ' ' || y1 || ')'',2100) LIMIT 1' INTO rec;
	source := rec.id;
	
	EXECUTE 'SELECT id::integer FROM public."ways_vertices_pgr" 
			ORDER BY the_geom <-> ST_GeometryFromText(''POINT(' 
			|| x2 || ' ' || y2 || ')'',2100) LIMIT 1' INTO rec;
	target := rec.id;

	--Clear records barriers
	--DELETE FROM public."BarrierPolygon";

	--INSERT records barriers
	--INSERT INTO public."BarrierPolygon" VALUES (ST_GeomFromText(barriers,2100));
	
	-- Shortest path query (TODO: limit extent by BBOX) 
        seq := 0;
       sql     := 'SELECT id, geom, text, cost, source, target, ST_Reverse(geom) AS flip_geom FROM ' ||
                        'pgr_dijkstra(''SELECT roads.id as id, source::int, target::int, '
                                        || 'time_cost::float AS cost FROM public."ways" as roads left join
							public."BarrierPolygon" as barrier on
						ST_Intersects(roads.geom, barrier.geom_polygon)
							where barrier.id_0 is null'' , '
                                        || source || ', '
                                        || target || ' , false, false), '
                                || 'public."ways" WHERE id2 = id ORDER BY seq';
	-- Remember start point
        point := source;

        FOR rec IN EXECUTE sql
        LOOP
		-- Flip geometry (if required)
		IF ( point != rec.source ) THEN
			rec.geom := rec.flip_geom;
			point := rec.source;
		ELSE
			point := rec.target;
		END IF;

		-- Calculate heading (simplified)
		EXECUTE 'SELECT degrees( ST_Azimuth( 
				ST_StartPoint(''' || rec.geom::text || '''),
				ST_EndPoint(''' || rec.geom::text || ''') ) )' 
			INTO heading;

		-- Return record
                seq     := seq + 1;
                gid1     := rec.id;
                name    := rec.text;
                cost    := rec.cost;
                geom    := rec.geom;
                RETURN NEXT;
        END LOOP;
        RETURN;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.pgr_fromatobwithbarriers(double precision, double precision, double precision, double precision)
  OWNER TO postgres;
