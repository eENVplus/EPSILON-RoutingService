CREATE TABLE ways AS(
	SELECT 
	"RoadLink any"."id",
	  "RoadLink any"."geom",
	  "RoadLink any"."gml_id",
	  "RoadLink any"."beginLifespanVersion",
	  "RoadLink any"."localId",
	  "RoadLink any"."namespace",
	  "RoadLink any"."fictitious",
	  "RoadLink any"."language",
	  "RoadLink any"."nativeness",
	  "RoadLink any"."nameStatus",
	  "RoadLink any"."sourceOfName",
	  "RoadLink any"."text",

    "SpeedLimit"."speedLimitValue", "SpeedLimit"."speedLimitValue_uom"
    FROM public."RoadLink any" INNER JOIN public."SpeedLimit" 
    ON ("SpeedLimit"."localId" = "RoadLink any"."localId"));

 ALTER TABLE public.ways  ADD PRIMARY KEY (id);
   
CREATE INDEX ways_id_idx ON public."ways"("id");

-- Add "source" and "target" column
ALTER TABLE public."ways" ADD COLUMN "source" integer;
ALTER TABLE public."ways" ADD COLUMN "target" integer;


ALTER TABLE public."ways" ADD COLUMN length double precision;
UPDATE public."ways" SET length = ST_Length(geom);

-- Run topology function
SELECT pgr_createTopology('ways', 0.00001, 'geom', 'id');


--CREATE INDEX ways_source_idx ON public."ways"("source");
--CREATE INDEX ways_target_idx ON public."ways"("target");



ALTER TABLE public."ways" ADD COLUMN time_cost double precision;
UPDATE public."ways" SET time_cost  = ST_Length(geom)/("speedLimitValue" * 1000/60);
ALTER TABLE public."ways" ADD COLUMN reverse_cost double precision;
UPDATE public."ways" SET reverse_cost  = time_cost;
