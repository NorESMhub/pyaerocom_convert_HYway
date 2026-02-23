# Oddities in the data files

## EMAC-DLR
- no mmrso4 data

## EC-Earth3-AerChem
- no mmrso4 data

## GFDL-AM4.1
- sulphate data very low?
- Julian calendar
- time code in filename missing
- partially wrong file naming scheme (see next)

## GFDL-ESM4-c1
- Julian calendar
- Sulphate data very low
- wrong variable name in file 

According to the CMIP standard the variable name in the filename and the netcdf variable name are supposed to be the same (here: `o3` vs. `O3_dvmr`)
```
(base) [jang@login3-nird-lmd modelling_repository]$ ncdump -h /nird/datapeak/NS11106K/HYway/modelling_repository/GFDL-AM4.1/transient2010s/monthly_3d_native/O3_dvmr_transient2010s_GFDL-ESM4-c1_r1_gn_201001-201912.nc
netcdf O3_dvmr_transient2010s_GFDL-ESM4-c1_r1_gn_201001-201912 {
dimensions:
	time = UNLIMITED ; // (120 currently)
	pfull = 49 ;
	lat = 180 ;
	lon = 288 ;
	bnds = 2 ;
variables:
	float O3_dvmr(time, pfull, lat, lon) ;
		O3_dvmr:_FillValue = -1.e+10f ;
		O3_dvmr:missing_value = -1.e+10f ;
		O3_dvmr:units = "mol/mol" ;
		O3_dvmr:long_name = "o3 (dry vmr)" ;
		O3_dvmr:cell_methods = "time: mean" ;
		O3_dvmr:interp_method = "conserve_order1" ;
	double bnds(bnds) ;
		bnds:long_name = "vertex number" ;
	double lat(lat) ;
		lat:long_name = "latitude" ;
		lat:units = "degrees_N" ;
		lat:axis = "Y" ;
		lat:bounds = "lat_bnds" ;
	double lat_bnds(lat, bnds) ;
		lat_bnds:long_name = "latitude bounds" ;
		lat_bnds:units = "degrees_N" ;
		lat_bnds:axis = "Y" ;
	double lon(lon) ;
		lon:long_name = "longitude" ;
		lon:units = "degrees_E" ;
		lon:axis = "X" ;
		lon:bounds = "lon_bnds" ;
	double lon_bnds(lon, bnds) ;
		lon_bnds:long_name = "longitude bounds" ;
		lon_bnds:units = "degrees_E" ;
		lon_bnds:axis = "X" ;
	double pfull(pfull) ;
		pfull:units = "mb" ;
		pfull:long_name = "ref full pressure level" ;
		pfull:axis = "Z" ;
		pfull:positive = "down" ;
	double time(time) ;
		time:units = "days since 1870-01-01 00:00:00" ;
		time:long_name = "time" ;
		time:axis = "T" ;
		time:calendar_type = "JULIAN" ;
		time:calendar = "julian" ;
		time:bounds = "time_bnds" ;
	double time_bnds(time, bnds) ;
		time_bnds:units = "days since 1870-01-01 00:00:00" ;
		time_bnds:long_name = "time axis boundaries" ;

```





