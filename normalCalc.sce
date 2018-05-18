// normalCalc v 0.0.3
// This script computes the normals of the surface selected a solar panels
// Authour : Matthieu D. 
// Created on 16 May 2018
// Last modified 18 May 2018

xVertices = t.x(:,activSurfs) // Gets the x position of the vertices of the solar panel surfaces
yVertices = t.y(:,activSurfs) // Gets the y position of the vertices of the solar panel surfaces
zVertices = t.z(:,activSurfs) // Gets the z position of the vertices of the solar panel surfaces
disp(xVertices) // | 
disp(yVertices) // | -- for testing
disp(zVertices) // |
PanSurfeArea=[];//Initialize Area Storage
n = zeros(length(activSurfs),3) // Initialize matrix for storage of normal vectors
for i = 1:length(activSurfs)
    // For each surface this loop computes the normal vector
    xy = [(xVertices(1,i)-xVertices(2,i)) (yVertices(1,i)-yVertices(2,i)) (zVertices(1,i)-zVertices(2,i))]
    xz = [(xVertices(1,i)-xVertices(3,i)) (yVertices(1,i)-yVertices(3,i)) (zVertices(1,i)-zVertices(3,i))]
    yz = [(xVertices(3,i)-xVertices(2,i)) (yVertices(3,i)-yVertices(2,i)) (zVertices(3,i)-zVertices(2,i))]
    n(i,:) = cross(xy,xz)
    n(i,:) = n(i,:)/sqrt(n(i,1)^2 + n(i,2)^2 + n(i,3)^2); // Computes unit vector
   
  //Find the area of each surface
  Lenxy=norm(xy);// |
  Lenxz=norm(xz);// |Length of each side
  Lenyz=norm(yz);// |
  surfp=(Lenxy+Lenxz+Lenyz)/2;// Half the Perimeter
  SurfArea(i)=sqrt(surfp*(surfp-Lenxy)*(surfp-Lenxz)*(surfp-Lenyz));//Heron's Formula
    disp(n(i,:)) // for testing
end

s = msprintf("Computed %0.0f surface normal unit vectors.", length(activSurfs));
disp(s)
<<<<<<< HEAD

//Panel Power
//This script will calculate the power produced by the satellite solar panels
//Input: Satellite Model, Attitude, mission time, and panel efficiency
//Output: Power

//Parameters
S=1366; // [W/m^2] (later change this to function of time)

//Step 1: Find Area of Solar Panel surfaces
//  I have SurfArea, storing Area of each panel surface

//Step 2: Find Surace Normal Vector
//  I have n , storing the normal for each panel surface
//Step 3: Find Satellite-Sun Vector
//  
//Step 4: Compute with P= nu*S*A*cos(theta)
=======
>>>>>>> 7ea102f5cf0c83d913ded8ff72262cee4fe4274c
