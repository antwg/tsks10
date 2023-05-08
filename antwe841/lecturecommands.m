clear              % Rensa Workspace
close all          % Stäng alla figurfönster
clc                % Rensa Command Window

%% I tidsled
[x,fs]=audioread("x.wav");
Ts=1/fs;           % Sampelperiod
L=length(x);
t=Ts*[0:L-1];
figure
plot(t,x)

%% I frekvensled
f=fs*[0:L-1]/L;
X=abs(fft(x));
figure
plot(f,X)

%% Uppsamplat i tidsled
M=5;               % Uppsamplingsfaktor
x2=upsample(x,M);
L2=length(x2);
Ts2=Ts/M;          % Ny sampelperiod
t2=Ts2*[0:L2-1];
figure
plot(t2,x2)
figure
plot(t2,x2,'-',t,x,'x') % Hur förhåller sig x och x2?

%% Uppsamplat i frekvensled
fs2=fs*M;          % Ny sampelfrekvens
f2=fs2*[0:L2-1]/L2;
X2=abs(fft(x2));
figure
plot(f2,X2)

%% Filtrerat i tidsled
N=100;             % Filtrets gradtal
F0=(fs/2)/(fs2/2); % Normerad gränsfrekvens. Kan 
                   % förstås skrivas fs/fs2 eller 1/M.
[b,a]=fir1(N,F0);  % Designa filter
y=filter(b,a,x2);  % Filtrera signalen
figure
plot(t2,y)         % Notera att signalen är fördröjd 
                   % och trunkerad i slutet.

%% Justerad filtrerat i tidsled
y2=filter(b,a,[x2;zeros(N/2,1)]);
y2=y2(N/2+1:end);
figure
plot(t2,y2)        % Inte fördröjd eller trunkerad.
figure
plot(t2,M*y2,'-',t,x,'x') % Hur förhåller sig x och y2?
                          % Lite annorlunda än jag gjorde på föreläsningen.
                          % Uppsamplingen gör att vart M-te sampel är ett
                          % ursprungligt sampel, och övriga sampel är
                          % noll-sampel. Det resulterar i att effekten
                          % skalas ned med faktorn M. Vidare filtrerar
                          % LP-filtret bort M-1 stycken av M kopior av
                          % ursprungligt spektrum. Det skalar också ned
                          % effekten med faktorn M. Totalt har effekten
                          % alltså skalats ned med faktorn M^2. Det
                          % motsvarar en division av signalen med M.
                          % Multiplikationen i plot-kommandot kompenserar
                          % för det.
%% Filtrerat i frekvensled
Y2=abs(fft(y2));
figure
plot(f2,Y2)

%% Modulerat i tidsled
fc=30e3;           % Bärfrekvensen
carrier=cos(2*pi*fc*t2).';
z2=y2.*carrier;
figure
plot(t2,z2)
hold on
plot(t2,y2)        % Hur förhåller sig y2 och z2?
hold off

%% Modulerat i frekvensled
Z2=abs(fft(z2));
figure
plot(f2,Z2)
