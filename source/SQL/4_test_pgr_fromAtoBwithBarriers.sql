﻿--X1=411433.70134908903, X2=413095.07813330873, Y1=4501290.545471773, Y2=4497398.372703665
SELECT
   ST_MakeLine(route.geom) 
   FROM(
SELECT *
   FROM
      pgr_fromatobwithbarriers(
      411433.70134908903,
      4501290.545471773,
      413095.07813330873,
      4497398.372703665  , 'POLYGON((414868.535847718 4500883.21187759,414375.776511618 4500381.95669087,415072.436262656 4500229.03137967,415548.203897511 4500594.35295643,415548.203897511 4500594.35295643,414868.535847718 4500883.21187759))'  ) 
      ORDER BY  seq ) as route