%% Trabajo en los metodos propuestos
%Dado que exite la utilizacion de 3 datset, en un principio se trabajara
%solo con el primero por la extencion misma de los datos 

%ANTES DE CORRER ESTE ARCHIVO SE DEBE CORRER APERTURA DATASET
clear all;close all;clc;
load("Datos.mat");
largo_maximo = 16384;%32768;
senal = signal{6};
senal = senal(1:largo_maximo);
senales = {};

tm = tm{6};
tm = tm(1:largo_maximo);
N = largo_maximo;
frecuencia = 60; % en Hz
frecuencia_muestreo = 360; % en Hz
duracion = length(senal); % en muestras
t = tm;

senal_sinusoidal = sin(2 * pi * frecuencia * t);

for i = 1:length(senal)
    amplitud = rand/2;
    senal_total(i,1) = senal(i) + amplitud*senal_sinusoidal(i);
end
senal_con_ruido = senal_total(:,1);
senal_canal_1 = senal_con_ruido;
figure;
plot(t,senal_con_ruido);
title('Registro ECG MIT-BIH Arrhythmia - Registro 106');
xlabel('Muestras');
ylabel('Amplitud');
hold on
grid on
plot(t,senal);
xlim ([40 50])
ylim ([-1 2])
legend('Señal con ruido','Señal original');

%%
filename = "Senal_actual.mat";
save(filename,"senal","senal_con_ruido", "senal_canal_1","senal")


%% Primeros filtros
% filtro pasa bajo y pasa alto 
num_l = [0.8576 -0.032 0.8629 -0.0811]; 
den_l = [1 -1.2096 0.2696 0.0144]; 
filtro_pasa_bajo = tf(num_l, den_l,1);

num_h = [-0.5034 1.9441 -1.9441 0.5034];
den_h = [1 -1.1737 0.2982 0.0245];
filtro_pasa_alto = tf(num_h, den_h,1);

figure;
bode(filtro_pasa_bajo)
hold on 
bode(filtro_pasa_alto)

etapa_1 = filter(num_l, den_l,senal_con_ruido);
etapa_1y2 = filter(num_h,den_h,etapa_1);
etapa_2 = filter(num_h,den_h,senal_con_ruido);

figure;
plot(t, etapa_2);
title('Registro 100, Filtrado mediante pasa bajo y pasa alto ');
xlabel('Muestras');
ylabel('Amplitud');
hold on
plot(t, etapa_1);
plot(t,etapa_1y2)
plot(t, senal_con_ruido);
legend('Señal L', 'Señal H','Pasa Banda','Señal original con ruido');

%% Eliminacion de ruido mediante 
% load('DWT_adaptativo.mat'); 
%[c,l] = wavedec(senal_canal_1,3,'bior3.1');
%[cd1,cd2,cd3] = detcoef(c,l,[1 2 3]);

f = @(vars,senal) DWT_adap(vars(1), vars(2), vars(3),senal);

load('Senal_actual.mat', 'senal_canal_1','senal')

%x0 = [0.01,0.01,0.01];
fun = @(x)f(x,senal_canal_1);

x0 = [1,1,1];

[x,fval] = fminsearch(fun,x0)

[c,l] = wavedec(senal_con_ruido',3,'bior3.1');
[cd1,cd2,cd3] = detcoef(c,l,[1 2 3]);

cd1 = wthresh(cd1,'s',x0(1));
cd2 = wthresh(cd2,'s',x0(1));
cd3 = wthresh(cd3,'s',x0(1));

c_nuevo = [c(1:l(1)) cd1 cd2 cd3];
senal_nueva = waverec(c_nuevo,l,'bior3.1');

figure;
plot(t, senal_nueva);
title('Registro 100, Filtrado mediante DWT ');
xlabel('Muestras');
ylabel('Amplitud');
hold on
plot(t, senal_con_ruido);

%% EMD
% N=32768;%1024*1;
fs=frecuencia_muestreo;%100;
t=tm;%(0:N-1)/100;
senal =senal_canal_1;%randn(1,N)*1+0*sin(2*pi*5*t);
%X = wgn(1024,1,0); % white Gaussian noise of power 0 dBW
% plot(X);

imfs = emd(senal);

denoised_ecg = sum(imfs(:,1:6),2);

% Visualizar las IMFs y la componente residual
figure;
%subplot(length(imfs)+1,1,1);
plot(t, senal);
%title('Señal Original');
hold on
plot(t, denoised_ecg);


% for i = 1:length(imfs)
%     subplot(length(imfs)+1,1,i+1);
%     plot(t, imfs{i});
%     title(['IMF ' num2str(i)]);
% end



%% Analisis mediante furier

% Habra que trabajar con el recorte de una señal, ajustar señal original
% senal_furier = fft(senal_canal_1);
% senal_furier = abs(senal_furier);
% senal_furier = senal_furier(1:length(senal_furier)/2+1);

%N=10000;%1024*1;
Fs=frecuencia_muestreo;%100;
t=tm(1:largo_maximo);%(0:N-1)/100;
%tt=t(end); % total time
X=senal_canal_1(1:largo_maximo);%randn(1,N)*1+0*sin(2*pi*5*t);
%X = wgn(1024,1,0); % white Gaussian noise of power 0 dBW
plot(X);
%sp_FMD_Low2High_High2LowSacnningGroupDelay(X,Fs,t); 
%imfs=sp_FMD(X,Fs,t,Fs/5);
%figure 
echo on;
display('Pase por menos uno');
[xt_recov_IMFsLowToHigh xt_recov_IMFsHighToLow el]=FMD_Low2High_High2LowSacnning(X,Fs,t); 

%GroupDelay
%GroupDelayOfFIBFs(xt_recov_IMFsLowToHigh,Fs,t);
echo on;
display('Pase por cero');

NbofFIBFs=length(xt_recov_IMFsHighToLow(1,:));      
weightedMeanFreq=zeros(1,NbofFIBFs-2);   

echo on;
display('Pase por uno');

figure
plot(weightedMeanFreq);
hold on
%stem(diff(weightedMeanFreq),'r');
plot(weightedMeanFreq(1:end-1)./weightedMeanFreq(2:end),'r')
%plot(weightedMeanFreq);


NbofFIBFs=length(xt_recov_IMFsLowToHigh(1,:)); 
weightedMeanFreq=zeros(1,NbofFIBFs-2);

echo on;
display('Pase por dos');

figure
stem(weightedMeanFreq);
hold on
stem(diff(weightedMeanFreq),'r');
plot(weightedMeanFreq(2:end)./weightedMeanFreq(1:end-1),'r')
%sp_FIBFs_Plot(xt_recov_IMFsLowToHigh,xt_recov_IMFsHighToLow,t,X)
%% Imagen resultante
denoised_ecg = sum(xt_recov_IMFsLowToHigh(:,1:8),2);
% Plot the results
figure;
plot(t, X);
%title('Noisy ECG Signal');
hold on
plot(t, denoised_ecg);
%title('Denoised ECG Signal');
%% Post iteracion FDM

%filename = "Datos_post_FDM.mat";
%save(filename)

%% Stationary Wavelet Transform

nivel = 3;      % Nivel de descomposición
wavelet = 'bior3.1';% Tipo de wavelet
x = senal_canal_1;
% Realizar la Transformada Wavelet Estacionaria
[c, l] = swt(x, nivel, wavelet);

% Omitir los coeficientes de detalle para la reconstrucción
c_sin_ruido = c;
%c_sin_ruido(1:nivel, :) = 0;


% Reconstruir la señal sin el ruido
x_sin_ruido = iswt(c_sin_ruido,l, wavelet);

% Mostrar los resultados
figure;
plot(x_sin_ruido);
%title('Señal Original');
hold on
plot(x_sin_ruido);
%title('Señal Reconstruida sin Ruido');

%% Este metodo resulto ser mas limpio, aunque se debe especificar que ocurre con cada valor tanto como thr, y sorh.
[swa,swd] = swt(x,nivel, wavelet); 

[thr,sorh] = ddencmp('den','wv',x); 

dswd = wthresh(swd,sorh,thr);

clean = iswt(swa,dswd,'db1'); 

subplot(2,1,1), plot(x); title('Original signal') 
subplot(2,1,2), plot(clean); title('denoised signal')



 

 
