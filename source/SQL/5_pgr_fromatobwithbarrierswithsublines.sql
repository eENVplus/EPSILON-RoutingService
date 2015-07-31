-- Function: public.pgr_fromatobwithbarrierswithsublines(double precision, double precision, double precision, double precision, text)

--DROP FUNCTION public.pgr_fromatobwithbarrierswithsublines(double precision, double precision, double precision, double precision, text);

CREATE OR REPLACE FUNCTION public.pgr_fromatobwithbarrierswithsublines(x1 double precision, y1 double precision, x2 double precision, y2 double precision, barriers text)
  RETURNS geometry AS
$BODY$
DECLARE
	startPoint geometry;	endPoint geometry;	nearesrsStartLine geometry;	nearestEndLine geometry;
	nearestStartNode geometry;	nearestEndNode geometry;	
        routewihoutSubline geometry;        startSubLine geometry;		pointStartSubLine geometry;
		pointEndSubLine geometry;	endSubLine geometry;		finalStartRoute geometry;
		finalEndRoute geometry;		closestStartDistance double precision;		closestEndDistance double precision;
BEGIN
--Find the nearest StartLine
EXECUTE 'SELECT geom FROM public."ways" 
    ORDER BY geom <-> ST_GeometryFromText(''POINT('||x1 || ' ' || y1 || ')'',2100) LIMIT 1' INTO nearesrsStartLine;
	startPoint:= ST_GeometryFromText('POINT('||x1 || ' ' || y1 || ')',2100);
	nearesrsStartLine:=  ST_SetSRID(nearesrsStartLine, 2100);
  
  --Find the StartPointSubLine
	pointStartSubLine:=  ST_ClosestPoint(nearesrsStartLine, startPoint);
	IF(ST_LineLocatePoint(nearesrsStartLine, pointStartSubLine)>0.5) THEN
	nearestStartNode:= ST_EndPoint(nearesrsStartLine);
	startSubLine:=	ST_Line_Substring (nearesrsStartLine, ST_LineLocatePoint(nearesrsStartLine, pointStartSubLine), 1);	
	 ELSE
	 nearestStartNode:= ST_StartPoint(nearesrsStartLine);
	 startSubLine:=	ST_Line_Substring (nearesrsStartLine,0,ST_LineLocatePoint(nearesrsStartLine, pointStartSubLine));
	 END IF;

EXECUTE 'SELECT geom FROM public."ways" 
    ORDER BY geom <-> ST_GeometryFromText(''POINT('|| x2 || ' ' || y2 || ')'',2100) LIMIT 1' INTO nearestEndLine;
    endPoint:= ST_GeometryFromText('POINT('||x2 || ' ' || y2 || ')',2100);
	nearestEndLine:=  ST_SetSRID(nearestEndLine, 2100);
	
	 --Find the StartPointSubLine
	pointEndSubLine:=  ST_ClosestPoint(nearestEndLine, endPoint);
IF(ST_LineLocatePoint(nearestEndLine, pointEndSubLine)>0.5) THEN
	nearestEndNode:= ST_EndPoint(nearestEndLine);
	endSubLine:=	ST_Line_Substring (nearestEndLine, ST_LineLocatePoint(nearestEndLine, pointEndSubLine), 1);	
	 ELSE
	 nearestEndNode:= ST_StartPoint(nearestEndLine);
	 endSubLine:=	ST_Line_Substring (nearestEndLine,0,ST_LineLocatePoint(nearestEndLine, pointEndSubLine));
	 END IF;
DELETE FROM public."BarrierPolygon";

EXECUTE 'INSERT INTO public."BarrierPolygon" VALUES (ST_GeomFromText(''' || barriers || ''' ,2100))';

routewihoutSubline:=  ST_MakeLine(route.geom)  
FROM
   ( SELECT *   FROM   pgr_fromatobwithbarriers(ST_X(nearestStartNode), ST_Y(nearestStartNode), ST_X(nearestEndNode),ST_Y(nearestEndNode) ) 
   ORDER BY  seq) as route;


   
 if(closestStartDistance>0.5) then
	   if(ST_DWithin(routewihoutSubline, ST_StartPoint(startSubLine), 0.1))then
		finalStartRoute:=ST_Difference(routewihoutSubline, ST_Buffer(startSubLine, 0.1));
	   else
		finalStartRoute:= ST_Union(ARRAY[routewihoutSubline, startSubLine]);
	   end if;
   else
	   if(ST_DWithin(routewihoutSubline, ST_EndPoint(startSubLine), 0.1))then
		finalStartRoute:=ST_Difference(routewihoutSubline, ST_Buffer(startSubLine, 0.1));
	   else
		finalStartRoute:= ST_Union(ARRAY[routewihoutSubline, startSubLine]);
	   end if;
   end if;

if(closestEndDistance>0.5) then
	   if(ST_DWithin(finalStartRoute, ST_StartPoint(endSubLine), 0.1))then
		finalEndRoute:=ST_Difference(finalStartRoute, ST_Buffer(endSubLine, 0.1));
	   else
		finalEndRoute:= ST_Union(ARRAY[finalStartRoute, endSubLine]);
	   end if;
   else
	   if(ST_DWithin(finalStartRoute, ST_EndPoint(endSubLine), 0.1))then
		finalEndRoute:=ST_Difference(finalStartRoute, ST_Buffer(endSubLine, 0.1));
	   else
		finalEndRoute:= ST_Union(ARRAY[finalStartRoute, endSubLine]);
	   end if;
   end if;


RETURN finalEndRoute;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.pgr_fromatobwithbarrierswithsublines(double precision, double precision, double precision, double precision, text)
  OWNER TO postgres;
