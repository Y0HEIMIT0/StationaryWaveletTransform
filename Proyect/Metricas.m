%% Cargado de datos.
clear all;close all;clc;

load("Metricas_Fourier.mat","mse_metodo_DF","snr_metodo_DF","PRD_metodo_DF")

load("Metricas_Sin_metodo.mat","snr_comparativo_sin_metodo", "PRD_sin_metodo","mse_sin_metodo")

load("Metricas_Wavelets_adaptativo.mat","snr_metodo_WA","mse_metodo_WA","PRD_metodo_WA")

load("Metricas_Filtrado_HL.mat","mse_Filtrado_l","mse_Filtrado_h","PRD_Filtrado_h","PRD_Filtrado_l","snr_comparativo_Filtrado_l","snr_comparativo_Filtrado_h")

load("Metricas_EMD.mat","snr_metodo_EM","mse_metodo_EM","PRD_metodo_EM")

load("Metricas_Wavelets_Estacionaria.mat","snr_metodo_WE","mse_metodo_WE","PRD_metodo_WE")



%%
% generamos el valor absoluto de cada PRD
for i = 1:10
    PRD_metodo_DF{i} = abs(PRD_metodo_DF{i});
    PRD_sin_metodo{i} = abs(PRD_sin_metodo{i});
    PRD_metodo_WA{i} = abs(PRD_metodo_WA{i});
    PRD_Filtrado_h{i} = abs(PRD_Filtrado_h{i});
    PRD_Filtrado_l{i} = abs(PRD_Filtrado_l{i});
    PRD_metodo_EM{i} = abs(PRD_metodo_EM{i});
    PRD_metodo_WE{i} = abs(PRD_metodo_WE{i});   

end


%%
filename = "auxiliar.mat";
save(filename)