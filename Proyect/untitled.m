%% Proyecto 
clear all;close all;clc;
% Instalacion previa de las dependencias
cd /home/pablo/Escritorio/SuperDSP/Proyecto
%[old_path]=which('rdsamp'); if(~isempty(old_path)) rmpath(old_path(1:end-8)); end
%wfdb_url='https://physionet.org/physiotools/matlab/wfdb-app-matlab/wfdb-app-toolbox-0-10-0.zip';
%[filestr,status] = urlwrite(wfdb_url,'wfdb-app-toolbox-0-10-0.zip');
%unzip('wfdb-app-toolbox-0-10-0.zip');
cd mcode
addpath(pwd)
savepath

%% Lectura primaria de datos
% Especifica el nombre del registro y el directorio del conjunto de datos
record_name = '100';
dataset_directory = '/home/pablo/Escritorio/SuperDSP/Proyecto/database/mitdb';  

% Carga los datos ECG y las anotaciones
[signal, attributes,tm] = rdsamp(record_name, [], [], dataset_directory);
%[ann, anntype, subtype, chan, num, aux] = rdann(record_name, 'atr', [], dataset_directory);

% Visualiza el registro ECG
plot(signal);
title('Registro ECG MIT-BIH Arrhythmia - Registro 100');
xlabel('Muestras');
ylabel('Amplitud');
grid on;

%% Aqui funciono a medias

[~,config]=wfdbloadlib;
echo on;
display('Reading samples ECG signal from MIT-BIH Arrhythmia Database');
N=10000;
[ecg,Fs,tm]=rdsamp('mitdb/100',1,N);

display('Reading and plotting annotations (human labels) of QRS complexes performend on the signals');
%by cardiologists.
[ann,type,subtype,chan,num]=rdann('mitdb/100','atr',1,N);

%Plot 2D version of signal and labels
figure;
plot(tm(1:N),ecg(1:N));hold on;grid on;
%plot(tm(ann(ann<N)+1),ecg(ann(ann<N)+1),'ro');

%% Stack the ECG signals based on the labeled QRSs
display('Ploting 3D version of signal and labels');
[RR,tms]=ann2rr('mitdb/100','atr',N);
delay=round(0.1/tm(2));
M=length(RR);
offset=0.3;
stack=zeros(M,min(RR))+NaN;
qrs=zeros(M,2)+NaN;
for m=1:M
    stack(m,1:min(RR)+1)=ecg(tms(m)-delay:tms(m)+min(RR)-delay);
    qrs(m,:)=[delay+1 ecg(tms(m))];
end

%Generate plot inspired by
%Clifford GD, Azuaje F, McSharry PE, editors.
%Advanced Methods and Tools for ECG Analysis.
%1st ed., Norwood, MA, USA: Artech House; 2006. (Engineering in Medicine and Biology; 1).
figure;
[X,Y] = meshgrid(1:min(RR)+1,1:M);
surf(Y,X,stack);hold on;grid on;
shading interp;
plot3(1:M,qrs(:,1),qrs(:,2)+offset,'go-','MarkerFaceColor','g');
view(120, 30);
axis off;

%% Generate plot inspired by
% Samenie et al
% "Filtering Noisy ECG Signals Using Extended Kalman Filter Based on a
% Modified Dynamic ECG Model"
% Computers in Cardiology, 2005
figure;
stack=stack';
stack=stack(:)+[0:length(stack(:))-1]'.*0.0005;
theta=linspace(0,M*2*pi,length(stack));
x=sin(theta);y=cos(theta);
plot3(x,y,stack,'b');
grid on;
axis off;

%Display information about databases availabe in PhysioNet
fprintf('**Querying PhysioNet for available databases...\n');
db_list=physionetdb;
db_size=length(db_list);
fprintf(['\tYou currently have access to ' num2str(db_size) ' databases for download in PhysioNet (type ''help physionetdb'' for more info)!\n']);
display('Demoing finished !!');
display('For more information about the toolbox, type ''wfdb'' at the command prompt.');
echo off;


