using BarriersService.App_Start;
using BarriersService.Models;
using Loyc.Geometry;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;

namespace BarriersService.Controllers
{
    public class GeoprocessingController : Controller
    {
        private ExtentedMethods ex = new ExtentedMethods();

        public JsonResult GetStudyAreas()
        {
            using (MeteoDataEntities me = new MeteoDataEntities())
            {
                var result = me.StudyAreas.Select(x => new
                {
                    Id = x.Id,
                    Area = x.Area,
                    AreaName = x.AreaName,
                    x.xllcorner,
                    x.yllcorner,
                    xUpperllcorner = (x.xllcorner + (x.ncols * x.cellsize)),
                    yUpperllcorner = (x.yllcorner + (x.cellsize * x.nrows)),
                    x.ncols,
                    x.nrows
                }).ToList();
                return this.Json(result, JsonRequestBehavior.AllowGet);
            }
        }

        public JsonResult FireSimulationMapsList(string area)
        {
            using (MeteoDataEntities me = new MeteoDataEntities())
            {
                var result = me.IndexMaps.Where(x => x.Area == area).Select(x => new { x.Id, x.Name }).ToArray();
                return this.Json(result, JsonRequestBehavior.AllowGet);
            }
        }

        public JsonResult ForecastTimeMap(int IdMap)
        {
            using (MeteoDataEntities me = new MeteoDataEntities())
            {
                var result = me.IndexMaps.Where(x => x.Id == IdMap).Select(x => x.SimulationTime).FirstOrDefault();
                int maxValue = result ?? 180;
                List<ForeCastTimeList> fc = new List<ForeCastTimeList>();
                for (int i = 0; i <= maxValue; i += 30)
                {
                    fc.Add(new ForeCastTimeList() { Id = IdMap, SimulationTime = i });
                }
                return this.Json(fc, JsonRequestBehavior.AllowGet);
            }
        }

        public JsonResult ConvexHull(int Id, int Forecast)
        {
            if (Forecast > 0)
            {
                using (MeteoDataEntities me = new MeteoDataEntities())
                {
                    var asciiResult = me.IndexMaps.Where(x => x.Id == Id).Select(x => x.IndexMapZipAscii).First();
                    Byte[] ascii = ex.Uncompress(asciiResult);
                    //System.IO.File.WriteAllBytes(@"C:\Static\test.asc", ascii);

                    #region Read ascii

                    List<AsciiValues> listasp = new List<AsciiValues>();
                    int counter = 0;
                    string line;
                    int ncols = 0;
                    int nrows = 0;
                    int xllcorner = 0;
                    int yllcorner = 0;
                    int cellsize = 0;
                    int NODATA_value = 0;
                    using (MemoryStream memoryStream = new MemoryStream(ascii))
                    {
                        using (StreamReader st = new StreamReader(memoryStream))
                        {
                            while ((line = st.ReadLine()) != null)
                            {
                                //System.Console.WriteLine(line);
                                if (!string.IsNullOrWhiteSpace(line))
                                {
                                    counter++;

                                    #region ASC Details

                                    if (counter < 7)
                                    {
                                        string[] result = line.Split(' ');
                                        if (result[0].Contains("ncols"))
                                        {
                                            for (int i = 1; i < result.Length; i++)
                                            {
                                                if (!String.IsNullOrWhiteSpace(result[i]))
                                                {
                                                    int number;
                                                    if (int.TryParse(result[i], out number))
                                                    {
                                                        ncols = number;
                                                    }
                                                }
                                            }
                                        }
                                        if (result[0].Contains("nrows"))
                                        {
                                            for (int i = 1; i < result.Length; i++)
                                            {
                                                if (!String.IsNullOrWhiteSpace(result[i]))
                                                {
                                                    int number;
                                                    if (int.TryParse(result[i], out number))
                                                    {
                                                        nrows = number;
                                                    }
                                                }
                                            }
                                        }

                                        if (result[0].Contains("xllcorner"))
                                        {
                                            for (int i = 1; i < result.Length; i++)
                                            {
                                                if (!String.IsNullOrWhiteSpace(result[i]))
                                                {
                                                    int number;
                                                    if (int.TryParse(result[i], out number))
                                                    {
                                                        xllcorner = number;
                                                    }
                                                }
                                            }
                                        }
                                        if (result[0].Contains("yllcorner"))
                                        {
                                            for (int i = 1; i < result.Length; i++)
                                            {
                                                if (!String.IsNullOrWhiteSpace(result[i]))
                                                {
                                                    int number;
                                                    if (int.TryParse(result[i], out number))
                                                    {
                                                        yllcorner = number;
                                                    }
                                                }
                                            }
                                        }
                                        if (result[0].Contains("cellsize"))
                                        {
                                            for (int i = 1; i < result.Length; i++)
                                            {
                                                if (!String.IsNullOrWhiteSpace(result[i]))
                                                {
                                                    int number;
                                                    if (int.TryParse(result[i], out number))
                                                    {
                                                        cellsize = number;
                                                    }
                                                }
                                            }
                                        }
                                        if (result[0].Contains("NODATA_value"))
                                        {
                                            for (int i = 1; i < result.Length; i++)
                                            {
                                                if (!String.IsNullOrWhiteSpace(result[i]))
                                                {
                                                    int number;
                                                    if (int.TryParse(result[i], out number))
                                                    {
                                                        NODATA_value = number;
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    #endregion ASC Details

                                    else
                                    {
                                        string[] result = line.Split(' ');
                                        for (int i = 0; i < result.Length; i++)
                                        {
                                            int number;
                                            if (int.TryParse(result[i], out number))
                                            {
                                                AsciiValues aspul = new AsciiValues()
                                                {
                                                    X = xllcorner + (i * cellsize),
                                                    Y = (yllcorner + (nrows * cellsize)) - (cellsize * (counter - 7)),
                                                    Value = number
                                                };
                                                AsciiValues aspur = new AsciiValues()
                                                {
                                                    X = xllcorner + (i * cellsize) + cellsize,
                                                    Y = (yllcorner + (nrows * cellsize)) - (cellsize * (counter - 7)),
                                                    Value = number
                                                };
                                                AsciiValues aspdl = new AsciiValues()
                                                {
                                                    X = xllcorner + (i * cellsize),
                                                    Y = (yllcorner + (nrows * cellsize)) - (cellsize * (counter - 7)) - cellsize,
                                                    Value = number
                                                };
                                                AsciiValues aspdr = new AsciiValues()
                                                {
                                                    X = xllcorner + (i * cellsize) + cellsize,
                                                    Y = (yllcorner + (nrows * cellsize)) - (cellsize * (counter - 7)) - cellsize,
                                                    Value = number
                                                };
                                                listasp.Add(aspul);
                                                listasp.Add(aspur);
                                                listasp.Add(aspdl);
                                                listasp.Add(aspdr);
                                            }
                                        }
                                    }
                                }
                            }
                            counter.ToString();
                        }
                    }

                    #endregion Read ascii

                    var points = listasp.Where(x => x.Value <= Forecast && x.Value > 0);
                    var finalpoints = points.Select(x => new Point<double>() { X = x.X, Y = x.Y }).ToList();
                    var ConvexHullresult = PointMath.ComputeConvexHull(finalpoints, true);
                    return this.Json(ConvexHullresult, JsonRequestBehavior.AllowGet);
                }
            }
            else
            {
                return this.Json(null, JsonRequestBehavior.AllowGet);
            }
        }
    }
}