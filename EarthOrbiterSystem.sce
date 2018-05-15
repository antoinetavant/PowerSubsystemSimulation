// EarthOrbiterSystem v 0.0.3
// This program models the orbital trajectory of a CAD model about the Earth
// Authours : Arvin T. Matthieu D. Jessie A.
// Created on 11 May 2018
// Last modified 15 May 2018
// Table of contents
//  Part 1 : Definition of global variables
//      Part 1a : initialization of orbit related variables
//      Part 1b : initialization of frame related variables
//      Part 1c : time and perturbation related parameters
//      Part 1d : initialization of 3D spacecraft model related variables
//  Part 2 : Definition of proprietary functions
//      Part 2a : trace_traj function
//      Part 2b : plot_sphere function
//  Part 3 : Creation of the solar system environment
//      Part 3a : Creation of the Earth spheroid
//      Part 3b : Creation of the 'space' environment
//      Part 3c : Insertion of the orbital trajectory
//      PART 3d : Insert STL model of spacecraft
//      Part 3e : Motion of the satellite
// celestLab demo are located in C:\Users\matth\AppData\Roaming\Scilab\scilab-5.5.2\atoms\x64\celestlab\3.2.1\demos

clear; clc; clf; // Clear variable list, console, and figures

CL_init(); // Importation of celestLab library
// Part 1 --- Definition of global variables ----------------------------------
// Part 1a --- initialization of orbit related parameters ---------------------

// This part promts the user to input the Keplerian orbital element, by default the program uses that of the ISS
desc = list(..
CL_defParam("Semimajor axis",           val = 6782.4744,     units=['km']),..
CL_defParam("Eccentricity",             val = 0.0003293),..
CL_defParam("Inclination",              val = 51.6397 *%CL_deg2rad,    units=['rad','deg']),..
CL_defParam("RAAN",                     val = 196.5549*%CL_deg2rad,   units=['rad','deg']),..
CL_defParam("Argument of Perigee",      val = 67.2970*%CL_deg2rad,    units=['rad','deg']),..
CL_defParam("Mean anomaly at epoch",    val = 292.8531*%CL_deg2rad,   units=['rad','deg']));
[aa, ec, in, ra, wp, ma] = CL_inputParam(desc)
TA  = linspace(ma*%pi/180,ma*%pi/180 + 2*%pi,1000); // Mean anomaly values for one orbit [rad]
kepCoeff0 = [aa; ec; in; wp; ra; ma]; // Keplerian elements of the orbit
// aa-semimajor axis [km], ec-eccentricity, in-inclination [deg], ra-right ascension of the ascending node [deg], wp-argument of perigee [deg], ma-mean anomaly [deg]

// Part 1b --- initialization of frame related parameters ---------------------
// Use the celestLab constants for these
AU      = CL_dataGet("au")/10^3  // Definition of an astronomical unit [km]
RSun    = 695700                 // Radius of the Sun [km]
REarth  = 6378                   // Radius of the Earth [km]
LSun    = 3.828e26               // Luminosity of the Sun [W/m^2]
frame   = 10e3;                  // Dimension of the data bounds [km]

// Part 1c----time and perturbation related parameters-------------------------
//prompt the user for mission start time, date, and duration
dt = getdate(); // Gets date and time information
desc2 = list(..
CL_defParam("Start year",           val = dt(1)),..
CL_defParam("Start month",          val = dt(2)),..
CL_defParam("Start day",            val = dt(6)),..
CL_defParam("Start hour",           val = dt(7)),..
CL_defParam("Start minute",         val = dt(8)),..
CL_defParam("Start second",         val = dt(9)),..
CL_defParam("Mission duration",     val = 1,        units = ['days']),..
CL_defParam("Time step",            val = 10,       units = ['seconds']));
[YYYY, MM, DD, HH,tMin,tSec,xduration,tstep] = CL_inputParam(desc2);

cjd0 = CL_dat_cal2cjd(YYYY,MM,DD,HH,tMin,tSec);
cjd = cjd0 + (0 : tstep/86400 : xduration);

//J2 Perturbation model
kepCoeff= CL_ex_propagate("j2sec", "kep", cjd0, kepCoeff0, cjd, "m");
// Part 1d --- initialization of variables related to the 3D model of the spacecraft
enlarge = 10; // Enlargement factor to increase the volume of the model, this should be removed or made optional, in any case it cant affect the final results


//  Part 2 --- Definition of proprietary functions ----------------------------
//  Part 2a --- trace_traj function -------------------------------------------
function trace_traj(traj,F,col,th)
    //  Copyright (c) CNES  2008
    //  This software is part of CelestLab, a CNES toolbox for Scilab
    //  This function traces great cr
    param3d(F*traj(1,:), F*traj(2,:), F*traj(3,:));
    e=gce();
    e.foreground=col;
    e.thickness=th;
endfunction

//  Part 2b --- plot_sphere function ------------------------------------------
function [] = plot_sphere(r,n,d)
    // Copyright (c) York University 2018   Authors: Matthieu D. and Jessie A.
    // This function plots the surface of a sphere
    // Inputs: r - radius of the sphere [km], n - number of divisions, d - change in size along axes [km]
    lat = linspace(-%pi/2,%pi/2,n +1);
    lon = linspace(0,2*%pi,n*2 + 1);
    x     = r*(cos(lat)'*cos(lon)) + d(1);
    y     = r*(cos(lat)'*sin(lon)) + d(2);
    z     = r*(sin(lat)'*ones(lon)) + d(3);
    plot3d2(x,y,z);
    e = gce();
    e.color_flag = 2;
    e.color_mode = 12; // Sets the colour of the surfaces
    e.foreground = 18; // Sets the colour of the lines seperating each surface
    trace_traj(r*[cos(lat);zeros(lat);sin(lat)], F=1, col=16, th=1); // Plots meridian
    trace_traj(r*[cos(lon);sin(lon);zeros(lon)], F=1, col=16, th=1); // Plots equator

    a = gca();
    a.isoview = 'on'; // Changes the view to isometric
    a.grid = [1 1]; // Adds grid lines to the graphical object
endfunction

//  Part 3 --- Creation of the solar system and simulation --------------------
//  Part 3a --- Creation of the Earth spheroid --------------------------------
plot_sphere(REarth,50,[0 0 0]) // Plots the Earth as a sphere

//  Part 3b --- Creation of the 'space' environment ---------------------------
xarrows([0 frame],[0 0],[0 0],20000,color(255,179,0)) //Create Sun-Earth vector

//  Part 3c --- Insertion of the orbital trajectory ---------------------------
rad = zeros(3,length(TA)); // Matrix storing components of radius vector
vel = zeros(3,length(TA)); // Matrix storing components of velocity vector
for i = 1:length(TA)
    kepCoeff(6) = TA(i); // Changes true anomaly
    [rad_hold,vel_hold] = CL_oe_kep2car(kepCoeff); // Convert the Kepler coefficients to state vector to place the object in the frame
    rad(1,i) = rad_hold(1); // |
    rad(2,i) = rad_hold(2); // | Sets the values just component to their space in the radius array
    rad(3,i) = rad_hold(3); // |
end
kepCoeff(6) = ma; // Changes true anomaly back to initial value
param3d(rad(1,:),rad(2,:),rad(3,:)); // Plots the entire orbit
set(gca(),"isoview",'on')

//  PART 3d --- Insertion STL model of spacecraft --------------------------------
exec("C:\Scilab\stlfiles\etc\stlfiles.start"); // Execute files needed for STL import, this needs to be changed to fit any user
stlpath = get_absolute_file_path("EarthOrbiterSystem.sce") // Gets the path leading the the desiring STL file, this needs to be changed to fit any user
t = stlread(fullfile(stlpath, "humanoid.stl"), "ascii"); // Imports the STL file
tcolor = 12*ones(1, size(t.x,"c")) // Sets the colour of all surfaces of the file
[radV,velV] = CL_oe_kep2car(kepCoeff); // Convert the Kepler coefficients to state vector to place the object in the frame
xIns = (t.x*enlarge) - radV(1,1); // |
yIns = (t.y*enlarge) + radV(2,1); // | Changes the position of all vertices to place the object in the frame
zIns = (t.z*enlarge) + radV(3,1); // |
plot3d(-xIns,yIns,list(zIns,tcolor)); // Plots the STL model in the frame

// Part 3e --- Motion of the satellite ----------------------------------------

    for i = 1:length(radV) // For mission duration
        delete() // Deletes the last graphical element
        xIns = (t.x*enlarge) - radV(1,i); // |
        yIns = (t.y*enlarge) + radV(2,i); // | Changes the position of all vertices to place the object in the frame
        zIns = (t.z*enlarge) + radV(3,i); // |
        h = gca(); // Gets the current graphic axes
        h.auto_clear = "off"; // Equivalent of MATLAB's hold on command
        plot3d(-xIns,yIns,list(zIns,tcolor)); // Plots the STL model in the frame
        sleep(1000) // Pauses the loop for 10 ms
    end
end
