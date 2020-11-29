%% Header
  
%    +----------------------------------------+
%    | Instituto Tecnológico de Aeronáutica   |
%    | CTC-17: Laboratório I                  |
%    | Alunos:                                |
%    |    - Gianluigi Dal Toso                |
%    |    - Lucas Alberto Bilobran Lema       |
%    +----------------------------------------+


% Limpar Variáveis e Tela
clear all
clc


%% 1) Padrões de Entrada e Saída
camargoos = load('datasets/01-camargos.txt');  % Vetor 82 x 12 (1971 - 2012)
furnaas   = load('datasets/02-furnas.txt');    % Vetor 82 x 12 (1971 - 2012)

camargos = reshape(camargoos', 1, []);
furnas = reshape(furnaas', 1, []);

P_camargos_t_dt = [];
P_camargos_t = [];
P_furnas_t_dt = [];
P_furnas_t = [];
Tcamargos = [];
Tfurnas = [];

N = size(camargos, 2);

P_camargos_t_dt = camargos(1, 1:N-2);
P_camargos_t    = camargos(1, 2:N-1);
P_furnas_t_dt   = furnas  (1, 1:N-2);
P_furnas_t      = furnas  (1, 2:N-1);

Tcamargos       = camargos(1, 3:N);
Tfurnas         = furnas  (1, 3:N);


P = [P_camargos_t_dt; P_camargos_t; P_furnas_t_dt; P_furnas_t];
T = [Tcamargos; Tfurnas];

%% 2) Construção da Rede MLP
algorithm = 'trainlm';
net_layer = [20];
net = feedforwardnet(net_layer, algorithm);
net = configure(net, P, T);

%% 3) Dividir Padrões

net.divideFcn = 'dividerand';
net.divideParam.trainRatio = 1.00;
net.divideParam.valRatio   = 0.00;
net.divideParam.testRatio  = 0.00;

%% 4) Inicializando os Pesos da Rede
net = init(net);

%% 5) Treinando a Rede Neural
net.trainParam.showWindow = true;
%net.layers{1}.dimensions  = 20;
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'purelin';
net.performFcn            = 'mse';
net.trainFcn              = algorithm;
net.trainParam.epochs     = 10000;
net.trainParam.time       = 120;
net.trainParam.lr         = 0.2;
net.trainParam.min_grad   = 10^-8;
net.trainParam.max_fail   = 1000;

[net, tr] = train(net, P, T);

%% 6) Simular as respostas de saída da rede MLP.

% 6.1 - Resultados da Simulação

% PsA = [camargos(1, 1); camargos(1, 2); furnas(1, 1); furnas(1, 2)];
% PsM = [camargos(1, 2); furnas(1, 2)];
% 
% Ms1 = [];
% Ms2 = [];
% 
% for i = 1:1:N-2
%     PsD = sim(net, PsA);
%     Ms1 = [Ms1 PsD(1, 1)];
%     Ms2 = [Ms2 PsD(2, 1)];
%     
%     PsA = [PsM(1, 1); PsD(1, 1); PsM(2, 1); PsD(2, 1)];
%     PsM = PsD;
% end

Ms1 = [];
Ms2 = [];


for i = 2:1:N-1
    PsA = [camargos(1, i-1); camargos(1, i); furnas(1, i-1); furnas(1, i)];
    PsD = sim(net, PsA);
    Ms1 = [Ms1 PsD(1, 1)];
    Ms2 = [Ms2 PsD(2, 1)];
end


xP = 1:1:N-12;
XcamargosP = camargos(:, 1:N-12);
xF = (N-12)+1:1:N;
XcamargosF = camargos(:, (N-12)+1:N);
plot(xP, XcamargosP, 'b', xF, XcamargosF, 'r');
xlabel('Meses');
ylabel('Vazão');
title('Vazão do Rio Camargo');
grid
hold on

xS = 3:1:N;
plot(xS, Ms1, ':m');
hold off

figure(2)

xP = 1:1:N-12;
XfurnasP = furnas(:, 1:N-12);
xF = (N-12)+1:1:N;
XfurnasF = furnas(:, (N-12)+1:N);
plot(xP, XfurnasP, 'b', xF, XfurnasF, 'r');
xlabel('Meses');
ylabel('Vazão');
title('Vazão do Rio Furnas');
grid
hold on

xS = 3:1:N;
Ms2 = [Ms2];
plot(xS, Ms2, ':m');
hold off


