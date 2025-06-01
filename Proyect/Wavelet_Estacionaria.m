clear all;close all;clc;
load("Guardado_Senales_Necesarias.mat");

senal_wavelet_stacionaria = {};

nivel = 3;      % Nivel de descomposición
wavelet = 'bior3.1';% Tipo de wavelet


for i = 1:10
    x = senales_con_ruido{i};
    [swa,swd] = swt(x,nivel, wavelet); 

    [thr,sorh] = ddencmp('den','wv',x); 

    dswd = wthresh(swd,sorh,thr);

    senal_wavelet_stacionaria{i} = iswt(swa,dswd,'db1'); 

end

%% Metricas

snr_metodo_WE = {};
PRD_metodo_WE = {};
mse_metodo_WE = {};

echo on;
display('Comenzamos con el calculo de PDR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senal_wavelet_stacionaria{i};
    senal_sin_ruido = senales_con_ruido{i};
    Error=senal_con_ruido - senal_sin_ruido;
    se=Error.*Error;
    sumse=sum(se);
    ma=senal_con_ruido.*senal_sin_ruido;
    summa=sum(ma);
    prd=100*sqrt(sumse/summa);
    PRD_metodo_WE{i} = prd;
end

% calculo de snr
display('Comenzamos con el calculo de SNR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senal_wavelet_stacionaria{i};
    senal_sin_ruido = senales_con_ruido{i};
    ruido = noise{i};
    snr_aux = snr(senal_con_ruido)-snr(senal_sin_ruido);
    snr_metodo_WE{i} = snr_aux;
end

% calculo de mse
display('Comenzamos con el calculo de MSE');
for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senal_wavelet_stacionaria{i};
    senal_sin_ruido = senales_con_ruido{i};
    mse_aux = immse(senal_sin_ruido,senal_con_ruido');
    mse_metodo_WE{i} = mse_aux;
end

%%
filename = "Metricas_Wavelets_Estacionaria.mat";
save(filename,"snr_metodo_WE","mse_metodo_WE","PRD_metodo_WE")
