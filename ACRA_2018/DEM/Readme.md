### How to download DEM data
1. Go to `http://elevation.fsdf.org.au/`
2. Select an area, then download `DEMs` from `Geoscience Australia`
3. Submit an email, it will send the zip file through email
4. Unzip the downloaded file, load it into `QGIS` through `Layer` --> `Add Layer` --> `Add Raster Layer`
5. Clip to a preferred size in `QGIS`: 
   * Select a centre point coordinate, called `home_pos` in `lon` and `lat`.
   * Run the following command in matlab
    ```matlab
        top_left = Calculate_Next_GPS_Mat(home_pos,[-500;500]);
        bottom_right = Calculate_Next_GPS_Mat(home_pos,[500;-500]);
        fprintf('%.7f\n',top_left);
        fprintf('%.7f\n',bottom_right);
    ```
    * Key in top_left in `box 1` and bottom_right in `box 2` in `x` and `y` order, which is '`lon` and `lat`. 
6. Convert the clipped area into `xyz` data: 
   * `Raster` --> `Conversion` --> `Translate (Convert format)` .
   * `Input Layer`: Select the clipped file.
   * `Output file`: Name the file with `*.xyz`, file type: `ASCII Gridded XYZ`.