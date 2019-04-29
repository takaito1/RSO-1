%% calc_eke_obs.m

% v0. Taka Ito 2019

% This script needs to be executed on gulf.eas.gatech.edu. 
% >> calc_eke_obs.m
% will produce a matlab data file containing the eddy kinetic energy based on the 
% observed sea surface height from satellite altimeters. 
% the SSH data comes from JPL_MEASURES program. 

% safety first
close all
clear all

% load the original SSH data
load /data/ito/SSH/ssh_obs_SO.mat;

% select regions
xr=[0 360];
yr=[-90 -45];

% get the size of the array
N=size(ssh);

% calculate indices for the box
I=find(x>xr(1)&x<xr(2));
J=find(y>yr(1)&y<yr(2));

% calculate dx and dy
dy=1/6*6.37e6*pi/180;
dx=dy*cos(y*pi/180);
dy=dy*ones(N(1),N(2));
dx=repmat(dx,[1 N(1)])';

% set up parameters
f = 2*(2*pi/86400)*sin(62/180*pi);
g = 9.8;

cnt=1;
for n=1:N(4)
 for m=1:N(3)
   % calculate ssh gradient
   if time(m,n) == 0
      % do nothing
   else
   dhdx=zeros(N(1),N(2));
   dhdx(2:N(1)-1,:)=(ssh(3:N(1),:,m,n)-ssh(1:N(1)-2,:,m,n))./(dx(2:N(1)-1,:)*2);
   dhdy=zeros(N(1),N(2));
   dhdy(:,2:N(2)-1)=(ssh(:,3:N(2),m,n)-ssh(:,1:N(2)-2,m,n))./(dy(:,2:N(2)-1,:)*2);
   % calculate eke
   eke(:,:,cnt) = 1/2*(g/f)^2*(dhdx.^2+dhdy.^2);
   time1(cnt)=time(m,n)/365+1985;
   cnt=cnt+1;
   end
 end

end

% calculate regionally averaged eke time series
ekets = squeeze(mean(mean(eke(I,J,:),1),2));

save eke_obs.mat -v7.3 ekets eke I J x y time1;

