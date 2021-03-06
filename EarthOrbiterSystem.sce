// EarthOrbiterSystem v 0.1.0
// This program models the orbital trajectory of a CAD model about the Earth
// Authours : Arvin T. Matthieu D. Jessie A. 
// Created on 11 May 2018
// Last modified 18 May 2018
// Table of contents 
//  Part 1 : Definition of proprietary functions
//      Part 1a : trace_traj function
//      Part 1b : plot_sphere function
//  Part 2 : Definition of global variables
//      Part 2a : initialization of frame related variables
//      Part 2b : initialization of orbit related variables
//      Part 2c : time and perturbation related parameters
//      Part 2d : initialization of 3D spacecraft model related variables
//  Part 3 : Output Data
//      Part 3a : Ground Track
//  Part 4 : Creation of the solar system environment
//      Part 4a : Creation of the Earth spheroid
//      Part 4b : Creation of the 'space' environment
//      Part 4c : Insertion of the orbital trajectory
//      Part 4d : Motion of the satellite
CL_init(); // Importation of celestLab library   


//  PART 1 --- DEFINITION OF PROPRIETARY FUNCTIONS ----------------------------


//  Part 1a --- trace_traj function -------------------------------------------
function trace_traj(traj,F,col,th)
    //  Copyright (c) CNES  2008
    //  This software is part of CelestLab, a CNES toolbox for Scilab
    //  This function traces great cr
    param3d(F*traj(1,:), F*traj(2,:), F*traj(3,:)); 
    e=gce();
    e.foreground=col;
    e.thickness=th;
endfunction
//  Part 1b --- plot_sphere function ------------------------------------------
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
clc // Clear unimportant warnings from console

// PART 2 --- DEFINITION OF GLOBAL VARIABLES ----------------------------------


// Part 2a --- initialization of frame related parameters ---------------------
// Changing grav. parameter, solar constant, and radius, depending on master body
//Grav. Parameter [m^3/s^2]
//radius [km]
//S [W/m^2]
L = 3.828e26; //Luminosity of the sun, in W

select bodyStr
case 'Mercury'
    mu = CL_dataGet("body.Mercury.mu");
    r = CL_dataGet("body.Mercury.eqRad")/1000;
case 'Venus'
    mu = CL_dataGet('body.Venus.mu');
    r = CL_dataGet("body.Venus.eqRad")/1000;
case 'Earth'
    mu = CL_dataGet('body.Earth.mu');
    r  = CL_dataGet("body.Earth.eqRad")/1000;
case 'Moon'
    mu = CL_dataGet('body.Moon.mu');
    r = CL_dataGet("body.Moon.eqRad")/1000;
case 'Mars'
    mu = CL_dataGet('body.Mars.mu');
    r = CL_dataGet("body.Mars.eqRad")/1000;
case 'Jupiter'
    mu = CL_dataGet('body.Jupiter.mu');
    r = CL_dataGet("body.Jupiter.eqRad")/1000;
case 'Saturn'
    mu = CL_dataGet('body.Saturn.mu');
    r = CL_dataGet("body.Saturn.eqRad")/1000;
case 'Uranus'
    mu = CL_dataGet('body.Uranus.mu'); 
    r = CL_dataGet("body.Uranus.eqRad")/1000;
case 'Neptune'
    mu = CL_dataGet('body.Neptune.mu'); 
    r = CL_dataGet("body.Neptune.eqRad")/1000;
case 'Pluto'
    mu = CL_dataGet('body.Pluto.mu');
    r = CL_dataGet("body.Pluto.eqRad")/1000;
end
AU      = CL_dataGet("au")/10^3  // Definition of an astronomical unit [km]
frame   = 1e4;                  // Dimension of the data bounds [km]
// Part 2b --- initialization of orbit related parameters ---------------------
// This part promts the user to input the Keplerian orbital element, by default the program uses that of the ISS
desc = list(..
CL_defParam("Semimajor axis",           val = 6782.4744e3,   units=['m','km']),..//aa is stored in METRES
CL_defParam("Eccentricity",             val = 0.0003293),..
CL_defParam("Inclination",              val = 51.6397,     units=['deg']),..
CL_defParam("RAAN",                     val = 196.5549,   units=['deg']),..
CL_defParam("Argument of Perigee",      val = 67.2970, units=['deg']),..
CL_defParam("Mean anomaly at epoch",    val = 292.8531,   units=['deg']));
[aa, ec, in, ra, wp, ma] = CL_inputParam(desc) 
TP = 2*%pi*sqrt(aa^3/mu);//orbital period [seconds]
//kepCoeff0 stores the elements in this specific order for the J2 function,
//aa is required to be in metres and all angles in radians
// (we should consider changing the user input to radians and m, although this may be inconvenient for the user...)
kepCoeff0 = [aa; ec; in*(%pi)/180; wp*(%pi)/180; ra*(%pi)/180; ma*(%pi)/180]; // Keplerian elements of the orbit
// aa-semimajor axis [km], ec-eccentricity, in-inclination [deg], ra-right ascension of the ascending node [deg], wp-argument of perigee [deg], ma-mean anomaly [deg]

// Part 2c----time and perturbation related parameters----------------------;
dt = getdate()
desc2 = list(..
CL_defParam("Start year",           val = dt(1)),..
CL_defParam("Start month",          val = dt(2)),..
CL_defParam("Start day",            val = dt(6)),..
CL_defParam("Start hour",           val = 12),..
CL_defParam("Start minute",         val = 0),..
CL_defParam("Start second",         val = 0),..
CL_defParam("Mission duration",     val = 3/24,        units = ['days']),..
CL_defParam("Time step",            val = 10,       units = ['seconds']));
[YYYY, MM, DD, HH,tMin,tSec,xduration,tstep] = CL_inputParam(desc2);

//cjd0-Mission Start Date
cjd0 = CL_dat_cal2cjd(YYYY,MM,DD,HH,tMin,tSec);//Calendar date to modified Julian Day
//cjd is 1xn array, where n is number of timesteps throughout mission duration
cjd = cjd0 + (0 : tstep/86400 : xduration);

//input initial orbital elements into J2 Perturbation model
//Output is a 6xn array of orbital elements, for n timesteps of mission duration
// i.e stores the changing trajectory at each timestep
kepCoeff = CL_ex_propagate("j2sec", "kep", cjd0, kepCoeff0, cjd, "m"); // "m" for mean, may be changed to "o" for osculating
kepCoeff(1,:) = kepCoeff(1,:)/1000;//changing semi major axis to kilometres, to keep with dimensions of section 1b
[pos_eci,vel_eci] = CL_oe_kep2car(kepCoeff); // State Vector in ECI frame
// Part 2d --- initialization of variables related to the 3D model of the spacecraft
enlarge = 10; // Enlargement factor to increase the volume of the model


// PART 3 --- MISSION DATA OUTPUT ----------------------------------


// Part 3a-----Ground Track----------------------------------------- 
pos_ecf = CL_fr_convert("ECI", "ECF", cjd, pos_eci);//Position vector in ECF frame 
fig1 = scf(); 
orbitstep = TP/tstep;//number of tsteps in one orbit
intorbits = floor((length(cjd)*tstep)/TP);//integer number of full orbits
CL_plot_earthMap(color_id=color("seagreen"));// Plot Earth map
CL_plot_ephem(pos_ecf, color_id=color("indianred1"));// Plot ground tracks


//  PART 4 --- CREATION OF THE SOLAR SYSTEM AND SIMULATION --------------------

//  Part 4a --- Creation of the 'space' environment ---------------------------
pos_sun = CL_eph_sun(cjd);//Sun position in ECI coordinates
exec(pwd()+'\PanelPower.sce',-1)//execute Power output
//  Part 4b --- Creation of the Earth spheroid --------------------------------
scf(); 
//plot_sphere(REarth,50,[0 0 0]) // Plots the Earth as a sphere
exec(pwd()+'\plot_sphere.sci',-1); // Executes attitude script


//  Part 4c --- Insertion of the orbital trajectory ---------------------------
param3d(pos_eci(1,:),pos_eci(2,:),pos_eci(3,:)); 


// Part 4d --- Motion of the satellite ----------------------------------------
for i = 1:max(size(pos_eci)) // For mission duration
    if i > 1 // Make sure spacecraft has done one orbit
        delete(h.children(1)) // Deletes the Sun-earth vector
        delete(h.children(1)) // Deletes the last STL
    end
    misstime=i*tstep;
    timestring=string(misstime)
    [xAtt,yAtt,zAtt] = AttitudeAdjust(xAtt,yAtt,zAtt,[],[],[pos_eci(1,i) pos_eci(2,i) pos_eci(3,i)],[vel_eci(1,i) vel_eci(2,i) vel_eci(3,i)]);
    xIns = (xAtt*enlarge) - pos_eci(1,i); // |
    yIns = (yAtt*enlarge) + pos_eci(2,i); // | Changes the position of all vertices to place the object in the frame
    zIns = (zAtt*enlarge) + pos_eci(3,i); // |
    normPos_sun = norm([pos_sun(1,i) pos_sun(2,i) pos_sun(3,i)]); // Calculate the magnitude of the Sun-Earth vector
    for j = 1:3
        sun_vect(j) = 1.5*frame*(pos_sun(j,i)/normPos_sun); // Assign the components to the Sun-Earth Vector
    end
    xarrows([0 sun_vect(1)],[0 sun_vect(2)],[0 sun_vect(3)],20000,color(255,179,0)) //Create Sun-Earth vector
    xtitle(['t+ ',timestring,'seconds']);
    h = gca(); // Gets the current graphic axes
    h.auto_clear = "off"; // Equivalent of MATLAB's hold on command
    plot3d(-xIns,yIns,list(zIns,tcolor)); // Plots the STL model in the frame
    h.isoview="on";//easier on the eyes, isometric view of plot
    sleep(1000/60) // Pauses the loop for 16.6-7 ms (60 Hz animation)
end
