clc; clear; 
% close all

%%
% ������� ������:
fs = 225e6;     %������� �������������
ts = 1/fs;      %������ �������������
tend = 2e-4;    %����� �������
N = tend*fs;    %����� �������- ��� �������

%%
qb    = 16;
delta = logspace(0, 2, 10);
dsn   = linspace(8, 30, 10);
T     = linspace(1e-5, 1e-4, 5);
Ti    = linspace(1e-7, 0.5e-4, 5);
F     = linspace(1e6, 224e6, 5);
Phi   = pi/4;

s1 = ResearchSignal(512, 32, ts, N, qb, dsn, delta);

s1 = s1.searchRadioPulse(1.2, 0.2, T, Ti, F, Phi, ["Ti" "F"]);
%%
s1.VisualiseResults("RadioPulse", "Ti");
s1.VisualiseResults("RadioPulse", "F");